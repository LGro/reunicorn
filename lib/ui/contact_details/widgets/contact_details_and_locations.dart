// Copyright 2024 - 2025 The Reunicorn Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../data/models/coag_contact.dart';
import '../../profile/page.dart';
import '../../utils.dart';
import 'temporary_locations.dart';

class ContactDetailsAndLocations extends StatelessWidget {
  final CoagContact _contact;

  const ContactDetailsAndLocations(this._contact, {super.key});

  @override
  Widget build(BuildContext context) => Column(
    children: [
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

      if (_contact.details == null)
        Padding(
          padding: const EdgeInsets.only(left: 16, right: 16),
          child: Text(
            'Once you are connected, the information ${_contact.name} shares '
            'with you shows up here.',
          ),
        )
      else if (_contact.details!.names.isEmpty &&
          _contact.details!.phones.isEmpty &&
          _contact.details!.emails.isEmpty &&
          _contact.addressLocations.isEmpty &&
          _contact.details!.socialMedias.isEmpty &&
          _contact.details!.events.isEmpty &&
          _contact.details!.websites.isEmpty)
        Padding(
          padding: const EdgeInsets.only(left: 16, right: 16),
          child: Text(
            'It looks like ${_contact.name} has not shared any contact details '
            'with you yet.',
          ),
        ),

      // Contact details
      if (_contact.details?.names.isNotEmpty ?? false)
        ...detailsList(context, _contact.details!.names, hideLabel: true),
      if (_contact.details?.phones.isNotEmpty ?? false)
        ...detailsList(
          context,
          _contact.details!.phones,
          hideEditButton: true,
          editCallback: (label) =>
              launchUrl('tel:${_contact.details!.phones[label]}'),
        ),
      if (_contact.details?.emails.isNotEmpty ?? false)
        ...detailsList(
          context,
          _contact.details!.emails,
          hideEditButton: true,
          editCallback: (label) =>
              launchUrl('mailto:${_contact.details!.emails[label]}'),
        ),
      if (_contact.addressLocations.isNotEmpty)
        ...detailsList(
          context,
          _contact.addressLocations.map(
            (label, a) => MapEntry(label, commasToNewlines(a.address ?? '')),
          ),
        ),
      if (_contact.details?.socialMedias.isNotEmpty ?? false)
        ...detailsList(context, _contact.details!.socialMedias),
      if (_contact.details?.websites.isNotEmpty ?? false)
        ...detailsList(
          context,
          _contact.details!.websites,
          hideEditButton: true,
          editCallback: (label) => launchUrl(
            (_contact.details!.websites[label] ?? '').startsWith('http')
                ? _contact.details!.websites[label] ?? ''
                : 'https://${_contact.details!.websites[label]}',
          ),
        ),
      if (_contact.details?.events.isNotEmpty ?? false)
        ...detailsList(
          context,
          _contact.details!.events.map(
            (label, date) => MapEntry(
              label,
              DateFormat.yMd(
                Localizations.localeOf(context).languageCode,
              ).format(date),
            ),
          ),
          hideEditButton: true,
        ),
      if (_contact.details?.misc.isNotEmpty ?? false)
        ...detailsList(context, _contact.details!.misc, hideEditButton: true),
      if (_contact.details?.tags.isNotEmpty ?? false)
        ...detailsList(
          context,
          _contact.details!.tags,
          hideEditButton: true,
          hideLabel: true,
        ),

      // Locations
      if (_contact.temporaryLocations.isNotEmpty)
        TemporaryLocationsCard(
          Text(
            'Locations',
            textScaler: const TextScaler.linear(1.4),
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          _contact.temporaryLocations,
        ),
    ],
  );
}
