// Copyright 2024 - 2026 The Reunicorn Authors. All rights reserved.
// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:convert';
import 'dart:typed_data';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:reunicorn/data/models/utils.dart';
import 'package:veilid/veilid.dart';

import '../coag_contact.dart';
import '../contact_details.dart';
import '../contact_introduction.dart';
import '../contact_location.dart';

part 'schema.freezed.dart';
part 'schema.g.dart';

typedef ContactSharingSchema = ContactSharingSchemaV3;

@freezed
sealed class ContactSharingSchemaV3
    with _$ContactSharingSchemaV3
    implements BinarySerializable, JsonEncodable {
  const factory ContactSharingSchemaV3({
    /// Shared contact details of author
    required ContactDetails details,

    /// Shared address locations of author
    @Default({}) Map<String, ContactAddressLocation> addressLocations,

    /// Shared temporary locations of author
    @Default({}) Map<String, ContactTemporaryLocation> temporaryLocations,

    /// Attestations for connections between the author and their contacts
    @Default([]) List<String> connectionAttestations,

    /// Introduction proposals by the author for the recipient
    @Default([]) List<ContactIntroduction> introductions,

    /// Keys for DHT records the author asks the recipient to pin for them
    @Default([]) List<RecordKey> recordsToPin,

    /// Long lived identity key, used for example to derive a connection
    /// attestation for enabling others to discover shared contacts
    PublicKey? identityKey,

    /// Recipient specific push notification topic the recipient can use to
    /// trigger notifications for the author via the Reunicorn Veilid Push Bridge
    String? pushNotificationTopic,

    /// Schema version to facilitate data migration
    @Default(3) int schemaVersion,
  }) = _ContactSharingSchemaV3;
  const ContactSharingSchemaV3._();

  factory ContactSharingSchemaV3.fromJson(Map<String, dynamic> json) =>
      _$ContactSharingSchemaV3FromJson(json);

  factory ContactSharingSchemaV3.fromBytes(Uint8List data) =>
      ContactSharingSchemaV3.fromJson(
        jsonDecode(utf8.decode(data)) as Map<String, dynamic>,
      );

  @override
  Uint8List toBytes() => utf8.encode(jsonEncode(toJson()));

  bool get isEmpty {
    if (details.emails.isNotEmpty ||
        details.phones.isNotEmpty ||
        details.names.isNotEmpty ||
        details.events.isNotEmpty ||
        details.websites.isNotEmpty ||
        details.socialMedias.isNotEmpty ||
        details.organizations.isNotEmpty) {
      return false;
    }
    if (temporaryLocations.isNotEmpty || addressLocations.isNotEmpty) {
      return false;
    }
    return true;
  }
}
