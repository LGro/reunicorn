// Copyright 2024 - 2026 The Reunicorn Authors. All rights reserved.
// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:veilid/veilid.dart';

import 'utils.dart';
part 'contact_introduction.g.dart';

@JsonSerializable()
class ContactIntroduction extends Equatable implements JsonEncodable {
  const ContactIntroduction({
    required this.otherName,
    required this.otherPublicKey,
    required this.publicKey,
    required this.dhtRecordKeyReceiving,
    required this.dhtRecordKeySharing,
    required this.dhtWriterSharing,
    this.message,
  });

  factory ContactIntroduction.fromJson(Map<String, dynamic> json) =>
      _$ContactIntroductionFromJson(migrateToVeilidTypedKeys(json));

  /// Name of the contact this is not the introduction for
  final String otherName;

  /// Public key of the contact this is not the introduction for
  final PublicKey otherPublicKey;

  /// Public key of the recipient of this invite, the app user
  final PublicKey publicKey;

  /// Optional message for the introduction
  final String? message;

  /// Record key where the contact this is not the introduction for is sharing
  final RecordKey dhtRecordKeyReceiving;

  /// Record key where the contact this is the introduction for can share
  final RecordKey dhtRecordKeySharing;

  /// Writer for the key where the contact this is the introduction for can share
  final KeyPair dhtWriterSharing;

  @override
  Map<String, dynamic> toJson() => _$ContactIntroductionToJson(this);

  @override
  List<Object?> get props => [
    otherName,
    otherPublicKey,
    publicKey,
    message,
    dhtRecordKeyReceiving,
    dhtRecordKeySharing,
    dhtWriterSharing,
  ];
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
