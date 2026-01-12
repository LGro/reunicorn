// Copyright 2024 - 2026 The Reunicorn Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/models/models.dart';
import '../../utils.dart';
import '../../widgets/details_list.dart';
import '../cubit.dart';
import 'edit_or_add.dart';

class ProfilePhonesWidget extends StatelessWidget {
  const ProfilePhonesWidget(
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
    contact.phones,
    title: Text(
      context.loc.phones.capitalize(),
      textScaler: const TextScaler.linear(1.4),
      style: TextStyle(
        fontWeight: FontWeight.bold,
        color: Theme.of(context).colorScheme.primary,
      ),
    ),
    getDetailSharingSettings: (l) => profileSharingSettings.phones[l],
    circles: circles,
    circleMemberships: circleMemberships,
    deleteCallback: (label) => context.read<ProfileCubit>().updateDetails(
      contact.copyWith(phones: {...contact.phones}..remove(label)),
    ),
    editCallback: (label) => onEditDetail(
      context: context,
      headlineSuffix: context.loc.phoneNumber,
      labelHelperText: 'e.g. home, mobile or work',
      label: label,
      value: contact.phones[label] ?? '',
      existingLabels: contact.phones.keys.toList(),
      circles: circles,
      circleMemberships: circleMemberships,
      detailSharingSettings: profileSharingSettings.phones,
      onSave: context.read<ProfileCubit>().updatePhone,
      onDelete: () => context.read<ProfileCubit>().updateDetails(
        contact.copyWith(phones: {...contact.phones}..remove(label)),
      ),
    ),
    addCallback: () => onAddDetail(
      context: context,
      headlineSuffix: context.loc.phoneNumber,
      labelHelperText: 'e.g. home, mobile or work',
      defaultLabel: (contact.phones.isEmpty) ? 'mobile' : null,
      existingLabels: contact.phones.keys.toList(),
      circles: circles,
      circleMemberships: circleMemberships,
      onAdd: (label, value, circlesWithSelection) => context
          .read<ProfileCubit>()
          .updatePhone(null, label, value, circlesWithSelection),
    ),
  );
}
