// Copyright 2026 The Reunicorn Authors. All rights reserved.
// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:convert';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:veilid/veilid.dart';

import '../utils.dart';

part 'app_link.freezed.dart';
part 'app_link.g.dart';

@freezed
sealed class AppLink with _$AppLink implements JsonEncodable {
  factory AppLink({
    required String appId,
    required String label,
    required bool autoAddContacts,
    required List<String> circles,
    required RecordKey sharingRecord,
    required KeyPair sharingWriter,
    required RecordKey receivingRecord,
    KeyPair? receivingWriter,
  }) = _AppLink;

  factory AppLink.fromJson(Map<String, dynamic> json) =>
      _$AppLinkFromJson(json);
}

Future<AppLink> appLinkMigrateFromJson(String json) async =>
    AppLink.fromJson(jsonDecode(json) as Map<String, dynamic>);
