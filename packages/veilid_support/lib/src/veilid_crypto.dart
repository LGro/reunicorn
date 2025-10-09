import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import '../../../veilid_support.dart';
import 'crypto_codec.dart';

////////////////////////////////////
/// Encrypted for a specific symmetric key
class VeilidCryptoPrivate implements CryptoCodec {
  final VeilidCryptoSystem _cryptoSystem;

  final SharedSecret _secret;

  VeilidCryptoPrivate._(VeilidCryptoSystem cryptoSystem, SharedSecret secretKey)
    : _cryptoSystem = cryptoSystem,
      _secret = secretKey;

  static Future<VeilidCryptoPrivate> fromSecretKey(
    SecretKey secretKey,
    String domain,
  ) async {
    final cryptoSystem = await Veilid.instance.getCryptoSystem(secretKey.kind);
    final keyMaterial = Uint8List.fromList([
      ...secretKey.value.toBytes(),
      ...utf8.encode(domain),
    ]);
    final secretHash = await cryptoSystem.generateHash(keyMaterial);
    final sharedSecret = SharedSecret.fromBytes(secretHash.toBytes());
    return VeilidCryptoPrivate._(cryptoSystem, sharedSecret);
  }

  static Future<VeilidCryptoPrivate> fromKeyPair(
    KeyPair keyPair,
    String domain,
  ) => fromSecretKey(keyPair.secret, domain);

  static Future<VeilidCryptoPrivate> fromSharedSecret(
    CryptoKind kind,
    SharedSecret sharedSecret,
  ) async {
    final cryptoSystem = await Veilid.instance.getCryptoSystem(kind);
    return VeilidCryptoPrivate._(cryptoSystem, sharedSecret);
  }

  @override
  Future<Uint8List> encrypt(Uint8List data) =>
      _cryptoSystem.encryptNoAuthWithNonce(data, _secret);

  @override
  Future<Uint8List> decrypt(Uint8List data) =>
      _cryptoSystem.decryptNoAuthWithNonce(data, _secret);
}

////////////////////////////////////
/// No encryption
class VeilidCryptoPublic implements CryptoCodec {
  const VeilidCryptoPublic();

  @override
  Future<Uint8List> encrypt(Uint8List data) async => data;

  @override
  Future<Uint8List> decrypt(Uint8List data) async => data;
}
