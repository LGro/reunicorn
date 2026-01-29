// Copyright 2024 - 2026 The Reunicorn Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:veilid_support/veilid_support.dart';

import '../../models/models.dart';
import '../../utils.dart';
import 'veilid_dht.dart';

part 'encrypted_communication.freezed.dart';
part 'encrypted_communication.g.dart';

void _debugPrint(String message) => debugPrint('RCRN-E $message');

Uint8List padUint8ListRight(Uint8List original, int targetLength) {
  // If it's already the right size or larger, return it (or truncate if needed)
  if (original.length >= targetLength) {
    return original.sublist(0, targetLength);
  }

  // Create a new list of the fixed length (automatically filled with 0s)
  final paddedList = Uint8List(targetLength)
    // Copy original data starting at index 0
    ..setRange(0, original.length, original);

  return paddedList;
}

Uint8List trimPaddedUint8List(Uint8List padded) {
  // Find the index of the first null byte
  final firstNull = padded.indexOf(0);

  // If no null is found, use the whole length; otherwise, use the index
  final end = (firstNull == -1) ? padded.length : firstNull;

  return padded.sublist(0, end);
}

// TODO(LGro): Drop share back writer when handshake ack to reduce risk of leaking it
@freezed
sealed class EncryptionMetaData with _$EncryptionMetaData {
  static const byteLength = 343;

  const factory EncryptionMetaData({
    /// DHT record key for recipient to share back
    RecordKey? shareBackDHTKey,

    /// DHT record writer for recipient to share back
    KeyPair? shareBackDHTWriter,

    /// The next author public key for the recipient to use when encrypting
    /// their shared back information and to try when decrypting the next update
    PublicKey? shareBackPubKey,
    @Default(false) bool ackHandshakeComplete,
  }) = _EncryptionMetaData;

  const EncryptionMetaData._();

  factory EncryptionMetaData.fromJson(Map<String, dynamic> json) =>
      _$EncryptionMetaDataFromJson(json);

  Uint8List toBytes() => padUint8ListRight(
    Uint8List.fromList(utf8.encode(jsonEncode(toJson()))),
    byteLength,
  );

  static (EncryptionMetaData, Uint8List) fromBytes(Uint8List data) => (
    EncryptionMetaData.fromJson(
      jsonDecode(
            utf8.decode(
              trimPaddedUint8List(
                Uint8List.fromList(data.getRange(0, byteLength).toList()),
              ),
            ),
          )
          as Map<String, dynamic>,
    ),
    Uint8List.fromList(data.getRange(byteLength, data.length).toList()),
  );
}

Future<VeilidCryptoPrivate?> getVeilidEncryptionCrypto(
  CryptoState cryptoState,
) async {
  switch (cryptoState) {
    // Symmetric crypto
    case CryptoInitializedSymmetric(:final initialSharedSecret) ||
        CryptoEstablishedSymmetric(:final initialSharedSecret):
      return VeilidCryptoPrivate.fromSharedSecret(
        initialSharedSecret.kind,
        initialSharedSecret,
      );

    // Asymmetric crypto
    // Always encrypt with the next available one to signal we received it
    case CryptoInitializedAsymmetric(
          :final myKeyPair,
          :final theirNextPublicKey,
        ) ||
        CryptoEstablishedAsymmetric(
          :final myKeyPair,
          :final theirNextPublicKey,
        ):
      return Veilid.instance
          .getCryptoSystem(myKeyPair.kind)
          .then(
            (cs) => cs.generateSharedSecret(
              theirNextPublicKey,
              myKeyPair.secret,
              utf8.encode('dht'),
            ),
          )
          .then(
            (secret) =>
                VeilidCryptoPrivate.fromSharedSecret(secret.kind, secret),
          );
    case CryptoPendingAsymmetric():
      return null;
  }
}

String _short(Object? value) =>
    value?.toString().substring(0, min(10, value.toString().length)) ?? 'null';

