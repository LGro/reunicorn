// Copyright 2024 - 2026 The Reunicorn Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

part of 'cubit.dart';

@freezed
sealed class IntroductionsState with _$IntroductionsState {
  const factory IntroductionsState({
    @Default({}) Map<String, CoagContact> contacts,
    @Default({}) Map<String, Community> communities,
  }) = _IntroductionsState;

  factory IntroductionsState.fromJson(Map<String, dynamic> json) =>
      _$IntroductionsStateFromJson(json);
}
