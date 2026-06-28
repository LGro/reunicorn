import 'dart:typed_data';

import 'package:meta/meta.dart';

import '../../../veilid_support.dart';

abstract interface class DHTRecordOperations<O> {
  /// Get a record's subkey value from this transaction
  /// Returns the most recent value data for this subkey or null if this subkey
  /// has not yet been written to.
  /// * 'refreshMode' determines whether or not to return a locally existing
  ///   value or always check the network
  /// * 'outSeqNum' optionally returns the sequence number of the value being
  ///   returned if one was returned.
  @mustBeOverridden
  Future<Uint8List?> getBytes({
    int subkey = -1,
    CryptoCodec? crypto,
    DHTRecordRefreshMode refreshMode = DHTRecordRefreshMode.cached,
    Output<int>? outSeqNum,
  });

  /// Attempt to write a byte buffer to a DHTTransaction record subkey
  /// If a newer value was found on the network, it is returned
  /// If the value was succesfully written, null is returned
  @mustBeOverridden
  Future<Uint8List?> tryWriteBytes(
    Uint8List newValue, {
    int subkey = -1,
    CryptoCodec? crypto,
    O? options,
    Output<int>? outSeqNum,
  });

  /// Builds options for eventual operations
  @mustBeOverridden
  O eventualOptions(KeyPair? writer);

  /// Return the inspection state of a set of subkeys of a record in
  /// the DHTTransaction.
  /// See Veilid's 'inspectDHTRecord' call for details on how this works
  @mustBeOverridden
  Future<DHTRecordReport> inspect({
    List<ValueSubkeyRange>? subkeys,
    DHTReportScope scope = DHTReportScope.local,
  });
}

