// Copyright 2024 The Reunicorn Authors. All rights reserved.
// SPDX-License-Identifier: AGPL-3.0-or-later

part of 'cubit.dart';

@JsonSerializable()
final class LocationsState extends Equatable {
  const LocationsState({
    this.temporaryLocations = const {},
    this.circleMemberships = const {},
  });

  factory LocationsState.fromJson(Map<String, dynamic> json) =>
      _$LocationsStateFromJson(json);

  final Map<String, ContactTemporaryLocation> temporaryLocations;
  final Map<String, List<String>> circleMemberships;

  Map<String, dynamic> toJson() => _$LocationsStateToJson(this);

  // TODO: Are we intentionally missing circleMemberships?
  @override
  List<Object?> get props => [temporaryLocations];
}
