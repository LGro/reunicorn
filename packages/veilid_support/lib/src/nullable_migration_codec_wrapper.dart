import 'dart:typed_data';

import 'migration_codec.dart';

class NullableMigrationCodecWrapper<T> implements MigrationCodec<T?> {
  MigrationCodec<T> wrapped;

  NullableMigrationCodecWrapper(this.wrapped);

  @override
  Uint8List toBytes(T? value) =>
      value == null ? Uint8List(0) : wrapped.toBytes(value);

  @override
  MigratedValue<T?> fromBytes(Uint8List data) => data.lengthInBytes == 0
      ? MigratedValue(value: null, migrated: false)
      : wrapped.fromBytes(data);
}
