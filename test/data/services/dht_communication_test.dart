// Copyright 2026 The Reunicorn Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

import 'dart:convert';
import 'dart:typed_data';

import 'package:reunicorn/data/services/dht_communication.dart';
import 'package:test/test.dart';

import '../../mocked_providers.dart';

void main() {
  group('encryption meta-data', () {
    test('empty encryption meta-data (de-)serialization', () {
      const em = EncryptionMetaData();
      final em2 = EncryptionMetaData.fromBytes(em.toBytes()).$1;
      expect(em, em2, reason: 'meta-data does not match after deserialization');
    });

    test('full encryption meta-data (de-)serialization', () {
      final em = EncryptionMetaData(
        shareBackDHTKey: fakeDhtRecordKey(),
        shareBackDHTWriter: fakeKeyPair(),
        shareBackPubKey: fakeKeyPair().key,
        ackHandshakeComplete: true,
      );
      final em2 = EncryptionMetaData.fromBytes(em.toBytes()).$1;
      expect(em, em2, reason: 'meta-data does not match after deserialization');
    });

    test('encryption meta-data (de-)serialization with payload', () {
      const em = EncryptionMetaData();
      final pl = utf8.encode('Payload');
      final (em2, pl2) = EncryptionMetaData.fromBytes(
        Uint8List.fromList([...em.toBytes(), ...pl]),
      );
      expect(em, em2, reason: 'meta-data does not match after deserialization');
      expect(pl, pl2, reason: 'payload does not match after deserialization');
    });
  });
}
