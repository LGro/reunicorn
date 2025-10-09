import 'dart:typed_data';

import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../src/veilid_log.dart';
import '../veilid_support.dart';

part 'identity_instance.freezed.dart';
part 'identity_instance.g.dart';

@freezed
sealed class IdentityInstance with _$IdentityInstance {
  const factory IdentityInstance({
    // Private DHT record storing identity account mapping
    required RecordKey recordKey,

    // Public key of identity instance
    @JsonKey(name: 'public_key') required BarePublicKey barePublicKey,

    // Secret key of identity instance
    // Encrypted with appended salt, key is DeriveSharedSecret(
    //    password = SuperIdentity.secret,
    //    salt = publicKey)
    // Used to recover accounts without generating a new instance
    @Uint8ListJsonConverter() required Uint8List encryptedSecretKey,

    // Signature of SuperInstance recordKey and SuperInstance publicKey
    // by publicKey
    @JsonKey(name: 'super_signature') required BareSignature bareSuperSignature,

    // Signature of recordKey, publicKey, encryptedSecretKey, and superSignature
    // by SuperIdentity publicKey
    @JsonKey(name: 'signature') required BareSignature bareSignature,
  }) = _IdentityInstance;

  factory IdentityInstance.fromJson(dynamic json) =>
      _$IdentityInstanceFromJson(json as Map<String, dynamic>);

  const IdentityInstance._();

  ////////////////////////////////////////////////////////////////////////////
  // Public interface

  static Future<T> createIdentityInstance<T>({
    required RecordKey superRecordKey,
    required KeyPair superKeyPair,
    required Future<T> Function(IdentityInstance, SecretKey) closure,
  }) async {
    assert(
      superRecordKey.kind == superKeyPair.kind,
      'super record key and keypair should have same cryptosystem',
    );

    final pool = DHTRecordPool.instance;
    veilidLoggy.debug('Creating identity instance record');
    // Identity record is private
    return (await pool.createRecord(
      kind: superRecordKey.kind,
      debugName: 'SuperIdentityWithSecrets::create::IdentityRecord',
      parent: superRecordKey,
    )).deleteScope((identityRec) async {
      final identityRecordKey = identityRec.key;
      final identityPublicKey = identityRec.ownerKeyPair!.key;
      final identitySecretKey = identityRec.ownerKeyPair!.secret;

      // Make encrypted secret key
      final cs = await Veilid.instance.getCryptoSystem(identityRecordKey.kind);

      final encryptionKey = await cs.deriveSharedSecret(
        superKeyPair.secret.value.toBytes(),
        identityPublicKey.value.toBytes(),
      );
      final encryptedSecretKey = await cs.encryptNoAuthWithNonce(
        identitySecretKey.value.toBytes(),
        encryptionKey,
      );

      // Make supersignature
      final superSignature = await _createSuperSignature(
        superRecordKey: superRecordKey,
        superPublicKey: superKeyPair.key.value,
        publicKey: identityPublicKey,
        secretKey: identitySecretKey,
      );

      // Make signature
      final signature = await _createIdentitySignature(
        recordKey: identityRecordKey,
        publicKey: identityPublicKey,
        encryptedSecretKey: encryptedSecretKey,
        superSignature: superSignature,
        superKeyPair: superKeyPair,
      );

      // Make empty identity
      const identity = Identity(accountRecords: IMapConst({}));

      // Write empty identity to identity dht key
      await identityRec.eventualWriteJson(identity);

      final identityInstance = IdentityInstance(
        recordKey: identityRecordKey,
        barePublicKey: identityPublicKey.value,
        encryptedSecretKey: encryptedSecretKey,
        bareSuperSignature: superSignature.value,
        bareSignature: signature.value,
      );

      return closure(identityInstance, identitySecretKey);
    });
  }

  Future<bool> validate({
    required RecordKey superRecordKey,
    required PublicKey superPublicKey,
  }) async {
    final sigValid = await _validateIdentitySignature(
      recordKey: recordKey,
      barePublicKey: barePublicKey,
      encryptedSecretKey: encryptedSecretKey,
      bareSuperSignature: bareSuperSignature,
      superPublicKey: superPublicKey,
      signature: signature,
    );
    if (!sigValid) {
      return false;
    }

    final superSigValid = await _validateSuperSignature(
      superRecordKey: superRecordKey,
      superPublicKey: superPublicKey.value,
      publicKey: publicKey,
      superSignature: superSignature,
    );
    if (!superSigValid) {
      return false;
    }

    return true;
  }

  Future<VeilidCryptoSystem> validateIdentitySecret(SecretKey secretKey) async {
    final cs = await getCryptoSystem();
    final keyOk = await cs.validateKeyPair(publicKey, secretKey);
    if (!keyOk) {
      throw IdentityException.invalid;
    }
    return cs;
  }

  /// Delete this identity instance record
  /// Only deletes from the local machine not the DHT
  Future<void> delete() async {
    final pool = DHTRecordPool.instance;
    await pool.deleteRecord(recordKey);
  }

