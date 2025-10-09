/// General-purpose versioned migration codec for protobufs
library;

import 'dart:typed_data';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:protobuf/protobuf.dart';

import '../veilid_support.dart';

/// A single protobuf migration for a single version
typedef ProtobufMigration = Uint8List Function(Uint8List);

/// Evolves a data format over time
abstract class ProtobufMigrationCodec<T extends GeneratedMessage>
    implements MigrationCodec<T> {
  /// List of migrations from one version to the next
  @mustBeOverridden
  List<ProtobufMigration> get migrations;

  /// Decoder for the most recent version
  @mustBeOverridden
  T fromBuffer(Uint8List data);

  /// Encode the value in its newest format
  @nonVirtual
  @override
  Uint8List toBytes(T value) {
    final out = BytesBuilder(copy: false);

    final header = Uint8List(5);
    ByteData.sublistView(header)
      // Add protobuf-safe tag
      ..setUint8(0, 0xFF)
      // Add version number
      ..setUint32(1, migrations.length);

    out
      ..add(header)
      ..add(value.writeToBuffer());

    return out.toBytes();
  }

  /// Read any older supported format and upgrade it
  /// Returns a status if the data has changed format
  @nonVirtual
  @override
  MigratedValue<T> fromBytes(Uint8List data) {
    final int originalVersion;
    final newestVersion = migrations.length;
    if (data.lengthInBytes < 5) {
      // Special case for version zero if no room for tag
      originalVersion = 0;
    } else {
      final header = ByteData.sublistView(data, 0, 5);
      final tag = header.getUint8(0);
      if (tag != 0xFF) {
        // Special case for tag not present
        originalVersion = 0;
      } else {
        // Get the version number and remove the tag
        originalVersion = header.getUint32(1);
        data = data.sublist(5);
      }
    }

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
    final value = fromBuffer(data);

    return MigratedValue(value: value, migrated: migrated);
  }
}
