// Copyright 2026 The Reunicorn Authors. All rights reserved.
// SPDX-License-Identifier: AGPL-3.0-or-later

part of 'cubit.dart';

@JsonSerializable()
final class SharedProfileState extends Equatable {
  const SharedProfileState({this.current, this.pending, this.diff});

  factory SharedProfileState.fromJson(Map<String, dynamic> json) =>
      _$SharedProfileStateFromJson(json);

  final ContactSharingSchema? current;
  final ContactSharingSchema? pending;
  final ContactSharingSchemaDiff? diff;

  Map<String, dynamic> toJson() => _$SharedProfileStateToJson(this);

  @override
  List<Object?> get props => [current, pending, diff];
}
