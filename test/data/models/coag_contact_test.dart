// Copyright 2024 - 2026 The Reunicorn Authors. All rights reserved.
// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:convert';

import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reunicorn/data/models/models.dart';
import 'package:reunicorn/data/repositories/contact_system.dart';

import '../../mocked_providers.dart';
import 'utils.dart';

void main() {
  test('details equatable', () {
    const details = ContactDetails(emails: {'e1': '1@com'});
    const sameDetails = ContactDetails(emails: {'e1': '1@com'});
    const otherDetails = ContactDetails(emails: {'e1': '2@com'});
    expect(details == sameDetails, true);
    expect(details == otherDetails, false);
  });

  test('schema serialization and deserialization', () {
    const schema = ContactSharingSchema(
      details: ContactDetails(names: {'0': 'My Name'}),
      addressLocations: {},
      temporaryLocations: {},
      connectionAttestations: [],
      introductions: [],
    );
    final schema2 = ContactSharingSchema.fromJson(schema.toJson());
    expect(schema, schema2);
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

  test('00 save current json schema version', () async {
    final contactMinimal = CoagContact.explicit(
      coagContactId: 'coag-contact-id',
      name: 'Display Name',
      dhtConnection: DhtConnectionState.invited(
        recordKeyThemSharing: fakeDhtRecordKey(),
      ),
      connectionCrypto: CryptoState.symmetric(
        sharedSecret: fakePsk(0),
        accountVod: '',
      ),
      myIdentity: fakeKeyPair(),
      myIntroductionKeyPair: fakeKeyPair(),
      theirIntroductionKey: fakeKeyPair().key,
      details: null,
      theirIdentity: null,
      connectionAttestations: const [],
      systemContactId: null,
      addressLocations: const {},
      temporaryLocations: const {},
      comment: '',
      profileSharingStatus: const ProfileSharingStatus(),
      myPreviousIntroductionKeyPairs: const [],
      introductionsForThem: const [],
      introductionsByThem: const [],
      origin: null,
      verified: false,
    );
    // TODO: Add more to full contact
    final contactFull = contactMinimal.copyWith(
      dhtConnection: DhtConnectionState.established(
        recordKeyThemSharing: fakeDhtRecordKey(),
        recordKeyMeSharing: fakeDhtRecordKey(),
        writerMeSharing: fakeKeyPair(),
      ),
      connectionCrypto: CryptoState.establishedAsymmetric(
        myNextKeyPair: fakeKeyPair(),
        theirNextPublicKey: fakeKeyPair(1, 2).key,
        myKeyPair: fakeKeyPair(3, 4),
        theirPublicKey: fakeKeyPair(5, 6).key,
      ),
      details: const ContactDetails(
        names: {'n1': 'Awesome Name'},
        emails: {'em1': 'mail@mailmail'},
      ),
    );
    await saveJsonModelAsset(contactMinimal, versionSuffix: 'minimal');
    await saveJsonModelAsset(contactFull, versionSuffix: 'full');
  });

  test('test loading previous json schema versions', () async {
    for (final jsonEntry
        in loadAllPreviousSchemaVersionJsonFiles<CoagContact>().entries) {
      final jsonData =
          await jsonDecode(jsonEntry.value) as Map<String, dynamic>;
      final migrated = await migrateContactAddIdentityAndIntroductionKeyPairs(
        jsonData,
        generateKeyPair: () async => fakeKeyPair(),
      );
      CoagContact.fromJson(migrated);
    }
  });
}
