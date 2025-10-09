import 'dart:convert';
import 'dart:typed_data';

import '../src/veilid_log.dart';
import '../veilid_support.dart';

Uint8List identityCryptoDomain = utf8.encode('identity');

/// SuperIdentity creator with secret
/// Not freezed because we never persist this class in its entirety.
class WritableSuperIdentity {
  SuperIdentity superIdentity;
  SecretKey superSecret;
  SecretKey identitySecret;

  WritableSuperIdentity._({
    required this.superIdentity,
    required this.superSecret,
    required this.identitySecret,
  });

  static Future<WritableSuperIdentity> create() async {
    final pool = DHTRecordPool.instance;

    // SuperIdentity DHT record is public/unencrypted
    veilidLoggy.debug('Creating super identity record');
    return (await pool.createRecord(
      debugName: 'WritableSuperIdentity::create::SuperIdentityRecord',
      crypto: const VeilidCryptoPublic(),
    )).deleteScope((superRec) {
      final superRecordKey = superRec.key;
      final superBarePublicKey = superRec.ownerKeyPair!.key.value;
      final superSecret = superRec.ownerKeyPair!.secret;

      return IdentityInstance.createIdentityInstance(
        superRecordKey: superRecordKey,
        superKeyPair: superRec.ownerKeyPair!,
        closure: (identityInstance, identitySecret) async {
          final signature = await _createSuperIdentitySignature(
            recordKey: superRecordKey,
            superKeyPair: superRec.ownerKeyPair!,
            currentInstanceSignature: identityInstance.signature.value,
            deprecatedInstancesSignatures: [],
            deprecatedSuperRecordKeys: [],
          );

          final superIdentity = SuperIdentity(
            recordKey: superRecordKey,
            barePublicKey: superBarePublicKey,
            currentInstance: identityInstance,
            deprecatedInstances: [],
            deprecatedSuperRecordKeys: [],
            bareSignature: signature.value,
          );

          // Write superidentity to dht record
          await superRec.eventualWriteJson(superIdentity);

          return WritableSuperIdentity._(
            superIdentity: superIdentity,
            superSecret: superSecret,
            identitySecret: identitySecret,
          );
        },
      );
    });
  }

  ////////////////////////////////////////////////////////////////////////////
  // Public Interface

  /// Delete a super identity with secrets
  Future<void> delete() => superIdentity.delete();

  /// Produce a recovery key for this superIdentity
  Uint8List get recoveryKey =>
      (BytesBuilder()
            ..add(superIdentity.recordKey.toBytes())
            ..add(superSecret.toBytes()))
          .toBytes();

  /// xxx: migration support, new identities, reveal identity secret etc

  ////////////////////////////////////////////////////////////////////////////
  /// Private Implementation

  static Future<Signature> _createSuperIdentitySignature({
    required RecordKey recordKey,
    required BareSignature currentInstanceSignature,
    required List<BareSignature> deprecatedInstancesSignatures,
    required List<RecordKey> deprecatedSuperRecordKeys,
    required KeyPair superKeyPair,
  }) async {
    final cs = await Veilid.instance.getCryptoSystem(recordKey.kind);
    final sigBytes = SuperIdentity.signatureBytes(
      recordKey: recordKey,
      currentInstanceSignature: currentInstanceSignature,
      deprecatedInstancesSignatures: deprecatedInstancesSignatures,
      deprecatedSuperRecordKeys: deprecatedSuperRecordKeys,
    );
    return cs.sign(superKeyPair.key, superKeyPair.secret, sigBytes);
  }
}
