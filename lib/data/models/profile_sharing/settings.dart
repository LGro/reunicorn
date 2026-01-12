// Copyright 2024 - 2026 The Reunicorn Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

import 'package:freezed_annotation/freezed_annotation.dart';

part 'settings.freezed.dart';
part 'settings.g.dart';

@freezed
sealed class ProfileSharingSettings with _$ProfileSharingSettings {
  const factory ProfileSharingSettings({
    /// Map of name ID to circle IDs that have access to names
    @Default({}) Map<String, List<String>> names,

    /// Map of phone label to circle IDs that have access to phones
    @Default({}) Map<String, List<String>> phones,

    /// Map of email label to circle IDs that have access to emails
    @Default({}) Map<String, List<String>> emails,

    /// Map of address label to circle IDs that have access to addresses
    @Default({}) Map<String, List<String>> addresses,

    /// Map of ??? to circle IDs that have access to organizations
    // TODO: Do organizations even have labels?
    @Default({}) Map<String, List<String>> organizations,

    /// Map of website label to circle IDs that have access to websites
    @Default({}) Map<String, List<String>> websites,

    /// Map of social media label to circle IDs that have access to socialMedias
    @Default({}) Map<String, List<String>> socialMedias,

    /// Map of event label to circle IDs that have access to events
    @Default({}) Map<String, List<String>> events,

    /// Map of misc ID to circle IDs that have access to misc field
    @Default({}) Map<String, List<String>> misc,

    /// Map of tag ID to circle IDs that have access to tag
    @Default({}) Map<String, List<String>> tags,
  }) = _ProfileSharingSettings;

  factory ProfileSharingSettings.fromJson(Map<String, dynamic> json) =>
      _$ProfileSharingSettingsFromJson(json);
}
