import '../../../veilid_support.dart';
import '../proto.dart' as v1proto;
import '../proto.deprecated.dart' as v0proto;

extension DHTShortArrayMigrationV0 on v0proto.DHTShortArray {
  v1proto.DHTShortArray migrate() => v1proto.DHTShortArray(
    keys: keys.map(
      (v) => RecordKey(
        opaque: v.toDartOpaqueRecordKey(),
        encryptionKey: null,
      ).toProto(),
    ),
    index: index,
    seqs: seqs,
  );
}
