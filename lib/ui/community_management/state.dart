// Copyright 2024 - 2026 The Reunicorn Authors. All rights reserved.
// SPDX-License-Identifier: AGPL-3.0-or-later

part of 'cubit.dart';

@freezed
sealed class CommunityManagementState with _$CommunityManagementState {
  const factory CommunityManagementState({
    ManagedCommunity? community,
    int? iSelectedMember,
    @Default(false) bool isProcessing,
  }) = _CommunityManagementState;

  factory CommunityManagementState.fromJson(Map<String, dynamic> json) =>
      _$CommunityManagementStateFromJson(json);
}
