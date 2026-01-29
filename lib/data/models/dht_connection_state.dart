// Copyright 2024 - 2026 The Reunicorn Authors. All rights reserved.
// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:veilid/veilid.dart';

part 'dht_connection_state.freezed.dart';
part 'dht_connection_state.g.dart';

@freezed
sealed class DhtConnectionState with _$DhtConnectionState {
  const factory DhtConnectionState.initialized({
    /// Record key of my sharing DHT record
    required RecordKey recordKeyMeSharing,

    /// Writer of my sharing DHT record
    required KeyPair writerMeSharing,

    /// Record key of their sharing DHT record
    required RecordKey recordKeyThemSharing,

    /// Writer of their sharing DHT record
    required KeyPair writerThemSharing,
  }) = DhtConnectionInitialized;

  const factory DhtConnectionState.invited({
    /// Record key of their sharing DHT record
    required RecordKey recordKeyThemSharing,
  }) = DhtConnectionInvited;

  const factory DhtConnectionState.established({
    /// Record key of my sharing DHT record
    required RecordKey recordKeyMeSharing,

    /// Writer of my sharing DHT record
    required KeyPair writerMeSharing,

    /// Record key of their sharing DHT record
    required RecordKey recordKeyThemSharing,
  }) = DhtConnectionEstablished;

  factory DhtConnectionState.fromJson(Map<String, dynamic> json) =>
      _$DhtConnectionStateFromJson(json);
}

extension DhtConnectionStateMayBeGetters on DhtConnectionState {
  RecordKey? get recordKeyMeSharingOrNull => mapOrNull(
    initialized: (s) => s.recordKeyMeSharing,
    established: (s) => s.recordKeyMeSharing,
  );

  KeyPair? get writerMeSharingOrNull => mapOrNull(
    initialized: (s) => s.writerMeSharing,
    established: (s) => s.writerMeSharing,
  );

  KeyPair? get writerThemSharingOrNull =>
      mapOrNull(initialized: (s) => s.writerThemSharing);
}
