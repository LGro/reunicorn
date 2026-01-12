// Copyright 2024 - 2026 The Reunicorn Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:reunicorn/data/models/circle.dart';
import 'package:reunicorn/data/models/models.dart';
import 'package:reunicorn/data/models/profile_info.dart';
import 'package:reunicorn/data/models/profile_sharing_settings.dart';
import 'package:reunicorn/data/repositories/contact_dht.dart';
import 'package:reunicorn/data/services/dht/veilid_dht.dart';
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
    final contactStorageB = MemoryStorage<CoagContact>();
    final circleStorageB = MemoryStorage<Circle>();
    final profileStorageB = MemoryStorage<ProfileInfo>();
    final dhtStorage = VeilidDht(watchLocalChanges: true);

    // Initialize Alice's repository
    final _cRepoA = ContactDhtRepository(
      contactStorageA,
      circleStorageA,
      MemoryStorage<ProfileInfo>()..addToMemory(
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
      dhtStorage,
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
      dhtStorage,
    );

    // Alice prepares invite for Bob and shares via default circle
    debugPrint('ALICE ACTING');
    var contactBobInvitedByA = await _cRepoA.createContactForInvite(
      'Bob Invite',
      pubKey: null,
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

    await retryUntilTimeout(20, () async {
      contactBobInvitedByA =
          await contactStorageA.get(contactBobInvitedByA.coagContactId) ??
          contactBobInvitedByA;
      expect(
        contactBobInvitedByA.dhtSettings.recordKeyMeSharing,
        isNotNull,
        reason: 'Sharing record prepared',
      );
      expect(
        contactBobInvitedByA.dhtSettings.recordKeyThemSharing,
        isNotNull,
        reason: 'Receiving record prepared',
      );
      expect(
        contactBobInvitedByA.dhtSettings.initialSecret,
        isNotNull,
        reason: 'Initial secret for symmetric encryption ready',
      );
      expect(
        contactBobInvitedByA.dhtSettings.theirPublicKey,
        isNull,
        reason: 'We have not seen any public keys from them yet',
      );
      expect(
        contactBobInvitedByA.dhtSettings.theirNextPublicKey,
        isNull,
        reason: 'We have not seen any public keys from them yet',
      );
      // TODO: Can those be used as matchers?
      expect(showSharingInitializing(contactBobInvitedByA), false);
      expect(showSharingOffer(contactBobInvitedByA), false);
      expect(showDirectSharing(contactBobInvitedByA), true);
    });
    final directSharingLinkFromAliceForBob = DirectSharingInvite(
      'Alice Sharing',
      contactBobInvitedByA.dhtSettings.recordKeyMeSharing!,
      contactBobInvitedByA.dhtSettings.initialSecret!,
    ).uri;

    // Bob accepts invite from Alice and shares via default circle
    debugPrint('---');
    debugPrint('BOB ACTING');
    await createContactFromDirectSharing(
      directSharingLinkFromAliceForBob.fragment,
      contactStorageB,
    );
    var contactAliceFromBobsRepo = await contactStorageB.getAll().then(
      (contacts) => contacts.values.first,
    );
    await circleStorageB.set(
      _defaultCircleId,
      Circle(
        id: _defaultCircleId,
        name: 'circle1',
        memberIds: [contactAliceFromBobsRepo.coagContactId],
      ),
    );

    await retryUntilTimeout(20, () async {
      contactAliceFromBobsRepo = (await contactStorageB.get(
        contactAliceFromBobsRepo.coagContactId,
      ))!;
      expect(
        contactAliceFromBobsRepo.name,
        'Alice Sharing',
        reason: 'Name from invite URL',
      );
      expect(
        contactAliceFromBobsRepo.details?.names.values.firstOrNull,
        'UserA',
        reason: 'Name from sharing profile',
      );
      expect(
        contactAliceFromBobsRepo.dhtSettings.initialSecret,
        isNotNull,
        reason:
            'Initial secret still in place because no full pub key cycle yet',
      );
      expect(
        contactAliceFromBobsRepo.dhtSettings.theirNextPublicKey,
        isNotNull,
        reason: 'Public key is expected to be available after first read',
      );
      expect(showSharingInitializing(contactAliceFromBobsRepo), false);
      expect(showSharingOffer(contactAliceFromBobsRepo), false);
      expect(showDirectSharing(contactAliceFromBobsRepo), false);
    });

    // Alice checks for Bob sharing back
    debugPrint('---');
    debugPrint('ALICE ACTING');

    await retryUntilTimeout(20, () async {
      contactBobInvitedByA = (await contactStorageA.get(
        contactBobInvitedByA.coagContactId,
      ))!;
      expect(
        contactBobInvitedByA.details?.names.values.firstOrNull,
        'UserB',
        reason: 'Name from sharing profile',
      );
      expect(
        contactBobInvitedByA.dhtSettings.theyAckHandshakeComplete,
        true,
        reason: 'Bob indicated handshake complete',
      );
      expect(
        contactBobInvitedByA.dhtSettings.initialSecret,
        isNull,
        reason: 'Initial secret discarded due to switch to public key crypto',
      );
    });

    // Bob checks for completed handshake after updating receive and share
    debugPrint('---');
    debugPrint('BOB ACTING');
    await retryUntilTimeout(20, () async {
      contactAliceFromBobsRepo = (await contactStorageB.get(
        contactAliceFromBobsRepo.coagContactId,
      ))!;
      expect(
        contactAliceFromBobsRepo.dhtSettings.theyAckHandshakeComplete,
        true,
        reason: 'Handshake accepted as complete by Alice',
      );
      expect(
        contactAliceFromBobsRepo.dhtSettings.initialSecret,
        isNull,
        reason: 'Initial secret removed after pub keys exchanged and handshake',
      );
    });

    //// TRANSITION FROM SYMMETRIC TO ASYMMETRIC CRYPTO COMPLETED ////
    ////           TESTING ASYMMETRIC KEY ROTATION NOW            ////

    // Bob shares update, testing key rotation
    debugPrint('---');
    debugPrint('BOB ACTING');
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

    // Alice receives new location
    debugPrint('---');
    debugPrint('ALICE ACTING');
    await retryUntilTimeout(20, () async {
      final contactBobFromAlicesRepo = (await contactStorageA.get(
        contactBobInvitedByA.coagContactId,
      ))!;
      expect(
        contactBobFromAlicesRepo.dhtSettings.theirPublicKey,
        isNotNull,
        reason: 'Public key is marked as working',
      );
      expect(
        contactBobFromAlicesRepo.dhtSettings.theirNextPublicKey,
        isNotNull,
        reason: 'Follow up public key has been transmitted',
      );
      expect(
        contactBobFromAlicesRepo.dhtSettings.theirPublicKey,
        isNot(equals(contactBobFromAlicesRepo.dhtSettings.theirNextPublicKey)),
        reason: 'Follow up key differs',
      );
      expect(
        contactBobFromAlicesRepo.dhtSettings.theirNextPublicKey,
        contactAliceFromBobsRepo.dhtSettings.myNextKeyPair?.key,
        reason: 'Next key matches source next key pair public key',
      );
    });
  });
}
