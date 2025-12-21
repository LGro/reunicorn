import 'dart:typed_data';

import '../src/dynamic_debug.dart';
import '../veilid_support.dart' as veilid;
import 'veilid.deprecated.pb.dart' as proto_deprecated;

export 'veilid.deprecated.pb.dart';
export 'veilid.deprecated.pbenum.dart';
export 'veilid.deprecated.pbjson.dart';
export 'veilid.deprecated.pbserver.dart';

////////////////////////////////////////////////////////////////////////////////
/// Deprecated types protobuf marshaling

extension DeprecatedCryptoKeyToDart on proto_deprecated.CryptoKey {
  T _toDart<T extends veilid.EncodedString>() {
    final b = ByteData(32)
      ..setUint32(0 * 4, u0)
      ..setUint32(1 * 4, u1)
      ..setUint32(2 * 4, u2)
      ..setUint32(3 * 4, u3)
      ..setUint32(4 * 4, u4)
      ..setUint32(5 * 4, u5)
      ..setUint32(6 * 4, u6)
      ..setUint32(7 * 4, u7);
    return veilid.EncodedString.fromBytes<T>(Uint8List.view(b.buffer));
  }

  veilid.BarePublicKey toDartBarePublicKey() => _toDart<veilid.BarePublicKey>();
  veilid.BareSignature toDartBareSignature() => _toDart<veilid.BareSignature>();
  veilid.BareSecretKey toDartBareSecretKey() => _toDart<veilid.BareSecretKey>();
  veilid.BareHashDigest toDartBareHashDigest() =>
      _toDart<veilid.BareHashDigest>();
  veilid.BareSharedSecret toDartBareSharedSecret() =>
      _toDart<veilid.BareSharedSecret>();
  veilid.BareRouteId toDartBareRouteId() => _toDart<veilid.BareRouteId>();
  veilid.BareNodeId toDartBareNodeId() => _toDart<veilid.BareNodeId>();
  veilid.BareMemberId toDartBareMemberId() => _toDart<veilid.BareMemberId>();
  veilid.BareOpaqueRecordKey toDartBareOpaqueRecordKey() =>
      _toDart<veilid.BareOpaqueRecordKey>();
  veilid.Nonce toDartNonce() => _toDart<veilid.Nonce>();
}

extension DeprecatedSignatureToDart on proto_deprecated.Signature {
  veilid.Signature toDart() {
    final b = ByteData(64)
      ..setUint32(0 * 4, u0)
      ..setUint32(1 * 4, u1)
      ..setUint32(2 * 4, u2)
      ..setUint32(3 * 4, u3)
      ..setUint32(4 * 4, u4)
      ..setUint32(5 * 4, u5)
      ..setUint32(6 * 4, u6)
      ..setUint32(7 * 4, u7)
      ..setUint32(8 * 4, u8)
      ..setUint32(9 * 4, u9)
      ..setUint32(10 * 4, u10)
      ..setUint32(11 * 4, u11)
      ..setUint32(12 * 4, u12)
      ..setUint32(13 * 4, u13)
      ..setUint32(14 * 4, u14)
      ..setUint32(15 * 4, u15);
    return veilid.Signature.fromBytes(Uint8List.view(b.buffer));
  }
}

extension DeprecatedNonceToDart on proto_deprecated.Nonce {
  veilid.Nonce toDart() {
    final b = ByteData(24)
      ..setUint32(0 * 4, u0)
      ..setUint32(1 * 4, u1)
      ..setUint32(2 * 4, u2)
      ..setUint32(3 * 4, u3)
      ..setUint32(4 * 4, u4)
      ..setUint32(5 * 4, u5);
    return veilid.Nonce.fromBytes(Uint8List.view(b.buffer));
  }
}

extension DeprecatedTypedKeyToDart on proto_deprecated.TypedKey {
  veilid.PublicKey toDartPublicKey() => veilid.PublicKey(
    kind: veilid.CryptoKind.fromInt(kind),
    value: value.toDartBarePublicKey(),
  );
  veilid.Signature toDartSignature() => veilid.Signature(
    kind: veilid.CryptoKind.fromInt(kind),
    value: value.toDartBareSignature(),
  );
  veilid.SecretKey toDartSecretKey() => veilid.SecretKey(
    kind: veilid.CryptoKind.fromInt(kind),
    value: value.toDartBareSecretKey(),
  );
  veilid.HashDigest toDartHashDigest() => veilid.HashDigest(
    kind: veilid.CryptoKind.fromInt(kind),
    value: value.toDartBareHashDigest(),
  );
  veilid.SharedSecret toDartSharedSecret() => veilid.SharedSecret(
    kind: veilid.CryptoKind.fromInt(kind),
    value: value.toDartBareSharedSecret(),
  );
  veilid.RouteId toDartRouteId() => veilid.RouteId(
    kind: veilid.CryptoKind.fromInt(kind),
    value: value.toDartBareRouteId(),
  );
  veilid.NodeId toDartNodeId() => veilid.NodeId(
    kind: veilid.CryptoKind.fromInt(kind),
    value: value.toDartBareNodeId(),
  );
  veilid.MemberId toDartMemberId() => veilid.MemberId(
    kind: veilid.CryptoKind.fromInt(kind),
    value: value.toDartBareMemberId(),
  );
  veilid.OpaqueRecordKey toDartOpaqueRecordKey() => veilid.OpaqueRecordKey(
    kind: veilid.CryptoKind.fromInt(kind),
    value: value.toDartBareOpaqueRecordKey(),
  );
}

extension DeprecatedBareKeyPairToDart on proto_deprecated.KeyPair {
  veilid.BareKeyPair toDart() => veilid.BareKeyPair(
    key: key.toDartBarePublicKey(),
    secret: secret.toDartBareSecretKey(),
  );
}

////////////////////////////////////////////////////////////////////////////////
/// Debug printing registration

void registerVeilidProtoDeprecatedToDebug() {
  dynamic toDebug(dynamic protoObj) {
    // Debug prints for deprecated types
    if (protoObj is proto_deprecated.CryptoKey) {
      return protoObj.toDartBareHashDigest().toString();
    }
    if (protoObj is proto_deprecated.Signature) {
      return protoObj.toDart();
    }
    if (protoObj is proto_deprecated.Nonce) {
      return protoObj.toDart();
    }
    if (protoObj is proto_deprecated.TypedKey) {
      return protoObj.toDartHashDigest().toString();
    }
    if (protoObj is proto_deprecated.KeyPair) {
      return protoObj.toDart();
    }
    return protoObj;
  }

  DynamicDebug.registerToDebug(toDebug);
}
