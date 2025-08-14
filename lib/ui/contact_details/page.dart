// Copyright 2024 - 2025 The Reunicorn Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

import 'dart:math';

import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../data/models/coag_contact.dart';
import '../../data/repositories/contacts.dart';
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
import 'widgets/shared_profile.dart';
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
                        context.goNamed('contacts');
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
              context.read<ContactsRepository>(),
              widget.coagContactId,
            ),
          ),
          BlocProvider(
            create: (context) =>
                ProfileCubit(context.read<ContactsRepository>()),
          ),
        ],
        child: BlocConsumer<ContactDetailsCubit, ContactDetailsState>(
          listener: (context, state) async {},
          builder: (context, state) => Scaffold(
            appBar: AppBar(
              title: _isEditingName
                  ? TextField(
                      autofocus: true,
                      autocorrect: false,
                      controller: _nameController
                        ..text = state.contact?.name ?? '',
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
                ? const SingleChildScrollView(child: Text('Contact not found.'))
                : RefreshIndicator(
                    onRefresh: () async =>
                        context.read<ContactDetailsCubit>().refresh().then(
                              (success) => context.mounted
                                  ? ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          [
                                            if (success.$1)
                                              'Updated contact successfully.'
                                            else
                                              'Updating contact failed, try again later.',
                                            if (success.$2)
                                              'Updated shared information successfully.'
                                            else
                                              'Updating shared information failed, try again later.',
                                          ].join('\n'),
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
  ) =>
      SingleChildScrollView(
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
            ...contactDetailsAndLocations(context, contact),

            // Sharing circle settings and shared profile
            Padding(
              padding: const EdgeInsets.only(left: 12, top: 16, right: 12),
              child: Text(
                'Connection settings',
                textScaler: const TextScaler.linear(1.4),
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 4, top: 4, right: 4),
              child: _sharingSettings(context, contact, circles),
            ),

            Padding(
              padding: const EdgeInsets.only(left: 4, top: 4, right: 4),
              child: EmojiSasVerification(contact),
            ),

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
                                ((knownContacts.values.asList()..shuffle())
                                        .sublist(
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
                              onPressed: () async => Navigator.of(context).push(
                                MaterialPageRoute<IntroductionsPage>(
                                  builder: (context) =>
                                      const IntroductionsPage(),
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
                    onTapOutside: (event) async => context
                        .read<ContactDetailsCubit>()
                        .updateComment(_contactCommentController.text),
                    controller: _contactCommentController
                      ..text = contact.comment,
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
                      onPressed: () async => Navigator.of(context).push(
                        MaterialPageRoute<LinkToSystemContactPage>(
                          builder: (_) => LinkToSystemContactPage(
                            coagContactId: contact.coagContactId,
                          ),
                        ),
                      ),
                      child: const Text('Link to address book contact'),
                    )
                  : FilledButton.tonal(
                      onPressed: () async => context
                          .read<ContactDetailsCubit>()
                          .unlinkFromSystemContact(),
                      child: const Text('Unlink from address book contact'),
                    ),
            ),

            // Delete contact
            Center(
              child: TextButton(
                onPressed: () async => _showDeleteContactDialog(
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
                  style:
                      TextStyle(color: Theme.of(context).colorScheme.onError),
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
                    if (contact.dhtSettings.recordKeyMeSharing != null)
                      DhtStatusWidget(
                        recordKey: contact.dhtSettings.recordKeyMeSharing!,
                        statusWidgets: const {},
                      ),
                    if (contact.dhtSettings.recordKeyThemSharing != null)
                      DhtStatusWidget(
                        recordKey: contact.dhtSettings.recordKeyThemSharing!,
                        statusWidgets: const {},
                      ),
                  ],
                ),
                // const SizedBox(height: 8),
                // Text('Updated: ${contact.mostRecentUpdate}'),
                // Text('Changed: ${contact.mostRecentChange}'),
                _paddedDivider(),
                Text(
                  'MyPubKey: ${_shorten(contact.dhtSettings.myKeyPair?.key.toString() ?? 'null')}...',
                ),
                Text(
                  'MyNextPubKey: ${_shorten(contact.dhtSettings.myNextKeyPair?.key.toString() ?? 'null')}...',
                ),
                Text(
                  'MyDhtKey: ${_shorten(contact.dhtSettings.recordKeyMeSharing.toString())}...',
                ),
                Text(
                  'TheirPubKey: ${_shorten(contact.dhtSettings.theirPublicKey.toString())}...',
                ),
                Text(
                  'TheirNextPubKey: ${_shorten(contact.dhtSettings.theirNextPublicKey.toString())}...',
                ),
                Text(
                  'TheirDhtKey: ${_shorten(contact.dhtSettings.recordKeyThemSharing.toString())}...',
                ),
                Text(
                  'InitSec: ${_shorten(contact.dhtSettings.initialSecret.toString())}...',
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

Widget _sharingSettings(
  BuildContext context,
  CoagContact contact,
  Map<String, String> circles,
) =>
    Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CirclesCard(contact.coagContactId, circles.values.toList()),
          if ((contact.dhtSettings.recordKeyMeSharing == null ||
                  contact.details == null) &&
              context
                  .read<ContactDetailsCubit>()
                  .wasNotIntroduced(contact)) ...[
            _paddedDivider(),
            ConnectingCard(context, contact, circles),
          ],
          if (circles.isNotEmpty && contact.sharedProfile != null) ...[
            _paddedDivider(),
            ...sharedProfile(
              context,
              contact.sharedProfile!.details,
              contact.sharedProfile!.addressLocations,
            ),
          ],
          if (contact.sharedProfile?.temporaryLocations.isNotEmpty ??
              false) ...[
            _paddedDivider(),
            TemporaryLocationsCard(
              const Row(
                children: [
                  Icon(Icons.share_location),
                  SizedBox(width: 8),
                  Text('Shared locations', textScaler: TextScaler.linear(1.2)),
                ],
              ),
              contact.sharedProfile!.temporaryLocations,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 12, right: 12, bottom: 8),
              child: Text(
                'These current and future locations are available to '
                '${contact.name} based on the circles you shared the '
                'locations with.',
              ),
            ),
          ],
        ],
      ),
    );