  /// Read the account record info for a specific applicationId from the
  /// identity instance record using the identity instance secret key to decrypt
  Future<List<AccountRecordInfo>> readAccount({
    required RecordKey superRecordKey,
    required SecretKey secretKey,
    required String applicationId,
  }) async {
    // Read the identity key to get the account keys
    final pool = DHTRecordPool.instance;

    final identityRecordCrypto = await _getPrivateCrypto(secretKey);

    late final List<AccountRecordInfo> accountRecordInfo;
    await (await pool.openRecordRead(
      recordKey,
      debugName: 'IdentityInstance::readAccounts::IdentityRecord',
      parent: superRecordKey,
      crypto: identityRecordCrypto,
    )).scope((identityRec) async {
      final identity = await identityRec.getJson(Identity.fromJson);
      if (identity == null) {
        // Identity could not be read or decrypted from DHT
        throw IdentityException.readError;
      }
      final accountRecords = IMapOfSets.from(identity.accountRecords);
      final vcAccounts = accountRecords.get(applicationId);

      accountRecordInfo = vcAccounts.toList();
    });

    return accountRecordInfo;
  }

  /// Creates a new Account associated with super identity and store it in the
  /// identity instance record.
  Future<AccountRecordInfo> addAccount({
    required RecordKey superRecordKey,
    required SecretKey secretKey,
    required String applicationId,
    required Future<Uint8List> Function(RecordKey parent) createAccountCallback,
    int maxAccounts = 1,
  }) async {
    final pool = DHTRecordPool.instance;

    /////// Add account with profile to DHT

    // Open identity key for writing
    veilidLoggy.debug('Opening identity record');
    return (await pool.openRecordWrite(
      recordKey,
      writer(secretKey),
      debugName: 'IdentityInstance::addAccount::IdentityRecord',
      parent: superRecordKey,
    )).scope((identityRec) async {
      // Create new account to insert into identity
      veilidLoggy.debug('Creating new account');
      return (await pool.createRecord(
        debugName:
            'IdentityInstance::addAccount::IdentityRecord::AccountRecord',
        parent: identityRec.key,
      )).deleteScope((accountRec) async {
        final account = await createAccountCallback(accountRec.key);
        // Write account key
        veilidLoggy.debug('Writing account record');
        await accountRec.eventualWriteBytes(account);

        // Update identity key to include account
        final newAccountRecordInfo = AccountRecordInfo(
          accountRecord: OwnedDHTRecordPointer(
            recordKey: accountRec.key,
            owner: accountRec.ownerKeyPair!.value,
          ),
        );

        veilidLoggy.debug('Updating identity with new account');
        await identityRec.eventualUpdateJson(Identity.fromJson, (
          oldIdentity,
        ) async {
          if (oldIdentity == null) {
            throw IdentityException.readError;
          }
          final oldAccountRecords = IMapOfSets.from(oldIdentity.accountRecords);

          if (oldAccountRecords.get(applicationId).length >= maxAccounts) {
            throw IdentityException.limitExceeded;
          }
          final accountRecords = oldAccountRecords
              .add(applicationId, newAccountRecordInfo)
              .asIMap();
          return oldIdentity.copyWith(accountRecords: accountRecords);
        });

        return newAccountRecordInfo;
      });
    });
  }

  /// Removes an Account associated with super identity from the identity
  /// instance record. 'removeAccountCallback' returns the account to be
  /// removed from the list passed to it.
  Future<bool> removeAccount({
    required RecordKey superRecordKey,
    required SecretKey secretKey,
    required String applicationId,
    required Future<AccountRecordInfo?> Function(
      List<AccountRecordInfo> accountRecordInfos,
    )
    removeAccountCallback,
  }) async {
    final pool = DHTRecordPool.instance;

    /////// Add account with profile to DHT

    // Open identity key for writing
    veilidLoggy.debug('Opening identity record');
    return (await pool.openRecordWrite(
      recordKey,
      writer(secretKey),
      debugName: 'IdentityInstance::addAccount::IdentityRecord',
      parent: superRecordKey,
    )).scope((identityRec) async {
      try {
        // Update identity key to remove account
        veilidLoggy.debug('Updating identity to remove account');
        await identityRec.eventualUpdateJson(Identity.fromJson, (
          oldIdentity,
        ) async {
          if (oldIdentity == null) {
            throw IdentityException.readError;
          }
          final oldAccountRecords = IMapOfSets.from(oldIdentity.accountRecords);

          // Get list of accounts associated with the application
          final vcAccounts = oldAccountRecords.get(applicationId);
          final accountRecordInfos = vcAccounts.toList();

          // Call the callback to return what account to remove
          final toRemove = await removeAccountCallback(accountRecordInfos);
          if (toRemove == null) {
            throw IdentityException.cancelled;
          }
          final newAccountRecords = oldAccountRecords
              .remove(applicationId, toRemove)
              .asIMap();

          return oldIdentity.copyWith(accountRecords: newAccountRecords);
        });
      } on IdentityException catch (e) {
        if (e == IdentityException.cancelled) {
          return false;
        }
        rethrow;
      }
      return true;
    });
  }

