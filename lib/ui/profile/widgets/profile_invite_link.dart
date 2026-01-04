// Copyright 2024 - 2026 The Reunicorn Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:veilid/veilid.dart';

import '../../utils.dart';
import '../../widgets/details_list.dart';

class ProfileInviteLinkWidget extends StatelessWidget {
  const ProfileInviteLinkWidget({
    required this.name,
    required this.profilePubKey,
    super.key,
  });

  final String name;
  final PublicKey profilePubKey;

  @override
  Widget build(BuildContext context) => DetailsCard(
    title: Text(
      'Public invite link',
      textScaler: const TextScaler.linear(1.4),
      style: TextStyle(
        fontWeight: FontWeight.bold,
        color: Theme.of(context).colorScheme.primary,
      ),
    ),
    children: [
      const SizedBox(height: 10),
      const Text(
        'You can add the following link to your social media '
        'profiles, website, e-mail signature or any place where '
        'you want to show others an opportunity to connect with '
        'you via Reunicorn. Others can use this link to generate a '
        'personal sharing offer for you that they can send you '
        'through existing means of communication for you to add '
        'them to Reunicorn.',
      ),
      Row(
        children: [
          Expanded(
            child: Text(
              profileUrl(name, profilePubKey).toString(),
              softWrap: true,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          IconButton.filledTonal(
            onPressed: () => SharePlus.instance.share(
              ShareParams(uri: profileUrl(name, profilePubKey)),
            ),
            icon: const Icon(Icons.copy),
          ),
        ],
      ),
    ],
  );
}
