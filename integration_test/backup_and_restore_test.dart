// Copyright 2024 - 2026 The Reunicorn Authors. All rights reserved.
// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:reunicorn/data/models/circle.dart';
import 'package:reunicorn/data/models/community.dart';
import 'package:reunicorn/data/models/models.dart';
import 'package:reunicorn/data/models/profile_info.dart';
import 'package:reunicorn/data/models/profile_sharing_settings.dart';
import 'package:reunicorn/data/models/setting.dart';
import 'package:reunicorn/data/repositories/backup_dht.dart';
import 'package:reunicorn/data/repositories/contact_dht.dart';
import 'package:reunicorn/data/services/storage/memory.dart';
import 'package:reunicorn/data/utils.dart';
import 'package:reunicorn/ui/receive_request/cubit.dart';
import 'package:reunicorn/ui/receive_request/utils/profile_based.dart';
import 'package:reunicorn/ui/utils.dart';
import 'package:reunicorn/veilid_init.dart';

import 'encrypted_communication_test.dart';
import 'utils.dart';

const _defaultCircleId = 'c1';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    await AppGlobalInit.initialize(veilidBootstrapUrl);
  });

  test('Backup and restore user account A', () async {
    // Profile based connection flow between A and B
    // Alice prepares invite for Bob using Bob's profile public key and shares
    // via the default circle
    // SETUP
    final _contactStorageA = MemoryStorage<CoagContact>();
    final _circleStorageA = MemoryStorage<Circle>();
    final _profileStorageA = MemoryStorage<ProfileInfo>();
    final _contactStorageB = MemoryStorage<CoagContact>();
    final _circleStorageB = MemoryStorage<Circle>();
    final _profileStorageB = MemoryStorage<ProfileInfo>();
    final dhtStorage = MockDht();

    await _profileStorageA.set(
      'p1',
      ProfileInfo('p1', mainKeyPair: await generateKeyPairBest()),
    );
    await _profileStorageB.set(
      'p1',
      ProfileInfo('p1', mainKeyPair: await generateKeyPairBest()),
    );

    // Initialize Alice's repository
    final _cRepoA = ContactDhtRepository(
      _contactStorageA,
      _circleStorageA,
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
      _contactStorageB,
      _circleStorageB,
      MemoryStorage<ProfileInfo>()..addToMemory(
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

    final bobsMainKeyPair = await _profileStorageB.getAll().then(
      (profiles) => profiles.values.first.mainKeyPair!,
    );
    final bobsProfileUrl = profileUrl('Bob Profile', bobsMainKeyPair.key);

    // Alice prepares invite for Bob using Bob's profile public key and shares via the default circle
    debugPrint('ALICE ACTING');
    final rrCubitA = ReceiveRequestCubit(
      _contactStorageA,
      _profileStorageA,
      MemoryStorage<Community>(),
      _cRepoA,
    );
    await rrCubitA.handleProfileLink(bobsProfileUrl.fragment);
    var contactBobFromProfile = await _contactStorageA.getAll().then(
      (contacts) => contacts.values.first,
    );
    await _circleStorageA.set(
      _defaultCircleId,
      Circle(
        id: _defaultCircleId,
        name: 'circle1',
        memberIds: [contactBobFromProfile.coagContactId],
      ),
    );
    // Wait for sharing
    await retryUntilTimeout(20, () async {
      contactBobFromProfile = (await _contactStorageA.get(
        contactBobFromProfile.coagContactId,
      ))!;
      expect(
        contactBobFromProfile.dhtSettings.theirNextPublicKey,
        bobsMainKeyPair.key,
        reason: 'Used given profile public key',
      );
      expect(
        contactBobFromProfile.dhtSettings.recordKeyMeSharing,
        isNotNull,
        reason: 'Sharing record prepared',
      );
      expect(
        contactBobFromProfile.dhtSettings.recordKeyThemSharing,
        isNotNull,
        reason: 'Receiving record prepared',
      );
    });
    final profileBasedOfferLinkFromAliceForBob = ProfileBasedInvite(
      'Alice Sharing',
      contactBobFromProfile.dhtSettings.recordKeyMeSharing!,
      contactBobFromProfile.dhtSettings.myKeyPair!.key,
    );

    // Bob accepts profile based offer from Alice and shares via default circle
    debugPrint('---');
    debugPrint('BOB ACTING');
    final contactAliceFromBobsRepo = await createContactFromProfileInvite(
      profileBasedOfferLinkFromAliceForBob.uri.fragment,
      bobsMainKeyPair,
      _contactStorageB,
    );
    await _circleStorageB.set(
      _defaultCircleId,
      Circle(
        id: _defaultCircleId,
        name: 'circle1',
        memberIds: [contactAliceFromBobsRepo!.coagContactId],
      ),
    );
    // await retryUntilTimeout(20, () async {
    //   contactBobFromProfile = (await _contactStorageA.get(
    //     contactBobFromProfile.coagContactId,
    //   ))!;
    //   expect(
    //     contactBobFromProfile.details?.names.values.firstOrNull,
    //     'UserB',
    //     reason: 'Name from sharing profile',
    //   );
    //   expect(
    //     contactBobFromProfile.details?.phones.values.firstOrNull,
    //     '123',
    //     reason: 'Phone number from shared details',
    //   );
    // });

    // Backup for Alice
    final backingUpRepo = BackupRepository(
      _profileStorageA,
      _contactStorageA,
      _circleStorageA,
      MemoryStorage<Setting>(),
    );
    final backupInfo = await backingUpRepo.backup(waitForRecordSync: false);
    expect(
      backupInfo,
      isNotNull,
      reason: 'Expecting successful backup record creation.',
    );

    // Restore for Alice
    final restoredProfiles = MemoryStorage<ProfileInfo>();
    final restoredContacts = MemoryStorage<CoagContact>();
    final restoredCircles = MemoryStorage<Circle>();
    final restoredSettings = MemoryStorage<Setting>();
    final restoringBackupRepo = BackupRepository(
      restoredProfiles,
      restoredContacts,
      restoredCircles,
      restoredSettings,
    );
    final restoreSuccess = await restoringBackupRepo.restore(
      backupInfo!.$1,
      backupInfo.$2,
    );
    expect(restoreSuccess, true, reason: 'Expected restore to succeed');
    final restoredProfile = await restoredProfiles.getAll().then(
      (p) => p.values.firstOrNull,
    );
    expect(restoredProfile?.details.names.values.firstOrNull, 'UserA');
    final restoredContactB = await restoredContacts.get(
      await _contactStorageA.getAll().then((c) => c.keys.first),
    );
    expect(restoredContactB?.name, 'Bob Profile');
    expect(restoredContactB?.details?.phones.values.first, '123');
    expect(restoredContactB?.details?.names.values.first, 'UserB');
    expect(
      restoredContactB?.sharedProfile?.details.names.values.first,
      'UserA',
    );
  });
}