Future<(KeyPair?, PublicKey?, EncryptionMetaData?, Uint8List?)> decrypt(
  Uint8List data,
  CryptoState crypto,
) async {
  final domain = utf8.encode('dht');
  final secrets = <(KeyPair?, PublicKey?, SharedSecret?)>[
    ...await crypto.map(
      pendingAsymmetric: (s) => [(null, null, null)],
      initializedSymmetric: (s) => [(null, null, s.initialSharedSecret)],
      establishedSymmetric: (s) async => [
        // Already try asymmetric ...
        (
          s.myNextKeyPair,
          s.theirNextPublicKey,
          await Veilid.instance
              .getCryptoSystem(s.myNextKeyPair.kind)
              .then(
                (cs) => cs.generateSharedSecret(
                  s.theirNextPublicKey,
                  s.myNextKeyPair.secret,
                  domain,
                ),
              ),
        ),
        // ... but fall back to symmetric
        (null, null, s.initialSharedSecret),
      ],
      initializedAsymmetric: (s) async =>
          <(KeyPair?, PublicKey?, SharedSecret)>[
            ...(await Future.wait(
              [
                    (s.myNextKeyPair, s.theirNextPublicKey),
                    (s.myKeyPair, s.theirNextPublicKey),
                  ]
                  .map(
                    (v) async => (
                      v.$1,
                      v.$2,
                      await Veilid.instance
                          .getCryptoSystem(v.$1.kind)
                          .then(
                            (cs) => cs.generateSharedSecret(
                              v.$2,
                              v.$1.secret,
                              domain,
                            ),
                          ),
                    ),
                  )
                  .toList(),
            )),
            // Still include fall back to symmetric
            (null, null, s.initialSharedSecret),
          ],
      // Try all combinations for asymmetric crypto
      establishedAsymmetric: (s) => Future.wait(
        [
          (s.myKeyPair, s.theirPublicKey),
          (s.myKeyPair, s.theirNextPublicKey),
          (s.myNextKeyPair, s.theirPublicKey),
          (s.myNextKeyPair, s.theirNextPublicKey),
        ].map(
          (v) async => (
            v.$1,
            v.$2,
            await Veilid.instance
                .getCryptoSystem(v.$1.kind)
                .then(
                  (cs) => cs.generateSharedSecret(v.$2, v.$1.secret, domain),
                ),
          ),
        ),
      ),
    ),
  ];

  _debugPrint('trying ${secrets.length} secrets');
  for (final (kp, pubKey, sharedSecret) in secrets) {
    if (sharedSecret == null) {
      continue;
    }
    if (pubKey == null && kp == null) {
      _debugPrint('trying psk ${_short(sharedSecret)}');
    } else {
      _debugPrint('trying pub ${_short(pubKey)} kp ${_short(kp)}');
    }

    final Uint8List decryptedData;
    try {
      decryptedData = await VeilidCryptoPrivate.fromSharedSecret(
        sharedSecret.kind,
        sharedSecret,
      ).then((dc) => dc.decrypt(data));
    } on FormatException catch (e) {
      _debugPrint('failed to decrypt with $e');
      // This seems to happen for the "not enough bytes to decrypt" case
      return (null, null, null, null);
    }

    try {
      final (metaData, payload) = EncryptionMetaData.fromBytes(decryptedData);
      if (pubKey == null && kp == null) {
        _debugPrint('got with psk ${_short(sharedSecret)}');
      } else {
        _debugPrint('got with pub ${_short(pubKey)} kp ${_short(kp)}');
      }
      return (kp, pubKey, metaData, payload);
    } catch (e) {
      // TODO(LGro): Try previous schema versions (e.g. different
      //             EncryptionMetaData sizes).
      continue;
    }
  }

  _debugPrint('nothing found');
  return (null, null, null, null);
}

EncryptionMetaData encryptionMetaData(
  DhtConnectionState connection,
  CryptoState crypto,
) => connection.maybeMap(
  initialized: (s) => EncryptionMetaData(
    shareBackDHTKey: s.recordKeyThemSharing,
    shareBackDHTWriter: s.writerThemSharing,
    shareBackPubKey: crypto.myNextKeyPair.key,
    ackHandshakeComplete: crypto.theirNextPublicKeyOrNull != null,
  ),
  orElse: () => EncryptionMetaData(
    shareBackPubKey: crypto.myNextKeyPair.key,
    ackHandshakeComplete: crypto.theirNextPublicKeyOrNull != null,
  ),
);

