// Copyright 2024 - 2026 The Reunicorn Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/models/models.dart';
import '../../widgets/details_list.dart';
import '../cubit.dart';
import 'edit_or_add.dart';

class ProfileSocialsWidget extends StatelessWidget {
  const ProfileSocialsWidget(
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
    contact.socialMedias,
    title: Text(
      'Socials',
      textScaler: const TextScaler.linear(1.4),
      style: TextStyle(
        fontWeight: FontWeight.bold,
        color: Theme.of(context).colorScheme.primary,
      ),
    ),
    getDetailSharingSettings: (l) => profileSharingSettings.socialMedias[l],
    circles: circles,
    circleMemberships: circleMemberships,
    deleteCallback: (label) => context.read<ProfileCubit>().updateDetails(
      contact.copyWith(socialMedias: {...contact.socialMedias}..remove(label)),
    ),
    editCallback: (label) => onEditDetail(
      context: context,
      headlineSuffix: 'social media profile',
      labelHelperText: 'e.g. Signal or Instagram',
      existingLabels: contact.socialMedias.keys.toList(),
      label: label,
      value: contact.socialMedias[label] ?? '',
      circles: circles,
      circleMemberships: circleMemberships,
      detailSharingSettings: profileSharingSettings.socialMedias,
      onSave: context.read<ProfileCubit>().updateSocialMedia,
      onDelete: () => context.read<ProfileCubit>().updateDetails(
        contact.copyWith(
          socialMedias: {...contact.socialMedias}..remove(label),
        ),
      ),
    ),
    addCallback: () => onAddDetail(
      context: context,
      headlineSuffix: 'social media profile',
      valueHintText: '@profileName',
      labelHelperText: 'e.g. Signal or Instagram',
      existingLabels: contact.socialMedias.keys.toList(),
      circles: circles,
      circleMemberships: circleMemberships,
      onAdd: (label, value, circlesWithSelection) => context
          .read<ProfileCubit>()
          .updateSocialMedia(null, label, value, circlesWithSelection),
    ),
  );
}
