// Copyright 2025 The Reunicorn Authors. All rights reserved.
// SPDX-License-Identifier: AGPL-3.0-or-later

part of 'cubit.dart';

@JsonSerializable()
final class DhtStatusState extends Equatable {
  const DhtStatusState(this.status);
  final String status;

  factory DhtStatusState.fromJson(Map<String, dynamic> json) =>
      _$DhtStatusStateFromJson(json);

  Map<String, dynamic> toJson() => _$DhtStatusStateToJson(this);

  @override
  List<Object?> get props => [status];
}
