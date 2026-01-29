// Copyright 2024 - 2026 The Reunicorn Authors. All rights reserved.
// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../data/models/contact_location.dart';

int numberContactsShared(
  Iterable<Iterable<String>> circleMemberships,
  Iterable<String> circles,
) => circleMemberships
    .where((c) => c.toSet().intersectsWith(circles.toSet()))
    .length;

class LocationTile extends StatelessWidget {
  final ContactTemporaryLocation _location;
  final Map<String, List<String>>? circleMemberships;
  final Future<void> Function()? onTap;

  const LocationTile(
    this._location, {
    this.circleMemberships,
    this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) => ListTile(
    title: Text(_location.name),
    contentPadding: EdgeInsets.zero,
    onTap: onTap,
    subtitle: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'From: ${DateFormat.yMd(Localizations.localeOf(context).languageCode).format(_location.start)}',
        ),
        if (_location.end != _location.start)
          Text(
            'Till: ${DateFormat.yMd(Localizations.localeOf(context).languageCode).format(_location.end)}',
          ),
        // Text('Lon: ${location.longitude.toStringAsFixed(4)}, '
        //     'Lat: ${location.latitude.toStringAsFixed(4)}'),
        if (circleMemberships != null)
          Text(
            'Shared with ${numberContactsShared(circleMemberships!.values, _location.circles)} '
            'contact${(numberContactsShared(circleMemberships!.values, _location.circles) == 1) ? '' : 's'}',
          ),
        if (_location.details.isNotEmpty) Text(_location.details),
      ],
    ),
    trailing:
        // TODO: Better icon to indicate checked in
        (_location.checkedIn && DateTime.now().isBefore(_location.end))
        ? const Icon(Icons.pin_drop_outlined)
        : null,
  );
}

class TemporaryLocationsCard extends StatelessWidget {
  const TemporaryLocationsCard(this.title, this._locations, {super.key});

  final Widget title;
  final Map<String, ContactTemporaryLocation> _locations;

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
            children: _locations.values
                .where((l) => l.end.isAfter(DateTime.now()))
                .map(
                  (l) => Padding(
                    padding: const EdgeInsets.only(
                      left: 16,
                      right: 16,
                      bottom: 4,
                    ),
                    child: LocationTile(
                      l,
                      onTap: () async => context.goNamed(
                        'mapAtLocation',
                        pathParameters: {
                          'latitude': l.latitude.toString(),
                          'longitude': l.longitude.toString(),
                        },
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ),
      ),
    ],
  );
}
