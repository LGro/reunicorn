// Copyright 2024 - 2026 The Reunicorn Authors. All rights reserved.
// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/models/models.dart';
import '../../widgets/details_list.dart';
import '../cubit.dart';
import 'edit_or_add.dart';

class ProfileMiscWidget extends StatelessWidget {
  const ProfileMiscWidget(
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
    contact.misc,
    title: Text(
      'Miscellaneous',
      textScaler: const TextScaler.linear(1.4),
      style: TextStyle(
        fontWeight: FontWeight.bold,
        color: Theme.of(context).colorScheme.primary,
      ),
    ),
    getDetailSharingSettings: (l) => profileSharingSettings.misc[l],
    circles: circles,
    circleMemberships: circleMemberships,
    deleteCallback: (label) => context.read<ProfileCubit>().updateDetails(
      contact.copyWith(misc: {...contact.misc}..remove(label)),
    ),
    editCallback: (label) => onEditDetail(
      context: context,
      headlineSuffix: 'miscellaneous',
      labelHelperText: '',
      label: label,
      existingLabels: contact.misc.keys.toList(),
      value: contact.misc[label] ?? '',
      circles: circles,
      circleMemberships: circleMemberships,
      detailSharingSettings: profileSharingSettings.misc,
      onSave: context.read<ProfileCubit>().updateMisc,
      onDelete: () => context.read<ProfileCubit>().updateDetails(
        contact.copyWith(misc: {...contact.misc}..remove(label)),
      ),
    ),
    addCallback: () => onAddDetail(
      context: context,
      headlineSuffix: 'miscellaneous',
      labelHelperText: '',
      //defaultLabel: (contact.misc.isEmpty) ? 'private' : null,
      existingLabels: contact.misc.keys.toList(),
      circles: circles,
      circleMemberships: circleMemberships,
      onAdd: (label, value, circlesWithSelection) => context
          .read<ProfileCubit>()
          .updateMisc(null, label, value, circlesWithSelection),
    ),
  );
}
