import 'dart:typed_data';

import 'package:meta/meta.dart';

import '../../../veilid_support.dart';

class SuperIdentityMigrationCodec extends JsonMigrationCodec<SuperIdentity> {
  /////////////////////////////////////////////////////////
  @override
  @protected
  List<JsonMigration> get migrations => [];

  @override
  int detectVersion(Uint8List data) => 0;

  @override
  SuperIdentity fromJson(json) => SuperIdentity.fromJson(json);
}
