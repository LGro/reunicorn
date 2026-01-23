// Copyright 2024 - 2026 The Reunicorn Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

// TODO: Ensure this page looks ok if no contact could be found for given ID -> alert and redirect

import 'dart:math';

import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../data/models/circle.dart';
import '../../data/models/models.dart';
import '../../data/models/profile_info.dart';
import '../../data/repositories/contact_dht.dart';
import '../../data/services/storage/base.dart';
import '../../ui/profile/cubit.dart';
import '../introductions/page.dart';
import '../utils.dart';
import '../widgets/dht_status/widget.dart';
import '../widgets/veilid_status/widget.dart';
import 'cubit.dart';
import 'link_to_system_contact/page.dart';
import 'widgets/circles.dart';
import 'widgets/connecting.dart';
import 'widgets/contact_details_and_locations.dart';
import 'widgets/emoji_sas_verification.dart';
import 'widgets/shared_profile/widget.dart';
import 'widgets/temporary_locations.dart';

String _shorten(String str) => str.substring(0, min(10, str.length));

class ContactPage extends StatefulWidget {
  const ContactPage({required this.coagContactId, super.key});

  final String coagContactId;

  static Route<void> route(String coagContactId) => MaterialPageRoute(
    fullscreenDialog: true,
    builder: (context) => ContactPage(coagContactId: coagContactId),
  );

  @override
  State<ContactPage> createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _contactCommentController =
      TextEditingController();

