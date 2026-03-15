// Copyright 2024 - 2026 The Reunicorn Authors. All rights reserved.
// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:veilid/veilid.dart';

part 'crypto_state.freezed.dart';
part 'crypto_state.g.dart';

@freezed
sealed class CryptoState with _$CryptoState {
  /// Symmetric encryption to start with, e.g. in the context of a direct
  /// sharing link / qr code based invite.
  /// Since Veilid DHT records are encrypted by default, we could omit this, but
  /// we manage the crypto on the app level consistently.
  const factory CryptoState.symmetric({
    required SharedSecret sharedSecret,
    required String accountVod,
  }) = CryptoSymmetric;

  /// Symmetric cryptography with a prepared vodozemac / olm session, ready to
  /// transition to as soon as one roundtrip was confirmed.
  const factory CryptoState.symToVod({
    required SharedSecret sharedSecret,
    required String theirIdentityKey,
    required String myIdentityKey,
    required String sessionVod,
  }) = CryptoSymToVod;

  /// Initial vodozemac / olm session that has not yet successfully seen a
  /// roundtrip of encrypted communication; the account is still there to remedy
  /// race conditions about two parties initializing vodozemac / olm crypto
  /// at the same time, trying to both encrypt with outbound sessions.
  const factory CryptoState.vodozemacInitial({
    required String theirIdentityKey,
    required String myIdentityKey,
    required String accountVod,
    required String sessionVod,
  }) = CryptoVodozemacInitial;

  /// Established vodozemac / olm session
  const factory CryptoState.vodozemac({
    required String theirIdentityKey,
    required String myIdentityKey,
    required String sessionVod,
  }) = CryptoVodozemac;

  factory CryptoState.fromJson(Map<String, dynamic> json) =>
      _$CryptoStateFromJson(json);
}

// We use map instead of mapOrNull here, to make sure we don't miss adding
// cases for new states
extension CryptoStateMaybeGetters on CryptoState {
  SharedSecret? get sharedSecretOrNull => map(
    symmetric: (s) => s.sharedSecret,
    symToVod: (s) => s.sharedSecret,
    vodozemacInitial: (s) => null,
    vodozemac: (s) => null,
  );
}
