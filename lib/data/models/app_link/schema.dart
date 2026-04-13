// Copyright 2026 The Reunicorn Authors. All rights reserved.
// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:veilid/veilid.dart';

import '../utils.dart';

part 'schema.freezed.dart';
part 'schema.g.dart';

@freezed
sealed class Connection with _$Connection implements JsonEncodable {
  factory Connection({
    required String theirName,
    required RecordKey myRecord,
    required KeyPair myWriter,
    required RecordKey theirRecord,
  }) = _Connection;

  factory Connection.fromJson(Map<String, dynamic> json) =>
      _$ConnectionFromJson(json);
}

@freezed
sealed class AppLinkSchema with _$AppLinkSchema implements JsonEncodable {
  factory AppLinkSchema({
    @Default("app.reunicorn") String appId,
    @Default({}) Map<String, Connection> connections,
  }) = _AppLinkSchema;

  factory AppLinkSchema.fromJson(Map<String, dynamic> json) =>
      _$AppLinkSchemaFromJson(json);
}
