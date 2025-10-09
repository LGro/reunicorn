import 'dart:typed_data';

import '../../../veilid_support.dart';

////////////////////////////////////////////////////////////////////////////
// Insert/Remove interface
abstract class DHTInsertRemove {
  /// Try to insert an item as position 'pos' of the DHT container.
  /// Return if the element was successfully inserted
  /// Throws DHTExceptionTryAgain if the state changed before the element could
  /// be inserted or a newer value was found on the network.
  /// Throws an IndexError if the position removed exceeds the length of
  /// the container.
  /// Throws a StateError if the container exceeds its maximum size.
  Future<void> insert(int pos, Uint8List value);

  /// Try to insert items at position 'pos' of the DHT container.
  /// Return if the elements were successfully inserted
  /// Throws DHTExceptionTryAgain if the state changed before the elements could
  /// be inserted or a newer value was found on the network.
  /// Throws an IndexError if the position removed exceeds the length of
  /// the container.
  /// Throws a StateError if the container exceeds its maximum size.
  Future<void> insertAll(int pos, List<Uint8List> values);

  /// Remove an item at position 'pos' in the DHT container.
  /// If the remove was successful this returns:
  ///   * outValue will return the prior contents of the element
  /// Throws an IndexError if the position removed exceeds the length of
  /// the container.
  Future<void> remove(int pos, {Output<Uint8List>? output});
}

extension DHTInsertRemoveExt on DHTInsertRemove {
  /// Like insert but also encodes the input value as JSON
  Future<void> insertJson<T>(int pos, T newValue) =>
      insert(pos, jsonEncodeBytes(newValue));

  /// Convenience function:
  /// Like insert but also migrates the input value
  Future<void> insertMigrated<T>(
    MigrationCodec<T> migrationCodec,
    int pos,
    T newValue,
  ) => insert(pos, migrationCodec.toBytes(newValue));

  /// Convenience function:
  /// Like insertAll but also encodes the input values as JSON
  Future<void> insertAllJson<T>(int pos, List<T> values) =>
      insertAll(pos, values.map(jsonEncodeBytes).toList());

  /// Convenience function:
  /// Like insertAll but also migrates the input values
  Future<void> insertAllMigrated<T>(
    MigrationCodec<T> migrationCodec,
    int pos,
    List<T> values,
  ) => insertAll(pos, values.map((x) => migrationCodec.toBytes(x)).toList());

  /// Convenience function:
  /// Like remove but also parses the returned element as JSON
  Future<void> removeJson<T>(
    T Function(dynamic) fromJson,
    int pos, {
    Output<T>? output,
  }) async {
    final outValueBytes = output == null ? null : Output<Uint8List>();
    await remove(pos, output: outValueBytes);
    output.mapSave(outValueBytes, (b) => jsonDecodeBytes(fromJson, b));
  }

  /// Convenience function:
  /// Like remove but also migrates the returned element
  Future<void> removeMigrated<T>(
    MigrationCodec<T> migrationCodec,
    int pos, {
    Output<MigratedValue<T>>? output,
  }) async {
    final outValueBytes = output == null ? null : Output<Uint8List>();
    await remove(pos, output: outValueBytes);
    output.mapSave(outValueBytes, migrationCodec.fromBytes);
  }
}
