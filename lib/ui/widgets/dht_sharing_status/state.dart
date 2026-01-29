// Copyright 2025 The Reunicorn Authors. All rights reserved.
// SPDX-License-Identifier: AGPL-3.0-or-later

part of 'cubit.dart';

@JsonSerializable()
final class DhtSharingStatusState extends Equatable {
  const DhtSharingStatusState(this.status);
  final String status;

  factory DhtSharingStatusState.fromJson(Map<String, dynamic> json) =>
      _$DhtSharingStatusStateFromJson(json);

  Map<String, dynamic> toJson() => _$DhtSharingStatusStateToJson(this);

  @override
  List<Object?> get props => [status];
}
