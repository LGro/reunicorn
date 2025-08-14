// Copyright 2024 - 2025 The Reunicorn Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

import 'dart:typed_data';

import 'package:reunicorn/data/models/coag_contact.dart';
import 'package:veilid/veilid.dart';

final dummyKeyPair = TypedKeyPair(
  kind: cryptoKindVLD0,
  key: FixedEncodedString43.fromBytes(Uint8List(32)),
  secret: FixedEncodedString43.fromBytes(Uint8List(32)),
);

final dummyBaseContact = CoagContact(
  coagContactId: 'dummy-id',
  name: 'dummy',
  myIdentity: dummyKeyPair,
  myIntroductionKeyPair: dummyKeyPair,
  dhtSettings: const DhtSettings(),
);
