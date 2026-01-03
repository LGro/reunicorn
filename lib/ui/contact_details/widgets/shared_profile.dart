// Copyright 2024 - 2025 The Reunicorn Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../data/models/coag_contact.dart';
import '../../../data/models/contact_location.dart';
import '../../profile/page.dart';
import '../../utils.dart';

class SharedProfile extends StatelessWidget {
  const SharedProfile(this._details, this._addressLocations, {super.key});

  final ContactDetails _details;
  final Map<String, ContactAddressLocation> _addressLocations;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      const Padding(
        padding: EdgeInsets.only(top: 8, left: 12, right: 12, bottom: 8),
        child: Row(
          children: [
            Icon(Icons.contact_page),
            SizedBox(width: 4),
            Text('Shared profile', textScaler: TextScaler.linear(1.2)),
          ],
        ),
      ),
      if (_details.picture != null)
        Center(
          child: Padding(
            padding: const EdgeInsets.only(left: 12, top: 4, right: 12),
            child: roundPictureOrPlaceholder(_details.picture, radius: 48),
          ),
        ),
      if (_details.names.isNotEmpty)
        ...detailsList(context, _details.names, hideLabel: true),
      if (_details.phones.isNotEmpty) ...detailsList(context, _details.phones),
      if (_details.emails.isNotEmpty) ...detailsList(context, _details.emails),
      if (_addressLocations.isNotEmpty)
        ...detailsList(
          context,
          _addressLocations.map(
            (label, address) =>
                MapEntry(label, commasToNewlines(address.address ?? '')),
          ),
        ),
      if (_details.socialMedias.isNotEmpty)
        ...detailsList(context, _details.socialMedias),
      if (_details.websites.isNotEmpty)
        ...detailsList(context, _details.websites),
      if (_details.organizations.isNotEmpty)
        ...detailsList(
          context,
          hideLabel: true,
          _details.organizations.map(
            (id, org) => MapEntry(
              id,
              [
                org.company,
                org.title,
                org.department,
              ].where((v) => v.isNotEmpty).join('\n'),
            ),
          ),
        ),
      if (_details.events.isNotEmpty)
        ...detailsList(
          context,
          _details.events.map(
            (label, date) => MapEntry(
              label,
              DateFormat.yMd(
                Localizations.localeOf(context).languageCode,
              ).format(date),
            ),
          ),
        ),
      if (_details.misc.isNotEmpty) ...detailsList(context, _details.misc),
      if (_details.tags.isNotEmpty)
        ...detailsList(context, _details.tags, hideLabel: true),

      const Padding(
        padding: EdgeInsets.only(left: 12, right: 12, bottom: 8, top: 4),
        child: Text(
          'You are sharing the above information with them based on the '
          'circles you added them to.',
        ),
      ),
      // TODO(LGro): Check if opted out
      const Padding(
        padding: EdgeInsets.only(left: 12, right: 12, bottom: 8, top: 4),
        child: Text(
          'They also see how many contacts you are connected with, but can '
          'only find out who an individual contact is if they are '
          'connected with them as well and only see the information that '
          'contact shared with them.',
        ),
      ),
    ],
  );
}
