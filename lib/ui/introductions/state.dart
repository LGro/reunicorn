// Copyright 2024 - 2026 The Reunicorn Authors. All rights reserved.
// SPDX-License-Identifier: AGPL-3.0-or-later

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
