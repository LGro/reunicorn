// Interface for data schema evolution
// Used to upgrade protobufs and other serializations from deprecated formats

import 'dart:typed_data';

import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

/// Evolves a data format over time
abstract interface class MigrationCodec<T> {
  /// Encode the value in its newest format
  Uint8List toBytes(T value);

  /// Read any older supported format and upgrade it
  /// Returns a status if the data has changed format
  MigratedValue<T> fromBytes(Uint8List data);
}

/// Class the represents a migration status
@immutable
class MigratedValue<T> extends Equatable {
  /// The most recent value
  final T value;

  /// If the value changed format upon deserialization
  final bool migrated;

  const MigratedValue({required this.value, required this.migrated});

  @override
  List<Object?> get props => [value, migrated];
}
