// Copyright 2026 The Reunicorn Authors. All rights reserved.
// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:async';
import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_ce/hive.dart';
import 'package:reunicorn/config.dart';

import '../../../debug_log.dart';
import '../../../tools/tools.dart';
import '../../utils.dart';
import 'base.dart';

class HiveStorage<T> extends Storage<T> {
  final String _name;
  final String Function(T) _toJson;
  final Future<T> Function(String) _fromJson;
  final _changeEventStreamController =
      StreamController<StorageEvent<T>>.broadcast();
  final _getEventStreamController = StreamController<T>.broadcast();

  HiveStorage(this._name, this._toJson, this._fromJson);

  @override
  Stream<StorageEvent<T>> get changeEvents =>
      _changeEventStreamController.stream.asBroadcastStream();

  @override
  Stream<T> get getEvents =>
      _getEventStreamController.stream.asBroadcastStream();

  Future<Box<String>> _box() async {
    const secureStorage = FlutterSecureStorage();
    final key = await secureStorage.read(key: hiveSecretKeyName);
    if (key == null) {
      throw Exception('No hive secret key initialized.');
    }
    return Hive.openBox(
      _name,
      encryptionCipher: HiveAesCipher(base64Url.decode(key)),
    );
  }

  @override
  Future<void> set(String key, T value) async {
    log.debug('RCRN-S SET $T $key');
    final json = _toJson(value);
    final box = await _box();
    final existing = await box.get(key);
    if (existing != json) {
      await box.put(key, json);
      _changeEventStreamController.add(
        StorageEvent.set(
          (existing == null) ? null : await _fromJson(existing),
          value,
        ),
      );
    }
  }

  @override
  Future<T?> get(String key) async {
    log.debug('RCRN-S GET $T $key');
    final result = await _box().then((b) => b.get(key));

    try {
      final value = (result == null) ? null : await _fromJson(result);
      if (value != null) {
        _getEventStreamController.add(value);
      }
      return value;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<Map<String, T>> getAll() async {
    log.debug('RCRN-S GET $T ALL');
    final resultsRaw = await _box().then((b) => b.toMap());

    final results = <String, T>{};
    for (final entry in resultsRaw.entries) {
      try {
        final decoded = await _fromJson(entry.value);
        results[entry.key as String] = decoded;
      } catch (e) {
        DebugLogger().log(
          'Error getting $_name with ${entry.key}: $e\n'
          '${replacePictureWithEmptyInJson(entry.value)}',
        );
        return {};
      }
    }

    for (final value in results.values) {
      _getEventStreamController.add(value);
    }

    return results;
  }

  @override
  Future<void> delete(String key) async {
    log.debug('RCRN-S DEL $T $key');
    // Await lock to ensure nobody else is attempting to write
    await lock.synchronized(key, () async {
      final removed = await get(key);
      if (removed != null) {
        await _box().then((b) => b.delete(key));
        _changeEventStreamController.add(StorageEvent.delete(removed));
      }
    });
  }
}
