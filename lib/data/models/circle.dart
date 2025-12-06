// Copyright 2025 The Reunicorn Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

import 'package:freezed_annotation/freezed_annotation.dart';

import 'utils.dart';

part 'circle.freezed.dart';
part 'circle.g.dart';

@freezed
sealed class Circle with _$Circle implements JsonEncodable {
  factory Circle({
    /// Label or name for the circle
    required String id,

    /// Label or name for the circle
    required String name,

    /// Contact IDs of the circle members
    required List<String> memberIds,
  }) = _Circle;

  factory Circle.fromJson(Map<String, dynamic> json) => _$CircleFromJson(json);
}

Future<Circle> circleMigrateFromJson(Map<String, dynamic> json) async =>
    Circle.fromJson(json);

Map<String, List<String>> circlesByContactIds(Iterable<Circle> circles) {
  final result = <String, List<String>>{};
  for (final circle in circles) {
    for (final memberId in circle.memberIds) {
      result[memberId] ??= [];
      result[memberId]!.add(circle.id);
    }
  }
  return result;
}
