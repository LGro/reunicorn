// Copyright 2024 - 2025 The Reunicorn Authors. All rights reserved.
// SPDX-License-Identifier: AGPL-3.0-or-later

part of 'cubit.dart';

enum CirclesListStatus { initial, success, denied }

extension CirclesListStatusX on CirclesListStatus {
  bool get isInitial => this == CirclesListStatus.initial;
  bool get isSuccess => this == CirclesListStatus.success;
  bool get isDenied => this == CirclesListStatus.denied;
}

@JsonSerializable()
final class CirclesListState extends Equatable {
  const CirclesListState(
    this.status, {
    this.circleMemberships = const {},
    this.circleMemberPictures = const {},
    this.filter = '',
    this.circles = const {},
  });

  factory CirclesListState.fromJson(Map<String, dynamic> json) =>
      _$CirclesListStateFromJson(json);

  final Map<String, List<String>> circleMemberships;
  final Map<String, String> circles;
  final Map<String, List<List<int>>> circleMemberPictures;
  final String filter;
  final CirclesListStatus status;

  CirclesListState copyWith({
    CirclesListStatus? status,
    Map<String, List<String>>? circleMemberships,
    Map<String, List<List<int>>>? circleMemberPictures,
    Map<String, String>? circles,
    String? filter,
  }) => CirclesListState(
    status ?? this.status,
    circleMemberships: circleMemberships ?? this.circleMemberships,
    filter: filter ?? this.filter,
    circleMemberPictures: circleMemberPictures ?? this.circleMemberPictures,
    circles: circles ?? this.circles,
  );

  Map<String, dynamic> toJson() => _$CirclesListStateToJson(this);

  @override
  List<Object?> get props => [
    status,
    circleMemberships,
    circles,
    circleMemberPictures,
    filter,
  ];
}
