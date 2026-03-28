// Copyright 2024 - 2026 The Reunicorn Authors. All rights reserved.
// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:reunicorn/data/models/circle.dart';
import 'package:reunicorn/data/models/models.dart';
import 'package:reunicorn/data/models/profile_info.dart';
import 'package:reunicorn/data/models/setting.dart';
import 'package:reunicorn/data/repositories/contact_dht.dart';
import 'package:reunicorn/data/services/storage/memory.dart';
import 'package:reunicorn/ui/receive_request/utils/direct_sharing.dart';
import 'package:reunicorn/ui/utils.dart';
import 'package:reunicorn/veilid_init.dart';

import 'utils.dart';

const _defaultCircleId = 'c1';
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    await AppGlobalInit.initialize(veilidBootstrapUrl);
  });

  test('Create, write and read a DHT record', () async {
    // SETUP
    final contactStorageA = MemoryStorage<CoagContact>();
    final circleStorageA = MemoryStorage<Circle>();
    final profileStorageA = MemoryStorage<ProfileInfo>();
    final contactStorageB = MemoryStorage<CoagContact>();
    final circleStorageB = MemoryStorage<Circle>();
    final profileStorageB = MemoryStorage<ProfileInfo>();

    // Setup interconnected mock DHTs
    final dhtA = MockDht(useVeilidKeyPairWriter: true);
    final dhtB = MockDht(useVeilidKeyPairWriter: true);
    dhtA.connect(dhtB);
    dhtB.connect(dhtA);

    // Initialize Alice's repository
    final _cRepoA = ContactDhtRepository(
      contactStorageA,
      circleStorageA,
      profileStorageA..addToMemory(
        'pA1',
        const ProfileInfo(
          'pA1',
          details: ContactDetails(names: {'n1': 'UserA'}),
          sharingSettings: ProfileSharingSettings(
            names: {
              'n1': [_defaultCircleId],
            },
          ),
        ),
      ),
      MemoryStorage<Setting>(),
      dhtA,
    );

    // Initialize Bob's repository
    final _cRepoB = ContactDhtRepository(
      contactStorageB,
      circleStorageB,
      profileStorageB..addToMemory(
        'pB1',
        const ProfileInfo(
          'pB1',
          details: ContactDetails(names: {'n1': 'UserB'}),
          sharingSettings: ProfileSharingSettings(
            names: {
              'n1': [_defaultCircleId],
            },
          ),
        ),
      ),
      MemoryStorage<Setting>(),
      dhtB,
    );

    // Alice prepares invite for Bob and shares via default circle
    debugPrint('ALICE ACTING (prep invite)');
    var contactBobInvitedByA = await _cRepoA.createContactForInvite(
      'Bob Invite',
    );
    await contactStorageA.set(
      contactBobInvitedByA.coagContactId,
      contactBobInvitedByA,
    );
    await circleStorageA.set(
      _defaultCircleId,
      Circle(
        id: _defaultCircleId,
        name: 'circle1',
        memberIds: [contactBobInvitedByA.coagContactId],
      ),
    );
    expect(
      contactBobInvitedByA.connectionCrypto,
      isA<CryptoInitializedSymmetric>(),
      reason: "Expect initialized symmetric for initial invite",
    );

    // Wait until sharing connection is set up and populated
    await retryUntilTimeout(10, () async {
      contactBobInvitedByA =
          await contactStorageA.get(contactBobInvitedByA.coagContactId) ??
          contactBobInvitedByA;
      expect(
        contactBobInvitedByA.dhtConnection,
        isA<DhtConnectionInitialized>(),
      );
      // TODO: Can those be used as matchers?
      expect(
        showSharingInitializing(contactBobInvitedByA.dhtConnection),
        false,
      );
      expect(showSharingOffer(contactBobInvitedByA), false);
      expect(showDirectSharing(contactBobInvitedByA), true);
    });
    // Generate direct sharing invite
    final directSharingLinkFromAliceForBob = DirectSharingInvite(
      'Alice Sharing',
      contactBobInvitedByA.dhtConnection!.recordKeyMeSharingOrNull!,
      contactBobInvitedByA.connectionCrypto.initialSharedSecretOrNull!,
    ).uri;

    // Bob accepts invite from Alice and shares via default circle
    debugPrint('---');
    debugPrint('BOB ACTING (accept invite)');
    var contactAliceFromBobsRepo = await createContactFromDirectSharing(
      directSharingLinkFromAliceForBob.fragment,
      contactStorageB,
    );
    await circleStorageB.set(
      _defaultCircleId,
      Circle(
        id: _defaultCircleId,
        name: 'circle1',
        memberIds: [contactAliceFromBobsRepo!.coagContactId],
      ),
    );
    expect(
      contactAliceFromBobsRepo.connectionCrypto,
      isA<CryptoInitializedSymmetric>(),
      reason:
          'Just from the link we are missing their next public key, '
          'so it is just initialized instead of established symmetric until '
          'first successful read',
    );

    // Wait until shared information was read successfully once
    await retryUntilTimeout(10, () async {
      contactAliceFromBobsRepo = await contactStorageB.get(
        contactAliceFromBobsRepo!.coagContactId,
      );
      expect(
        contactAliceFromBobsRepo!.name,
        'Alice Sharing',
        reason: 'Name from invite URL',
      );
      expect(
        contactAliceFromBobsRepo!.details?.names.values.firstOrNull,
        'UserA',
        reason: 'Name from sharing profile',
      );
      expect(
        contactAliceFromBobsRepo!.connectionCrypto,
        isA<CryptoEstablishedSymmetric>(),
        reason:
            'After successful read, we have established the symmetric channel',
      );
      expect(
        contactAliceFromBobsRepo?.profileSharingStatus.mostRecentSuccess,
        isNotNull,
      );
      expect(
        contactAliceFromBobsRepo
            ?.profileSharingStatus
            .sharedProfile
            ?.details
            .names
            .values
            .first,
        "UserB",
        reason: "Bob sharing the right name with Alice",
      );
      expect(
        showSharingInitializing(contactAliceFromBobsRepo!.dhtConnection),
        false,
      );
      expect(showSharingOffer(contactAliceFromBobsRepo!), false);
      expect(showDirectSharing(contactAliceFromBobsRepo!), false);
    });

    // Alice checks for Bob sharing back
    debugPrint('---');
    debugPrint('ALICE ACTING (check Bob shares back)');

    await retryUntilTimeout(10, () async {
      contactBobInvitedByA = (await contactStorageA.get(
        contactBobInvitedByA.coagContactId,
      ))!;
      expect(
        contactBobInvitedByA.details?.names.values.firstOrNull,
        'UserB',
        reason: 'Name from sharing profile',
      );
      expect(
        contactBobInvitedByA.connectionCrypto,
        isA<CryptoInitializedAsymmetric>(),
        reason:
            "Expect initialized asymmetric after Alice read what Bob shared",
      );
    });

    // Alice shares something else for Bob
    final profileA = await profileStorageA.getAll().then(
      (p) => p.values.firstOrNull,
    );
    profileStorageA.set(
      profileA!.id,
      profileA.copyWith(
        details: profileA.details.copyWith(phones: {'p123': '123'}),
        sharingSettings: profileA.sharingSettings.copyWith(
          phones: {
            'p123': [_defaultCircleId],
          },
        ),
      ),
    );
    await retryUntilTimeout(10, () async {
      contactBobInvitedByA = (await contactStorageA.get(
        contactBobInvitedByA.coagContactId,
      ))!;
      expect(
        contactBobInvitedByA
            .profileSharingStatus
            .sharedProfile
            ?.details
            .phones
            .values
            .firstOrNull,
        '123',
        reason: 'Shared new phone number',
      );
    });

    // Bob checks for completed handshake after updating receive and share
    debugPrint('---');
    debugPrint('BOB ACTING (check handshake completed)');
    await retryUntilTimeout(10, () async {
      contactAliceFromBobsRepo = (await contactStorageB.get(
        contactAliceFromBobsRepo!.coagContactId,
      ))!;
      expect(
        contactAliceFromBobsRepo!.details?.phones.values.firstOrNull,
        '123',
        reason: 'Also expect the new phone number',
      );
      expect(
        contactAliceFromBobsRepo!.connectionCrypto,
        isA<CryptoInitializedAsymmetric>(),
        reason: 'Handshake accepted as complete by Alice',
      );
    });

    //// TRANSITION FROM SYMMETRIC TO ASYMMETRIC CRYPTO COMPLETED ////
    ////           TESTING ASYMMETRIC KEY ROTATION NOW            ////

    // Bob shares update, testing key rotation
    debugPrint('---');
    debugPrint('BOB ACTING (share update)');
    final profileB = await profileStorageB.getAll().then((p) => p.values.first);
    await profileStorageB.set(
      profileB.id,
      profileB.copyWith(
        addressLocations: {
          'a0': const ContactAddressLocation(latitude: 0, longitude: 0),
        },
        sharingSettings: profileB.sharingSettings.copyWith(
          addresses: {
            'a0': [_defaultCircleId],
          },
        ),
      ),
    );
    await retryUntilTimeout(10, () async {
      contactAliceFromBobsRepo = (await contactStorageB.get(
        contactAliceFromBobsRepo!.coagContactId,
      ))!;
      expect(
        contactAliceFromBobsRepo!
            .profileSharingStatus
            .sharedProfile
            ?.addressLocations
            .values
            .firstOrNull
            ?.latitude,
        0,
        reason: 'New address is shared',
      );
    });

    // Alice receives new location
    debugPrint('---');
    debugPrint('ALICE ACTING (receive update)');
    await retryUntilTimeout(10, () async {
      final contactBobFromAlicesRepo = (await contactStorageA.get(
        contactBobInvitedByA.coagContactId,
      ))!;
      expect(
        contactBobFromAlicesRepo.connectionCrypto,
        isA<CryptoEstablishedAsymmetric>(),
      );
    });
  });
}
