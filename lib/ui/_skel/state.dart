// Copyright 2024 - 2025 The Reunicorn Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

part of 'cubit.dart';

enum SkelStatus { initial, success, denied }

extension SkelStatusX on SkelStatus {
  bool get isInitial => this == SkelStatus.initial;
  bool get isSuccess => this == SkelStatus.success;
  bool get isDenied => this == SkelStatus.denied;
}

@JsonSerializable()
final class SkelState extends Equatable {
  const SkelState(this.status, {this.contacts = const {}});

  factory SkelState.fromJson(Map<String, dynamic> json) =>
      _$SkelStateFromJson(json);

  final SkelStatus status;
  final Map<String, CoagContact> contacts;

  Map<String, dynamic> toJson() => _$SkelStateToJson(this);

  @override
  List<Object?> get props => [status, contacts];
}
