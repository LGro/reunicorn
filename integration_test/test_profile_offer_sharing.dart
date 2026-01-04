// Copyright 2024 - 2025 The Reunicorn Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reunicorn/data/models/circle.dart';
import 'package:reunicorn/data/models/coag_contact.dart';
import 'package:reunicorn/data/models/community.dart';
import 'package:reunicorn/data/models/profile_info.dart';
import 'package:reunicorn/data/models/profile_sharing_settings.dart';
import 'package:reunicorn/data/repositories/contact_dht.dart';
import 'package:reunicorn/data/services/storage/memory.dart';
import 'package:reunicorn/data/utils.dart';
import 'package:reunicorn/ui/receive_request/cubit.dart';
import 'package:reunicorn/ui/receive_request/utils/profile_based.dart';
import 'package:reunicorn/ui/utils.dart';

import 'utils.dart';

const _defaultCircleId = 'c1';

Future<void> testProfileOfferBasedSharing() async {
  // SETUP
  final _contactStorageA = MemoryStorage<CoagContact>();
  final _circleStorageA = MemoryStorage<Circle>();
  final _profileStorageA = MemoryStorage<ProfileInfo>();
  final _contactStorageB = MemoryStorage<CoagContact>();
  final _circleStorageB = MemoryStorage<Circle>();
  final _profileStorageB = MemoryStorage<ProfileInfo>();

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
    true,
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
    true,
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
    expect(showSharingInitializing(contactBobFromProfile), false);
    expect(showSharingOffer(contactBobFromProfile), true);
    expect(showDirectSharing(contactBobFromProfile), false);
  });
  final profileBasedOfferLinkFromAliceForBob = ProfileBasedInvite(
    'Alice Sharing',
    contactBobFromProfile.dhtSettings.recordKeyMeSharing!,
    contactBobFromProfile.dhtSettings.myKeyPair!.key,
  );

  // Bob accepts profile based offer from Alice and shares via default circle
  debugPrint('---');
  debugPrint('BOB ACTING');
  var contactAliceFromBobsRepo = await createContactFromProfileInvite(
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
  // Wait for sharing
  await retryUntilTimeout(20, () async {
    contactAliceFromBobsRepo = await _contactStorageB.get(
      contactAliceFromBobsRepo!.coagContactId,
    );
    expect(
      contactAliceFromBobsRepo!.dhtSettings.myKeyPair,
      bobsMainKeyPair,
      reason: 'Used correct profile key pair',
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
      contactAliceFromBobsRepo!.dhtSettings.theyAckHandshakeComplete,
      true,
      reason: 'Handshake accepted as complete by Alice',
    );
    expect(showSharingInitializing(contactAliceFromBobsRepo!), false);
    expect(showSharingOffer(contactAliceFromBobsRepo!), false);
    expect(showDirectSharing(contactAliceFromBobsRepo!), false);
  });

  // Alice checks for Bob sharing back
  debugPrint('---');
  debugPrint('ALICE ACTING');
  // Wait for sharing
  await retryUntilTimeout(20, () async {
    contactBobFromProfile = (await _contactStorageA.get(
      contactBobFromProfile.coagContactId,
    ))!;
    expect(
      contactBobFromProfile.details?.names.values.firstOrNull,
      'UserB',
      reason: 'Name from sharing profile',
    );
    expect(
      contactBobFromProfile.dhtSettings.theyAckHandshakeComplete,
      true,
      reason: 'Bob indicated handshake complete',
    );
  });
}
