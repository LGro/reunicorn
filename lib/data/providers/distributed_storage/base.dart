// Copyright 2024 - 2025 The Reunicorn Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

import 'dart:typed_data';

import 'package:veilid/veilid.dart';

import '../../models/backup.dart';
import '../../models/coag_contact.dart';

abstract class DistributedStorage {
  /// Create an empty DHT record, return key and writer in string representation
  Future<(RecordKey, KeyPair)> createRecord({String? writer});

  /// Read DHT record for given key and secret, return decrypted content
  Future<(PublicKey?, KeyPair?, String?, Uint8List?)> readRecord({
    required RecordKey recordKey,
    required KeyPair keyPair,
    KeyPair? nextKeyPair,
    SharedSecret? psk,
    PublicKey? publicKey,
    PublicKey? nextPublicKey,
  });

  /// Encrypt the content with the given secret and write it to the DHT at key
  Future<void> updateRecord(
    CoagContactDHTSchema? sharedProfile,
    DhtSettings settings,
  );

  Future<void> watchRecord(
    String coagContactId,
    RecordKey key,
    Future<void> Function(String coagContactId, RecordKey key) onNetworkUpdate,
  );

  Future<CoagContact?> getContact(
    CoagContact contact, {
    Iterable<KeyPair> myMiscKeyPairs = const [],
    bool useLocalCache = false,
  });

  Future<void> updateBackupRecord(
    AccountBackup backup,
    RecordKey recordKey,
    KeyPair writer,
    SharedSecret secret,
  );

  Future<String?> readBackupRecord(
    RecordKey recordKey,
    SharedSecret secret,
  );
}
