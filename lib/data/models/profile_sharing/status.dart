// Copyright 2024 - 2026 The Reunicorn Authors. All rights reserved.
// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:freezed_annotation/freezed_annotation.dart';
import 'schema.dart';

part 'status.freezed.dart';
part 'status.g.dart';

@freezed
sealed class ProfileSharingStatus with _$ProfileSharingStatus {
  const factory ProfileSharingStatus({
    /// Timestamp of the most recent sharing success
    DateTime? mostRecentSuccess,

    /// Timestamp of the most recent sharing attempt
    DateTime? mostRecentAttempt,

    /// Successfully shared profile, not necessarily the most recent version
    ContactSharingSchema? sharedProfile,
  }) = _ProfileSharingStatus;

  factory ProfileSharingStatus.fromJson(Map<String, dynamic> json) =>
      _$ProfileSharingStatusFromJson(json);
}
