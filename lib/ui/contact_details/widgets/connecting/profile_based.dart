// Copyright 2025 The Reunicorn Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../data/models/coag_contact.dart';
import '../../../utils.dart';

class ProfileBasedSharingWidget extends StatelessWidget {
  late final Uri _uri;

  ProfileBasedSharingWidget(CoagContact contact, {super.key}) {
    _uri = ProfileBasedInvite(
      contact.sharedProfile?.details.names.values.firstOrNull ?? '???',
      contact.dhtSettings.recordKeyMeSharing!,
      contact.dhtSettings.myKeyPair!.key,
    ).uri;
  }

  @override
  Widget build(BuildContext context) => Column(
    children: [
      const Text(
        'You added them from their profile link. To finish '
        'connecting, send them this link via your favorite messenger:',
      ),
      Row(
        children: [
          Expanded(
            child: Text(
              _uri.toString(),
              maxLines: 1,
              softWrap: false,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          IconButton(
            onPressed: () => SharePlus.instance.share(ShareParams(uri: _uri)),
            icon: const Icon(Icons.copy),
          ),
        ],
      ),
    ],
  );
}
