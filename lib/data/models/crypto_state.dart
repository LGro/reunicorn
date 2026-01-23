// Copyright 2024 - 2026 The Reunicorn Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:veilid/veilid.dart';

part 'crypto_state.freezed.dart';
part 'crypto_state.g.dart';

@freezed
sealed class CryptoState with _$CryptoState {
  const factory CryptoState.initializedSymmetric({
    /// Initial shared secret for symmetric cryptography
    required SharedSecret initialSharedSecret,

    /// My key pair for transition to asymmetric cryptography
    required KeyPair myNextKeyPair,
  }) = CryptoInitializedSymmetric;

  const factory CryptoState.establishedSymmetric({
    /// Initial shared secret for symmetric cryptography
    required SharedSecret initialSharedSecret,

    /// My key pair for transition to asymmetric cryptography
    required KeyPair myNextKeyPair,

    /// Their public key for transition to asymmetric cryptography
    required PublicKey theirNextPublicKey,
  }) = CryptoEstablishedSymmetric;

  const factory CryptoState.pendingAsymmetric({
    /// My key pair for asymmetric cryptography
    required KeyPair myNextKeyPair,
  }) = CryptoPendingAsymmetric;

  const factory CryptoState.initializedAsymmetric({
    /// Initial shared secret for symmetric cryptography
    required SharedSecret initialSharedSecret,

    /// My key pair, of which they used the public key successfully
    required KeyPair myKeyPair,

    /// My key pair for transition to asymmetric cryptography
    required KeyPair myNextKeyPair,

    /// Their public key for transition to asymmetric cryptography
    required PublicKey theirNextPublicKey,
  }) = CryptoInitializedAsymmetric;

  const factory CryptoState.establishedAsymmetric({
    /// My key pair, of which they used the public key successfully
    required KeyPair myKeyPair,

    /// My key pair for the next rotation
    required KeyPair myNextKeyPair,

    /// Their public key I used successfully
    required PublicKey theirPublicKey,

    /// Their public key for the next rotation
    required PublicKey theirNextPublicKey,
  }) = CryptoEstablishedAsymmetric;

  factory CryptoState.fromJson(Map<String, dynamic> json) =>
      _$CryptoStateFromJson(json);
}

extension CryptoStateMaybeGetters on CryptoState {
  SharedSecret? get initialSharedSecretOrNull => mapOrNull(
    initializedSymmetric: (s) => s.initialSharedSecret,
    establishedSymmetric: (s) => s.initialSharedSecret,
    initializedAsymmetric: (s) => s.initialSharedSecret,
  );

  PublicKey? get theirPublicKeyOrNull =>
      mapOrNull(establishedAsymmetric: (s) => s.theirPublicKey);

  PublicKey? get theirNextPublicKeyOrNull => mapOrNull(
    establishedSymmetric: (s) => s.theirNextPublicKey,
    initializedAsymmetric: (s) => s.theirNextPublicKey,
    establishedAsymmetric: (s) => s.theirNextPublicKey,
  );

  KeyPair? get myKeyPairOrNull => mapOrNull(
    initializedAsymmetric: (s) => s.myKeyPair,
    establishedAsymmetric: (s) => s.myKeyPair,
  );
}
