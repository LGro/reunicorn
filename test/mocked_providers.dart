// Copyright 2024 - 2026 The Reunicorn Authors. All rights reserved.
// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:math';
import 'dart:typed_data';

import 'package:reunicorn/data/models/models.dart';
import 'package:veilid_support/veilid_support.dart';

const dummyAppUserName = 'App User Name';

Uint8List randomUint8List(int length) {
  final random = Random.secure();
  return Uint8List.fromList(List.generate(length, (_) => random.nextInt(256)));
}

SharedSecret fakePsk(int i) => SharedSecret.fromString(
  [
    'VLD0:',
    BareSharedSecret.fromBytes(
      Uint8List.fromList(List.filled(32, i)),
    ).toString(),
  ].join(),
);

RecordKey fakeDhtRecordKey([int? i]) => RecordKey(
  opaque: OpaqueRecordKey(
    kind: cryptoKindVLD0,
    value: (i == null)
        ? BareOpaqueRecordKey.fromBytes(randomUint8List(32))
        : BareOpaqueRecordKey.fromBytes(Uint8List.fromList(List.filled(32, i))),
  ),
  encryptionKey: fakePsk(i ?? 0),
);

KeyPair fakeKeyPair([int pub = 0, int sec = 1]) => KeyPair.fromBareKeyPair(
  cryptoKindVLD0,
  BareKeyPair(
    key: BarePublicKey.fromBytes(Uint8List.fromList(List.filled(32, pub))),
    secret: BareSecretKey.fromBytes(Uint8List.fromList(List.filled(32, sec))),
  ),
);

final minimalBaseContact = CoagContact(
  coagContactId: 'dummy-id',
  name: 'dummy',
  myIdentity: fakeKeyPair(1000),
  myIntroductionKeyPair: fakeKeyPair(2000),
  dhtConnection: DhtConnectionState.invited(
    recordKeyThemSharing: fakeDhtRecordKey(),
  ),
  connectionCrypto: CryptoState.symmetric(
    sharedSecret: fakePsk(3),
    accountVod: '',
  ),
);
