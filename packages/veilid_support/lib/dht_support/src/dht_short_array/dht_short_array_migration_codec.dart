import 'dart:typed_data';

import 'package:meta/meta.dart';

import '../../../veilid_support.dart';
import '../../proto/proto.dart' as v1proto;
import '../../proto/proto.deprecated.dart' as v0proto;

class DHTShortArrayMigrationCodec
    extends ProtobufMigrationCodec<v1proto.DHTShortArray> {
  Uint8List _migration_0(Uint8List data) {
    final v0value = v0proto.DHTShortArray.fromBuffer(data);
    final v1value = v0value.migrate();
    return v1value.writeToBuffer();
  }

  /////////////////////////////////////////////////////////
  @override
  @protected
  List<ProtobufMigration> get migrations => [_migration_0];

  @override
  @protected
  v1proto.DHTShortArray fromBuffer(Uint8List data) =>
      v1proto.DHTShortArray.fromBuffer(data);
}
