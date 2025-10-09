/// General-purpose versioned migration codec for protobufs
library;

import 'dart:typed_data';

import 'package:freezed_annotation/freezed_annotation.dart';

import '../veilid_support.dart';

/// A single json migration for a single version
typedef JsonMigration = Uint8List Function(Uint8List);

/// Evolves a data format over time
abstract class JsonMigrationCodec<T> implements MigrationCodec<T> {
  /// List of migrations from one version to the next
  @mustBeOverridden
  List<JsonMigration> get migrations;

  /// Decoder for the most recent version
  @mustBeOverridden
  T fromJson(dynamic json);

  /// Detector for starting migration
  @mustBeOverridden
  int detectVersion(Uint8List data);

  /// Encode the value in its newest format
  @nonVirtual
  @override
  Uint8List toBytes(T value) => jsonEncodeBytes(value);

  /// Read any older supported format and upgrade it
  /// Returns a status if the data has changed format
  @nonVirtual
  @override
  MigratedValue<T> fromBytes(Uint8List data) {
    final originalVersion = detectVersion(data);
    final newestVersion = migrations.length;

    // Run through all migrations
    var migrated = false;
    for (
      var currentVersion = originalVersion;
      currentVersion < newestVersion;
      currentVersion += 1
    ) {
      data = migrations[currentVersion](data);
      migrated = true;
    }

    // Decode the fully migrated version
    final value = jsonDecodeBytes(fromJson, data);

    return MigratedValue(value: value, migrated: migrated);
  }
}
