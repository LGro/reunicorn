// Copyright 2024 - 2025 The Reunicorn Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:reunicorn/data/models/contact_introduction.dart';

import '../../mocked_providers.dart';
import '../utils.dart';

const jsonAssetDirectory = 'test/assets/models/contact_introduction';

void main() {
  test('save current json schema version', () async {
    final version = await readCurrentVersionFromPubspec();
    final file = File('$jsonAssetDirectory/$version.json');

    final contactIntro = ContactIntroduction(
      otherName: 'other name',
      otherPublicKey: fakeKeyPair(1).key,
      publicKey: fakeKeyPair(2).key,
      dhtRecordKeyReceiving: fakeDhtRecordKey(3),
      dhtRecordKeySharing: fakeDhtRecordKey(4),
      dhtWriterSharing: fakeKeyPair(5, 6),
    );

    final jsonString = json.encode(contactIntro.toJson());

    if (!loadAllPreviousSchemaVersionJsons(
      jsonAssetDirectory,
    ).values.toSet().contains(jsonString)) {
      await file.writeAsString(jsonString);
    }
  });

  test('test loading previous json schema versions', () async {
    for (final jsonEntry in loadAllPreviousSchemaVersionJsons(
      jsonAssetDirectory,
    ).entries) {
      try {
        final jsonData =
            await jsonDecode(jsonEntry.value) as Map<String, dynamic>;
        ContactIntroduction.fromJson(jsonData);
      } catch (e, stackTrace) {
        fail('Failed to deserialize ${jsonEntry.key}:\n$e\n$stackTrace');
      }
    }
  });
}
