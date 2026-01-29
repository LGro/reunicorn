// Copyright 2025 - 2026 The Reunicorn Authors. All rights reserved.
// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:async';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../../../debug_log.dart';
import '../../../tools/tools.dart';
import '../../utils.dart';
import 'base.dart';

Future<Database> _getDatabase(String name) async => openDatabase(
  // TODO: Escape name?
  join(await getDatabasesPath(), '$name.db'),
  onCreate: (db, version) async {
    await db.execute('CREATE TABLE data(id TEXT PRIMARY KEY, json TEXT)');
  },
  version: 1,
);

// TODO: Add in-memory caching
class SqliteStorage<T> extends Storage<T> {
  final String _name;
  final String Function(T) _toJson;
  final Future<T> Function(String) _fromJson;
  final _changeEventStreamController =
      StreamController<StorageEvent<T>>.broadcast();
  final _getEventStreamController = StreamController<T>.broadcast();
  Database? _db;

  SqliteStorage(this._name, this._toJson, this._fromJson);

  Future<Database> _getDb() async {
    // Only open the database if it isn't already open
    _db ??= await _getDatabase(_name);
    return _db!;
  }

  @override
  Stream<StorageEvent<T>> get changeEvents =>
      _changeEventStreamController.stream.asBroadcastStream();

  @override
  Stream<T> get getEvents =>
      _getEventStreamController.stream.asBroadcastStream();

  @override
  Future<void> set(String key, T value) async {
    log.debug('RCRN-S SET $T $key');
    final json = _toJson(value);
    final db = await _getDb();
    final existing = await get(key);
    if (existing == null) {
      await db.insert('data', {'json': json, 'id': key});
    } else {
      await db.update(
        'data',
        {'json': json},
        where: '"id" = ?',
        whereArgs: [key],
      );
    }
    if (existing != value) {
      _changeEventStreamController.add(StorageEvent.set(existing, value));
    }
  }

  @override
  Future<T?> get(String key) async {
    log.debug('RCRN-S GET $T $key');
    final db = await _getDb();
    final result = await db.query(
      'data',
      columns: ['json'],
      where: '"id" = ?',
      whereArgs: [key],
      limit: 1,
    );

    try {
      final value = result.isEmpty
          ? null
          : await _fromJson(result[0]['json']! as String);
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
    final db = await _getDb();
    final resultsRaw = await db.query('data', columns: ['id', 'json']);

    final results = <String, T>{};
    for (final r in resultsRaw) {
      late String id;
      late String json;
      try {
        id = r['id']! as String;
        json = r['json']! as String;
        results[id] = await _fromJson(json);
      } catch (e) {
        DebugLogger().log(
          'Error getting $_name with $id: $e\n'
          '${replacePictureWithEmptyInJson(json)}',
        );
        // Return empty result to make sure we notice in the UI
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
        await _getDb().then(
          (db) => db.delete('data', where: '"id" = ?', whereArgs: [key]),
        );
        _changeEventStreamController.add(StorageEvent.delete(removed));
      }
    });
  }
}
