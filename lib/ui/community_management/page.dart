// Copyright 2024 - 2026 The Reunicorn Authors. All rights reserved.
// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:convert';

import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

import '../../data/models/community.dart';
import '../../data/repositories/community_dht.dart';
import '../widgets/veilid_status/widget.dart';
import 'cubit.dart';
import 'widgets/community_overview.dart';
import 'widgets/import_community.dart';
import 'widgets/member_details.dart';

class CommunityManagementPage extends StatelessWidget {
  const CommunityManagementPage({super.key});

  @override
  Widget build(context) => Scaffold(
    appBar: AppBar(title: const Text('Community Management')),
    body: BlocProvider(
      create: (context) =>
          CommunityManagementCubit(context.read<CommunityDhtRepository>()),
      child: BlocBuilder<CommunityManagementCubit, CommunityManagementState>(
        builder: (context, state) {
          if (state.isProcessing) {
            return const Center(child: CircularProgressIndicator());
          }
          final selectedMember = (state.iSelectedMember == null)
              ? null
              : state.community!.membersWithWriters.getOrNull(
                  state.iSelectedMember!,
                );
          // Member details if selected
          if (state.community != null && selectedMember != null) {
            final memberWithWriter =
                state.community!.membersWithWriters[state.iSelectedMember!];
            return MemberDetails(
              state.community!,
              memberWithWriter.$1,
              memberWithWriter.$2,
            );
          }
          // Community overview if imported or created
          if (state.community != null) {
            return CommunityOverview(state.community!);
          }
          // Offer to create or import community
          return Column(
            spacing: 16,
            children: [
              // Just to establish full width
              VeilidStatusWidget(statusWidgets: {}),
              const Row(),
              FilledButton(
                onPressed: (state.isProcessing)
                    ? null
                    : context.read<CommunityManagementCubit>().createCommunity,
                child: (state.isProcessing)
                    ? const CircularProgressIndicator()
                    : const Text('Create Community'),
              ),
              const ImportCommunity(),
            ],
          );
        },
      ),
    ),
  );
}

Widget existingCommunityWidget(
  BuildContext context,
  ManagedCommunity community,
) => Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    Text(
      'Community: "${community.name}"',
      style: const TextStyle(fontWeight: FontWeight.bold),
    ),
    if (community.expiresAt != null)
      Text(
        'Due date ${DateFormat('yyyy-MM-dd').format(community.expiresAt!)}, ',
      ),
    const SizedBox(height: 8),
    Row(
      children: [
        FilledButton.tonal(
          onPressed: () async {
            final links = 'FIXME';
            await Clipboard.setData(ClipboardData(text: links));
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Links copied to clipboard')),
            );
          },
          child: const Row(
            children: [
              Icon(Icons.copy),
              SizedBox(width: 8),
              Text('Copy links'),
              SizedBox(width: 2),
            ],
          ),
        ),
        const SizedBox(width: 4),
        FilledButton.tonal(
          onPressed: () => SharePlus.instance.share(
            ShareParams(
              files: [
                XFile.fromData(utf8.encode('FIXME'), mimeType: 'text/plain'),
              ],
              // TODO(LGro): Lower case, ASCII, space to underscore
              fileNameOverrides: [
                'reunicorn_community_invites_${community.name}.txt',
              ],
            ),
          ),
          child: const Row(
            children: [
              Icon(Icons.download),
              SizedBox(width: 8),
              Text('Save links'),
              SizedBox(width: 2),
            ],
          ),
        ),
      ],
    ),
    const SizedBox(height: 4),
    FilledButton.tonal(
      onPressed: () => SharePlus.instance.share(
        ShareParams(
          files: [
            XFile.fromData(
              utf8.encode(jsonEncode(community.toJson())),
              mimeType: 'text/plain',
            ),
          ],
          // TODO(LGro): Lower case, ASCII, space to underscore
          fileNameOverrides: [
            'reunicorn_community_admin_${community.name}.json',
          ],
        ),
      ),
      child: const Row(
        children: [
          Icon(Icons.download),
          SizedBox(width: 8),
          Text('Save community management info'),
          SizedBox(width: 2),
        ],
      ),
    ),
  ],
);
