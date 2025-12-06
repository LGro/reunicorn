// Copyright 2025 The Reunicorn Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

import 'dart:typed_data';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../data/models/circle.dart';
import '../../data/models/close_by_match.dart';
import '../../data/models/coag_contact.dart';
import '../../data/models/contact_location.dart';
import '../../data/models/profile_info.dart';
import '../../data/repositories/contact_dht.dart';
import '../../data/repositories/settings.dart';
import '../../data/services/storage/base.dart';
import 'cubit.dart';

// Ideal state data structure, list of: locationIdString, ContactTemporaryLocation, CoagContact?, CloseByBool

class LocationListTile extends StatelessWidget {
  const LocationListTile({
    required this.locationId,
    required this.location,
    required this.contact,
    required this.closeByMatches,
    super.key,
  });

  final String locationId;
  final ContactTemporaryLocation location;
  final CoagContact? contact;
  final Iterable<CloseByMatch> closeByMatches;

  // highlight my own
  // highlight close by

  @override
  Widget build(BuildContext context) {
    // Close by indicator
    // TODO: Is this getting too slow?
    final closeByMatch = closeByMatches.firstWhereOrNull(
      (m) => m.theirLocationId == locationId,
    );
    final trailing = (closeByMatch == null || contact == null)
        ? null
        : const Icon(Icons.group);

    // Title: Name @ Location
    final title =
        '${(contact == null) ? 'Me' : contact!.name} @ ${location.name}';

    // Subtitle: start - end
    final subTitle = [
      DateFormat.yMd(
        Localizations.localeOf(context).languageCode,
      ).format(location.start),
      if (location.end != location.start) ...[
        ' - ',
        DateFormat.yMd(
          Localizations.localeOf(context).languageCode,
        ).format(location.end),
      ],
      if (closeByMatch != null && contact != null)
        '\nclose by ${closeByMatch.myLocationLabel}',
    ].join();

    // Contact picture
    final picture = (contact?.details?.picture == null)
        ? const CircleAvatar(radius: 18, child: Icon(Icons.person))
        : CircleAvatar(
            backgroundImage: MemoryImage(
              Uint8List.fromList(contact!.details!.picture!),
            ),
            radius: 18,
          );

    return ListTile(
      leading: picture,
      title: Text(title),
      subtitle: Text(subTitle),
      trailing: trailing,
    );
  }
}

class SliverListWithMonthHeaders extends StatelessWidget {
  const SliverListWithMonthHeaders({super.key, required this.data});

  final List<(String, ContactTemporaryLocation, CoagContact?)> data;

  @override
  Widget build(BuildContext context) {
    final sorted = [...data]..sort((a, b) => a.$2.start.compareTo(b.$2.start));

    final children = <Widget>[];
    int? lastYear, lastMonth;

    for (final e in sorted) {
      final y = e.$2.start.year;
      final m = e.$2.start.month;

      if (lastYear != y || lastMonth != m) {
        children.add(
          Container(
            padding: const EdgeInsets.all(8),
            child: Text(
              DateFormat('MMMM yyyy').format(e.$2.start),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        );
        lastYear = y;
        lastMonth = m;
      }
      children.add(
        LocationListTile(
          locationId: e.$1,
          location: e.$2,
          contact: e.$3,

          // FIXME: add to state and use here
          closeByMatches: [],
        ),
      );
    }

    return CustomScrollView(
      slivers: [SliverList(delegate: SliverChildListDelegate(children))],
    );
  }
}

class LocationListPage extends StatelessWidget {
  const LocationListPage({super.key});

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (context) => MapCubit(
      context.read<Storage<CoagContact>>(),
      context.read<Storage<Circle>>(),
      context.read<Storage<ProfileInfo>>(),
      context.read<SettingsRepository>(),
    ),
    child: BlocConsumer<MapCubit, MapState>(
      listener: (context, state) {},
      builder: (context, state) {
        final locations = [
          ...filterTemporaryLocations(
            state.profileInfo?.temporaryLocations ?? {},
          ).entries.map((e) => (e.key, e.value, null)),
          ...state.contacts
              .map((c) => (c, filterTemporaryLocations(c.temporaryLocations)))
              .expand((l) => l.$2.entries.map((e) => (e.key, e.value, l.$1))),
        ]..sort((l1, l2) => l1.$2.start.compareTo(l2.$2.start));

        return Scaffold(
          appBar: AppBar(title: const Text('Locations')),
          body: Expanded(child: SliverListWithMonthHeaders(data: locations)),
        );
      },
    ),
  );
}
