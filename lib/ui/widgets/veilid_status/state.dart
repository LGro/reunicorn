// Copyright 2025 The Reunicorn Authors. All rights reserved.
// SPDX-License-Identifier: AGPL-3.0-or-later

part of 'cubit.dart';

@JsonSerializable()
final class VeilidStatusState extends Equatable {
  const VeilidStatusState(this.status);
  final String status;

  factory VeilidStatusState.fromJson(Map<String, dynamic> json) =>
      _$VeilidStatusStateFromJson(json);

  Map<String, dynamic> toJson() => _$VeilidStatusStateToJson(this);

  @override
  List<Object?> get props => [status];
}
