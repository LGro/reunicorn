// Copyright 2024 - 2026 The Reunicorn Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:veilid_support/veilid_support.dart';

import '../models/coag_contact.dart';
import '../repositories/contact_dht.dart';
import '../utils.dart';

part 'dht_communication.freezed.dart';
part 'dht_communication.g.dart';

abstract class BaseDht {
  Future<(RecordKey, KeyPair)> create();
  Future<void> write(RecordKey key, Uint8List value);
  Future<Uint8List?> read(RecordKey key);
  Future<void> watch(RecordKey key, Future<void> Function(Uint8List) callback);
}

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
sealed class EncryptionMetaData with _$EncryptionMetaData {
  // TODO(LGro): Shrink this down to the required maximum
  static const byteLength = 400;

  const EncryptionMetaData._();

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

DhtSettings updateDhtSettings(
  DhtSettings settings,
  EncryptionMetaData update,
) => settings.copyWith(
  // If the update contains a public key and it is not already the one in
  // use, add it as the next candidate public key
  theirNextPublicKey:
      (update.shareBackPubKey != null &&
          update.shareBackPubKey != settings.theirPublicKey)
      ? update.shareBackPubKey
      : null,
  recordKeyMeSharing: update.shareBackDHTKey,
  writerMeSharing: update.shareBackDHTWriter,
  // Prevent going back to unacknowledged when a contact sends false
  theyAckHandshakeComplete:
      settings.theyAckHandshakeComplete || update.ackHandshakeComplete,
);

Future<VeilidCryptoPrivate?> getVeilidEncryptionCrypto(
  DhtSettings settings,
) async {
  if (settings.recordKeyMeSharing == null) {
    return null;
  }

  // Prefer their next public key over the established one for sending updates
  final theirPublicKey = settings.theirNextPublicKey ?? settings.theirPublicKey;

  // TODO: Is it safe to assume consistent crypto systems between record key
  //       and psk/public keys or would it make sense to use typed instances?
  final SharedSecret secret;
  if (settings.initialSecret != null && !settings.theyAckHandshakeComplete) {
    // Otherwise, if an initial secret is present, use it for symmetric crypto
    secret = settings.initialSecret!;
    debugPrint(
      'using psk ${secret.toString().substring(0, 10)} '
      'for writing ${settings.recordKeyMeSharing.toString().substring(0, 10)}',
    );
  } else if (theirPublicKey != null && settings.myKeyPair != null) {
    // If a next public key is queued, use it to confirm
    debugPrint(
      'using their pubkey ${theirPublicKey.toString().substring(0, 10)} '
      'and my kp ${settings.myKeyPair!.key.toString().substring(0, 10)} '
      'for writing ${settings.recordKeyMeSharing.toString().substring(0, 10)}',
    );
    // Derive DH secret with next public key
    secret = await Veilid.instance
        .getCryptoSystem(settings.myKeyPair!.kind)
        .then(
          (cs) => cs.generateSharedSecret(
            theirPublicKey,
            settings.myKeyPair!.secret,
            utf8.encode('dht'),
          ),
        );
  } else {
    // TODO: Raise Exception / signal to user that something is broken
    debugPrint(
      'no crypto for '
      '${settings.recordKeyMeSharing.toString().substring(0, 10)}',
    );
    return null;
  }

  return VeilidCryptoPrivate.fromSharedSecret(
    settings.recordKeyMeSharing!.kind,
    secret,
  );
}

String _short(Object? value) =>
    value?.toString().substring(0, min(10, value.toString().length)) ?? 'null';

Future<(KeyPair?, PublicKey?, EncryptionMetaData?, Uint8List?)> decrypt(
  Uint8List data,
  DhtSettings settings,
) async {
  final domain = utf8.encode('dht');
  final secrets = <(KeyPair?, PublicKey?, SharedSecret)>[
    if (settings.theirNextPublicKey != null && settings.myNextKeyPair != null)
      (
        settings.myNextKeyPair,
        settings.theirNextPublicKey,
        await Veilid.instance
            .getCryptoSystem(settings.myNextKeyPair!.kind)
            .then(
              (cs) => cs.generateSharedSecret(
                settings.theirNextPublicKey!,
                settings.myNextKeyPair!.secret,
                domain,
              ),
            ),
      ),

    if (settings.theirNextPublicKey != null && settings.myKeyPair != null)
      (
        settings.myKeyPair,
        settings.theirNextPublicKey,
        await Veilid.instance
            .getCryptoSystem(settings.myKeyPair!.kind)
            .then(
              (cs) => cs.generateSharedSecret(
                settings.theirNextPublicKey!,
                settings.myKeyPair!.secret,
                domain,
              ),
            ),
      ),
    if (settings.theirPublicKey != null && settings.myNextKeyPair != null)
      (
        settings.myNextKeyPair,
        settings.theirPublicKey,
        await Veilid.instance
            .getCryptoSystem(settings.myNextKeyPair!.kind)
            .then(
              (cs) => cs.generateSharedSecret(
                settings.theirPublicKey!,
                settings.myNextKeyPair!.secret,
                domain,
              ),
            ),
      ),
    if (settings.theirPublicKey != null && settings.myKeyPair != null)
      (
        settings.myKeyPair,
        settings.theirPublicKey,
        await Veilid.instance
            .getCryptoSystem(settings.myKeyPair!.kind)
            .then(
              (cs) => cs.generateSharedSecret(
                settings.theirPublicKey!,
                settings.myKeyPair!.secret,
                domain,
              ),
            ),
      ),
    if (settings.initialSecret != null) (null, null, settings.initialSecret!),
  ];

  final sRecKey = _short(settings.recordKeyThemSharing);
  debugPrint('for $sRecKey trying ${secrets.length} secrets');
  for (final secret in secrets) {
    if (secret.$2 == null && secret.$1 == null) {
      debugPrint('for $sRecKey trying psk ${_short(secret.$3)}');
    } else {
      debugPrint(
        'for $sRecKey trying pub ${_short(secret.$2)} kp ${_short(secret.$1)}',
      );
    }

    final decryptionCrypto = await VeilidCryptoPrivate.fromSharedSecret(
      settings.recordKeyThemSharing!.kind,
      secret.$3,
    );

    final decryptedData = await decryptionCrypto.decrypt(data);

    try {
      final (metaData, payload) = EncryptionMetaData.fromBytes(decryptedData);
      if (secret.$2 == null && secret.$1 == null) {
        debugPrint('got $sRecKey with psk ${_short(secret.$3)}');
      } else {
        debugPrint(
          'got $sRecKey with pub ${_short(secret.$2)} kp ${_short(secret.$1)}',
        );
      }
      return (secret.$1, secret.$2, metaData, payload);
    } catch (e) {
      continue;
    }
  }

  debugPrint('nothing for $sRecKey');
  return (null, null, null, null);
}

// TODO(LGro): Do we need to lock this
class BidirectionalDhtCommunication<T> {
  final BaseDht _dht;
  final Future<Uint8List> Function(T) _encodePayload;
  final Future<T> Function(Uint8List) _decodePayload;
  final Future<void> Function(T, DhtSettings) _watchCallback;
  var _settings = const DhtSettings();

