// Copyright 2025 The Reunicorn Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

import 'dart:typed_data';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../data/models/circle.dart';
import '../../data/models/close_by_match.dart';
import '../../data/models/coag_contact.dart';
import '../../data/models/contact_introduction.dart';
import '../../data/models/contact_update.dart';
import '../../data/models/profile_info.dart';
import '../../data/services/storage/base.dart';
import '../introductions/cubit.dart';
import '../introductions/page.dart';
import '../updates/page.dart';
import '../utils.dart';
import 'cubit.dart';
import 'utils.dart';

String formatDateTime(DateTime dateTime, String languageCode) {
  final format = DateFormat.yMd(languageCode);
  if (dateTime.hour != 0 || dateTime.minute != 0) {
    format.add_Hm();
  }
  return format.format(dateTime);
}

class ShowMoreButton extends StatelessWidget {
  const ShowMoreButton(this.onPressed, {super.key});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Padding(
        padding: const EdgeInsetsGeometry.symmetric(horizontal: 8),
        child: TextButton(onPressed: onPressed, child: const Text('More')),
      ),
    ],
  );
}

class SectionHeadline extends StatelessWidget {
  const SectionHeadline(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(8),
    child: Text(
      text,
      textScaler: const TextScaler.linear(1.4),
      style: TextStyle(
        fontWeight: FontWeight.bold,
        color: Theme.of(context).colorScheme.primary,
      ),
    ),
  );
}

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final List<String> list1 = List.generate(20, (i) => 'List 1 Item ${i + 1}');
  final List<String> list2 = List.generate(
    20,
    (i) => i % 4 == 0
        ? 'List 2 Item ${i + 1} — even longer text that could take two or three lines, loooooong boys and gals and non binary pals.'
        : 'List 2 Item ${i + 1}',
  );
  final List<String> list3 = List.generate(20, (i) => 'List 2 Item ${i + 1}');

  // Measured heights (null until known)
  double? _hHeader;
  double? _hButton;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Dashboard'),
      actions: [
        IconButton(
          onPressed: () => context.pushNamed('settings'),
          icon: const Icon(Icons.settings),
        ),
      ],
    ),
    body: BlocProvider(
      create: (context) => DashboardCubit(
        context.read<Storage<CoagContact>>(),
        context.read<Storage<Circle>>(),
        context.read<Storage<ContactUpdate>>(),
        context.read<Storage<ProfileInfo>>(),
      ),
      child: BlocConsumer<DashboardCubit, DashboardState>(
        listener: (context, state) {},
        builder: (context, state) => LayoutBuilder(
          builder: (context, constraints) {
            // Data preparation
            final introductions = pendingIntroductions(state.contacts).toList();
            final contactUpdates = state.updates.toList();

            // Layout calculations
            final totalH = constraints.maxHeight;
            // Fallback estimates until measured; they'll update on first frame
            final headerH = _hHeader ?? 48.0;
            final buttonH = _hButton ?? 56.0;
            // Height left for all lists' rows (no headlines, no button)
            final rowsArea = (totalH - 3 * headerH - 3 * buttonH).clamp(
              0,
              totalH,
            );
            // Split equally between active row areas
            final numActive =
                ((introductions.isNotEmpty) ? 1 : 0) +
                ((state.closeByMatches.isNotEmpty) ? 1 : 0) +
                ((contactUpdates.isNotEmpty) ? 1 : 0);
            // TODO: Subtract the placeholder text height for empty sections
            final listRowsMaxH = rowsArea / numActive;

            // Build the content column with minimal vertical size so the button
            // hugs the last item.
            final content = Padding(
              padding: const EdgeInsetsGeometry.symmetric(horizontal: 8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Introductions
                  const SectionHeadline('Introductions'),
                  if (introductions.isNotEmpty) ...[
                    BlocProvider(
                      create: (context) => IntroductionsCubit(
                        context.read<Storage<CoagContact>>(),
                      ),
                      child:
                          BlocConsumer<IntroductionsCubit, IntroductionsState>(
                            listener: (context, state) {},
                            builder: (context, state) =>
                                DynamicFitList<
                                  (CoagContact, ContactIntroduction)
                                >(
                                  items: introductions,
                                  maxRowsHeight: listRowsMaxH,
                                  itemBuilder: (context, data) =>
                                      IntroductionListTile(
                                        introducer: data.$1,
                                        introduction: data.$2,
                                      ),
                                ),
                          ),
                    ),
                    ShowMoreButton(() => context.pushNamed('introductions')),
                  ] else
                    const Padding(
                      padding: EdgeInsetsGeometry.only(
                        left: 16,
                        right: 16,
                        bottom: 8,
                      ),
                      child: Text(
                        'When someone introduces you to one of their contacts, '
                        'it shows up here.',
                      ),
                    ),

                  // Close By
                  const SectionHeadline('Close By'),
                  if (state.closeByMatches.isNotEmpty) ...[
                    DynamicFitList<CloseByMatch>(
                      items: state.closeByMatches,
                      maxRowsHeight: listRowsMaxH,
                      itemBuilder: (context, match) => _CloseByRow(
                        match,
                        // TODO: Can we speed this up by storing a map of contacts?
                        picture: state.contacts
                            .firstWhereOrNull(
                              (c) => c.coagContactId == match.coagContactId,
                            )
                            ?.details
                            ?.picture,
                      ),
                    ),
                    // FIXME: Implement close by list or redirect to map page list view?
                    //ShowMoreButton(() {}),
                  ] else
                    const Padding(
                      padding: EdgeInsetsGeometry.only(
                        left: 16,
                        right: 16,
                        bottom: 8,
                      ),
                      child: Text(
                        'When contacts share a location close to any of '
                        'yours, it shows up here.',
                      ),
                    ),

                  // Updates
                  const SectionHeadline('Updates'),
                  if (contactUpdates.isNotEmpty) ...[
                    DynamicFitList<ContactUpdate>(
                      items: contactUpdates,
                      maxRowsHeight: listRowsMaxH,
                      itemBuilder: (context, update) =>
                          _ContactUpdateRow(update),
                    ),
                    ShowMoreButton(() => context.pushNamed('updates')),
                  ] else
                    const Padding(
                      padding: EdgeInsetsGeometry.only(
                        left: 16,
                        right: 16,
                        bottom: 8,
                      ),
                      child: Text(
                        'When contacts update the information they share with '
                        'you, it shows up here.',
                      ),
                    ),
                ],
              ),
            );

            return Stack(
              children: [
                // What the user sees
                Align(alignment: Alignment.topCenter, child: content),
                // Offstage measurement for headers and button (to compute exact heights)
                Offstage(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      MeasureSize(
                        onChange: (s) =>
                            _setIfChanged(header: true, value: s.height),
                        // TODO: Pick which ever is the longest headline,
                        // also considering current language translation
                        child: const SectionHeadline('Introductions'),
                      ),
                      MeasureSize(
                        onChange: (s) =>
                            _setIfChanged(button: true, value: s.height),
                        child: ShowMoreButton(() {}),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    ),
  );

  void _setIfChanged({
    bool header = false,
    bool button = false,
    required double value,
  }) {
    setState(() {
      if (header && _hHeader != value) _hHeader = value;
      if (button && _hButton != value) _hButton = value;
    });
  }
}

class _CloseByRow extends StatelessWidget {
  const _CloseByRow(this.match, {this.picture});

  final CloseByMatch match;
  final List<int>? picture;

  @override
  Widget build(BuildContext context) {
    final start = formatDateTime(
      match.start,
      Localizations.localeOf(context).languageCode,
    );
    final end = formatDateTime(
      match.end,
      Localizations.localeOf(context).languageCode,
    );

    return ListTile(
      leading: (picture == null || picture!.isEmpty)
          ? const CircleAvatar(radius: 18, child: Icon(Icons.person))
          : CircleAvatar(
              backgroundImage: MemoryImage(Uint8List.fromList(picture!)),
              radius: 18,
            ),
      // titleAlignment: ListTileTitleAlignment.top,
      title: Text(
        [
          '${match.coagContactName} will be near you at ',
          '"${match.myLocationLabel}" between $start and $end',
          // TODO: Make the on-tap something that helps with letting them know
          if (!match.theyKnow) '\nThey do not know about this, let them know.',
        ].join(),
      ),
      onTap: () => context.pushNamed(
        'contactDetails',
        pathParameters: {'coagContactId': match.coagContactId},
      ),
    );
  }
}

class _ContactUpdateRow extends StatelessWidget {
  const _ContactUpdateRow(this.update);

  final ContactUpdate update;

  @override
  Widget build(BuildContext context) => updateTile(
    getContactNameForUpdate(update.oldContact, update.newContact),
    formatTimeDifference(DateTime.now().difference(update.timestamp)),
    contactUpdateSummary(update.oldContact, update.newContact),
    onTap: (update.coagContactId == null)
        ? null
        : () => context.pushNamed(
            'contactDetails',
            pathParameters: {'coagContactId': update.coagContactId!},
          ),
    picture: update.newContact.details?.picture,
  );
}
