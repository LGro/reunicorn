// Copyright 2024 - 2025 The Reunicorn Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

import 'dart:convert';
import 'dart:io';

import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reunicorn/data/models/coag_contact.dart';
import 'package:reunicorn/data/models/contact_location.dart';
import 'package:reunicorn/data/providers/legacy/sqlite.dart';

import '../../mocked_providers.dart';
import '../utils.dart';

const jsonAssetDirectory = 'test/assets/models/coag_contact';

void main() {
  test('details equatable', () {
    const details = ContactDetails(emails: {'e1': '1@com'});
    const sameDetails = ContactDetails(emails: {'e1': '1@com'});
    const otherDetails = ContactDetails(emails: {'e1': '2@com'});
    expect(details == sameDetails, true);
    expect(details == otherDetails, false);
  });

  test('schema serialization and deserialization', () {
    final schema = CoagContactDHTSchemaV2(
      details: const ContactDetails(names: {'0': 'My Name'}),
      shareBackDHTKey: 'dhtKey',
      shareBackDHTWriter: 'dhtWriter',
      shareBackPubKey: 'pubKey',
    );
    final schema2 = CoagContactDHTSchemaV2.fromJson(schema.toJson());
    expect(schema, schema2);
  });

  test('equality test copy with change', () {
    final contact = CoagContact(
      coagContactId: '',
      name: 'name',
      myIdentity: fakeKeyPair(),
      myIntroductionKeyPair: fakeKeyPair(),
      dhtSettings: DhtSettings(myNextKeyPair: fakeKeyPair()),
      details: const ContactDetails(picture: [1, 2, 3]),
      temporaryLocations: {
        '0': ContactTemporaryLocation(
          longitude: 0,
          latitude: 0,
          name: 'loc',
          details: '',
          start: DateTime(2000),
          end: DateTime(2000).add(const Duration(days: 1)),
        ),
      },
    );
    final copy = contact.copyWith(
      details: contact.details!.copyWith(
        names: {
          ...contact.details!.names,
          ...{'1': 'b'},
        },
      ),
    );
    expect(contact == copy, false);
  });

  test('equality test copy then change, ensure no references', () {
    final contact = CoagContact(
      coagContactId: '',
      name: 'name',
      myIdentity: fakeKeyPair(),
      myIntroductionKeyPair: fakeKeyPair(),
      dhtSettings: DhtSettings(myNextKeyPair: fakeKeyPair()),
      details: const ContactDetails(picture: [1, 2, 3]),
      temporaryLocations: {
        '0': ContactTemporaryLocation(
          longitude: 0,
          latitude: 0,
          name: 'loc',
          details: '',
          start: DateTime(2000),
          end: DateTime(2000).add(const Duration(days: 1)),
        ),
      },
    );
    final copy = contact.copyWith();
    copy.temporaryLocations['1'] = ContactTemporaryLocation(
      longitude: 2,
      latitude: 2,
      name: 'loc2',
      details: '',
      start: DateTime(2000),
      end: DateTime(2000).add(const Duration(days: 1)),
    );
    expect(contact == copy, false);
  });

  test('merge system contacts', () {
    final merged = mergeSystemContacts(
      Contact(
        id: 'sys',
        displayName: 'Sys Name',
        phones: [
          Phone('1234-sys'),
          Phone(
            '0000-coag',
            label: PhoneLabel.custom,
            customLabel: 'old mansion $appManagedLabelSuffix',
          ),
        ],
      ),
      Contact(
        id: 'coag',
        displayName: 'Coag Name',
        phones: [
          Phone('54321-coag', label: PhoneLabel.custom, customLabel: 'mansion'),
        ],
      ),
    );
    expect(merged.id, 'sys');
    expect(merged.displayName, 'Sys Name');
    expect(
      merged.phones.length,
      2,
      reason:
          'old mansion should be removed and mansion added '
          'alongside existing system phone',
    );
    expect(merged.phones[0].number, '1234-sys');
    expect(merged.phones[1].number, '54321-coag');
    expect(merged.phones[1].customLabel, 'mansion $appManagedLabelSuffix');
  });

  test('coveredByReunicorn Email with mismatched label still covers', () {
    final isCovered = coveredByReunicorn(Email('covered@coag.org'), [
      Email('other@corp.co'),
      Email('covered@coag.org', label: EmailLabel.school),
    ]);
    expect(isCovered, true);
  });

  test('removeCoagManagedSuffixes for phone', () {
    final withoutSuffixes = removeCoagManagedSuffixes(
      Contact(
        phones: [
          Phone(
            '123',
            label: PhoneLabel.custom,
            customLabel: addCoagSuffix('mobile'),
          ),
        ],
      ),
    );
    expect(withoutSuffixes.phones.length, 1);
    expect(withoutSuffixes.phones.first.customLabel, 'mobile');
  });

  test('add and remove Reunicorn managed suffix', () {
    const withSuffix = 'mobile $appManagedLabelSuffix';
    expect(removeCoagSuffix(addCoagSuffix(withSuffix)), 'mobile');

    const withoutSuffix = 'mobile';
    expect(removeCoagSuffix(addCoagSuffix(withoutSuffix)), withoutSuffix);

    const withNewlinesAndSuffix = 'foo\n\n $appManagedLabelSuffix';
    expect(removeCoagSuffix(addCoagSuffix(withNewlinesAndSuffix)), 'foo');

    expect(
      addCoagSuffixNewline('my note\n\n\n'),
      'my note\n\n$appManagedLabelSuffix',
    );
  });

  test('save current json schema version', () async {
    final version = await readCurrentVersionFromPubspec();
    final file = File('$jsonAssetDirectory/$version.json');

    final contact = CoagContact.explicit(
      coagContactId: 'coag-contact-id',
      name: 'Display Name',
      dhtSettings: const DhtSettings(),
      myIdentity: fakeKeyPair(),
      myIntroductionKeyPair: fakeKeyPair(),
      details: null,
      theirIdentity: null,
      connectionAttestations: const [],
      systemContactId: null,
      addressLocations: const {},
      temporaryLocations: const {},
      comment: '',
      sharedProfile: null,
      theirIntroductionKey: fakeKeyPair().key,
      myPreviousIntroductionKeyPairs: const [],
      introductionsForThem: const [],
      introductionsByThem: const [],
      origin: null,
      verified: false,
    );

    final jsonString = json.encode(contact.toJson());

    if (!loadAllPreviousSchemaVersionJsons(
      jsonAssetDirectory,
    ).values.toSet().contains(jsonString)) {
      await file.writeAsString(jsonString);
    }
  });

  test('test loading previous json schema versions', () async {
    for (final jsonEntry in loadAllPreviousSchemaVersionJsons(
      jsonAssetDirectory,
    ).entries) {
      try {
        final jsonData =
            await jsonDecode(jsonEntry.value) as Map<String, dynamic>;
        final migrated = await migrateContactAddIdentityAndIntroductionKeyPairs(
          jsonData,
          generateKeyPair: () async => fakeKeyPair(),
        );
        CoagContact.fromJson(migrated);
      } catch (e, stackTrace) {
        fail('Failed to deserialize ${jsonEntry.key}:\n$e\n$stackTrace');
      }
    }
  });
}