  Future<VeilidCryptoSystem> getCryptoSystem() =>
      Veilid.instance.getCryptoSystem(recordKey.kind);

  Future<CryptoCodec> _getPrivateCrypto(SecretKey secretKey) =>
      DHTRecordPool.privateCryptoFromSecretKey(secretKey);

  PublicKey get publicKey =>
      PublicKey(kind: recordKey.kind, value: barePublicKey);
  Signature get superSignature =>
      Signature(kind: recordKey.kind, value: bareSuperSignature);
  Signature get signature =>
      Signature(kind: recordKey.kind, value: bareSignature);

  KeyPair writer(SecretKey secret) {
    assert(secret.kind == recordKey.kind, 'secret kind must match record kind');
    return KeyPair(key: publicKey, secret: secret);
  }

  ////////////////////////////////////////////////////////////////////////////
  // Internal implementation

  static Uint8List _signatureBytes({
    required RecordKey recordKey,
    required BarePublicKey barePublicKey,
    required Uint8List encryptedSecretKey,
    required BareSignature bareSuperSignature,
  }) {
    final sigBuf = BytesBuilder()
      ..add(recordKey.opaque.toBytes())
      ..add(barePublicKey.toBytes())
      ..add(encryptedSecretKey)
      ..add(bareSuperSignature.toBytes());
    return sigBuf.toBytes();
  }

  static Future<bool> _validateIdentitySignature({
    required RecordKey recordKey,
    required BarePublicKey barePublicKey,
    required Uint8List encryptedSecretKey,
    required BareSignature bareSuperSignature,
    required PublicKey superPublicKey,
    required Signature signature,
  }) async {
    final cs = await Veilid.instance.getCryptoSystem(recordKey.kind);
    final identitySigBytes = _signatureBytes(
      recordKey: recordKey,
      barePublicKey: barePublicKey,
      encryptedSecretKey: encryptedSecretKey,
      bareSuperSignature: bareSuperSignature,
    );
    return cs.verify(superPublicKey, identitySigBytes, signature);
  }

  static Future<Signature> _createIdentitySignature({
    required RecordKey recordKey,
    required PublicKey publicKey,
    required Uint8List encryptedSecretKey,
    required Signature superSignature,
    required KeyPair superKeyPair,
  }) async {
    assert(
      publicKey.kind == recordKey.kind,
      'public key kind must match record kind',
    );
    assert(
      superSignature.kind == recordKey.kind,
      'super signature kind must match record kind',
    );
    final cs = await Veilid.instance.getCryptoSystem(recordKey.kind);
    final identitySigBytes = _signatureBytes(
      recordKey: recordKey,
      barePublicKey: publicKey.value,
      encryptedSecretKey: encryptedSecretKey,
      bareSuperSignature: superSignature.value,
    );
    return cs.sign(superKeyPair.key, superKeyPair.secret, identitySigBytes);
  }

  static Uint8List _superSignatureBytes({
    required RecordKey superRecordKey,
    required BarePublicKey superPublicKey,
  }) {
    final superSigBuf = BytesBuilder()
      ..add(superRecordKey.opaque.toBytes())
      ..add(superPublicKey.toBytes());
    return superSigBuf.toBytes();
  }

  static Future<bool> _validateSuperSignature({
    required RecordKey superRecordKey,
    required BarePublicKey superPublicKey,
    required PublicKey publicKey,
    required Signature superSignature,
  }) async {
    veilidLoggy.debug(
      '_validateSuperSignature:\n'
      'superRecordKey=$superRecordKey\n'
      'superPublicKey=$superPublicKey\n'
      'publicKey=$publicKey\n'
      'superSignature=$superSignature\n',
    );

    final cs = await Veilid.instance.getCryptoSystem(superRecordKey.kind);
    final superSigBytes = _superSignatureBytes(
      superRecordKey: superRecordKey,
      superPublicKey: superPublicKey,
    );
    return cs.verify(publicKey, superSigBytes, superSignature);
  }

  static Future<Signature> _createSuperSignature({
    required RecordKey superRecordKey,
    required BarePublicKey superPublicKey,
    required PublicKey publicKey,
    required SecretKey secretKey,
  }) async {
    veilidLoggy.debug(
      'createSuperSignature:\n'
      'superRecordKey=$superRecordKey\n'
      'superPublicKey=$superPublicKey\n'
      'publicKey=$publicKey\n'
      'secretKey=$secretKey\n',
    );

    final cs = await Veilid.instance.getCryptoSystem(superRecordKey.kind);
    final superSigBytes = _superSignatureBytes(
      superRecordKey: superRecordKey,
      superPublicKey: superPublicKey,
    );
    final signature = await cs.sign(publicKey, secretKey, superSigBytes);

    veilidLoggy.debug(
      'createSuperSignature returned:\n'
      'signature=$signature\n',
    );

    return signature;
  }
}
