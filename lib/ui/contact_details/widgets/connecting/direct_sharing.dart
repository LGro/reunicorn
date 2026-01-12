// Copyright 2025 - 2026 The Reunicorn Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../data/models/models.dart';
import '../../../utils.dart';

class DirectSharingWidget extends StatelessWidget {
  late final Uri _uri;
  late final String _contactName;

  DirectSharingWidget(
    CoagContact contact,
    DhtConnectionInitialized dhtConnection,
    CryptoInitializedSymmetric connectionCrypto, {
    super.key,
  }) {
    _contactName = contact.name;
    _uri = DirectSharingInvite(
      contact
              .profileSharingStatus
              .sharedProfile
              ?.details
              .names
              .values
              .firstOrNull ??
          '???',
      dhtConnection.recordKeyMeSharing,
      connectionCrypto.initialSharedSecret,
    ).uri;
  }

  @override
  Widget build(BuildContext context) => Column(
    children: [
      const SizedBox(height: 4),
      // TODO: Only show share back button when receiving key and psk but not writer are set i.e. is receiving updates and has share back settings
      TextButton(
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(Icons.qr_code),
            SizedBox(width: 8),
            Text('Show them this QR code'),
            SizedBox(width: 4),
          ],
        ),
        onPressed: () => showDialog<void>(
          context: context,
          builder: (_) => AlertDialog(
            titlePadding: const EdgeInsets.only(left: 16, right: 16, top: 16),
            title: Center(child: Text('Show to $_contactName')),
            // shape: const RoundedRectangleBorder(),
            content: SizedBox(
              height: 200,
              width: 200,
              child: Center(
                child: QrImageView(
                  data: _uri.toString(),
                  backgroundColor: Colors.white,
                  size: 200,
                ),
              ),
            ),
          ),
        ),
      ),
      // TextButton(
      //   child: const Row(
      //       mainAxisSize: MainAxisSize.min,
      //       children: <Widget>[
      //         Icon(Icons.share),
      //         SizedBox(width: 8),
      //         Text('Paste their profile link'),
      //         SizedBox(width: 4),
      //       ]),
      //       // TODO: Paste from clipboard and generate invite text to share
      //   onPressed: () {},
      // ),
      TextButton(
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(Icons.share),
            SizedBox(width: 8),
            Text('Share link via trusted channel'),
            SizedBox(width: 4),
          ],
        ),
        // TODO: Add warning dialogue that the link contains a secret and should only be transmitted via an end to end encrypted messenger
        onPressed: () => SharePlus.instance.share(
          ShareParams(
            text:
                "Hi $_contactName, I'd like to share with you: $_uri\n"
                "Keep this link a secret, it's just for you.",
          ),
        ),
      ),
      const SizedBox(height: 4),
      // TODO: Link "create an invite" to the corresponding page, and maybe also "contact page" to contacts list?
      Text(
        'This QR code and link are specifically for $_contactName. '
        'If you want to connect with someone else, go to their '
        'respective contact details or create a new invite.',
      ),
    ],
  );
}
