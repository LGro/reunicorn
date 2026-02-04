// Copyright 2024 - 2026 The Reunicorn Authors. All rights reserved.
// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:reunicorn/data/models/utils.dart';
import 'package:veilid_support/veilid_support.dart';
import 'package:vodozemac/vodozemac.dart' as vod;

import '../../models/models.dart';
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

@freezed
sealed class MessageWithEncryptionMetaData
    with _$MessageWithEncryptionMetaData {
  const factory MessageWithEncryptionMetaData({
    /// DHT record key for recipient to share back
    RecordKey? shareBackDHTKey,

    /// DHT record writer for recipient to share back
    KeyPair? shareBackDHTWriter,

    /// DHT record writer of sender to support deniability of shared info
    KeyPair? deniabilitySharingWriter,

    /// Base64 encoded vodozemac curve25519 one-time-key
    String? oneTimeKey,

    /// JSON message
    Map<String, dynamic>? message,
  }) = _MessageWithEncryptionMetaData;

  const MessageWithEncryptionMetaData._();

  factory MessageWithEncryptionMetaData.fromJson(Map<String, dynamic> json) =>
      _$MessageWithEncryptionMetaDataFromJson(json);

  String toJsonString() => jsonEncode(toJson());

  static MessageWithEncryptionMetaData? fromJsonString(String data) {
    try {
      return MessageWithEncryptionMetaData.fromJson(
        jsonDecode(data) as Map<String, dynamic>,
      );
    } on FormatException {
      return null;
    }
  }

  Uint8List toBytes() => utf8.encode(toJsonString());

  static MessageWithEncryptionMetaData? fromBytes(Uint8List data) =>
      fromJsonString(utf8.decode(data));
}

String _short(Object? value) =>
    value?.toString().substring(0, min(10, value.toString().length)) ?? 'null';

MessageWithEncryptionMetaData encryptionMetaData(
  DhtConnectionState connection,
  CryptoState crypto,
) {
  final metaData = connection.maybeMap(
    initialized: (s) => MessageWithEncryptionMetaData(
      shareBackDHTKey: s.recordKeyThemSharing,
      shareBackDHTWriter: s.writerThemSharing,
    ),
    established: (s) => MessageWithEncryptionMetaData(
      deniabilitySharingWriter: s.writerMeSharing,
    ),
    orElse: () => MessageWithEncryptionMetaData(),
  );
  return crypto.map(
    vodozemac: (s) => metaData,
    symToVod: (s) => metaData,
    symmetric: (s) {
      final account = vod.Account.fromPickleEncrypted(
        pickle: s.accountVod,
        pickleKey: Uint8List(32),
      );
      return metaData.copyWith(
        oneTimeKey: account.oneTimeKeys.values.first.toBase64(),
      );
    },
  );
}

Future<CryptoState> evolveCryptoState(
  CryptoState cryptoState, {
  String? theirIdentityKey,
  String? theirOnetimeKey,
}) async => cryptoState.map(
  symmetric: (s) {
    if (theirIdentityKey == null || theirOnetimeKey == null) {
      return s;
    }
    final account = vod.Account();
    final session = account.createOutboundSession(
      identityKey: vod.Curve25519PublicKey.fromBase64(theirIdentityKey),
      oneTimeKey: vod.Curve25519PublicKey.fromBase64(theirOnetimeKey),
    );
    return CryptoState.symToVod(
      sharedSecret: s.sharedSecret,
      theirIdentityKey: theirIdentityKey,
      myIdentityKey: account.identityKeys.curve25519.toBase64(),
      sessionVod: session.toPickleEncrypted(Uint8List(32)),
    );
  },
  symToVod: (s) => s,
  vodozemac: (s) => s,
);

vod.Curve25519PublicKey? curve25519PublicKeyFromBytesOrNull(Uint8List bytes) {
  try {
    return vod.Curve25519PublicKey.fromBytes(bytes);
  } catch (e) {
    return null;
  }
}

Future<(DhtConnectionInitialized, CryptoState)>
initializeEncryptedDhtConnection(BaseDht dht, CryptoState cryptoState) async {
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

  try {
    // Already try to make the share back information available
    return await encryptAndPrependVodInfo(
      jsonEncode(encryptionMetaData(connectionState, cryptoState).toJson()),
      cryptoState,
    ).then(
      (v) async => dht
          .write(shareKey, shareWriter, v.$1)
          .then((_) async => (connectionState, v.$2)),
    );
  } catch (e) {
    // Best effort, doesn't matter if that fails
  }

  return (connectionState, cryptoState);
}

Future<String?> decryptSymmetric(
  Uint8List ciphertext,
  SharedSecret sharedSecret,
) async {
  try {
    final payload = await VeilidCryptoPrivate.fromSharedSecret(
      sharedSecret.kind,
      sharedSecret,
    ).then((crypto) => crypto.decrypt(ciphertext));
    return utf8.decode(payload);
  } on FormatException {
    // This seems to happen for the "not enough bytes to decrypt" case
  }
  return null;
}

