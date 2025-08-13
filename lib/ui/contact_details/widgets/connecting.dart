// Copyright 2024 - 2025 The Reunicorn Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';

import '../../../data/models/coag_contact.dart';
import '../../utils.dart';

Widget _qrCodeButton(
  BuildContext context, {
  required String buttonText,
  required String alertTitle,
  required String qrCodeData,
}) =>
    TextButton(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const Icon(Icons.qr_code),
          const SizedBox(width: 8),
          Text(buttonText),
          const SizedBox(width: 4),
        ],
      ),
      onPressed: () async => showDialog<void>(
        context: context,
        builder: (_) => AlertDialog(
          titlePadding: const EdgeInsets.only(left: 16, right: 16, top: 16),
          title: Center(child: Text(alertTitle)),
          // shape: const RoundedRectangleBorder(),
          content: SizedBox(
            height: 200,
            width: 200,
            child: Center(
              child: QrImageView(
                data: qrCodeData,
                backgroundColor: Colors.white,
                size: 200,
              ),
            ),
          ),
        ),
      ),
    );

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
            if (showSharingInitializing(contact) &&
                circles.keys
                    .where((cId) => cId.startsWith('VLD'))
                    .isNotEmpty) ...[
              Text(
                '${contact.name} was added automatically via a batch that '
                'you were both invited from. You will be automatically '
                'connected in a moment. You can already go to the circle '
                'settings to decide what to share with ${contact.name} and '
                'others joining via that batch.',
              ),
            ] else if (showSharingInitializing(contact)) ...[
              const Text(
                'Please wait a moment until sharing options are initialized.',
              ),
              const SizedBox(height: 4),
              const Center(child: CircularProgressIndicator()),
            ] else if (showSharingOffer(contact)) ...[
              const Text(
                'You added them from their profile link. To finish '
                'connecting, send them this link via your favorite messenger:',
              ),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      profileBasedOfferUrl(
                        contact.sharedProfile?.details.names.values
                                .firstOrNull ??
                            '???',
                        contact.dhtSettings.recordKeyMeSharing!,
                        contact.dhtSettings.myKeyPair!.key,
                      ).toString(),
                      maxLines: 1,
                      softWrap: false,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    onPressed: () async => SharePlus.instance.share(
                      ShareParams(
                        uri: profileBasedOfferUrl(
                          contact.sharedProfile?.details.names.values
                                  .firstOrNull ??
                              '???',
                          contact.dhtSettings.recordKeyMeSharing!,
                          contact.dhtSettings.myKeyPair!.key,
                        ),
                      ),
                    ),
                    icon: const Icon(Icons.copy),
                  ),
                ],
              ),
            ] else if (showDirectSharing(contact)) ...[
              const SizedBox(height: 4),
              // TODO: Only show share back button when receiving key and psk but not writer are set i.e. is receiving updates and has share back settings
              _qrCodeButton(
                context,
                buttonText: 'Show them this QR code',
                alertTitle: 'Show to ${contact.name}',
                qrCodeData: directSharingUrl(
                  contact.sharedProfile?.details.names.values.firstOrNull ??
                      '???',
                  contact.dhtSettings.recordKeyMeSharing!,
                  contact.dhtSettings.initialSecret!,
                ).toString(),
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
                onPressed: () async => SharePlus.instance.share(
                  ShareParams(
                    text: "Hi ${contact.name}, I'd like to share with you: "
                        '${directSharingUrl(contact.sharedProfile?.details.names.values.firstOrNull ?? '???', contact.dhtSettings.recordKeyMeSharing!, contact.dhtSettings.initialSecret!)}\n'
                        "Keep this link a secret, it's just for you.",
                  ),
                ),
              ),
              const SizedBox(height: 4),
              // TODO: Link "create an invite" to the corresponding page, and maybe also "contact page" to contacts list?
              Text(
                'This QR code and link are specifically for ${contact.name}. '
                'If you want to connect with someone else, go to their '
                'respective contact details or create a new invite.',
              ),
            ] else
              const Text(
                'Something unexpected happened, please reach out to the '
                'Reunicorn team with information about how you got here.',
              ),
            const SizedBox(height: 8),
          ],
        ),
      );
}
