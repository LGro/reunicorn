// Copyright 2024 - 2026 The Reunicorn Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

import 'package:flutter/material.dart';

import '../../../data/models/models.dart';
import '../../utils.dart';
import 'connecting/direct_sharing.dart';
import 'connecting/profile_based.dart';

class ConnectingCard extends StatelessWidget {
  const ConnectingCard(this.context, this.contact, this.circles, {super.key});

  final BuildContext context;
  final CoagContact contact;
  final Map<String, String> circles;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(left: 12, right: 12, top: 8),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.private_connectivity),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                'To connect with ${contact.name}:',
                textScaler: const TextScaler.linear(1.2),
                softWrap: true,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),

        if (showSharingInitializing(contact.dhtConnection) &&
            circles.keys.where((cId) => cId.startsWith('VLD')).isNotEmpty) ...[
          Text(
            '${contact.name} was added automatically via a batch that '
            'you were both invited from. You will be automatically '
            'connected in a moment. You can already go to the circle '
            'settings to decide what to share with ${contact.name} and '
            'others joining via that batch.',
          ),
        ] else if (showSharingInitializing(contact.dhtConnection)) ...[
          const Text(
            'Please wait a moment until sharing options are initialized.',
          ),
          const SizedBox(height: 4),
          const Center(child: CircularProgressIndicator()),
        ] else if (showSharingOffer(contact))
          ProfileBasedSharingWidget(contact)
        else if (showDirectSharing(contact) &&
            contact.dhtConnection is DhtConnectionInitialized &&
            contact.connectionCrypto is CryptoInitializedSymmetric)
          DirectSharingWidget(
            contact,
            contact.dhtConnection as DhtConnectionInitialized,
            contact.connectionCrypto as CryptoInitializedSymmetric,
          )
        else
          const Text(
            'Something unexpected happened, please reach out to the '
            'Reunicorn team with information about how you got here.',
          ),
        const SizedBox(height: 8),
      ],
    ),
  );
}
