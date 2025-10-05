// Copyright 2024 - 2025 The Reunicorn Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:reunicorn/data/models/emoji_sas.dart';
import 'package:reunicorn/veilid_init.dart';

import '../test/utils.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    await AppGlobalInit.initialize();
  });

  // TODO: This could be a simple unit test, does not need to run on device
  // test('Emoji alphabet remains consistently sorted', () {
  //   final sortedAlphabet = sasEmojiAlphabet.sorted();
  //   expect(sasEmojiAlphabet, sortedAlphabet,
  //       reason: 'If the order changes, emoji verification is at risk.');
  // });

  test('Shared secret verification hash emoji validation', () async {
    final myKeyPair = dummyKeyPair;
    final theirPublicKey = dummyKeyPair.key;

    final hash = await sharedSecretVerificationHash(myKeyPair, theirPublicKey);
    expect(hash.decode(), hasLength(32));

    final emojiVerification = sasEmojisFromHash(hash);
    // The expected value should be showing as emoji - otherwise check your font
    expect(emojiVerification.map((e) => e.emoji).join(), '⚽👍🍎🦋📁🔨📌');
  });
}