Future<(String?, String)> decryptVodozemacEstablished(
  int messageType,
  Uint8List ciphertext,
  String session,
) async {
  try {
    final _session = vod.Session.fromPickleEncrypted(
      pickle: session,
      pickleKey: Uint8List(32),
    );
    final payload = _session.decrypt(
      messageType: messageType,
      ciphertext: utf8.decode(ciphertext),
    );
    _debugPrint('successfully decrypted vodozemac');
    return (payload, _session.toPickleEncrypted(Uint8List(32)));
  } catch (e) {
    // TODO(LGro): This should actually not happen
    _debugPrint('could not decrypt vodozemac');
  }
  return (null, session);
}

Future<(String?, CryptoState, String?)> decrypt(
  Uint8List payload,
  CryptoState cryptoState,
) async {
  if (payload.isEmpty) {
    _debugPrint('no payload to decrypt');
    return (null, cryptoState, null);
  }

  final messageType = payload[0];
  final theirIdentityKey = curve25519PublicKeyFromBytesOrNull(
    payload.sublist(1, 33),
  );
  final ciphertext = payload.sublist(33);

  return cryptoState.map(
    // Symmetric crypto
    symmetric: (s) async {
      // Try vodozemac encryption
      if (theirIdentityKey != null) {
        _debugPrint('trying to decrypt vodozemac for the first time');
        try {
          final myAccount = vod.Account.fromPickleEncrypted(
            pickle: s.accountVod,
            pickleKey: Uint8List(32),
          );
          final decrypted = myAccount.createInboundSession(
            theirIdentityKey: theirIdentityKey,
            // TODO(LGro): What about base64?
            preKeyMessageBase64: utf8.decode(ciphertext),
          );
          final updatedCryptoState = CryptoState.symToVod(
            sharedSecret: s.sharedSecret,
            theirIdentityKey: theirIdentityKey.toBase64(),
            myIdentityKey: myAccount.identityKeys.curve25519.toBase64(),
            sessionVod: decrypted.session.toPickleEncrypted(Uint8List(32)),
          );
          _debugPrint(
            'successfully decrypted with vodozemac for the first time',
          );
          return (
            decrypted.plaintext,
            updatedCryptoState,
            theirIdentityKey.toBase64(),
          );
        } catch (e) {
          _debugPrint('failed to decrypt vodozemac for the first time: $e');
        }
      }

      // Fall back to symmetric encryption
      final payload = await decryptSymmetric(ciphertext, s.sharedSecret);
      _debugPrint(
        'decrypting symmetric ${(payload == null) ? 'failed' : 'succeeded'}',
      );
      return (payload, s, theirIdentityKey?.toBase64());
    },

    // Transition between symmetric and vodozemac crypto
    symToVod: (s) async {
      _debugPrint('trying decrypt established vodozemac');
      final (plaintextVod, session) = await decryptVodozemacEstablished(
        messageType,
        ciphertext,
        s.sessionVod,
      );
      if (plaintextVod != null) {
        return (
          plaintextVod,
          CryptoState.vodozemac(
            theirIdentityKey: s.theirIdentityKey,
            myIdentityKey: s.myIdentityKey,
            sessionVod: session,
          ),
          theirIdentityKey?.toBase64(),
        );
      }

      // Fall back to symmetric encryption
      final plaintextSym = await decryptSymmetric(ciphertext, s.sharedSecret);
      _debugPrint(
        'decrypting symmetric ${(plaintextSym == null) ? 'failed' : 'succeeded'}',
      );
      return (plaintextSym, s, theirIdentityKey?.toBase64());
    },

    // Established vodozemac crypto
    vodozemac: (s) async {
      _debugPrint('trying decrypt established vodozemac');
      final (plaintextVod, session) = await decryptVodozemacEstablished(
        messageType,
        ciphertext,
        s.sessionVod,
      );
      return (
        plaintextVod,
        s.copyWith(sessionVod: session),
        theirIdentityKey?.toBase64(),
      );
    },
  );
}

