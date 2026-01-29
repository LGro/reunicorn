// Copyright 2024 - 2026 The Reunicorn Authors. All rights reserved.
// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/models/models.dart';
import '../../utils.dart';
import '../../widgets/details_list.dart';
import '../cubit.dart';
import 'edit_or_add.dart';

class ProfileNamesWidget extends StatelessWidget {
  const ProfileNamesWidget(
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
    contact.names,
    title: Text(
      context.loc.names.capitalize(),
      textScaler: const TextScaler.linear(1.4),
      style: TextStyle(
        fontWeight: FontWeight.bold,
        color: Theme.of(context).colorScheme.primary,
      ),
    ),
    hideLabel: true,
    getDetailSharingSettings: (l) => profileSharingSettings.names[l],
    circles: circles,
    circleMemberships: circleMemberships,
    deleteCallback: (label) => context.read<ProfileCubit>().updateDetails(
      contact.copyWith(names: {...contact.names}..remove(label)),
    ),
    editCallback: (label) => onEditDetail(
      context: context,
      headlineSuffix: context.loc.name,
      hideLabel: true,
      label: label,
      value: contact.names[label] ?? '',
      circles: circles,
      circleMemberships: circleMemberships,
      detailSharingSettings: profileSharingSettings.names,
      // We don't need to handle label changes here because the id
      // i.e. label is not exposed for the user to change it
      onSave: (_, id, value, circlesWithSelection) => context
          .read<ProfileCubit>()
          .updateName(id, value, circlesWithSelection),
      onDelete: () => context.read<ProfileCubit>().updateDetails(
        contact.copyWith(names: {...contact.names}..remove(label)),
      ),
    ),
    // TODO: Can this also be unified, using the same as other details?
    addCallback: () => showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (buildContext) => DraggableScrollableSheet(
        expand: false,
        maxChildSize: 0.9,
        initialChildSize: 0.9,
        builder: (_, scrollController) => SingleChildScrollView(
          controller: scrollController,
          child: EditOrAddWidget(
            isEditing: false,
            hideLabel: true,
            headlineSuffix: context.loc.name,
            valueHintText: 'Name (pronouns)',
            circles: circles
                .map(
                  (cId, cLabel) => MapEntry(cId, (
                    cId,
                    cLabel,
                    false,
                    circleMemberships.values
                        .where((circles) => circles.contains(cId))
                        .length,
                  )),
                )
                .values
                .toList(),
            onAddOrSave: (label, name, circles) => context
                .read<ProfileCubit>()
                .updateName(label, name, circles)
                .then(
                  (_) => (buildContext.mounted)
                      ? Navigator.of(buildContext).pop()
                      : null,
                ),
          ),
        ),
      ),
    ),
  );
}
