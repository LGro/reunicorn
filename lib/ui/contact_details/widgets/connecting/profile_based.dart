// Copyright 2025 - 2026 The Reunicorn Authors. All rights reserved.
// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../data/models/models.dart';
import '../../../utils.dart';

class ProfileBasedSharingWidget extends StatelessWidget {
  late final Uri _uri;

  ProfileBasedSharingWidget(CoagContact contact, {super.key}) {
    // _uri = ProfileBasedInvite(
    //   contact
    //           .profileSharingStatus
    //           .sharedProfile
    //           ?.details
    //           .names
    //           .values
    //           .firstOrNull ??
    //       '???',
    //   // TODO(LGro): Eliminate risk of null check operators
    //   contact.dhtConnection!.recordKeyMeSharingOrNull!,
    //   contact.connectionCrypto.myKeyPairOrNull!.key,
    // ).uri;
  }

  @override
  Widget build(BuildContext context) => SizedBox();
  //  Column(
  //   children: [
  //     const Text(
  //       'You added them from their profile link. To finish '
  //       'connecting, send them this link via your favorite messenger:',
  //     ),
  //     Row(
  //       children: [
  //         Expanded(
  //           child: Text(
  //             _uri.toString(),
  //             maxLines: 1,
  //             softWrap: false,
  //             overflow: TextOverflow.ellipsis,
  //           ),
  //         ),
  //         IconButton(
  //           onPressed: () => SharePlus.instance.share(ShareParams(uri: _uri)),
  //           icon: const Icon(Icons.copy),
  //         ),
  //       ],
  //     ),
  //   ],
  // );
}
