// Copyright 2025 The Reunicorn Authors. All rights reserved.
// SPDX-License-Identifier: AGPL-3.0-or-later

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
    this.closeByMatches = const [],
    this.circles = const {},
  });

  factory DashboardState.fromJson(Map<String, dynamic> json) =>
      _$DashboardStateFromJson(json);

  final Iterable<CoagContact> contacts;
  final Iterable<ContactUpdate> updates;
  final Map<String, String> circles;
  final List<CloseByMatch> closeByMatches;
  final DashboardStatus status;

  DashboardState copyWith({
    DashboardStatus? status,
    Map<String, String>? circles,
    Iterable<CoagContact>? contacts,
    Iterable<ContactUpdate>? updates,
    List<CloseByMatch>? closeByMatches,
  }) => DashboardState(
    status ?? this.status,
    circles: circles ?? this.circles,
    contacts: contacts ?? this.contacts,
    updates: updates ?? this.updates,
    closeByMatches: closeByMatches ?? this.closeByMatches,
  );

  Map<String, dynamic> toJson() => _$DashboardStateToJson(this);

  @override
  List<Object?> get props => [
    contacts,
    status,
    circles,
    updates,
    closeByMatches,
  ];
}