  var _isEditingName = false;
  var _dummyToTriggerRebuild = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Trigger a rebuild to make sure that when we edited the name of a contact
    // it shows up in the list up-to-date
    setState(() {
      _dummyToTriggerRebuild = _dummyToTriggerRebuild + 1;
    });
  }

  Future<void> _showDeleteContactDialog(
    CoagContact contact,
    Future<bool> Function(String) deleteCallback,
  ) async {
    var isLoading = false;

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, void Function(void Function()) setState) =>
            AlertDialog(
              titlePadding: const EdgeInsets.only(left: 16, right: 16, top: 16),
              title: Text(
                'Delete ${contact.name}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    [
                      // ignore: no_adjacent_strings_in_list
                      'Deleting this contact from Reunicorn can not guarantee '
                          'that all information that you shared with them is '
                          'removed on their side, because they might have '
                          'taken a screenshot or retain your info otherwise. '
                          'It will only ensure that none of your future '
                          'updates will be shared with them. ',
                      if (contact.systemContactId != null)
                        // ignore: no_adjacent_strings_in_list
                        'The linked contact in your local address book will '
                            'remain, but it will no longer be updated by '
                            'Reunicorn.',
                    ].join(),
                    softWrap: true,
                  ),
                  const SizedBox(height: 16),
                ],
              ),
              actions: isLoading
                  ? <Widget>[const Center(child: CircularProgressIndicator())]
                  : <Widget>[
                      FilledButton.tonal(
                        onPressed: Navigator.of(dialogContext).pop,
                        child: const Text('Cancel'),
                      ),
                      FilledButton(
                        onPressed: () async {
                          setState(() => isLoading = true);
                          final dhtSuccess = await deleteCallback(
                            contact.coagContactId,
                          );
                          if (context.mounted && !dhtSuccess) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Could not clear shared '
                                  'information. Make sure you '
                                  'are online and try again.',
                                ),
                              ),
                            );
                            setState(() => isLoading = false);
                            return;
                          }
                          if (dialogContext.mounted) {
                            dialogContext.pop();
                          }
                          if (context.mounted) {
                            context.pop();
                          }
                        },
                        child: const Text('Delete'),
                      ),
                    ],
            ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => MultiBlocProvider(
    providers: [
      BlocProvider(
        create: (context) => ContactDetailsCubit(
          context.read<Storage<CoagContact>>(),
          context.read<Storage<Circle>>(),
          context.read<ContactDhtRepository>(),
          widget.coagContactId,
        ),
      ),
      BlocProvider(
        create: (context) => ProfileCubit(
          context.read<Storage<ProfileInfo>>(),
          context.read<Storage<Circle>>(),
        ),
      ),
    ],
    child: BlocConsumer<ContactDetailsCubit, ContactDetailsState>(
      listener: (context, state) {},
      builder: (context, state) => Scaffold(
        appBar: AppBar(
          title: _isEditingName
              ? TextField(
                  autofocus: true,
                  autocorrect: false,
                  controller: _nameController..text = state.contact?.name ?? '',
                  decoration: const InputDecoration(isDense: true),
                )
              : Text(state.contact?.name ?? 'Contact Details'),
          actions: [
            IconButton(
              onPressed: () async {
                if (_isEditingName) {
                  await context.read<ContactDetailsCubit>().updateName(
                    _nameController.text,
                  );
                }
                setState(() {
                  _isEditingName = !_isEditingName;
                });
              },
              icon: Icon(_isEditingName ? Icons.check : Icons.edit),
            ),
          ],
        ),
        body: (state.contact == null)
            ? const SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsetsGeometry.only(top: 16),
                  child: Center(child: Text('Contact not found.')),
                ),
              )
            : RefreshIndicator(
                onRefresh: () =>
                    context.read<ContactDetailsCubit>().refresh().then(
                      (success) => context.mounted
                          ? ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  success
                                      ? 'Updated successfully.'
                                      : 'Update failed, try again later.',
                                ),
                              ),
                            )
                          : null,
                    ),
                child: _body(
                  context,
                  state.contact!,
                  state.circles,
                  state.knownContacts,
                ),
              ),
      ),
    ),
  );

  Widget _body(
    BuildContext context,
    CoagContact contact,
    Map<String, String> circles,
    Map<String, String> knownContacts,
  ) => SingleChildScrollView(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (contact.details?.picture != null)
          Center(
            child: Padding(
              padding: const EdgeInsets.only(left: 12, top: 16, right: 12),
              child: roundPictureOrPlaceholder(
                contact.details?.picture,
                radius: 64,
              ),
            ),
          ),

        // Contact details
        ContactDetailsAndLocations(contact),

        // Sharing circle settings and shared profile
        Padding(
          padding: const EdgeInsets.only(left: 12, top: 16, right: 12),
          child: Text(
            'Sharing settings',
            textScaler: const TextScaler.linear(1.4),
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 4, top: 4, right: 4),
          child: SharingSettings(contact, circles),
        ),

        // Padding(
        //   padding: const EdgeInsets.only(left: 4, top: 4, right: 4),
        //   child: EmojiSasVerification(contact),
        // ),

        // Introductions
        if (contact.introductionsByThem.isNotEmpty ||
            contact.introductionsForThem.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.only(
              left: 12,
              top: 8,
              right: 12,
              bottom: 4,
            ),
            child: Text(
              'Introductions',
              textScaler: const TextScaler.linear(1.4),
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.only(
                  left: 12,
                  right: 12,
                  top: 8,
                  bottom: 8,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (contact.connectionAttestations.isNotEmpty)
                      Text(
                        [
                          '${contact.name} claims to be connected with at least',
                          '${contact.connectionAttestations.length}',
                          'other folks via Reunicorn.',
                          if (knownContacts.isNotEmpty) ...[
                            'Including ${knownContacts.length} of your',
                            'contacts like:',
                            // TODO: Do we need to seed this shuffling to
                            //       avoid changes on each redraw?
                            ((knownContacts.values.asList()..shuffle()).sublist(
                                  0,
                                  10,
                                )..sort(
                                  (a, b) => a.toLowerCase().compareTo(
                                    b.toLowerCase(),
                                  ),
                                ))
                                .join(', '),
                            if (knownContacts.length > 10) 'and others.',
                          ],
                        ].join(' '),
                        softWrap: true,
                      ),
                    if (contact.introductionsForThem.isNotEmpty)
                      Text(
                        'You have introduced them to: '
                        '${contact.introductionsForThem.map((i) => i.otherName).join(', ')}',
                      ),
                    if (contact.introductionsByThem.isNotEmpty)
                      Text(
                        'They have introduced you to: '
                        '${contact.introductionsByThem.map((i) => i.otherName).join(', ')}',
                      ),
                    if (pendingIntroductions([contact]).isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: FilledButton.tonal(
                          onPressed: () => Navigator.of(context).push(
                            MaterialPageRoute<IntroductionsPage>(
                              builder: (context) => const IntroductionsPage(),
                            ),
                          ),
                          child: const Text('View pending introductions'),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],

        // Private note
        Padding(
          padding: const EdgeInsets.only(left: 12, top: 12, right: 12),
          child: Text(
            'Private note',
            textScaler: const TextScaler.linear(1.4),
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.only(
                left: 12,
                right: 12,
                top: 12,
                bottom: 8,
              ),
              child: TextFormField(
                key: const Key('contactDetailsNoteInput'),
                onTapOutside: (event) => context
                    .read<ContactDetailsCubit>()
                    .updateComment(_contactCommentController.text),
                controller: _contactCommentController..text = contact.comment,
                decoration: const InputDecoration(
                  isDense: true,
                  border: OutlineInputBorder(),
                  helperText: 'Just for you, this is never shared.',
                  // Somehow, this being null still causes the helper text
                  // to overflow into an ellipsis on narrow iOS screens
                  helperMaxLines: 20,
                ),
                textInputAction: TextInputAction.done,
                // TODO: Does this limit the number of lines or just
                // specify the visible ones? We need the latter not the
                // former.
                maxLines: 4,
              ),
            ),
          ),
        ),

        // TODO: Display note about which contact is linked?
        Padding(
          padding: const EdgeInsets.only(left: 16, top: 12, right: 16),
          child: (contact.systemContactId == null)
              ? FilledButton.tonal(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute<LinkToSystemContactPage>(
                      builder: (_) => LinkToSystemContactPage(
                        coagContactId: contact.coagContactId,
                      ),
                    ),
                  ),
                  child: const Text('Link to address book contact'),
                )
              : FilledButton.tonal(
                  onPressed: () => context
                      .read<ContactDetailsCubit>()
                      .unlinkFromSystemContact(),
                  child: const Text('Unlink from address book contact'),
                ),
        ),

        // Delete contact
        Center(
          child: TextButton(
            onPressed: () => _showDeleteContactDialog(
              contact,
              context.read<ContactDetailsCubit>().delete,
            ),
            style: ButtonStyle(
              backgroundColor: WidgetStatePropertyAll(
                Theme.of(context).colorScheme.error,
              ),
            ),
            child: Text(
              'Remove from Reunicorn',
              style: TextStyle(color: Theme.of(context).colorScheme.onError),
            ),
          ),
        ),

        // Debug output about update timestamps and receive / share DHT records
        // if (!kReleaseMode)
        Column(
          children: [
            const SizedBox(height: 16),
            const Text(
              'Developer debug information',
              textScaler: TextScaler.linear(1.2),
            ),
            const SizedBox(height: 8),
            const VeilidStatusWidget(statusWidgets: {}),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                switch (contact.dhtConnection) {
                  DhtConnectionInitialized(:final recordKeyMeSharing) ||
                  DhtConnectionEstablished(
                    :final recordKeyMeSharing,
                  ) => DhtStatusWidget(
                    recordKey: recordKeyMeSharing,
                    statusWidgets: const {},
                  ),
                  _ => const SizedBox(),
                },
                if (contact.dhtConnection != null)
                  DhtStatusWidget(
                    recordKey: contact.dhtConnection!.recordKeyThemSharing,
                    statusWidgets: const {},
                  ),
              ],
            ),
            // const SizedBox(height: 8),
            // Text('Updated: ${contact.mostRecentUpdate}'),
            // Text('Changed: ${contact.mostRecentChange}'),
            _paddedDivider(),
            Text(
              contact.connectionCrypto.map(
                initializedSymmetric: (_) => 'initSym',
                establishedSymmetric: (_) => 'estSym',
                initializedAsymmetric: (_) => 'initAsym',
                establishedAsymmetric: (_) => 'estAsym',
                pendingAsymmetric: (_) => 'penAsym',
              ),
            ),
            if (contact.profileSharingStatus.mostRecentAttempt != null &&
                contact.profileSharingStatus.mostRecentSuccess != null &&
                !contact.profileSharingStatus.mostRecentSuccess!.isBefore(
                  contact.profileSharingStatus.mostRecentAttempt!,
                ))
              const Text('Successfully shared')
            else if (contact.profileSharingStatus.mostRecentAttempt != null &&
                contact.profileSharingStatus.mostRecentSuccess != null &&
                contact.profileSharingStatus.mostRecentSuccess!.isBefore(
                  contact.profileSharingStatus.mostRecentAttempt!,
                ))
              const Text('Pending changes not shared yet'),
            // TODO(LGro): show diff above between shared profile and pending changes in shared profile
            Text(
              'MyPubKey: ${_shorten(contact.connectionCrypto.myKeyPairOrNull?.key.toString() ?? 'null')}...',
            ),
            Text(
              'MyNextPubKey: ${_shorten(contact.connectionCrypto.myNextKeyPair.key.toString())}...',
            ),
            Text(
              'MyDhtKey: ${_shorten(contact.dhtConnection?.recordKeyMeSharingOrNull.toString() ?? '')}...',
            ),
            Text(
              'TheirPubKey: ${_shorten(contact.connectionCrypto.theirPublicKeyOrNull.toString())}...',
            ),
            Text(
              'TheirNextPubKey: ${_shorten(contact.connectionCrypto.theirNextPublicKeyOrNull.toString())}...',
            ),
            Text(
              'TheirDhtKey: ${_shorten(contact.dhtConnection?.recordKeyThemSharing.toString() ?? '')}...',
            ),
            Text(
              'InitSec: ${_shorten(contact.connectionCrypto.initialSharedSecretOrNull.toString())}...',
            ),
            const SizedBox(height: 16),
          ],
        ),
      ],
    ),
  );
}

