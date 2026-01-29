// Copyright 2024 - 2026 The Reunicorn Authors. All rights reserved.
// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:veilid/veilid.dart';

part 'crypto_state.freezed.dart';
part 'crypto_state.g.dart';

@freezed
sealed class CryptoState with _$CryptoState {
  // TODO(LGro): Can we get rid of this because DHT records are encrypted by default?
  const factory CryptoState.symmetric({
    required SharedSecret sharedSecret,
    required String accountVod,
  }) = CryptoSymmetric;

  const factory CryptoState.symToVod({
    required SharedSecret sharedSecret,
    required String theirIdentityKey,
    required String myIdentityKey,
    required String sessionVod,
  }) = CryptoSymToVod;

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
    vodozemac: (s) => null,
  );
}
