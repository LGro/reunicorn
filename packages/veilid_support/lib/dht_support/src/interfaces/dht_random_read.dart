import 'dart:typed_data';

import '../../../veilid_support.dart';

////////////////////////////////////////////////////////////////////////////
// Reader interface
abstract class DHTRandomRead {
  /// Returns the number of elements in the DHT container
  int get length;

  /// Return the item at position 'pos' in the DHT container.
  /// Reads from local cache only — never touches the network.
  /// Call refresh() before operateRead() if network sync is needed.
  /// Throws an IndexError if the 'pos' is not within the length
  /// of the container.
  /// Throws DHTExceptionNotAvailable if the item is not in the local cache.
  Future<Uint8List> get(int pos);

  /// Return a list of a range of items in the DHTArray.
  /// Reads from local cache only — never touches the network.
  /// Call refresh() before operateRead() if network sync is needed.
  /// Throws an IndexError if either 'start' or '(start+length)' is not within
  /// the length of the container.
  /// Throws DHTExceptionNotAvailable if any item in the range is not in
  /// the local cache.
  Future<List<Uint8List>> getRange(
    int start, {
    int? length,
  });

  /// Returns the maximum number of elements that can be read in a single
  /// getRange call starting from position [start].
  int getRangeLimit(int start);

  /// Return the set of element positions that are not currently readable from
  /// the local cache and so should be skipped by readers:
  /// - Non-transactional types (e.g. DHTRecord): positions written offline and
  ///   not yet synced to the network.
  /// - DHTLog: positions that fall within segments that could not be fetched
  ///   (unavailable segments).
  /// - DHTShortArray: always empty — all of its elements are kept locally.
  Future<Set<int>> getOfflinePositions();
}

extension DHTRandomReadExt on DHTRandomRead {
  /// Convenience function:
  /// Like get but also parses the returned element as JSON
  Future<T> getJson<T>(
    T Function(dynamic) fromJson,
    int pos,
  ) => get(pos).then((out) => jsonDecodeBytes(fromJson, out));

  /// Convenience function:
  /// Like getRange but also parses the returned elements as JSON
  Future<List<T>> getRangeJson<T>(
    T Function(dynamic) fromJson,
    int start, {
    int? length,
  }) => getRange(start, length: length)
      .then((out) => out.map(fromJson).toList());

  /// Convenience function:
  /// Like get but also migrates the returned element
  Future<MigratedValue<T>> getMigrated<T>(
    MigrationCodec<T> migrationCodec,
    int pos,
  ) => get(pos).then((out) => migrationCodec.fromBytes(out));

  /// Convenience function:
  /// Like getRange but also migrates the returned elements
  Future<List<MigratedValue<T>>> getRangeMigrated<T>(
    MigrationCodec<T> migrationCodec,
    int start, {
    int? length,
  }) => getRange(start, length: length)
      .then((out) => out.map(migrationCodec.fromBytes).toList());
}
