// Copyright 2024 - 2026 The Reunicorn Authors. All rights reserved.
// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../data/models/circle.dart';
import '../../../../data/models/diff/base.dart';
import '../../../../data/models/diff/contact_sharing_schema.dart';
import '../../../../data/models/models.dart';
import '../../../../data/models/profile_info.dart';
import '../../../../data/services/storage/base.dart';
import '../../../utils.dart';
import '../../../widgets/details_list.dart';
import 'cubit.dart';

class SharedProfile extends StatelessWidget {
  const SharedProfile(this._contactId, {super.key});

  final String _contactId;

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (context) => SharedProfileCubit(
      _contactId,
      context.read<Storage<CoagContact>>(),
      context.read<Storage<Circle>>(),
      context.read<Storage<ProfileInfo>>(),
    ),
    child: BlocConsumer<SharedProfileCubit, SharedProfileState>(
      listener: (context, state) {},
      builder: (context, state) =>
          (state.current == null || state.pending == null || state.diff == null)
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                    top: 8,
                    left: 12,
                    right: 12,
                    bottom: 8,
                  ),
                  child: Row(
                    spacing: 4,
                    children: [
                      const Icon(Icons.contact_page),
                      const Expanded(
                        child: Text(
                          'Shared profile',
                          textScaler: TextScaler.linear(1.2),
                        ),
                      ),
                      if (!state.diff!.areAllKeep)
                        const Padding(
                          padding: EdgeInsetsGeometry.symmetric(horizontal: 8),
                          child: Icon(Icons.sync),
                        ),
                    ],
                  ),
                ),
                // Picture
                PictureDiff(
                  state.current?.details.picture,
                  state.pending?.details.picture,
                  state.diff!.details.picture,
                ),
                // Names
                DetailsDiffList(
                  state.current!.details.names,
                  state.pending!.details.names,
                  state.diff!.details.names,
                  hideLabel: true,
                ),
                // Phones
                DetailsDiffList(
                  state.current!.details.phones,
                  state.pending!.details.phones,
                  state.diff!.details.phones,
                ),
                // Emails
                DetailsDiffList(
                  state.current!.details.emails,
                  state.pending!.details.emails,
                  state.diff!.details.emails,
                ),
                // Address locations
                DetailsDiffList(
                  state.current!.addressLocations.map(
                    (label, address) => MapEntry(
                      label,
                      commasToNewlines(address.address ?? ''),
                    ),
                  ),
                  state.pending!.addressLocations.map(
                    (label, address) => MapEntry(
                      label,
                      commasToNewlines(address.address ?? ''),
                    ),
                  ),
                  state.diff!.addressLocations,
                ),
                // Socials
                DetailsDiffList(
                  state.current!.details.socialMedias,
                  state.pending!.details.socialMedias,
                  state.diff!.details.socialMedias,
                ),
                // Websites
                DetailsDiffList(
                  state.current!.details.websites,
                  state.pending!.details.websites,
                  state.diff!.details.websites,
                ),
                // Organizations
                DetailsDiffList(
                  state.current!.details.organizations.map(
                    (id, org) => MapEntry(
                      id,
                      [
                        org.company,
                        org.title,
                        org.department,
                      ].where((v) => v.isNotEmpty).join('\n'),
                    ),
                  ),
                  state.pending!.details.organizations.map(
                    (id, org) => MapEntry(
                      id,
                      [
                        org.company,
                        org.title,
                        org.department,
                      ].where((v) => v.isNotEmpty).join('\n'),
                    ),
                  ),
                  state.diff!.details.organizations,
                ),
                // Events
                DetailsDiffList(
                  state.current!.details.events.map(
                    (label, date) => MapEntry(
                      label,
                      DateFormat.yMd(
                        Localizations.localeOf(context).languageCode,
                      ).format(date),
                    ),
                  ),
                  state.pending!.details.events.map(
                    (label, date) => MapEntry(
                      label,
                      DateFormat.yMd(
                        Localizations.localeOf(context).languageCode,
                      ).format(date),
                    ),
                  ),
                  state.diff!.details.events,
                ),
                // Misc
                DetailsDiffList(
                  state.current!.details.misc,
                  state.pending!.details.misc,
                  state.diff!.details.misc,
                ),
                // Tags
                DetailsDiffList(
                  state.current!.details.tags,
                  state.pending!.details.tags,
                  state.diff!.details.tags,
                  hideLabel: true,
                ),

                const Padding(
                  padding: EdgeInsets.only(
                    left: 12,
                    right: 12,
                    bottom: 8,
                    top: 4,
                  ),
                  child: Text(
                    'You are sharing the information above with them based on '
                    'the circles you added them to.',
                  ),
                ),
                // TODO(LGro): Check if opted out
                const Padding(
                  padding: EdgeInsets.only(
                    left: 12,
                    right: 12,
                    bottom: 8,
                    top: 4,
                  ),
                  child: Text(
                    'They also see how many contacts you are connected with, '
                    'but can only find out who an individual contact is if '
                    'they are connected with them as well and only see the '
                    'information that contact shared with them.',
                  ),
                ),
              ],
            ),
    ),
  );
}