Future<CryptoState> evolveCryptoState(
  CryptoState cryptoState, {
  required PublicKey? shareBackPubKey,
  required PublicKey? usedPublicKey,
  required KeyPair? usedKeyPair,
  required bool ackHandshakeComplete,
  Future<KeyPair> Function() keyPairGenerator = generateKeyPairBest,
}) async => cryptoState.map(
  // Initialized Symmetric
  initializedSymmetric: (s) {
    if (shareBackPubKey == null) {
      return s;
    }
    _debugPrint('CS: initialized to established symmetric');
    return CryptoState.establishedSymmetric(
      // unchanged
      initialSharedSecret: s.initialSharedSecret,
      myNextKeyPair: s.myNextKeyPair,
      // new info
      theirNextPublicKey: shareBackPubKey,
    );
  },
  // Established Symmetric
  establishedSymmetric: (s) async {
    // If we either do not have a share back public key yet, or we do but they
    // haven't queued another one for rotation yet
    if (shareBackPubKey == null || !ackHandshakeComplete) {
      return s;
    }
    _debugPrint('CS: established symmetric to initialized asymmetric');
    return CryptoState.initializedAsymmetric(
      initialSharedSecret: s.initialSharedSecret,
      myKeyPair: s.myNextKeyPair,
      myNextKeyPair: await keyPairGenerator(),
      theirNextPublicKey: shareBackPubKey,
    );
  },
  // Pending Asymmetric
  pendingAsymmetric: (s) => s,
  // Initialized Asymmetric
  initializedAsymmetric: (s) async {
    if (usedPublicKey == null || usedKeyPair == null) {
      return s;
    }
    _debugPrint('CS: initialized to established asymmetric');
    return CryptoState.establishedAsymmetric(
      myKeyPair: usedKeyPair,
      theirPublicKey: usedPublicKey,
      myNextKeyPair: (usedKeyPair == s.myNextKeyPair)
          ? await keyPairGenerator()
          : s.myNextKeyPair,
      theirNextPublicKey: shareBackPubKey ?? s.theirNextPublicKey,
    );
  },
  // Established Asymmetric
  establishedAsymmetric: (s) async {
    if (usedPublicKey == null || usedKeyPair == null) {
      return s;
    }
    _debugPrint('CS: rotated established asymmetric');
    return CryptoState.establishedAsymmetric(
      // new info
      myKeyPair: usedKeyPair,
      theirPublicKey: usedPublicKey,
      myNextKeyPair: (usedKeyPair == s.myNextKeyPair)
          ? await keyPairGenerator()
          : s.myNextKeyPair,
      theirNextPublicKey: shareBackPubKey ?? s.theirNextPublicKey,
    );
  },
);

Future<DhtConnectionInitialized> initializeEncryptedDhtConnection(
  BaseDht dht,
  CryptoState cryptoState,
) async {
  // Init sharing settings
  final (shareKey, shareWriter) = await dht.create();

  // Init receiving settings
  final (receiveKey, receiveWriter) = await dht.create();

  final connectionState =
      DhtConnectionState.initialized(
            recordKeyMeSharing: shareKey,
            writerMeSharing: shareWriter,
            recordKeyThemSharing: receiveKey,
            writerThemSharing: receiveWriter,
          )
          as DhtConnectionInitialized;

  // Already try to make the share back information available
  final encryptionCrypto = await getVeilidEncryptionCrypto(cryptoState);
  if (encryptionCrypto != null) {
    try {
      await dht.write(
        shareKey,
        shareWriter,
        await encryptionCrypto.encrypt(
          EncryptionMetaData(
            shareBackDHTKey: receiveKey,
            shareBackDHTWriter: receiveWriter,
          ).toBytes(),
        ),
      );
    } catch (e) {
      // Best effort, doesn't matter if that fails
    }
  }

  return connectionState;
}

