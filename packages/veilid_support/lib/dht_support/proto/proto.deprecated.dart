import '../../../veilid_support.dart';
import '../../proto/dht.deprecated.pb.dart' as dhtproto_deprecated;
import '../../proto/proto.deprecated.dart' as veilidproto_deprecated;

export '../../proto/dht.deprecated.pb.dart';
export '../../proto/dht.deprecated.pbenum.dart';
export '../../proto/dht.deprecated.pbjson.dart';
export '../../proto/dht.deprecated.pbserver.dart';
export '../../proto/proto.deprecated.dart';

/// OwnedDHTRecordPointer protobuf marshaling
///

extension ProtoDeprecatedOwnedDHTRecordPointer
    on dhtproto_deprecated.OwnedDHTRecordPointer {
  OwnedDHTRecordPointer toDart() => OwnedDHTRecordPointer(
    recordKey: RecordKey(
      opaque: recordKey.toDartOpaqueRecordKey(),
      encryptionKey: null,
    ),
    owner: owner.toDart(),
  );
}

void registerVeilidDHTProtoDeprecatedToDebug() {
  dynamic toDebug(dynamic obj) {
    // deprecated veilid dht types
    if (obj is dhtproto_deprecated.OwnedDHTRecordPointer) {
      return {
        r'$runtimeType': obj.runtimeType,
        'recordKey': obj.recordKey,
        'owner': obj.owner,
      };
    }
    if (obj is dhtproto_deprecated.DHTData) {
      return {
        r'$runtimeType': obj.runtimeType,
        'keys': obj.keys,
        'hash': obj.hash,
        'chunk': obj.chunk,
        'size': obj.size,
      };
    }
    if (obj is dhtproto_deprecated.DHTLog) {
      return {
        r'$runtimeType': obj.runtimeType,
        'head': obj.head,
        'tail': obj.tail,
        'stride': obj.stride,
      };
    }
    if (obj is dhtproto_deprecated.DHTShortArray) {
      return {
        r'$runtimeType': obj.runtimeType,
        'keys': obj.keys,
        'index': obj.index,
        'seqs': obj.seqs,
      };
    }

    return obj;
  }

  DynamicDebug.registerToDebug(toDebug);
}
