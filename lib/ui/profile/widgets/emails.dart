// Copyright 2024 - 2026 The Reunicorn Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/models/models.dart';
import '../../utils.dart';
import '../../widgets/details_list.dart';
import '../cubit.dart';
import 'edit_or_add.dart';

class ProfileEmailsWidget extends StatelessWidget {
  const ProfileEmailsWidget(
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
    contact.emails,
    title: Text(
      context.loc.emails.capitalize(),
      textScaler: const TextScaler.linear(1.4),
      style: TextStyle(
        fontWeight: FontWeight.bold,
        color: Theme.of(context).colorScheme.primary,
      ),
    ),
    getDetailSharingSettings: (l) => profileSharingSettings.emails[l],
    circles: circles,
    circleMemberships: circleMemberships,
    deleteCallback: (label) => context.read<ProfileCubit>().updateDetails(
      contact.copyWith(emails: {...contact.emails}..remove(label)),
    ),
    editCallback: (label) => onEditDetail(
      context: context,
      headlineSuffix: context.loc.emailAddress,
      labelHelperText: 'e.g. private or work',
      label: label,
      existingLabels: contact.emails.keys.toList(),
      value: contact.emails[label] ?? '',
      circles: circles,
      circleMemberships: circleMemberships,
      detailSharingSettings: profileSharingSettings.emails,
      onSave: context.read<ProfileCubit>().updateEmail,
      onDelete: () => context.read<ProfileCubit>().updateDetails(
        contact.copyWith(emails: {...contact.emails}..remove(label)),
      ),
    ),
    addCallback: () => onAddDetail(
      context: context,
      headlineSuffix: context.loc.emailAddress,
      labelHelperText: 'e.g. private or work',
      defaultLabel: (contact.emails.isEmpty) ? 'private' : null,
      existingLabels: contact.emails.keys.toList(),
      circles: circles,
      circleMemberships: circleMemberships,
      onAdd: (label, value, circlesWithSelection) => context
          .read<ProfileCubit>()
          .updateEmail(null, label, value, circlesWithSelection),
    ),
  );
}
