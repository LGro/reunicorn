import 'dart:typed_data';

import '../src/dynamic_debug.dart';
import '../veilid_support.dart' as veilid;
import 'veilid.pb.dart' as proto;

export 'veilid.pb.dart';
export 'veilid.pbenum.dart';
export 'veilid.pbjson.dart';
export 'veilid.pbserver.dart';

// Support extensions for:
//
// BarePublicKey
// BareSignature
// BareSecretKey
// BareSharedSecret
// BareHashDigest
// BareOpaqueRecordKey
// BareRouteId
// BareNodeId
// BareMemberId
// Nonce
// PublicKey
// Signature
// SecretKey
// HashDigest
// OpaqueRecordKey
// SharedSecret
// RouteId
// NodeId
// MemberId
// BareKeyPair
// KeyPair
// BareRecordKey
// RecordKey

////////////////////////////////////////////////////////////////////////////////
/// Byte array protobuf marshaling

// BarePublicKey
extension BarePublicKeyToProto on veilid.BarePublicKey {
  proto.BarePublicKey toProto() => proto.BarePublicKey(data: toBytes());
}

extension BarePublicKeyToDart on proto.BarePublicKey {
  veilid.BarePublicKey toDart() =>
      veilid.BarePublicKey.fromBytes(Uint8List.fromList(data));
}

// BareSignature
extension BareSignatureToProto on veilid.BareSignature {
  proto.BareSignature toProto() => proto.BareSignature(data: toBytes());
}

extension BareSignatureToDart on proto.BareSignature {
  veilid.BareSignature toDart() =>
      veilid.BareSignature.fromBytes(Uint8List.fromList(data));
}

// BareSecretKey
extension BareSecretKeyToProto on veilid.BareSecretKey {
  proto.BareSecretKey toProto() => proto.BareSecretKey(data: toBytes());
}

extension BareSecretKeyToDart on proto.BareSecretKey {
  veilid.BareSecretKey toDart() =>
      veilid.BareSecretKey.fromBytes(Uint8List.fromList(data));
}

// BareSharedSecret
extension BareSharedSecretToProto on veilid.BareSharedSecret {
  proto.BareSharedSecret toProto() => proto.BareSharedSecret(data: toBytes());
}

extension BareSharedSecretToDart on proto.BareSharedSecret {
  veilid.BareSharedSecret toDart() =>
      veilid.BareSharedSecret.fromBytes(Uint8List.fromList(data));
}

// BareHashDigest
extension BareHashDigestToProto on veilid.BareHashDigest {
  proto.BareHashDigest toProto() => proto.BareHashDigest(data: toBytes());
}

extension BareHashDigestToDart on proto.BareHashDigest {
  veilid.BareHashDigest toDart() =>
      veilid.BareHashDigest.fromBytes(Uint8List.fromList(data));
}

// BareOpaqueRecordKey
extension BareOpaqueRecordKeyToProto on veilid.BareOpaqueRecordKey {
  proto.BareOpaqueRecordKey toProto() =>
      proto.BareOpaqueRecordKey(data: toBytes());
}

extension BareOpaqueRecordKeyToDart on proto.BareOpaqueRecordKey {
  veilid.BareOpaqueRecordKey toDart() =>
      veilid.BareOpaqueRecordKey.fromBytes(Uint8List.fromList(data));
}

// BareRouteId
extension BareRouteIdToProto on veilid.BareRouteId {
  proto.BareRouteId toProto() => proto.BareRouteId(data: toBytes());
}

extension BareRouteIdToDart on proto.BareRouteId {
  veilid.BareRouteId toDart() =>
      veilid.BareRouteId.fromBytes(Uint8List.fromList(data));
}

// BareNodeId
extension BareNodeIdToProto on veilid.BareNodeId {
  proto.BareNodeId toProto() => proto.BareNodeId(data: toBytes());
}

extension BareNodeIdToDart on proto.BareNodeId {
  veilid.BareNodeId toDart() =>
      veilid.BareNodeId.fromBytes(Uint8List.fromList(data));
}

// BareMemberId
extension BareMemberIdToProto on veilid.BareMemberId {
  proto.BareMemberId toProto() => proto.BareMemberId(data: toBytes());
}

extension BareMemberIdToDart on proto.BareMemberId {
  veilid.BareMemberId toDart() =>
      veilid.BareMemberId.fromBytes(Uint8List.fromList(data));
}

// Nonce
extension NonceToProto on veilid.Nonce {
  proto.Nonce toProto() => proto.Nonce(data: toBytes());
}

