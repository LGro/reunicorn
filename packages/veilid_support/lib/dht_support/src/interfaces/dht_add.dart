import 'dart:typed_data';

import 'package:protobuf/protobuf.dart';

import '../../../veilid_support.dart';

////////////////////////////////////////////////////////////////////////////
// Add
abstract class DHTAdd {
  /// Try to add an item to the DHT container.
  /// Return if the element was successfully added,
  /// Throws DHTExceptionTryAgain if the state changed before the element could
  /// be added or a newer value was found on the network.
  /// Throws a StateError if the container exceeds its maximum size.
  Future<void> add(Uint8List value);

  /// Try to add a list of items to the DHT container.
  /// Return the number of elements successfully added.
  /// Throws DHTExceptionTryAgain if the state changed before any elements could
  /// be added or a newer value was found on the network.
  /// Throws DHTConcurrencyLimit if the number values in the list was too large
  /// at this time
  /// Throws a StateError if the container exceeds its maximum size.
  Future<void> addAll(List<Uint8List> values);
}

extension DHTAddExt on DHTAdd {
  /// Convenience function:
  /// Like add but also encodes the input value as JSON
  Future<void> addJson<T>(
    T newValue,
  ) =>
      add(jsonEncodeBytes(newValue));

  /// Convenience function:
  /// Like add but also encodes the input value as a protobuf object
  Future<void> addProtobuf<T extends GeneratedMessage>(
    T newValue,
  ) =>
      add(newValue.writeToBuffer());

  /// Convenience function:
  /// Like addAll but also encodes the input values as JSON
  Future<void> addAllJson<T>(List<T> values) =>
      addAll(values.map(jsonEncodeBytes).toList());

  /// Convenience function:
  /// Like addAll but also encodes the input values as protobuf objects
  Future<void> addAllProtobuf<T extends GeneratedMessage>(List<T> values) =>
      addAll(values.map((x) => x.writeToBuffer()).toList());
}
