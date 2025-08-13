// Copyright 2024 - 2025 The Reunicorn Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../data/models/coag_contact.dart';
import '../../../data/models/contact_location.dart';
import '../../profile/page.dart';
import '../../utils.dart';

Iterable<Widget> sharedProfile(
  BuildContext context,
  ContactDetails details,
  Map<String, ContactAddressLocation> addressLocations,
) =>
    [
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
      if (details.picture != null)
        Center(
          child: Padding(
            padding: const EdgeInsets.only(left: 12, top: 4, right: 12),
            child: roundPictureOrPlaceholder(details.picture, radius: 48),
          ),
        ),
      if (details.names.isNotEmpty)
        ...detailsList(context, details.names, hideLabel: true),
      if (details.phones.isNotEmpty) ...detailsList(context, details.phones),
      if (details.emails.isNotEmpty) ...detailsList(context, details.emails),
      if (addressLocations.isNotEmpty)
        ...detailsList(
          context,
          addressLocations.map(
            (label, address) =>
                MapEntry(label, commasToNewlines(address.address ?? '')),
          ),
        ),
      if (details.socialMedias.isNotEmpty)
        ...detailsList(context, details.socialMedias),
      if (details.websites.isNotEmpty)
        ...detailsList(context, details.websites),
      if (details.organizations.isNotEmpty)
        ...detailsList(
          context,
          hideLabel: true,
          details.organizations.map(
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
      if (details.events.isNotEmpty)
        ...detailsList(
          context,
          details.events.map(
            (label, date) => MapEntry(
              label,
              DateFormat.yMd(
                Localizations.localeOf(context).languageCode,
              ).format(date),
            ),
          ),
        ),
      const Padding(
        padding: EdgeInsets.only(left: 12, right: 12, bottom: 8, top: 4),
        child: Text(
          'You are sharing the above information with them based on the '
          'circles you added them to.',
        ),
      ),
      // TODO: Check if opted out
      const Padding(
        padding: EdgeInsets.only(left: 12, right: 12, bottom: 8, top: 4),
        child: Text(
          'They also see how many contacts you are connected with, but can '
          'only find out who an individual contact is if they are '
          'connected with them as well and only see the information that '
          'contact shared with them.',
        ),
      ),
    ];
