// Copyright 2024 - 2025 The Reunicorn Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:reunicorn/data/models/models.dart';
import 'package:reunicorn/data/models/profile_info.dart';
import 'package:reunicorn/data/providers/legacy/sqlite.dart';

import '../../mocked_providers.dart';

void main() {
  test('migrate contact address locations from int to label indexing', () {
    const legacyJson = {
      'address_locations': {
        '0': {'longitude': 1.0, 'latitude': 0.0, 'name': 'address-loc'},
      },
      'unrelated': 'unchanged',
    };
    final migrated = migrateContactAddressLocationFromIntToLabelIndexing(
      legacyJson,
    );
    expect(migrated['unrelated'], 'unchanged');
    expect(migrated['address_locations'].keys, contains('address-loc'));
  });

  test('migrate contact address locations in profile info', () {
    const legacyAddressJson = {
      '0': {'longitude': 1.0, 'latitude': 0.0, 'name': 'address-loc'},
    };
    final json = const ProfileInfo('profileId').toJson();
    json['address_locations'] = legacyAddressJson;
    final migrated = migrateContactAddressLocationFromIntToLabelIndexing(json);
    expect(migrated['id'], 'profileId');
    expect(migrated['address_locations'].keys, contains('address-loc'));
    final info = ProfileInfo.fromJson(migrated);
    expect(info.id, 'profileId');
    expect(info.addressLocations.keys.firstOrNull, 'address-loc');
  });

  test(
    'no need to migrate contact address locations from int to label indexing',
    () {
      final upToDateJson = {
        'address_locations': {
          'address-loc': const ContactAddressLocation(
            longitude: 1.0,
            latitude: 0.0,
          ).toJson(),
        },
        'unrelated': 'unchanged',
      };
      final migrated = migrateContactAddressLocationFromIntToLabelIndexing(
        upToDateJson,
      );
      expect(migrated['unrelated'], 'unchanged');
      expect(migrated['address_locations'].keys, contains('address-loc'));
    },
  );

  test('schema json includes version', () {
    const schema = ContactSharingSchemaV3(details: ContactDetails());
    final json = schema.toJson();
    expect(json['schema_version'], 3);
  });
  test('schema simple to from json', () {
    const schema = ContactSharingSchemaV3(details: ContactDetails());
    final deserialized = ContactSharingSchemaV3.fromJson(schema.toJson());
    expect(schema, deserialized);
  });

  test('contacts deserialization for backwards compatibility', () async {
    final file = File('test/assets/example_contact.json');
    final contents = await file.readAsString();
    final contactJson = (json.decode(contents) as List<dynamic>).first;
    final migratedJson = await migrateContactAddIdentityAndIntroductionKeyPairs(
      contactJson as Map<String, dynamic>,
      generateKeyPair: () async => fakeKeyPair(),
    );
    final contact = CoagContact.fromJson(migratedJson);
    expect(contact.name, 'Display Name');
  });
}
