// Copyright 2025 - 2026 The Reunicorn Authors. All rights reserved.
// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:async';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:synchronized/synchronized.dart';

part 'base.freezed.dart';

@freezed
sealed class StorageEvent<T> with _$StorageEvent<T> {
  const factory StorageEvent.set(T? oldValue, T newValue) = SetEvent;
  const factory StorageEvent.delete(T value) = DeleteEvent;
}

class KeyLockManager {
  final Map<String, _LockReference> _locks = {};

  Future<T> synchronized<T>(
    String key,
    Future<T> Function() computation,
  ) async {
    final ref = _locks.putIfAbsent(key, _LockReference.new);
    ref.count++;

    try {
      return await ref.lock.synchronized(computation);
    } finally {
      ref.count--;
      if (ref.count == 0) {
        _locks.remove(key);
      }
    }
  }
}

class _LockReference {
  final lock = Lock();
  // Keeps track of how many processes are waiting on this lock
  var count = 0;
}

abstract class Storage<T> {
  final lock = KeyLockManager();

  Future<void> set(String key, T value);
  Future<T?> get(String key);
  Future<Map<String, T>> getAll();
  Future<void> delete(String key);
  Stream<StorageEvent<T>> get changeEvents;
  Stream<T> get getEvents;
}
