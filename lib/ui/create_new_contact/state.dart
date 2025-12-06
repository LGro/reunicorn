// Copyright 2025 The Reunicorn Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

part of 'cubit.dart';

@JsonSerializable()
final class CreateNewContactState extends Equatable {
  const CreateNewContactState({this.name = ''});

  factory CreateNewContactState.fromJson(Map<String, dynamic> json) =>
      _$CreateNewContactStateFromJson(json);

  final String name;

  Map<String, dynamic> toJson() => _$CreateNewContactStateToJson(this);

  CreateNewContactState copyWith({String? name}) =>
      CreateNewContactState(name: name ?? this.name);

  @override
  List<Object?> get props => [name];
}
