// Copyright 2026 The Reunicorn Authors. All rights reserved.
// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter_vodozemac/flutter_vodozemac.dart' as vod_flutter;
import 'package:integration_test/integration_test.dart';
import 'package:reunicorn/data/models/circle.dart';
import 'package:reunicorn/data/models/coag_contact.dart';
import 'package:reunicorn/data/models/community.dart';
import 'package:reunicorn/data/models/contact_details.dart';
import 'package:reunicorn/data/models/dht_connection_state.dart';
import 'package:reunicorn/data/models/profile_info.dart';
import 'package:reunicorn/data/models/profile_sharing/settings.dart';
import 'package:reunicorn/data/models/setting.dart';
import 'package:reunicorn/data/repositories/community_dht.dart';
import 'package:reunicorn/data/repositories/contact_dht.dart';
import 'package:reunicorn/data/services/storage/memory.dart';
import 'package:reunicorn/data/utils.dart';
import 'package:reunicorn/ui/utils.dart';
import 'package:reunicorn/veilid_init.dart';
import 'package:test/test.dart';
import 'package:uuid/uuid.dart';

import 'utils.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    await AppGlobalInit.initialize(veilidBootstrapUrl);
    await vod_flutter.init();
  });

  test('two community members connect', () async {
    // Setup interconnected mock DHTs
    final dhtMgmt = MockDht(useVeilidKeyPairWriter: true);
    final dhtA = MockDht(useVeilidKeyPairWriter: true);
    final dhtB = MockDht(useVeilidKeyPairWriter: true);
    dhtMgmt.connect(dhtA);
    dhtMgmt.connect(dhtB);
    dhtA.connect(dhtMgmt);
    dhtA.connect(dhtB);
    dhtB.connect(dhtMgmt);
    dhtB.connect(dhtA);

    // Community repo setup for community manager and two members A and B
    final repoMgmt = CommunityDhtRepository(
      MemoryStorage<Community>(),
      MemoryStorage<CoagContact>(),
      dhtMgmt,
    );
    final communityStorageA = MemoryStorage<Community>();
    final contactStorageA = MemoryStorage<CoagContact>();
    final repoA = CommunityDhtRepository(
      communityStorageA,
      contactStorageA,
      dhtA,
    );
    final communityStorageB = MemoryStorage<Community>();
    final contactStorageB = MemoryStorage<CoagContact>();
    final repoB = CommunityDhtRepository(
      communityStorageB,
      contactStorageB,
      dhtB,
    );

    // Set up community via community manager
    print('set up community with two members');
    final communitySecret = await generateRandomSharedSecretBest();
    final memberRecordA = await repoMgmt.createMemberRecord();
    final memberRecordB = await repoMgmt.createMemberRecord();
    final managedCommunity = ManagedCommunity(
      name: 'Community',
      communityUuid: '123',
      communitySecret: communitySecret,
      membersWithWriters: [
        (
          OrganizerProvidedMemberInfo(recordKey: memberRecordA.$1, name: 'A'),
          memberRecordA.$2,
        ),
        (
          OrganizerProvidedMemberInfo(recordKey: memberRecordB.$1, name: 'B'),
          memberRecordB.$2,
        ),
      ],
    );
    final managementSucceeded = await repoMgmt.updateManagedCommunityToDht(
      managedCommunity,
    );
    expect(managementSucceeded, equals(true));

    final inviteA = CommunityInvite(memberRecordA.$1, memberRecordA.$2);
    final inviteB = CommunityInvite(memberRecordB.$1, memberRecordB.$2);

    print('community set up, inviting members');

    // Community members accept their community invites and discover each other
    var communityA = await repoA.acceptCommunityFromInvite(
      inviteA.recordKey,
      inviteA.recordWriter,
    );
    var communityB = await repoB.acceptCommunityFromInvite(
      inviteB.recordKey,
      inviteB.recordWriter,
    );

    await Future.delayed(Duration(seconds: 2));

    communityA = (await communityStorageA.get(
      communityA.recordKey.toString(),
    ))!;
    communityB = (await communityStorageB.get(
      communityB.recordKey.toString(),
    ))!;

    expect(communityA, isNotNull);
    expect(communityA.members.firstOrNull?.name, equals('B'));

    expect(communityB, isNotNull);
    expect(communityB.members.firstOrNull?.name, equals('A'));

    print('members got their community info');

    // We need one more roundtrip to ensure the members populated their
    // community member identity key
    await repoA.updateCommunityFromDht(communityA.recordKey);
    await repoB.updateCommunityFromDht(communityB.recordKey);

    communityA = (await communityStorageA.get(
      communityA.recordKey.toString(),
    ))!;
    communityB = (await communityStorageB.get(
      communityB.recordKey.toString(),
    ))!;
    expect(communityA.members.first.theirPublicKey, isNotNull);
    expect(communityB.members.first.theirPublicKey, isNotNull);

    print('members discovered their public keys');

    // Community member A repo setup in prep for sharing
    final circleStorageA = MemoryStorage<Circle>();
    final profileStorageA = MemoryStorage<ProfileInfo>();
    final profileA = ProfileInfo(
      Uuid().v4(),
      details: ContactDetails(names: {'fn': 'A Full Name'}),
      sharingSettings: ProfileSharingSettings(
        names: {
          'fn': ['circleId'],
        },
      ),
    );
    await profileStorageA.set(profileA.id, profileA);
    final contactRepoA = ContactDhtRepository(
      contactStorageA,
      circleStorageA,
      profileStorageA,
      MemoryStorage<Setting>(),
      dhtA,
    );

    // Community member B repo setup in prep for sharing
    final circleStorageB = MemoryStorage<Circle>();
    final profileStorageB = MemoryStorage<ProfileInfo>();
    final profileB = ProfileInfo(
      Uuid().v4(),
      details: ContactDetails(names: {'fn': 'B Full Name'}),
      sharingSettings: ProfileSharingSettings(
        names: {
          'fn': ['circleId'],
        },
      ),
    );
    await profileStorageB.set(profileB.id, profileB);
    final contactRepoB = ContactDhtRepository(
      contactStorageB,
      circleStorageB,
      profileStorageB,
      MemoryStorage<Setting>(),
      dhtB,
    );

    // We need one more roundtrip
    await repoA.updateCommunityFromDht(communityA.recordKey);
    await repoB.updateCommunityFromDht(communityB.recordKey);
    communityA = (await communityStorageA.get(
      communityA.recordKey.toString(),
    ))!;
    communityB = (await communityStorageB.get(
      communityB.recordKey.toString(),
    ))!;

    await Future.delayed(Duration(seconds: 1));

    // Community members start sharing with each other
    var contactB = await repoA.addContactForMember(
      communityA.members.firstOrNull!,
    );

    await Future.delayed(Duration(seconds: 1));

    // With this step inbetween we're in a one inbound and one outbound situation
    // whereas with adding both contacts straight away, we're in two outbound
    await repoA.updateCommunityFromDht(communityA.recordKey);
    await repoB.updateCommunityFromDht(communityB.recordKey);

    await Future.delayed(Duration(seconds: 1));

    print('A tried to add B as a contact, now B tries to add A');
    var contactA = await repoB.addContactForMember(
      communityB.members.firstOrNull!,
    );

    expect(contactB, isNotNull);
    expect(contactA, isNotNull);

    await Future.delayed(Duration(seconds: 1));

    await repoA.updateCommunityFromDht(communityA.recordKey);
    await repoB.updateCommunityFromDht(communityB.recordKey);

    await Future.delayed(Duration(seconds: 1));

    contactA = await contactStorageB.get(contactA!.coagContactId);
    contactB = await contactStorageA.get(contactB!.coagContactId);
    // expect(
    //   contactB?.dhtConnection?.recordKeyThemSharing,
    //   equals(contactA?.dhtConnection?.recordKeyMeSharingOrNull),
    // );
    // expect(
    //   contactA?.dhtConnection?.recordKeyThemSharing,
    //   equals(contactB?.dhtConnection?.recordKeyMeSharingOrNull),
    // );

    await Future.delayed(Duration(seconds: 2));

    final circleB = Circle(
      id: 'circleId',
      name: 'Circle!',
      memberIds: [contactA!.coagContactId],
    );
    await circleStorageB.set(circleB.id, circleB);

    final circleA = Circle(
      id: 'circleId',
      name: 'Circle!',
      memberIds: [contactB!.coagContactId],
    );
    await circleStorageA.set(circleA.id, circleA);

    await Future.delayed(Duration(seconds: 2));

    contactA = await contactStorageB.get(contactA.coagContactId);
    contactB = await contactStorageA.get(contactB.coagContactId);
    expect(contactA?.details?.names.values.firstOrNull, equals('A Full Name'));
    expect(contactB?.details?.names.values.firstOrNull, equals('B Full Name'));
  });
}
