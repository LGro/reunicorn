// Copyright 2026 The Reunicorn Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

import 'dart:convert';
import 'dart:typed_data';

import 'package:reunicorn/data/models/models.dart';
import 'package:reunicorn/data/services/dht/encrypted_communication.dart';
import 'package:test/test.dart';

import '../../../mocked_providers.dart';

void main() {
  group('key rotation', () {
    test('symmetric direct sharing to first asymmetric rotation', () async {
      // A initializes records for both, preparing for direct invite, already
      // offering a public key for a fast transition to asymmetric cryptography
      final initialStateA =
          CryptoState.initializedSymmetric(
                initialSharedSecret: fakePsk(0),
                myNextKeyPair: fakeKeyPair(100, 101),
              )
              as CryptoInitializedSymmetric;

      // B received direct invite out of band and read share back pub key
      final initialStateB = CryptoState.establishedSymmetric(
        initialSharedSecret: initialStateA.initialSharedSecret,
        theirNextPublicKey: initialStateA.myNextKeyPair.key,
        myNextKeyPair: fakeKeyPair(200, 202),
      );

      // B writes symmetrically encrypted, including their next public key
      // A reads and learns about B's next public key
      final stateA1 = await evolveCryptoState(
        initialStateA,
        shareBackPubKey: initialStateB.myNextKeyPair.key,
        usedPublicKey: null,
        usedKeyPair: null,
        ackHandshakeComplete: true,
        keyPairGenerator: () async => fakeKeyPair(300, 303),
      );
      expect(
        stateA1,
        CryptoState.establishedSymmetric(
          // initial info unchanged
          initialSharedSecret: initialStateA.initialSharedSecret,
          myNextKeyPair: initialStateA.myNextKeyPair,
          // new info, now ready for asymmetric encryption
          theirNextPublicKey: initialStateB.myNextKeyPair.key,
        ),
      );

      // A writes using the available public private key crypto
      // B reads for the first time using asymmetric encryption
      final stateB1 = await evolveCryptoState(
        initialStateB,
        shareBackPubKey: stateA1.myNextKeyPair.key,
        usedPublicKey: stateA1.myNextKeyPair.key,
        usedKeyPair: initialStateB.myNextKeyPair,
        ackHandshakeComplete: true,
        keyPairGenerator: () async => fakeKeyPair(400, 404),
      );
      stateB1 as CryptoInitializedAsymmetric;
      expect(stateB1.myKeyPair, initialStateB.myNextKeyPair);
      expect(stateB1.myNextKeyPair, fakeKeyPair(400, 404));
      expect(stateB1.theirNextPublicKey, stateA1.myNextKeyPair.key);

      // B writes using the available public private key crypto
      // A reads for the first time using asymmetric encryption
      final stateA2 = await evolveCryptoState(
        stateA1,
        shareBackPubKey: stateB1.myNextKeyPair.key,
        usedPublicKey: stateB1.myNextKeyPair.key,
        usedKeyPair: stateA1.myNextKeyPair,
        ackHandshakeComplete: true,
        keyPairGenerator: () async => fakeKeyPair(500, 505),
      );
      stateA2 as CryptoInitializedAsymmetric;
      expect(stateA2.myKeyPair, stateA1.myNextKeyPair);
      expect(stateA2.myNextKeyPair, fakeKeyPair(500, 505));
      expect(stateA2.theirNextPublicKey, stateB1.myNextKeyPair.key);

      // A writes, B reads, both using asymmetric crypto
      final stateB2 = await evolveCryptoState(
        stateB1,
        shareBackPubKey: stateA2.myNextKeyPair.key,
        usedPublicKey: stateA1.myNextKeyPair.key,
        usedKeyPair: stateB1.myNextKeyPair,
        ackHandshakeComplete: true,
        keyPairGenerator: () async => fakeKeyPair(600, 606),
      );
      stateB2 as CryptoEstablishedAsymmetric;
      expect(stateB2.myKeyPair, stateB1.myNextKeyPair);
      expect(stateB2.myNextKeyPair, fakeKeyPair(600, 606));
      expect(stateB2.theirPublicKey, stateA1.myNextKeyPair.key);
      expect(stateB2.theirNextPublicKey, stateA2.myNextKeyPair.key);

      // B writes, A reads, both using asymmetric crypto
      final stateA3 = await evolveCryptoState(
        stateA2,
        shareBackPubKey: stateB2.myNextKeyPair.key,
        usedPublicKey: stateB1.myNextKeyPair.key,
        usedKeyPair: stateA1.myNextKeyPair,
        ackHandshakeComplete: true,
        keyPairGenerator: () async => fakeKeyPair(700, 707),
      );
      stateA3 as CryptoEstablishedAsymmetric;
      expect(stateA3.myKeyPair, stateA1.myNextKeyPair);
      expect(stateA3.myNextKeyPair, fakeKeyPair(500, 505));
      expect(stateA3.theirPublicKey, stateB1.myNextKeyPair.key);
      expect(stateA3.theirNextPublicKey, stateB2.myNextKeyPair.key);
    });
  });

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

    test('encryption metadata max size matches byteLength', () {
      final m = EncryptionMetaData(
        shareBackDHTKey: fakeDhtRecordKey(),
        shareBackDHTWriter: fakeKeyPair(),
        shareBackPubKey: fakeKeyPair().key,
        ackHandshakeComplete: false,
      );
      final bytes = Uint8List.fromList(utf8.encode(jsonEncode(m.toJson())));
      expect(bytes.length, equals(EncryptionMetaData.byteLength));
    });
  });
}