Widget _paddedDivider() => const Padding(
  padding: EdgeInsets.only(left: 16, right: 16),
  child: Divider(),
);

class SharingSettings extends StatelessWidget {
  const SharingSettings(this._contact, this._circles, {super.key});

  final CoagContact _contact;
  final Map<String, String> _circles;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      CirclesCard(_contact.coagContactId, _circles.values.toList()),
      if ((_contact.dhtConnection is DhtConnectionInvited ||
              _contact.details == null) &&
          context.read<ContactDetailsCubit>().wasNotIntroduced(_contact)) ...[
        ConnectingCard(context, _contact, _circles),
      ],
      if (_circles.isNotEmpty &&
          _contact.profileSharingStatus.sharedProfile != null)
        SharedProfile(_contact.coagContactId),
      if (_contact
              .profileSharingStatus
              .sharedProfile
              ?.temporaryLocations
              .isNotEmpty ??
          false) ...[
        TemporaryLocationsCard(
          const Row(
            children: [
              Icon(Icons.share_location),
              SizedBox(width: 8),
              Text('Shared locations', textScaler: TextScaler.linear(1.2)),
            ],
          ),
          _contact.profileSharingStatus.sharedProfile!.temporaryLocations,
        ),
        Padding(
          padding: const EdgeInsets.only(left: 12, right: 12, bottom: 8),
          child: Text(
            'These current and future locations are available to '
            '${_contact.name} based on the circles you shared the '
            'locations with.',
          ),
        ),
      ],
    ],
  );
}