Future<(T?, DhtConnectionState, CryptoState)>
readEncrypted<T extends BinarySerializable>(
  BaseDht dht,
  DhtConnectionState connectionState,
  CryptoState cryptoState,
  T Function(Map<String, dynamic>) decodePayload,
) async {
  final shortDhtKey = _short(connectionState.recordKeyThemSharing);
  final Uint8List? dhtValue;
  try {
    // Try reading DHT record
    dhtValue = await dht.read(connectionState.recordKeyThemSharing);
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

  if (dhtValue == null) {
    _debugPrint('no dht value for $shortDhtKey');
    return (null, connectionState, cryptoState);
  }

  final String? decryptedDhtValue;
  final String? theirIdentityKey;
  (decryptedDhtValue, cryptoState, theirIdentityKey) = await decrypt(
    dhtValue,
    cryptoState,
  );

  if (decryptedDhtValue == null) {
    _debugPrint('read $shortDhtKey but could not decrypt');
    return (null, connectionState, cryptoState);
  }
  final payload = MessageWithEncryptionMetaData.fromJsonString(
    decryptedDhtValue,
  );

  if (payload == null) {
    _debugPrint(
      'read and decrypted $shortDhtKey but could not parse meta data',
    );
    return (null, connectionState, cryptoState);
  }

  cryptoState = await evolveCryptoState(
    cryptoState,
    theirIdentityKey: theirIdentityKey,
    theirOnetimeKey: payload.oneTimeKey,
  );

  // If are in an invited state without any sharing connection infos and we've
  // just received a share back record, evolve the connection to established
  if (connectionState is DhtConnectionInvited &&
      payload.shareBackDHTKey != null &&
      payload.shareBackDHTWriter != null) {
    connectionState = DhtConnectionState.established(
      recordKeyMeSharing: payload.shareBackDHTKey!,
      writerMeSharing: payload.shareBackDHTWriter!,
      recordKeyThemSharing: connectionState.recordKeyThemSharing,
    );
  }

  if (payload.message != null) {
    try {
      final decodedPayload = decodePayload(payload.message!);
      _debugPrint('read $shortDhtKey, decrypted, decoded payload successfully');
      return (decodedPayload, connectionState, cryptoState);
    } catch ($e) {
      _debugPrint(
        'read and decrypted $shortDhtKey but failed decoding payload',
      );
    }
  }

  return (null, connectionState, cryptoState);
}

Future<(Uint8List, CryptoState)> encryptAndPrependVodInfo(
  String payload,
  CryptoState cryptoState,
) async => cryptoState.map(
  symmetric: (s) async {
    _debugPrint('encrypting symmetric');
    final account = vod.Account.fromPickleEncrypted(
      pickle: s.accountVod,
      pickleKey: Uint8List(32),
    );
    final encrypted = await VeilidCryptoPrivate.fromSharedSecret(
      s.sharedSecret.kind,
      s.sharedSecret,
    ).then((dc) => dc.encrypt(utf8.encode(payload)));
    return (
      Uint8List.fromList([
        0,
        ...account.identityKeys.curve25519.toBytes(),
        ...encrypted,
      ]),
      cryptoState,
    );
  },
  symToVod: (s) async {
    _debugPrint('encrypting symToVod with vod');
    final session = vod.Session.fromPickleEncrypted(
      pickle: s.sessionVod,
      pickleKey: Uint8List(32),
    );
    final encrypted = session.encrypt(payload);
    return (
      Uint8List.fromList([
        encrypted.messageType,
        ...vod.Curve25519PublicKey.fromBase64(s.myIdentityKey).toBytes(),
        ...utf8.encode(encrypted.ciphertext),
      ]),
      s.copyWith(sessionVod: session.toPickleEncrypted(Uint8List(32))),
    );
  },
  vodozemac: (s) async {
    _debugPrint('encrypting established vod');
    final session = vod.Session.fromPickleEncrypted(
      pickle: s.sessionVod,
      pickleKey: Uint8List(32),
    );
    final encrypted = session.encrypt(payload);
    return (
      Uint8List.fromList([
        encrypted.messageType,
        ...vod.Curve25519PublicKey.fromBase64(s.myIdentityKey).toBytes(),
        ...utf8.encode(encrypted.ciphertext),
      ]),
      s.copyWith(sessionVod: session.toPickleEncrypted(Uint8List(32))),
    );
  },
);

Future<CryptoState?> writeEncrypted<T extends JsonEncodable>(
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
      return null;

    // We extract the fields into final local variables directly
    case DhtConnectionInitialized(
          :final recordKeyMeSharing,
          :final writerMeSharing,
        ) ||
        DhtConnectionEstablished(
          :final recordKeyMeSharing,
          :final writerMeSharing,
        ):
      final (
        encryptedPayloadWithVodInfo,
        updatedCryptoState,
      ) = await encryptAndPrependVodInfo(
        encryptionMetaData(
          connectionState,
          cryptoState,
        ).copyWith(message: value?.toJson()).toJsonString(),

        cryptoState,
      );

      try {
        //TODO(LGro): Check encrypted payload size < DHT record limit?
        //            Or leave it to dht layer to start spreading across records?
        await dht.write(
          recordKeyMeSharing,
          writerMeSharing,
          encryptedPayloadWithVodInfo,
        );
        return updatedCryptoState;
      } on DHTExceptionNotAvailable catch (e) {
        _debugPrint('dht error for ${_short(recordKeyMeSharing)} $e');
        return null;
      }
  }
}
