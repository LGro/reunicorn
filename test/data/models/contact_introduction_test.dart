// Copyright 2024 - 2025 The Reunicorn Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:reunicorn/data/models/contact_introduction.dart';

import '../../mocked_providers.dart';
import 'utils.dart';

void main() {
  test('00 save current json schema version', () async {
    final contactIntro = ContactIntroduction(
      otherName: 'other name',
      otherPublicKey: fakeKeyPair(1).key,
      publicKey: fakeKeyPair(2).key,
      dhtRecordKeyReceiving: fakeDhtRecordKey(3),
      dhtRecordKeySharing: fakeDhtRecordKey(4),
      dhtWriterSharing: fakeKeyPair(5, 6),
    );

    await saveJsonModelAsset(contactIntro);
  });

  test('test loading previous json schema versions', () async {
    for (final jsonEntry
        in loadAllPreviousSchemaVersionJsonFiles<ContactIntroduction>()
            .entries) {
      final jsonData =
          await jsonDecode(jsonEntry.value) as Map<String, dynamic>;
      ContactIntroduction.fromJson(jsonData);
    }
  });
}
