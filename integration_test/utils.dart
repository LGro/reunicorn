// Copyright 2024 - 2026 The Reunicorn Authors. All rights reserved.
// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:math';
import 'dart:typed_data';
import 'dart:ui';

import 'package:reunicorn/data/services/dht/veilid_dht.dart';
import 'package:reunicorn/data/utils.dart';
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
      return;
    } on Exception {}
    await Future<void>.delayed(const Duration(milliseconds: 100));
  }
  await callable();
}

class MockDht implements BaseDht {
  final _storage = <RecordKey, Map<int, Uint8List>>{};
  final _watchCallbacks = <RecordKey, VoidCallback>{};
  final _dhtConnections = <MockDht>[];

  bool useVeilidKeyPairWriter;

  MockDht({this.useVeilidKeyPairWriter = false});

  void connect(MockDht dht) {
    _dhtConnections.add(dht);
  }

  @override
  Future<(RecordKey, KeyPair)> create() async {
    final recordSeed = Random.secure().nextInt(2048);
    final key = fakeDhtRecordKey(recordSeed);
    final writer = useVeilidKeyPairWriter
        ? await generateKeyPairBest()
        : fakeKeyPair(recordSeed, recordSeed + 1000);
    print('DHT create ${key.toString().substring(0, 12)}');
    return (key, writer);
  }

  @override
  Future<void> write(
    RecordKey key,
    KeyPair writer,
    Uint8List value, {
    int numChunks = 32,
    int chunkOffset = 0,
    bool local = true,
  }) async {
    print('DHT write ${key.toString().substring(0, 12)}');
    if (_storage.containsKey(key)) {
      _storage[key]![chunkOffset] = value;
    } else {
      _storage[key] = {chunkOffset: value};
    }
    if (local) {
      Future.wait(
        _dhtConnections.map(
          (dht) => dht.write(
            key,
            writer,
            value,
            numChunks: numChunks,
            chunkOffset: chunkOffset,
            local: false,
          ),
        ),
      );
    }
    if (!local && _watchCallbacks.containsKey(key)) {
      _watchCallbacks[key]!();
    }
  }

  @override
  Future<Uint8List?> read(
    RecordKey key, {
    int numChunks = 32,
    int chunkOffset = 0,
    bool local = false,
  }) async {
    print('DHT read ${key.toString().substring(0, 12)}');
    return _storage[key]?[chunkOffset];
  }

  @override
  Future<bool> watch(RecordKey key, VoidCallback callback) async {
    if (!_watchCallbacks.containsKey(key)) {
      print('DHT watch ${key.toString().substring(0, 12)}');
      _watchCallbacks[key] = callback;
    }
    return true;
  }
}