class PictureDiff extends StatelessWidget {
  final List<int>? _current;
  final List<int>? _pending;
  final DiffStatus _diff;

  const PictureDiff(this._current, this._pending, this._diff, {super.key});

  @override
  Widget build(BuildContext context) => (_current == null && _pending == null)
      ? const SizedBox()
      : Padding(
          padding: const EdgeInsets.only(top: 4, bottom: 8),
          child: switch (_diff) {
            // TODO(LGro): Mark with icon or fade or otherwise indicate add
            DiffStatus.add => Center(
              child: Padding(
                padding: const EdgeInsets.only(left: 12, right: 12),
                child: roundPictureOrPlaceholder(_pending, radius: 48),
              ),
            ),
            DiffStatus.change => Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                roundPictureOrPlaceholder(_current, radius: 48),
                roundPictureOrPlaceholder(_pending, radius: 48),
              ],
            ),
            // TODO(LGro): Mark with icon or fade or otherwise indicate delete
            DiffStatus.remove => Center(
              child: Padding(
                padding: const EdgeInsets.only(left: 12, right: 12),
                child: roundPictureOrPlaceholder(_current, radius: 48),
              ),
            ),
            DiffStatus.keep => Center(
              child: Padding(
                padding: const EdgeInsets.only(left: 12, right: 12),
                child: roundPictureOrPlaceholder(_current, radius: 48),
              ),
            ),
          },
        );
}

class DetailsDiffList extends StatelessWidget {
  const DetailsDiffList(
    this._current,
    this._pending,
    this._diff, {
    this.title,
    this.hideLabel = false,
    super.key,
  });

  final Map<String, String> _current;
  final Map<String, String> _pending;
  final Map<String, DiffStatus> _diff;
  final Text? title;
  final bool hideLabel;

  @override
  Widget build(BuildContext context) => (_current.isEmpty && _pending.isEmpty)
      ? const SizedBox()
      : DetailsCard(
          title: title,
          children: <Widget>[
            ..._diff.entries.map(
              (entry) => Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: switch (entry.value) {
                        DiffStatus.add => AddDetail(
                          label: hideLabel ? null : entry.key,
                          value: _pending[entry.key] ?? '???',
                        ),
                        DiffStatus.change => ChangeDetail(
                          label: hideLabel ? null : entry.key,
                          current: _current[entry.key] ?? '???',
                          pending: _pending[entry.key] ?? '???',
                        ),
                        DiffStatus.remove => RemoveDetail(
                          label: hideLabel ? null : entry.key,
                          value: _current[entry.key] ?? '???',
                        ),
                        DiffStatus.keep => KeepDetail(
                          label: hideLabel ? null : entry.key,
                          value: _current[entry.key] ?? '???',
                        ),
                      },
                    ),
                  ],
                ),
              ),
            ),
          ].addBetween(const SizedBox(height: 8)),
        );
}

