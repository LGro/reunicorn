// Copyright 2024 - 2025 The Reunicorn Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:reunicorn/config.dart';
import 'package:reunicorn/veilid_init.dart';
import 'package:veilid_support/veilid_support.dart';

import 'utils.dart';

void main() {
  setUp(() async {
    await AppGlobalInit.initialize(veilidBootstrapUrl);
  });

  test(
    'DH derived symmetric key is consistent across derivations and parties',
    () async {
      final cryptoSystem = await DHTRecordPool.instance.veilid.getCryptoSystem(
        cryptoKindVLD0,
      );
      final kpA = await cryptoSystem.generateKeyPair();
      final kpB = await cryptoSystem.generateKeyPair();

      final secA1 = await cryptoSystem.generateSharedSecret(
        kpB.key,
        kpA.secret,
        utf8.encode('my_domain'),
      );
      final secA2 = await cryptoSystem.generateSharedSecret(
        kpB.key,
        kpA.secret,
        utf8.encode('my_domain'),
      );
      final secB = await cryptoSystem.generateSharedSecret(
        kpA.key,
        kpB.secret,
        utf8.encode('my_domain'),
      );
      expect(secA1 == secA2, true);
      expect(secA1 == secB, true);
    },
  );

  test('DH key exchange', () async {
    final cryptoSystem = await DHTRecordPool.instance.veilid.getCryptoSystem(
      cryptoKindVLD0,
    );
    final kpA = await cryptoSystem.generateKeyPair();
    final kpB = await cryptoSystem.generateKeyPair();

    final secA = await cryptoSystem.generateSharedSecret(
      kpB.key,
      kpA.secret,
      utf8.encode('my_domain'),
    );
    final secB = await cryptoSystem.generateSharedSecret(
      kpA.key,
      kpB.secret,
      utf8.encode('my_domain'),
    );

    final payload = utf8.encode('hello');
    final ce = await VeilidCryptoPrivate.fromSharedSecret(
      cryptoSystem.kind(),
      secA,
    );
    final encForB = await ce.encrypt(payload);

    final cd = await VeilidCryptoPrivate.fromSharedSecret(
      cryptoSystem.kind(),
      secB,
    );
    final dec = await cd.decrypt(encForB);
    expect(dec, payload);
  });

  test('Crypto member string lengths', () async {
    final cryptoSystem = await DHTRecordPool.instance.veilid.getCryptoSystem(
      cryptoKindVLD0,
    );
    final hash = await cryptoSystem.generateHash(Uint8List.fromList([1, 2, 3]));
    final keyPair = await cryptoSystem.generateKeyPair();
    final sharedSecret = await cryptoSystem.generateSharedSecret(
      keyPair.key,
      keyPair.secret,
      utf8.encode('domain'),
    );

    expect(hash.toString().length, veilidHashStringLength);
    expect(sharedSecret.toString().length, veilidSharedSecretStringLength);
  });
}