extension NonceToDart on proto.Nonce {
  veilid.Nonce toDart() => veilid.Nonce.fromBytes(Uint8List.fromList(data));
}

////////////////////////////////////////////////////////////////////////////////
/// Typed byte array protobuf marshaling

// PublicKey
extension PublicKeyToProto on veilid.PublicKey {
  proto.PublicKey toProto() =>
      proto.PublicKey(kind: kind, data: value.toBytes());
}

extension PublicKeyToDart on proto.PublicKey {
  veilid.PublicKey toDart() => veilid.PublicKey(
    kind: kind,
    value: veilid.BarePublicKey.fromBytes(Uint8List.fromList(data)),
  );
}

// Signature
extension SignatureToProto on veilid.Signature {
  proto.Signature toProto() =>
      proto.Signature(kind: kind, data: value.toBytes());
}

extension SignatureToDart on proto.Signature {
  veilid.Signature toDart() => veilid.Signature(
    kind: kind,
    value: veilid.BareSignature.fromBytes(Uint8List.fromList(data)),
  );
}

// SecretKey
extension SecretKeyToProto on veilid.SecretKey {
  proto.SecretKey toProto() =>
      proto.SecretKey(kind: kind, data: value.toBytes());
}

extension SecretKeyToDart on proto.SecretKey {
  veilid.SecretKey toDart() => veilid.SecretKey(
    kind: kind,
    value: veilid.BareSecretKey.fromBytes(Uint8List.fromList(data)),
  );
}

// HashDigest
extension HashDigestToProto on veilid.HashDigest {
  proto.HashDigest toProto() =>
      proto.HashDigest(kind: kind, data: value.toBytes());
}

extension HashDigestToDart on proto.HashDigest {
  veilid.HashDigest toDart() => veilid.HashDigest(
    kind: kind,
    value: veilid.BareHashDigest.fromBytes(Uint8List.fromList(data)),
  );
}

// OpaqueRecordKey
extension OpaqueRecordKeyToProto on veilid.OpaqueRecordKey {
  proto.OpaqueRecordKey toProto() =>
      proto.OpaqueRecordKey(kind: kind, data: value.toBytes());
}

extension OpaqueRecordKeyToDart on proto.OpaqueRecordKey {
  veilid.OpaqueRecordKey toDart() => veilid.OpaqueRecordKey(
    kind: kind,
    value: veilid.BareOpaqueRecordKey.fromBytes(Uint8List.fromList(data)),
  );
}

// SharedSecret
extension SharedSecretToProto on veilid.SharedSecret {
  proto.SharedSecret toProto() =>
      proto.SharedSecret(kind: kind, data: value.toBytes());
}

extension SharedSecretToDart on proto.SharedSecret {
  veilid.SharedSecret toDart() => veilid.SharedSecret(
    kind: kind,
    value: veilid.BareSharedSecret.fromBytes(Uint8List.fromList(data)),
  );
}

// RouteId
extension RouteIdToProto on veilid.RouteId {
  proto.RouteId toProto() => proto.RouteId(kind: kind, data: value.toBytes());
}

extension RouteIdToDart on proto.RouteId {
  veilid.RouteId toDart() => veilid.RouteId(
    kind: kind,
    value: veilid.BareRouteId.fromBytes(Uint8List.fromList(data)),
  );
}

// NodeId
extension NodeIdToProto on veilid.NodeId {
  proto.NodeId toProto() => proto.NodeId(kind: kind, data: value.toBytes());
}

extension NodeIdToDart on proto.NodeId {
  veilid.NodeId toDart() => veilid.NodeId(
    kind: kind,
    value: veilid.BareNodeId.fromBytes(Uint8List.fromList(data)),
  );
}

// MemberId
extension MemberIdToProto on veilid.MemberId {
  proto.MemberId toProto() => proto.MemberId(kind: kind, data: value.toBytes());
}

extension MemberIdToDart on proto.MemberId {
  veilid.MemberId toDart() => veilid.MemberId(
    kind: kind,
    value: veilid.BareMemberId.fromBytes(Uint8List.fromList(data)),
  );
}
////////////////////////////////////////////////////////////////////////////////
/// Combination types protobuf marshaling

// BareKeyPair
extension BareKeyPairToProto on veilid.BareKeyPair {
  proto.BareKeyPair toProto() =>
      proto.BareKeyPair(key: key.toBytes(), secret: secret.toBytes());
}

extension BareKeyPairToDart on proto.BareKeyPair {
  veilid.BareKeyPair toDart() => veilid.BareKeyPair(
    key: veilid.BarePublicKey.fromBytes(Uint8List.fromList(key)),
    secret: veilid.BareSecretKey.fromBytes(Uint8List.fromList(secret)),
  );
}

