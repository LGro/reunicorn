// Copyright 2025 The Reunicorn Authors. All rights reserved.
// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:async';

import '../../models/utils.dart';
import 'base.dart';

class MemoryStorage<T extends JsonEncodable> extends Storage<T> {
  final _memory = <String, T>{};
  final _changeEventStreamController =
      StreamController<StorageEvent<T>>.broadcast();
  final _getEventStreamController = StreamController<T>.broadcast();
  var _allAvailable = false;

  @override
  Stream<StorageEvent<T>> get changeEvents =>
      _changeEventStreamController.stream.asBroadcastStream();

  @override
  Stream<T> get getEvents =>
      _getEventStreamController.stream.asBroadcastStream();

  bool get allAvailable => _allAvailable;

  @override
  Future<void> set(String key, T value) async {
    // TODO: This only works reliably if initially getAll has been called and
    // all have been admitted to memory; is this the reason we need to make this
    // subclass sqlite instead of the current way around?
    final existing = _memory[key];
    _memory[key] = value;
    if (existing != value) {
      _changeEventStreamController.add(StorageEvent.set(existing, value));
    }
  }

  @override
  Future<T?> get(String key) async {
    final value = _memory[key];
    if (value != null) {
      _getEventStreamController.add(value);
    }
    return value;
  }

  @override
  Future<Map<String, T>> getAll() async {
    // TODO: Benchmark how much this slows things down, could be moved to unawaited async
    for (final value in _memory.values) {
      _getEventStreamController.add(value);
    }
    return {..._memory};
  }

  @override
  Future<void> delete(String key) async {
    final removed = _memory.remove(key);
    if (removed != null) {
      _changeEventStreamController.add(StorageEvent.delete(removed));
    }
  }

  void addToMemory(String key, T value) => _memory[key] = value;

  void addAllToMemory(Map<String, T> all) {
    _memory.addAll(all);
    _allAvailable = true;
  }
}
