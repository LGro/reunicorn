// Copyright 2026 The Reunicorn Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../data/models/community.dart';
import '../cubit.dart';

class CommunityOverview extends StatelessWidget {
  CommunityOverview(this._community, {super.key});

  final ManagedCommunity _community;
  final _nameController = TextEditingController();
  final _newMemberNameController = TextEditingController();

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: TextFormField(
                key: const Key('communityName'),
                controller: _nameController..text = _community.name,
                decoration: const InputDecoration(
                  isDense: true,
                  border: OutlineInputBorder(),
                  helperText: 'community name',
                ),
              ),
            ),
            const SizedBox(width: 16),
            SizedBox(
              // TODO(LGro): Scale with required date text size
              width: 150,
              child: TextFormField(
                key: const Key('communityName'),
                readOnly: true,
                onTap: () async {
                  final pickedDate = await showDatePicker(
                    context: context,
                    initialDate: _community.expiresAt ?? DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365 * 3)),
                  );
                  if (pickedDate != null && context.mounted) {
                    context.read<CommunityManagementCubit>().updateCommunity(
                      _community.copyWith(expiresAt: pickedDate),
                    );
                  }
                },
                controller: TextEditingController()
                  ..text = (_community.expiresAt == null)
                      ? 'no expiry date'
                      : DateFormat('yyyy-MM-DD').format(_community.expiresAt!),
                decoration: const InputDecoration(
                  isDense: true,
                  border: OutlineInputBorder(),
                  helperText: 'expiry date',
                ),
              ),
            ),
            const SizedBox(width: 4),
            IconButton(
              onPressed: () => context
                  .read<CommunityManagementCubit>()
                  .updateCommunity(_community.copyWith(expiresAt: null)),
              icon: const Icon(Icons.cancel_outlined),
            ),
          ],
        ),
        const SizedBox(height: 8),
        FilledButton(
          onPressed: () => context
              .read<CommunityManagementCubit>()
              .saveCommunity(_community.copyWith(name: _nameController.text)),
          child: const Text('Save'),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: _community.membersWithWriters.length,
            itemBuilder: (context, i) => ListTile(
              title: Text(_community.membersWithWriters[i].$1.name),
              onTap: () =>
                  context.read<CommunityManagementCubit>().selectMember(i),
            ),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 8,
          children: [
            Expanded(
              child: TextFormField(
                key: const Key('newMemberName'),
                controller: _newMemberNameController,
                decoration: const InputDecoration(
                  isDense: true,
                  border: OutlineInputBorder(),
                  helperText: 'one or multiple comma separated member names',
                ),
              ),
            ),
            IconButton.filled(
              onPressed: () => context
                  .read<CommunityManagementCubit>()
                  .addMembers(_newMemberNameController.text),
              icon: const Icon(Icons.add),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 8,
          children: [
            FilledButton(onPressed: () {}, child: Text('Export Invites')),
            FilledButton(onPressed: () {}, child: Text('Export Mangement')),
          ],
        ),
      ],
    ),
  );
}
