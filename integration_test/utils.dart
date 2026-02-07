// Copyright 2024 - 2026 The Reunicorn Authors. All rights reserved.
// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:typed_data';
import 'dart:ui';

import 'package:reunicorn/data/services/dht/veilid_dht.dart';
import 'package:veilid/veilid.dart';

import '../test/mocked_providers.dart';

/// Veilid bootstrap URL for integration tests
const veilidBootstrapUrl = 'bootstrap-v1.veilid.net';

Future<void> retryUntilTimeout(
  int timeoutSeconds,
  Future<void> Function() callable,
) async {
  final end = DateTime.now().add(Duration(seconds: timeoutSeconds));
  while (DateTime.now().isBefore(end)) {
    try {
      await callable();
    } on Exception {}
    await Future<void>.delayed(const Duration(milliseconds: 100));
  }
  await callable();
}

class MockDht implements BaseDht {
  final _storage = <RecordKey, Map<int, Uint8List>>{};
  final _watchCallbacks = <RecordKey, VoidCallback>{};
  var _recordCounter = 0;

  @override
  Future<(RecordKey, KeyPair)> create() async {
    _recordCounter = _recordCounter + 1;
    return (
      fakeDhtRecordKey(_recordCounter),
      fakeKeyPair(_recordCounter, _recordCounter + 1000),
    );
  }

  @override
  Future<void> write(
    RecordKey key,
    KeyPair writer,
    Uint8List value, {
    int numChunks = 32,
    int chunkOffset = 0,
  }) async {
    _storage[key]![chunkOffset] = value;
    if (_watchCallbacks.containsKey(key)) {
      _watchCallbacks[key]!();
    }
  }

  @override
  Future<Uint8List?> read(
    RecordKey key, {
    int numChunks = 32,
    int chunkOffset = 0,
    bool local = false,
  }) async => _storage[key]?[chunkOffset];

  @override
  Future<bool> watch(RecordKey key, VoidCallback callback) async {
    _watchCallbacks[key] = callback;
    return true;
  }
}
