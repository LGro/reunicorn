// Copyright 2024 The Reunicorn Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

part of 'cubit.dart';

enum DashboardStatus { initial, success, denied }

extension DashboardStatusX on DashboardStatus {
  bool get isInitial => this == DashboardStatus.initial;
  bool get isSuccess => this == DashboardStatus.success;
  bool get isDenied => this == DashboardStatus.denied;
}

@JsonSerializable()
final class DashboardState extends Equatable {
  const DashboardState(
    this.status, {
    this.contacts = const [],
    this.updates = const [],
    this.circleMemberships = const {},
    this.circles = const {},
  });

  factory DashboardState.fromJson(Map<String, dynamic> json) =>
      _$DashboardStateFromJson(json);

  final Map<String, List<String>> circleMemberships;
  final Iterable<CoagContact> contacts;
  final Iterable<ContactUpdate> updates;
  final Map<String, String> circles;
  final DashboardStatus status;

  DashboardState copyWith({
    DashboardStatus? status,
    Map<String, List<String>>? circleMemberships,
    Map<String, String>? circles,
    Iterable<CoagContact>? contacts,
    Iterable<ContactUpdate>? updates,
  }) =>
      DashboardState(
        status ?? this.status,
        circleMemberships: circleMemberships ?? this.circleMemberships,
        circles: circles ?? this.circles,
        contacts: contacts ?? this.contacts,
        updates: updates ?? this.updates,
      );

  Map<String, dynamic> toJson() => _$DashboardStateToJson(this);

  @override
  List<Object?> get props => [
        contacts,
        status,
        circleMemberships,
        circles,
        updates,
      ];
}
