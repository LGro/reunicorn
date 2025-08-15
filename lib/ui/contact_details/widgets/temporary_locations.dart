// Copyright 2024 - 2025 The Reunicorn Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../data/models/contact_location.dart';

int numberContactsShared(
  Iterable<Iterable<String>> circleMemberships,
  Iterable<String> circles,
) =>
    circleMemberships
        .where((c) => c.toSet().intersectsWith(circles.toSet()))
        .length;

Widget locationTile(
  BuildContext context,
  ContactTemporaryLocation location, {
  Map<String, List<String>>? circleMemberships,
  Future<void> Function()? onTap,
}) =>
    ListTile(
      title: Text(location.name),
      contentPadding: EdgeInsets.zero,
      onTap: onTap,
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'From: ${DateFormat.yMd(Localizations.localeOf(context).languageCode).format(location.start)}',
          ),
          if (location.end != location.start)
            Text(
              'Till: ${DateFormat.yMd(Localizations.localeOf(context).languageCode).format(location.end)}',
            ),
          // Text('Lon: ${location.longitude.toStringAsFixed(4)}, '
          //     'Lat: ${location.latitude.toStringAsFixed(4)}'),
          if (circleMemberships != null)
            Text(
              'Shared with ${numberContactsShared(circleMemberships.values, location.circles)} '
              'contact${(numberContactsShared(circleMemberships.values, location.circles) == 1) ? '' : 's'}',
            ),
          if (location.details.isNotEmpty) Text(location.details),
        ],
      ),
      trailing:
          // TODO: Better icon to indicate checked in
          (location.checkedIn && DateTime.now().isBefore(location.end))
              ? const Icon(Icons.pin_drop_outlined)
              : null,
    );

class TemporaryLocationsCard extends StatelessWidget {
  const TemporaryLocationsCard(this.title, this.locations, {super.key});

  final Widget title;
  final Map<String, ContactTemporaryLocation> locations;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 12, right: 12, top: 8),
            child: title,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 4, right: 4, top: 4),
            child: Card(
              child: Column(
                children: locations.values
                    .where((l) => l.end.isAfter(DateTime.now()))
                    .map(
                      (l) => Padding(
                        padding: const EdgeInsets.only(
                          left: 16,
                          right: 16,
                          bottom: 4,
                        ),
                        child: locationTile(context, l,
                            onTap: () async => context.goNamed('mapAtLocation',
                                    pathParameters: {
                                      'latitude': l.latitude.toString(),
                                      'longitude': l.longitude.toString()
                                    })),
                      ),
                    )
                    .toList(),
              ),
            ),
          ),
        ],
      );
}