mixin DefaultDHTRecordOperations<O> implements DHTRecordOperations<O> {
  /// Get a record's subkey value from this transaction
  /// Process the record returned with a JSON unmarshal function 'fromJson'.
  /// Returns the most recent value data for this subkey or null if this subkey
  /// has not yet been written to.
  /// * 'refreshMode' determines whether or not to return a locally existing
  ///   value or always check the network
  /// * 'outSeqNum' optionally returns the sequence number of the value being
  ///   returned if one was returned.
  Future<T?> getJson<T>(
    T Function(dynamic) fromJson, {
    int subkey = -1,
    CryptoCodec? crypto,
    DHTRecordRefreshMode refreshMode = DHTRecordRefreshMode.cached,
    Output<int>? outSeqNum,
  }) async {
    final data = await getBytes(
      subkey: subkey,
      crypto: crypto,
      refreshMode: refreshMode,
      outSeqNum: outSeqNum,
    );
    if (data == null) {
      return null;
    }
    return jsonDecodeBytes(fromJson, data);
  }

  /// Get a record's subkey value from this transaction
  /// Process the record returned with a migration codec
  /// Returns the most recent value data for this subkey or null if this subkey
  /// has not yet been written to.
  /// * 'refreshMode' determines whether or not to return a locally existing
  ///   value or always check the network
  /// * 'outSeqNum' optionally returns the sequence number of the value being
  ///   returned if one was returned.
  Future<T?> getMigrated<T>(
    MigrationCodec<T> migrationCodec, {
    int subkey = -1,
    CryptoCodec? crypto,
    DHTRecordRefreshMode refreshMode = DHTRecordRefreshMode.cached,
    Output<int>? outSeqNum,
  }) async {
    final data = await getBytes(
      subkey: subkey,
      crypto: crypto,
      refreshMode: refreshMode,
      outSeqNum: outSeqNum,
    );
    if (data == null) {
      return null;
    }
    return migrationCodec.fromBytes(data).value;
  }

  /// Attempt to write a byte buffer to a DHTRecord subkey
  /// If a newer value was found on the network, another attempt
  /// will be made to write the subkey until this succeeds
  /// This operation must be performed online or it will throw
  /// DHTExceptionNotAvailable
  Future<void> eventualWriteBytes(
    Uint8List newValue, {
    int subkey = -1,
    CryptoCodec? crypto,
    KeyPair? writer,
    Output<int>? outSeqNum,
  }) async {
    while (true) {
      final out = await tryWriteBytes(
        newValue,
        subkey: subkey,
        crypto: crypto,
        options: eventualOptions(writer),
        outSeqNum: outSeqNum,
      );
      if (out == null) {
        return;
      }
    }
  }

  /// Attempt to write a byte buffer to a DHTRecord subkey
  /// If a newer value was found on the network, another attempt
  /// will be made to write the subkey until this succeeds
  /// Each attempt to write the value calls an update function with the
  /// old value to determine what new value should be attempted for that write.
  /// This operation must be performed online or it will throw
  /// DHTExceptionNotAvailable
  Future<void> eventualUpdateBytes(
    Future<Uint8List?> Function(Uint8List? oldValue) update, {
    int subkey = -1,
    CryptoCodec? crypto,
    KeyPair? writer,
    Output<int>? outSeqNum,
  }) async {
    // Get the existing data, do not allow force refresh here
    // because if we need a refresh the setDHTValue will fail anyway
    var oldValue = await getBytes(
      subkey: subkey,
      crypto: crypto,
      outSeqNum: outSeqNum,
    );

    do {
      // Update the data
      final updatedValue = await update(oldValue);
      if (updatedValue == null) {
        // If null is returned from the update, stop trying to do the update
        break;
      }
      // Try to write it back to the network
      oldValue = await tryWriteBytes(
        updatedValue,
        subkey: subkey,
        crypto: crypto,
        options: eventualOptions(writer),
        outSeqNum: outSeqNum,
      );

      // Repeat update if newer data on the network was found
    } while (oldValue != null);
  }

  /// Like 'set' but with JSON marshal/unmarshal of the value
  Future<T?> tryWriteJson<T>(
    T Function(dynamic) fromJson,
    T newValue, {
    int subkey = -1,
    CryptoCodec? crypto,
    O? options,
    Output<int>? outSeqNum,
  }) =>
      tryWriteBytes(
        jsonEncodeBytes(newValue),
        subkey: subkey,
        crypto: crypto,
        options: options,
        outSeqNum: outSeqNum,
      ).then((out) {
        if (out == null) {
          return null;
        }
        return jsonDecodeBytes(fromJson, out);
      });

  /// Like 'tryWriteBytes' but with migrated marshal/unmarshal of the value
  Future<MigratedValue<T>?> tryWriteMigrated<T>(
    MigrationCodec<T> migrationCodec,
    T newValue, {
    int subkey = -1,
    CryptoCodec? crypto,
    O? options,
    Output<int>? outSeqNum,
  }) =>
      tryWriteBytes(
        migrationCodec.toBytes(newValue),
        subkey: subkey,
        crypto: crypto,
        options: options,
        outSeqNum: outSeqNum,
      ).then((out) {
        if (out == null) {
          return null;
        }
        return migrationCodec.fromBytes(out);
      });

  /// Like 'eventualWriteBytes' but with JSON marshal/unmarshal of the value
  Future<void> eventualWriteJson<T>(
    T newValue, {
    int subkey = -1,
    CryptoCodec? crypto,
    KeyPair? writer,
    Output<int>? outSeqNum,
  }) => eventualWriteBytes(
    jsonEncodeBytes(newValue),
    subkey: subkey,
    crypto: crypto,
    writer: writer,
    outSeqNum: outSeqNum,
  );

  /// Like 'eventualWriteBytes' but with migrated marshal/unmarshal of the value
  Future<void> eventualWriteMigrated<T>(
    MigrationCodec<T> migrationCodec,
    T newValue, {
    int subkey = -1,
    CryptoCodec? crypto,
    KeyPair? writer,
    Output<int>? outSeqNum,
  }) => eventualWriteBytes(
    migrationCodec.toBytes(newValue),
    subkey: subkey,
    crypto: crypto,
    writer: writer,
    outSeqNum: outSeqNum,
  );

  /// Like 'eventualUpdateBytes' but with JSON marshal/unmarshal of the value
  Future<void> eventualUpdateJson<T>(
    T Function(dynamic) fromJson,
    Future<T?> Function(T?) update, {
    int subkey = -1,
    CryptoCodec? crypto,
    KeyPair? writer,
    Output<int>? outSeqNum,
  }) => eventualUpdateBytes(
    jsonUpdate(fromJson, update),
    subkey: subkey,
    crypto: crypto,
    writer: writer,
    outSeqNum: outSeqNum,
  );

  /// Like 'eventualUpdateBytes' but with migrated marshal/unmarshal of the value
  Future<void> eventualUpdateMigrated<T>(
    MigrationCodec<T> migrationCodec,
    Future<T?> Function(MigratedValue<T>?) update, {
    int subkey = -1,
    CryptoCodec? crypto,
    KeyPair? writer,
    Output<int>? outSeqNum,
  }) => eventualUpdateBytes(
    _migratedUpdate(migrationCodec, update),
    subkey: subkey,
    crypto: crypto,
    writer: writer,
    outSeqNum: outSeqNum,
  );

  /// Return the inspection state of a set of subkeys of a record in
  /// the DHTTransaction.
  /// See Veilid's 'inspectDHTRecord' call for details on how this works
  @override
  @mustBeOverridden
  Future<DHTRecordReport> inspect({
    List<ValueSubkeyRange>? subkeys,
    DHTReportScope scope = DHTReportScope.local,
  });

  /// Migration helper
  @protected
  Future<Uint8List?> _migrationUpdateBytes<T>(
    MigrationCodec<T> migrationCodec,
    Uint8List? oldBytes,
    Future<T?> Function(MigratedValue<T>?) update,
  ) async {
    final oldObj = oldBytes == null ? null : migrationCodec.fromBytes(oldBytes);
    final newObj = await update(oldObj);
    if (newObj == null) {
      return null;
    }
    return migrationCodec.toBytes(newObj);
  }

  /// Migration helper
  @protected
  Future<Uint8List?> Function(Uint8List?) _migratedUpdate<T>(
    MigrationCodec<T> migrationCodec,
    Future<T?> Function(MigratedValue<T>?) update,
  ) =>
      (oldBytes) => _migrationUpdateBytes(migrationCodec, oldBytes, update);
}
