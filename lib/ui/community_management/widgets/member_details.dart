// Copyright 2026 The Reunicorn Authors. All rights reserved.
// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:veilid/veilid.dart';

import '../../../data/models/community.dart';
import '../cubit.dart';

class MemberDetails extends StatelessWidget {
  final ManagedCommunity _community;
  final OrganizerProvidedMemberInfo _member;
  final KeyPair _writer;
  final _nameController = TextEditingController();
  final _commentController = TextEditingController();

  MemberDetails(this._community, this._member, this._writer, {super.key});

  @override
  Widget build(BuildContext context) => Column(
    children: [
      // Edit name
      TextFormField(
        key: const Key('communityMemberName'),
        controller: _nameController..text = _member.name,
        decoration: const InputDecoration(
          isDense: true,
          border: OutlineInputBorder(),
          helperText: '',
        ),
      ),
      // Comment
      TextFormField(
        key: const Key('communityMemberComment'),
        controller: _commentController..text = _member.comment ?? '',
        decoration: const InputDecoration(
          isDense: true,
          border: OutlineInputBorder(),
          helperText: '',
          // Somehow, this being null still causes the helper text
          // to overflow into an ellipsis on narrow iOS screens
          helperMaxLines: 20,
        ),
        textInputAction: TextInputAction.done,
        // TODO: Does this limit the number of lines or just
        // specify the visible ones? We need the latter not the
        // former.
        maxLines: 4,
      ),
      // Save
      FilledButton(
        onPressed: () => context.read<CommunityManagementCubit>().updateMember(
          memberRecordKey: _member.recordKey,
          name: _nameController.text,
          comment: _commentController.text,
        ),
        child: const Text('Save'),
      ),
      // Deactivate
      FilledButton(
        onPressed: context.read<CommunityManagementCubit>().deactivateMember,
        child: const Text('Deactivate'),
      ),
      // Remove
      FilledButton(
        onPressed: context.read<CommunityManagementCubit>().removeMember,
        child: const Text('Remove'),
      ),
      // Their invite link
      // Back
      FilledButton(
        onPressed: context.read<CommunityManagementCubit>().deselectMember,
        child: const Text('Back to Overview'),
      ),
    ],
  );
}