  BidirectionalDhtCommunication(
    this._dht,
    this._encodePayload,
    this._decodePayload,
    this._watchCallback,
  );

  Future<void> _updateSettings() async {
    // First get their updates to make sure we have the most recent key material
    // and potential share back records they prepared.
    if (_settings.recordKeyThemSharing != null) {
      try {
        await read();
      } on DHTExceptionNotAvailable {
        // We just skip this stage
      }
    }

    // TODO(LGro): What happens when they have a share back record, we don't
    //             get it because dht unavailable, initialize our own, but then
    //             got online again?

    if (_settings.recordKeyThemSharing == null &&
        _settings.recordKeyMeSharing == null) {
      // Init sharing settings
      final (shareKey, shareWriter) = await _dht.create();
      final initialSecret =
          (_settings.theirPublicKey == null &&
              _settings.theirNextPublicKey == null)
          ? await generateRandomSharedSecretBest()
          : null;
      _settings = _settings.copyWith(
        recordKeyMeSharing: shareKey,
        writerMeSharing: shareWriter,
        initialSecret: initialSecret,
      );

      // Init receiving settings
      final (receiveKey, receiveWriter) = await _dht.create();
      _settings = _settings.copyWith(
        recordKeyThemSharing: receiveKey,
        writerThemSharing: receiveWriter,
      );
    }
  }

