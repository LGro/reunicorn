// Copyright 2025 - 2026 The Reunicorn Authors. All rights reserved.
// SPDX-License-Identifier: AGPL-3.0-or-later

part of 'cubit.dart';

@freezed
sealed class CreateNewContactState with _$CreateNewContactState {
  const factory CreateNewContactState({CoagContact? contact}) =
      _CreateNewContactState;

  factory CreateNewContactState.fromJson(Map<String, dynamic> json) =>
      _$CreateNewContactStateFromJson(json);
}
