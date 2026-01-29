// Copyright 2025 - 2026 The Reunicorn Authors. All rights reserved.
// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:convert';

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

Future<Circle> circleMigrateFromJson(String json) async =>
    Circle.fromJson(jsonDecode(json) as Map<String, dynamic>);

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
