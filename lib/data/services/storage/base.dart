// Copyright 2025 The Reunicorn Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

import 'dart:async';

import 'package:freezed_annotation/freezed_annotation.dart';
import '../../models/utils.dart';

part 'base.freezed.dart';

@freezed
sealed class StorageEvent<T> with _$StorageEvent<T> {
  const factory StorageEvent.set(T? oldValue, T newValue) = SetEvent;
  const factory StorageEvent.delete(T value) = DeleteEvent;
}

abstract class Storage<T extends JsonEncodable> {
  Future<void> set(String key, T value);
  Future<T?> get(String key);
  Future<Map<String, T>> getAll();
  Future<void> delete(String key);
  Stream<StorageEvent<T>> get changeEvents;
  Stream<T> get getEvents;
}
