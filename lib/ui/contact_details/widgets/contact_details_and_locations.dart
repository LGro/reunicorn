// Copyright 2024 - 2025 The Reunicorn Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../data/models/coag_contact.dart';
import '../../profile/page.dart';
import '../../utils.dart';
import 'temporary_locations.dart';

Future<void> _launchUrl(String url) async {
  final uri = Uri.parse(url);
  try {
    final success = await launchUrl(uri);
  } on PlatformException {
    // TODO: Give feedback?
  }
}

List<Widget> contactDetailsAndLocations(
        BuildContext context, CoagContact contact) =>
    [
      Padding(
        padding: const EdgeInsets.only(left: 12, top: 8, right: 12, bottom: 8),
        child: Text(
          'Contact details',
          textScaler: const TextScaler.linear(1.4),
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ),

      if (contact.details == null)
        Padding(
          padding: const EdgeInsets.only(left: 16, right: 16),
          child: Text(
            'Once you are connected, the information '
            '${contact.name} shares with you shows up here.',
          ),
        )
      else if (contact.details!.names.isEmpty &&
          contact.details!.phones.isEmpty &&
          contact.details!.emails.isEmpty &&
          contact.addressLocations.isEmpty &&
          contact.details!.socialMedias.isEmpty &&
          contact.details!.events.isEmpty &&
          contact.details!.websites.isEmpty)
        Padding(
          padding: const EdgeInsets.only(left: 16, right: 16),
          child: Text(
            'It looks like ${contact.name} has not shared any contact '
            'details with you yet.',
          ),
        ),

      // Contact details
      if (contact.details?.names.isNotEmpty ?? false)
        ...detailsList(context, contact.details!.names, hideLabel: true),
      if (contact.details?.phones.isNotEmpty ?? false)
        ...detailsList(
          context,
          contact.details!.phones,
          hideEditButton: true,
          editCallback: (label) async =>
              _launchUrl('tel:${contact.details!.phones[label]}'),
        ),
      if (contact.details?.emails.isNotEmpty ?? false)
        ...detailsList(
          context,
          contact.details!.emails,
          hideEditButton: true,
          editCallback: (label) async =>
              _launchUrl('mailto:${contact.details!.emails[label]}'),
        ),
      if (contact.addressLocations.isNotEmpty)
        ...detailsList(
          context,
          contact.addressLocations.map(
            (label, a) => MapEntry(label, commasToNewlines(a.address ?? '')),
          ),
        ),
      if (contact.details?.socialMedias.isNotEmpty ?? false)
        ...detailsList(context, contact.details!.socialMedias),
      if (contact.details?.websites.isNotEmpty ?? false)
        ...detailsList(
          context,
          contact.details!.websites,
          hideEditButton: true,
          editCallback: (label) async => _launchUrl(
            (contact.details!.websites[label] ?? '').startsWith('http')
                ? contact.details!.websites[label] ?? ''
                : 'https://${contact.details!.websites[label]}',
          ),
        ),
      if (contact.details?.events.isNotEmpty ?? false)
        ...detailsList(
          context,
          contact.details!.events.map(
            (label, date) => MapEntry(
              label,
              DateFormat.yMd(
                Localizations.localeOf(context).languageCode,
              ).format(date),
            ),
          ),
          hideEditButton: true,
        ),

      // Locations
      if (contact.temporaryLocations.isNotEmpty)
        TemporaryLocationsCard(
          Text(
            'Locations',
            textScaler: const TextScaler.linear(1.4),
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          contact.temporaryLocations,
        ),
    ];
