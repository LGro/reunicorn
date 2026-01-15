// Copyright 2025 - 2026 The Reunicorn Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

part of 'cubit.dart';

@freezed
sealed class CreateNewContactState with _$CreateNewContactState {
  const factory CreateNewContactState({CoagContact? contact}) =
      _CreateNewContactState;

  factory CreateNewContactState.fromJson(Map<String, dynamic> json) =>
      _$CreateNewContactStateFromJson(json);
}