// KeyPair
extension KeyPairToProto on veilid.KeyPair {
  proto.KeyPair toProto() => proto.KeyPair(
    kind: kind,
    key: key.value.toBytes(),
    secret: secret.value.toBytes(),
  );
}

extension KeyPairToDart on proto.KeyPair {
  veilid.KeyPair toDart() => veilid.KeyPair(
    key: veilid.PublicKey(
      kind: kind,
      value: veilid.BarePublicKey.fromBytes(Uint8List.fromList(key)),
    ),
    secret: veilid.SecretKey(
      kind: kind,
      value: veilid.BareSecretKey.fromBytes(Uint8List.fromList(secret)),
    ),
  );
}

// BareRecordKey
extension BareRecordKeyToProto on veilid.BareRecordKey {
  proto.BareRecordKey toProto() => proto.BareRecordKey(
    key: key.toBytes(),
    encryptionKey: encryptionKey?.toBytes(),
  );
}

extension BareRecordKeyToDart on proto.BareRecordKey {
  veilid.BareRecordKey toDart() => veilid.BareRecordKey(
    key: veilid.BareOpaqueRecordKey.fromBytes(Uint8List.fromList(key)),
    encryptionKey: hasEncryptionKey()
        ? veilid.BareSharedSecret.fromBytes(Uint8List.fromList(encryptionKey))
        : null,
  );
}

// RecordKey
extension RecordKeyToProto on veilid.RecordKey {
  proto.RecordKey toProto() => proto.RecordKey(
    kind: kind,
    key: opaque.value.toBytes(),
    encryptionKey: encryptionKey?.value.toBytes(),
  );
}

extension RecordKeyToDart on proto.RecordKey {
  veilid.RecordKey toDart() => veilid.RecordKey(
    opaque: veilid.OpaqueRecordKey(
      kind: kind,
      value: veilid.BareOpaqueRecordKey.fromBytes(Uint8List.fromList(key)),
    ),
    encryptionKey: hasEncryptionKey()
        ? veilid.SharedSecret(
            kind: kind,
            value: veilid.BareSharedSecret.fromBytes(
              Uint8List.fromList(encryptionKey),
            ),
          )
        : null,
  );
}

////////////////////////////////////////////////////////////////////////////////
/// Debug printing registration

void registerVeilidProtoToDebug() {
  dynamic toDebug(dynamic protoObj) {
    // Debug prints for veilid types
    if (protoObj is proto.BarePublicKey) {
      return protoObj.toDart();
    }
    if (protoObj is proto.BareSignature) {
      return protoObj.toDart();
    }
    if (protoObj is proto.BareSecretKey) {
      return protoObj.toDart();
    }
    if (protoObj is proto.BareSharedSecret) {
      return protoObj.toDart();
    }
    if (protoObj is proto.BareHashDigest) {
      return protoObj.toDart();
    }
    if (protoObj is proto.BareOpaqueRecordKey) {
      return protoObj.toDart();
    }
    if (protoObj is proto.BareRouteId) {
      return protoObj.toDart();
    }
    if (protoObj is proto.BareNodeId) {
      return protoObj.toDart();
    }
    if (protoObj is proto.BareMemberId) {
      return protoObj.toDart();
    }
    if (protoObj is proto.Nonce) {
      return protoObj.toDart();
    }
    if (protoObj is proto.PublicKey) {
      return protoObj.toDart();
    }
    if (protoObj is proto.Signature) {
      return protoObj.toDart();
    }
    if (protoObj is proto.SecretKey) {
      return protoObj.toDart();
    }
    if (protoObj is proto.HashDigest) {
      return protoObj.toDart();
    }
    if (protoObj is proto.OpaqueRecordKey) {
      return protoObj.toDart();
    }
    if (protoObj is proto.SharedSecret) {
      return protoObj.toDart();
    }
    if (protoObj is proto.RouteId) {
      return protoObj.toDart();
    }
    if (protoObj is proto.NodeId) {
      return protoObj.toDart();
    }
    if (protoObj is proto.MemberId) {
      return protoObj.toDart();
    }
    if (protoObj is proto.BareKeyPair) {
      return protoObj.toDart();
    }
    if (protoObj is proto.KeyPair) {
      return protoObj.toDart();
    }
    if (protoObj is proto.BareRecordKey) {
      return protoObj.toDart();
    }
    if (protoObj is proto.RecordKey) {
      return protoObj.toDart();
    }

    return protoObj;
  }

  DynamicDebug.registerToDebug(toDebug);
}
