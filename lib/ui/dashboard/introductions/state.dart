// Copyright 2024 - 2025 The Reunicorn Authors. All rights reserved.
// SPDX-License-Identifier: AGPL-3.0-or-later

part of 'cubit.dart';

enum IntroductionsStatus { initial, success, denied }

extension IntroductionsStatusX on IntroductionsStatus {
  bool get isInitial => this == IntroductionsStatus.initial;
  bool get isSuccess => this == IntroductionsStatus.success;
  bool get isDenied => this == IntroductionsStatus.denied;
}

@JsonSerializable()
final class IntroductionsState extends Equatable {
  const IntroductionsState(this.status, {this.contacts = const []});

  factory IntroductionsState.fromJson(Map<String, dynamic> json) =>
      _$IntroductionsStateFromJson(json);

  final IntroductionsStatus status;
  final List<CoagContact> contacts;

  Map<String, dynamic> toJson() => _$IntroductionsStateToJson(this);

  @override
  List<Object?> get props => [status, contacts];
}