Future<(T?, DhtConnectionState, CryptoState)>
readEncrypted<T extends BinarySerializable>(
  BaseDht dht,
  DhtConnectionState connectionState,
  CryptoState cryptoState,
  T Function(Uint8List) decodePayload,
) async {
  final shortDhtKey = _short(connectionState.recordKeyThemSharing);
  final Uint8List? encryptedPayload;
  try {
    // Try reading DHT record
    encryptedPayload = await dht.read(connectionState.recordKeyThemSharing);
  } on DHTExceptionNotAvailable {
    _debugPrint('tried reading $shortDhtKey but dht unavailable');
    return (null, connectionState, cryptoState);
  } on DHTExceptionNoRecord {
    // TODO(LGro): Is this a retry scenario, or do we need to inform the user
    //             that something more fundamental is broken?
    _debugPrint('tried reading $shortDhtKey but record not found');
    return (null, connectionState, cryptoState);
  } on StateError catch (e) {
    // TODO(LGro): This was observed when a record is already closed
    _debugPrint('tried reading $shortDhtKey but got state error $e');
    return (null, connectionState, cryptoState);
  }

  if (encryptedPayload == null) {
    _debugPrint('no payload for $shortDhtKey');
    return (null, connectionState, cryptoState);
  }

  // Try decrypting payload
  final (usedKeyPair, usedPublicKey, metaData, payload) = await decrypt(
    encryptedPayload,
    cryptoState,
  );

  if (metaData == null || payload == null) {
    _debugPrint('read $shortDhtKey but could not decrypt');
    return (null, connectionState, cryptoState);
  }

  cryptoState = await evolveCryptoState(
    cryptoState,
    shareBackPubKey: metaData.shareBackPubKey,
    usedPublicKey: usedPublicKey,
    usedKeyPair: usedKeyPair,
    ackHandshakeComplete: metaData.ackHandshakeComplete,
  );

  // If are in an invited state without any sharing connection infos and we've
  // just received a share back record, evolve the connection to established
  if (connectionState is DhtConnectionInvited &&
      metaData.shareBackDHTKey != null &&
      metaData.shareBackDHTWriter != null) {
    connectionState = DhtConnectionState.established(
      recordKeyMeSharing: metaData.shareBackDHTKey!,
      writerMeSharing: metaData.shareBackDHTWriter!,
      recordKeyThemSharing: connectionState.recordKeyThemSharing,
    );
  }

  try {
    final decodedPayload = decodePayload(payload);
    _debugPrint('read $shortDhtKey, decrypted, decoded payload successfully');
    return (decodedPayload, connectionState, cryptoState);
  } catch ($e) {
    _debugPrint('read and decrypted $shortDhtKey but failed decoding payload');
  }

  return (null, connectionState, cryptoState);
}

// FIXME(LGro): this still doesn't bring back the correct plaintext
Future<T?> _readMyEncrypted<T extends BinarySerializable>(
  BaseDht dht,
  DhtConnectionState connectionState,
  CryptoState cryptoState,
  T Function(Uint8List) decodePayload,
) async {
  if (connectionState.recordKeyMeSharingOrNull == null) {
    return null;
  }
  final Uint8List? encryptedPayload;
  try {
    encryptedPayload = await dht.read(
      connectionState.recordKeyMeSharingOrNull!,
      local: true,
    );
  } on DHTExceptionNotAvailable {
    return null;
  } on DHTExceptionNoRecord {
    // This shouldn't happen when reading our own record locally
    return null;
  }
  if (encryptedPayload == null) {
    return null;
  }
  try {
    final (_, _, metaData, payload) = await decrypt(
      encryptedPayload,
      cryptoState,
    );
    if (payload != null) {
      return decodePayload(payload);
    }
  } on FormatException {
    return null;
  }
}

// TODO(LGro): Only populate the next key pair here when writing updates to
// avoid triggering a loop of useless key rotations
Future<bool> writeEncrypted<T extends BinarySerializable>(
  BaseDht dht,
  T? value,
  DhtConnectionState connectionState,
  CryptoState cryptoState,
) async {
  switch (connectionState) {
    case DhtConnectionInvited():
      // Can't write yet, need to read first
      _debugPrint(
        'trying to write but no record key to write to or writer to use',
      );
      return false;

    // We extract the fields into final local variables directly
    case DhtConnectionInitialized(
          :final recordKeyMeSharing,
          :final writerMeSharing,
        ) ||
        DhtConnectionEstablished(
          :final recordKeyMeSharing,
          :final writerMeSharing,
        ):
      final payload = Uint8List.fromList([
        ...encryptionMetaData(connectionState, cryptoState).toBytes(),
        if (value != null) ...value.toBytes(),
      ]);

      final encryptionCrypto = await getVeilidEncryptionCrypto(cryptoState);
      if (encryptionCrypto == null) {
        return false;
      }
      final encryptedPayload = await encryptionCrypto.encrypt(payload);

      try {
        //TODO(LGro): Check encrypted payload size < DHT record limit?
        //            Or leave it to dht layer to start spreading across records?
        await dht.write(recordKeyMeSharing, writerMeSharing, encryptedPayload);
        return true;
      } on DHTExceptionNotAvailable catch (e) {
        _debugPrint('dht error for ${_short(recordKeyMeSharing)} $e');
        return false;
      }
  }
}
