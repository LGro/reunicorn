// Copyright 2024 - 2026 The Reunicorn Authors. All rights reserved.
// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:veilid/veilid.dart';

import 'utils.dart';
part 'contact_introduction.freezed.dart';
part 'contact_introduction.g.dart';

@freezed
sealed class ContactIntroduction
    with _$ContactIntroduction
    implements JsonEncodable {
  const factory ContactIntroduction({
    /// Name of the contact this is not the introduction for
    required String otherName,

    /// Initial shared secret for encrypted communication
    required SharedSecret sharedSecret,

    /// Record key where the contact this is not the introduction for is sharing
    required RecordKey dhtRecordKeyReceiving,

    /// Record key where the contact this is the introduction for can share
    required RecordKey dhtRecordKeySharing,

    /// Writer for the key where the contact this is the introduction for can share
    required KeyPair dhtWriterSharing,

    /// Optional message for the introduction
    String? message,
  }) = _ContactIntroduction;
  const ContactIntroduction._();

  factory ContactIntroduction.fromJson(Map<String, dynamic> json) =>
      _$ContactIntroductionFromJson(migrateToVeilidTypedKeys(json));
}

Map<String, dynamic> migrateToVeilidTypedKeys(Map<String, dynamic> json) {
  final _json = {...json};
  const toMigrate = [
    'other_public_key',
    'public_key',
    'dht_record_key_receiving',
    'dht_record_key_sharing',
    'dht_writer_sharing',
  ];
  for (final k in toMigrate) {
    if (_json.containsKey(k) &&
        _json[k] != null &&
        _json[k] != 'null' &&
        !(_json[k] as String).startsWith('VLD0:')) {
      _json[k] = 'VLD0:${_json[k]}';
    }
  }
  if (!_json.containsKey('public_key') || _json['public_key'] == null) {
    // This makes the invite useless but prevents crashes during deserialization
    _json['public_key'] = 'VLD0:AQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQE';
  }
  return _json;
}
