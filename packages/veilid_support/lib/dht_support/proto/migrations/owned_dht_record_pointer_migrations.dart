import '../../../veilid_support.dart';
import '../proto.dart' as v1proto;
import '../proto.deprecated.dart' as v0proto;

extension OwnedDHTRecordPointerMigrationV0 on v0proto.OwnedDHTRecordPointer {
  v1proto.OwnedDHTRecordPointer migrate() => v1proto.OwnedDHTRecordPointer(
    recordKey: RecordKey(
      opaque: recordKey.toDartOpaqueRecordKey(),
      encryptionKey: null,
    ).toProto(),
    owner: owner.toDart().toProto(),
  );
}
