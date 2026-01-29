// Copyright 2024 - 2026 The Reunicorn Authors. All rights reserved.
// SPDX-License-Identifier: AGPL-3.0-or-later

part of 'cubit.dart';

enum RestoreStatus { ready, attaching, success, restoring, failure }

extension RestoreStatusX on RestoreStatus {
  bool get isAttaching => this == RestoreStatus.attaching;
  bool get isRestoring => this == RestoreStatus.restoring;
  bool get isReady => this == RestoreStatus.ready;
  bool get isSuccess => this == RestoreStatus.success;
  bool get isFailure => this == RestoreStatus.failure;
}

@freezed
sealed class RestoreState with _$RestoreState {
  const factory RestoreState({required RestoreStatus status}) = _RestoreState;

  factory RestoreState.fromJson(Map<String, dynamic> json) =>
      _$RestoreStateFromJson(json);
}
