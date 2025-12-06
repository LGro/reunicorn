// Copyright 2024 - 2025 The Reunicorn Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/models/coag_contact.dart';
import '../../../data/models/emoji_sas.dart';
import '../../../data/services/storage/base.dart';

class EmojiWrap extends StatelessWidget {
  const EmojiWrap({
    required this.items,
    super.key,
    this.baseEmojiFontSize = 32,
    this.baseLabelFontSize = 16,
    this.layoutGrowthMax = 1.35,
  });

  /// Provide (emoji, label) pairs.
  final Iterable<(String, String)> items;

  /// Base sizes that will scale with the user's textScaleFactor.
  final double baseEmojiFontSize;
  final double baseLabelFontSize;

  /// How much non-text layout grows as text scales (1.0–~1.6 is typical).
  final double layoutGrowthMax;

  @override
  Widget build(BuildContext context) {
    final textScaler = MediaQuery.textScalerOf(context);
    final textScaleFactor = MediaQuery.of(context).textScaleFactor;

    // Clamp the text scale for layout math only (text still scales fully).
    final clampedTSF = textScaleFactor.clamp(1.0, 2.5);
    final t = (clampedTSF - 1.0) / (2.5 - 1.0);

    // Smoothly scale non-text layout with a gentler curve.
    final layoutScale = ui.lerpDouble(1.0, layoutGrowthMax, t)!;

    final tileWidth = (90.0 * layoutScale).clamp(90.0, 220.0);
    final spacing = 16.0 * layoutScale;
    final runSpacing = 18.0 * layoutScale;
    final padding = 16.0 * layoutScale;

    return Container(
      padding: EdgeInsets.all(padding),
      child: Wrap(
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: spacing,
        runSpacing: runSpacing,
        children: [
          for (final (emoji, label) in items)
            Semantics(
              label: '$label $emoji',
              child: SizedBox(
                width: tileWidth,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      emoji,
                      textAlign: TextAlign.center,
                      textScaler: textScaler,
                      style: TextStyle(fontSize: baseEmojiFontSize, height: 1),
                    ),
                    SizedBox(height: 8.0 * layoutScale),
                    Text(
                      label,
                      textAlign: TextAlign.center,
                      softWrap: true,
                      overflow: TextOverflow.visible,
                      textScaler: textScaler,
                      style: TextStyle(
                        fontSize: baseLabelFontSize,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class EmojiSasVerification extends StatelessWidget {
  const EmojiSasVerification(this.contact, {super.key});

  final CoagContact contact;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      if (contact.dhtSettings.myKeyPair == null ||
          contact.dhtSettings.theirNextPublicKey == null)
        const SizedBox()
      else ...[
        Padding(
          padding: const EdgeInsets.only(left: 12, top: 8, right: 12),
          child: Text(
            'Connection Security Verification',
            textScaler: const TextScaler.linear(1.4),
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
        Card(
          child: Padding(
            padding: const EdgeInsets.only(
              left: 12,
              right: 12,
              top: 8,
              bottom: 12,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (contact.verified)
                  const Text('Your connection is verified as secure!')
                else ...[
                  Text(
                    'To verify your connection security, call or text '
                    '${contact.name} and ask if they see the same emoji in '
                    'the following order. If they match you can be more '
                    'confident that nobody snoops on what you share.',
                  ),
                  FutureBuilder<List<SasEmoji>>(
                    future: sharedSecretVerificationHash(
                      contact.dhtSettings.myKeyPair!,
                      contact.dhtSettings.theirNextPublicKey!,
                    ).then(sasEmojisFromHash),
                    builder: (context, emoji) => Center(
                      child: (!emoji.hasData)
                          ? const CircularProgressIndicator()
                          : EmojiWrap(
                              items: emoji.data!.map(
                                (e) => (e.emoji, e.description),
                              ),
                            ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      FilledButton.tonal(
                        onPressed: () {},
                        style: ButtonStyle(
                          backgroundColor: WidgetStatePropertyAll(
                            Theme.of(context).colorScheme.error,
                          ),
                        ),
                        child: Text(
                          'They differ',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onError,
                          ),
                        ),
                      ),
                      FilledButton.tonal(
                        // TODO: Move that out of the widget
                        onPressed: () =>
                            context.read<Storage<CoagContact>>().set(
                              contact.coagContactId,
                              contact.copyWith(verified: true),
                            ),
                        child: const Text('They match'),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    ],
  );
}
