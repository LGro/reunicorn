import 'dart:typed_data';

import 'package:meta/meta.dart';

import '../../../veilid_support.dart';
import '../../proto/proto.dart' as v1proto;
// import '../../proto/proto.deprecated.dart' as v0proto;

class DHTLogMigrationCodec extends ProtobufMigrationCodec<v1proto.DHTLog> {
  /////////////////////////////////////////////////////////
  @override
  @protected
  List<ProtobufMigration> get migrations => [];

  @override
  @protected
  v1proto.DHTLog fromBuffer(Uint8List data) => v1proto.DHTLog.fromBuffer(data);
}
