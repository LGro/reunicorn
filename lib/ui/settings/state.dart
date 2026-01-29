// Copyright 2024 - 2025 The Reunicorn Authors. All rights reserved.
// SPDX-License-Identifier: AGPL-3.0-or-later

part of 'cubit.dart';

enum SettingsStatus { initial, success, create, pick }

extension SettingsStatusX on SettingsStatus {
  bool get isInitial => this == SettingsStatus.initial;
  bool get isSuccess => this == SettingsStatus.success;
  bool get isCreate => this == SettingsStatus.create;
  bool get isPick => this == SettingsStatus.pick;
}

@JsonSerializable()
final class SettingsState extends Equatable {
  const SettingsState({
    required this.darkMode,
    required this.autoAddressResolution,
    required this.status,
    required this.message,
  });

  factory SettingsState.fromJson(Map<String, dynamic> json) =>
      _$SettingsStateFromJson(json);

  final SettingsStatus status;
  final String message;
  final bool darkMode;
  final bool autoAddressResolution;

  Map<String, dynamic> toJson() => _$SettingsStateToJson(this);

  SettingsState copyWith({
    bool? darkMode,
    bool? autoAddressResolution,
    SettingsStatus? status,
    String? message,
  }) => SettingsState(
    darkMode: darkMode ?? this.darkMode,
    autoAddressResolution: autoAddressResolution ?? this.autoAddressResolution,
    status: status ?? this.status,
    message: message ?? this.message,
  );

  @override
  List<Object?> get props => [status, message, darkMode, autoAddressResolution];
}
