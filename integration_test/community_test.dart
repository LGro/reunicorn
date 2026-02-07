// Copyright 2026 The Reunicorn Authors. All rights reserved.
// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter_vodozemac/flutter_vodozemac.dart' as vod_flutter;
import 'package:integration_test/integration_test.dart';
import 'package:reunicorn/data/models/coag_contact.dart';
import 'package:reunicorn/data/models/community.dart';
import 'package:reunicorn/data/repositories/community_dht.dart';
import 'package:reunicorn/data/services/storage/memory.dart';
import 'package:reunicorn/ui/utils.dart';
import 'package:reunicorn/veilid_init.dart';
import 'package:test/test.dart';

import '../test/mocked_providers.dart';
import 'utils.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    await AppGlobalInit.initialize(veilidBootstrapUrl);
    await vod_flutter.init();
  });

  test('two community members connect', () async {
    final dhtStorage = MockDht();
    final repoMgmt = CommunityDhtRepository(
      MemoryStorage<Community>(),
      MemoryStorage<CoagContact>(),
      dhtStorage,
    );
    final communityStorageA = MemoryStorage<Community>();
    final repoA = CommunityDhtRepository(
      communityStorageA,
      MemoryStorage<CoagContact>(),
      dhtStorage,
    );
    final communityStorageB = MemoryStorage<Community>();
    final repoB = CommunityDhtRepository(
      communityStorageB,
      MemoryStorage<CoagContact>(),
      dhtStorage,
    );

    final communitySecret = fakePsk(0);
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
    repoMgmt.updateManagedCommunityToDht(managedCommunity);

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
    communityB = await communityStorageA.get(communityB!.recordKey.toString());

    expect(communityA?.members.first.name, equals('B'));
    expect(communityB?.members.first.name, equals('A'));
  });
}