  Future<DhtSettings> init(DhtSettings settings) async {
    _settings = settings;
    await _updateSettings();
    return _settings;
  }

  Future<DhtSettings> write(T value) async {
    await _updateSettings();

    if (_settings.recordKeyMeSharing == null) {
      // TODO(LGro): error / log? this shouldn't happen given _updateSettings
      debugPrint('trying to write but no record key to write to');
      return _settings;
    }

    final encryptionCrypto = await getVeilidEncryptionCrypto(_settings);
    if (encryptionCrypto == null) {
      // TODO(LGro): error / log?
      debugPrint(
        'trying to write to ${_short(_settings.recordKeyMeSharing)} but no crypto',
      );
      return _settings;
    }

    final payload = Uint8List.fromList([
      ...EncryptionMetaData(
        shareBackDHTKey: _settings.recordKeyThemSharing,
        shareBackDHTWriter: _settings.writerThemSharing,
        shareBackPubKey: (_settings.myNextKeyPair != null)
            ? _settings.myNextKeyPair!.key
            : ((_settings.myKeyPair != null) ? _settings.myKeyPair!.key : null),
        ackHandshakeComplete:
            _settings.theirPublicKey != null ||
            _settings.theirNextPublicKey != null,
      ).toBytes(),
      ...await _encodePayload(value),
    ]);

    final encryptedPayload = await encryptionCrypto.encrypt(payload);

    //TODO(LGro): Check encrypted payload size < DHT record limit?
    //            Or leave it to dht layer to start spreading across records?

    await _dht.write(_settings.recordKeyMeSharing!, encryptedPayload);

    return _settings;
  }

  Future<(T?, DhtSettings)> read() async {
    if (_settings.recordKeyThemSharing == null) {
      debugPrint('read but their record is null');
      return (null, _settings);
    }

    final encryptedPayload = await _dht.read(_settings.recordKeyThemSharing!);

    if (encryptedPayload == null) {
      debugPrint(
        'read ${_short(_settings.recordKeyThemSharing)} but no payload',
      );
      return (null, _settings);
    }

    final (usedKeyPair, usedPublicKey, metaData, payload) = await decrypt(
      encryptedPayload,
      _settings,
    );

    if (metaData == null || payload == null) {
      debugPrint('read ${_settings.recordKeyThemSharing} but cant decrypt');
      return (null, _settings);
    }

    final dhtSettingsWithRotatedKeys = rotateKeysInDhtSettings(
      _settings,
      usedPublicKey,
      usedKeyPair,
      !_settings.theyAckHandshakeComplete && metaData.ackHandshakeComplete,
    );

    _settings = updateDhtSettings(dhtSettingsWithRotatedKeys, metaData);

    await _dht.watch(
      _settings.recordKeyThemSharing!,
      // TODO(LGro): does this always return the _settings during call time or during init time?
      (value) async => _watchCallback(await _decodePayload(value), _settings),
    );

    debugPrint('read ${_short(_settings.recordKeyThemSharing)} successfully');

    return (await _decodePayload(payload), _settings);
  }
}
