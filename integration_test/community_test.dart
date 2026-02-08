// Copyright 2026 The Reunicorn Authors. All rights reserved.
// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter_vodozemac/flutter_vodozemac.dart' as vod_flutter;
import 'package:integration_test/integration_test.dart';
import 'package:reunicorn/data/models/circle.dart';
import 'package:reunicorn/data/models/coag_contact.dart';
import 'package:reunicorn/data/models/community.dart';
import 'package:reunicorn/data/models/crypto_state.dart';
import 'package:reunicorn/data/models/profile_info.dart';
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
    final dhtMgmt = MockDht(useVeilidKeyPairWriter: true);
    final dhtA = MockDht(useVeilidKeyPairWriter: true);
    final dhtB = MockDht(useVeilidKeyPairWriter: true);
    dhtMgmt.connect(dhtA);
    dhtMgmt.connect(dhtB);
    dhtA.connect(dhtMgmt);
    dhtA.connect(dhtB);
    dhtB.connect(dhtMgmt);
    dhtB.connect(dhtA);

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

    var communityA = await repoA.acceptCommunityFromInvite(
      inviteA.recordKey,
      inviteA.recordWriter,
    );
    var communityB = await repoB.acceptCommunityFromInvite(
      inviteB.recordKey,
      inviteB.recordWriter,
    );

    await Future.delayed(Duration(seconds: 1));

    communityA = await communityStorageA.get(communityA!.recordKey.toString());
    communityB = await communityStorageB.get(communityB!.recordKey.toString());

    expect(communityA, isNotNull);
    expect(communityA!.members.firstOrNull?.name, equals('B'));

    expect(communityB, isNotNull);
    expect(communityB!.members.firstOrNull?.name, equals('A'));

    // TODO(LGro): start sharing between two members
    final contactRepoA = ContactDhtRepository(
      contactStorageA,
      MemoryStorage<Circle>(),
      MemoryStorage<ProfileInfo>(),
      MemoryStorage<Setting>(),
      dhtA,
    );
    final contactRepoB = ContactDhtRepository(
      contactStorageB,
      MemoryStorage<Circle>(),
      MemoryStorage<ProfileInfo>(),
      MemoryStorage<Setting>(),
      dhtB,
    );

    // TODO(LGro): What kind of crypto do we need / want here?
    // final contactB = CoagContact(
    //   coagContactId: Uuid().v4(),
    //   name: communityA.members.firstOrNull!.name,
    //   connectionCrypto: CryptoState.symToVod(
    //     theirIdentityKey: theirIdentityKey,
    //     myIdentityKey: myIdentityKey,
    //     sessionVod: sessionVod,
    //   ),
    //   myIdentity: myIdentity,
    // );
    // contactStorageA.set();
  });
}
