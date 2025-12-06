// Copyright 2025 The Reunicorn Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

import 'dart:async';
import 'dart:convert';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../../../debug_log.dart';
import '../../models/utils.dart';
import 'memory.dart';

Future<Database> _getDatabase(String name) async => openDatabase(
  // TODO: Escape name?
  join(await getDatabasesPath(), '$name.db'),
  onCreate: (db, version) async {
    await db.execute('CREATE TABLE data(id TEXT PRIMARY KEY, json TEXT)');
  },
  version: 1,
);

class SqliteStorage<T extends JsonEncodable> extends MemoryStorage<T> {
  final String _name;
  final Future<T> Function(Map<String, dynamic>) _fromJson;

  SqliteStorage(this._name, this._fromJson);

  Future<Database> _getDb() => _getDatabase(_name);

  @override
  Future<void> set(String key, T value) async {
    await super.set(key, value);
    final json = jsonEncode(value.toJson());
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
  }

  @override
  Future<T?> get(String key) async {
    final cached = await super.get(key);
    if (cached != null) {
      return cached;
    }

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
          : await _fromJson(
              jsonDecode(result[0]['json']! as String) as Map<String, dynamic>,
            );
      if (value != null) {
        super.addToMemory(key, value);
      }
      return value;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<Map<String, T>> getAll() async {
    if (super.allAvailable) {
      return super.getAll();
    }

    final db = await _getDb();
    final resultsRaw = await db.query('data', columns: ['id', 'json']);

    final results = <String, T>{};
    for (final r in resultsRaw) {
      late String id;
      late String json;
      try {
        id = r['id']! as String;
        json = r['json']! as String;
        results[id] = await _fromJson(jsonDecode(json) as Map<String, dynamic>);
      } catch (e) {
        DebugLogger().log('Error getting $_name with $id: $e\n$json');
        // Return empty result to make sure we notice in the UI
        return {};
      }
    }

    super.addAllToMemory(results);

    return results;
  }

  @override
  Future<void> delete(String key) async {
    // NOTE: There is a case where if a value for the given key was never
    //       retrieved before, the stream event won't fire in super.
    //       One workaround would be to add it to memory before deleting.
    await super.delete(key);
    await _getDb().then(
      (db) => db.delete('data', where: '"id" = ?', whereArgs: [key]),
    );
  }
}
