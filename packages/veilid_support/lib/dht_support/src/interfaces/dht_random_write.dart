import 'dart:typed_data';

import '../../../veilid_support.dart';

////////////////////////////////////////////////////////////////////////////
// Writer interface
// ignore: one_member_abstracts
abstract class DHTRandomWrite {
  /// Try to set an item at position 'pos' of the DHT container.
  /// Returns the prior contents of the element, or null if there
  /// was no value yet.
  /// Throws DHTExceptionOutdated if a newer value exists on the network.
  /// Throws IndexError if the position is not within the length.
  Future<Uint8List?> writeItem(int pos, Uint8List newValue);
}

extension DHTRandomWriteExt on DHTRandomWrite {
  /// Convenience function:
  /// Like writeItem but also encodes the input value as JSON and parses the
  /// returned element as JSON
  Future<T?> writeItemJson<T>(
    T Function(dynamic) fromJson,
    int pos,
    T newValue,
  ) async {
    final oldBytes = await writeItem(pos, jsonEncodeBytes(newValue));
    if (oldBytes == null) {
      return null;
    }
    return jsonDecodeBytes(fromJson, oldBytes);
  }

  /// Convenience function:
  /// Like writeItem but also migrates the input value
  /// and migrates the returned element as well
  Future<MigratedValue<T>?> writeItemMigrated<T>(
    MigrationCodec<T> migrationCodec,
    int pos,
    T newValue,
  ) async {
    final oldBytes =
        await writeItem(pos, migrationCodec.toBytes(newValue));
    if (oldBytes == null) {
      return null;
    }
    return migrationCodec.fromBytes(oldBytes);
  }
}
