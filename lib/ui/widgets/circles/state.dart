// Copyright 2024 The Reunicorn Authors. All rights reserved.
// SPDX-License-Identifier: AGPL-3.0-or-later

part of 'cubit.dart';

@JsonSerializable()
final class CirclesState extends Equatable {
  const CirclesState(this.circles);
  final List<(String, String, bool, int)> circles;

  factory CirclesState.fromJson(Map<String, dynamic> json) =>
      _$CirclesStateFromJson(json);

  Map<String, dynamic> toJson() => _$CirclesStateToJson(this);

  @override
  List<Object?> get props => [circles];
}
