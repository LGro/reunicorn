// Copyright 2024 - 2026 The Reunicorn Authors. All rights reserved.
// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/models/models.dart';
import '../../utils.dart';
import '../../widgets/details_list.dart';
import '../cubit.dart';
import 'edit_or_add.dart';

class ProfileWebsitesWidget extends StatelessWidget {
  const ProfileWebsitesWidget(
    this.contact,
    this.profileSharingSettings,
    this.circles,
    this.circleMemberships, {
    super.key,
  });

  final ContactDetails contact;
  final ProfileSharingSettings profileSharingSettings;
  final Map<String, String> circles;
  final Map<String, List<String>> circleMemberships;

  @override
  Widget build(BuildContext context) => DetailsList(
    contact.websites,
    title: Text(
      context.loc.websites.capitalize(),
      textScaler: const TextScaler.linear(1.4),
      style: TextStyle(
        fontWeight: FontWeight.bold,
        color: Theme.of(context).colorScheme.primary,
      ),
    ),
    getDetailSharingSettings: (l) => profileSharingSettings.websites[l],
    circles: circles,
    circleMemberships: circleMemberships,
    deleteCallback: (label) => context.read<ProfileCubit>().updateDetails(
      contact.copyWith(websites: {...contact.websites}..remove(label)),
    ),
    editCallback: (label) => onEditDetail(
      context: context,
      headlineSuffix: context.loc.website,
      labelHelperText: 'e.g. blog or portfolio',
      label: label,
      existingLabels: contact.websites.keys.toList(),
      value: contact.websites[label] ?? '',
      circles: circles,
      circleMemberships: circleMemberships,
      detailSharingSettings: profileSharingSettings.websites,
      onSave: context.read<ProfileCubit>().updateWebsite,
      onDelete: () => context.read<ProfileCubit>().updateDetails(
        contact.copyWith(websites: {...contact.websites}..remove(label)),
      ),
    ),
    addCallback: () => onAddDetail(
      context: context,
      headlineSuffix: context.loc.website,
      defaultLabel: (contact.websites.isEmpty) ? 'website' : null,
      // labelHelperText: 'e.g. blog or portfolio',
      valueHintText: 'my-awesome-site.com',
      existingLabels: contact.websites.keys.toList(),
      circles: circles,
      circleMemberships: circleMemberships,
      onAdd: (label, value, circlesWithSelection) => context
          .read<ProfileCubit>()
          .updateWebsite(null, label, value, circlesWithSelection),
    ),
  );
}