class KeepDetail extends StatelessWidget {
  final String? label;
  final String value;

  const KeepDetail({required this.value, this.label, super.key});

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      if (label != null)
        Text(
          label!,
          textScaler: const TextScaler.linear(1.1),
          style: Theme.of(context).textTheme.labelLarge,
        ),
      Text(
        value,
        textScaler: const TextScaler.linear(1.1),
        overflow: TextOverflow.ellipsis,
        maxLines: value.contains('\n') ? null : 1,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
          height: value.contains('\n') ? 1.2 : null,
        ),
      ),
    ],
  );
}

class RemoveDetail extends StatelessWidget {
  final String? label;
  final String value;

  const RemoveDetail({required this.value, this.label, super.key});

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      if (label != null)
        Text(
          label!,
          textScaler: const TextScaler.linear(1.1),
          style:
              Theme.of(context).textTheme.labelLarge?.copyWith(
                decoration: TextDecoration.lineThrough,
              ) ??
              const TextStyle(decoration: TextDecoration.lineThrough),
        ),
      Row(
        children: [
          Expanded(
            child: Text(
              value,
              textScaler: const TextScaler.linear(1.1),
              overflow: TextOverflow.ellipsis,
              maxLines: value.contains('\n') ? null : 1,
              style:
                  Theme.of(context).textTheme.bodyLarge?.copyWith(
                    height: value.contains('\n') ? 1.2 : null,
                    decoration: TextDecoration.lineThrough,
                  ) ??
                  const TextStyle(decoration: TextDecoration.lineThrough),
            ),
          ),
          const Icon(Icons.sync),
        ],
      ),
    ],
  );
}

class AddDetail extends StatelessWidget {
  final String? label;
  final String value;

  const AddDetail({required this.value, this.label, super.key});

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      if (label != null)
        Text(
          label!,
          textScaler: const TextScaler.linear(1.1),
          style: Theme.of(context).textTheme.labelLarge,
        ),
      Row(
        children: [
          Expanded(
            child: Text(
              value,
              textScaler: const TextScaler.linear(1.1),
              overflow: TextOverflow.ellipsis,
              maxLines: value.contains('\n') ? null : 1,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                height: value.contains('\n') ? 1.2 : null,
              ),
            ),
          ),
          const Icon(Icons.sync),
        ],
      ),
    ],
  );
}

class ChangeDetail extends StatelessWidget {
  final String? label;
  final String current;
  final String pending;

  const ChangeDetail({
    required this.current,
    required this.pending,
    this.label,
    super.key,
  });

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      if (label != null)
        Text(
          label!,
          textScaler: const TextScaler.linear(1.1),
          style: Theme.of(context).textTheme.labelLarge,
        ),
      Row(
        children: [
          Expanded(
            child: Text(
              current,
              textScaler: const TextScaler.linear(1.1),
              overflow: TextOverflow.ellipsis,
              maxLines: current.contains('\n') ? null : 1,
              style:
                  Theme.of(context).textTheme.bodyLarge?.copyWith(
                    height: current.contains('\n') ? 1.2 : null,
                    decoration: TextDecoration.lineThrough,
                  ) ??
                  const TextStyle(decoration: TextDecoration.lineThrough),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: Icon(Icons.arrow_forward),
          ),
          Expanded(
            child: Text(
              pending,
              textScaler: const TextScaler.linear(1.1),
              overflow: TextOverflow.ellipsis,
              maxLines: pending.contains('\n') ? null : 1,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                height: pending.contains('\n') ? 1.2 : null,
              ),
            ),
          ),
          const Icon(Icons.sync),
        ],
      ),
    ],
  );
}
