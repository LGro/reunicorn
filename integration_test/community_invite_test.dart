// Copyright 2025 - 2026 The Reunicorn Authors. All rights reserved.
// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:reunicorn/data/models/community.dart';
import 'package:reunicorn/data/models/models.dart';
import 'package:reunicorn/data/repositories/community_dht.dart';
import 'package:reunicorn/data/services/dht/veilid_dht.dart';
import 'package:reunicorn/data/services/storage/memory.dart';
import 'package:reunicorn/data/utils.dart';
import 'package:reunicorn/ui/introductions/cubit.dart';
import 'package:reunicorn/ui/utils.dart';
import 'package:reunicorn/veilid_init.dart';
import 'package:veilid_support/veilid_support.dart';

import 'utils.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    await AppGlobalInit.initialize(veilidBootstrapUrl);
  });

  test('Community invite leads to mutual contact introductions', () async {
    // ORGANIZER: Create community with two members
    debugPrint('ORGANIZER: Creating community');
    final communitySecret = await generateRandomSharedSecretBest();

    // Create member records for User A and User B
    final recordA = await DHTRecordPool.instance.createRecord(
      debugName: 'test::member-a',
    );
    final openedA = await DHTRecordPool.instance.openRecordWrite(
      recordA.key,
      recordA.writer!,
      debugName: 'test::open-write-member-a',
    );
    await openedA.eventualWriteBytes(Uint8List(0));

    final recordB = await DHTRecordPool.instance.createRecord(
      debugName: 'test::member-b',
    );
    final openedB = await DHTRecordPool.instance.openRecordWrite(
      recordB.key,
      recordB.writer!,
      debugName: 'test::open-write-member-b',
    );
    await openedB.eventualWriteBytes(Uint8List(0));

    final memberInfoA = OrganizerProvidedMemberInfo(
      recordKey: recordA.key,
      name: 'UserA',
    );
    final memberInfoB = OrganizerProvidedMemberInfo(
      recordKey: recordB.key,
      name: 'UserB',
    );

    // Write CommunityInfo to each member's DHT record
    final communityInfo = CommunityInfo(
      name: 'Test Community',
      secret: communitySecret,
      membersInfo: [memberInfoA, memberInfoB],
    );
    final communityInfoBytes = utf8.encode(jsonEncode(communityInfo.toJson()));

    // Write community info to member A's record
    final cryptoA = await VeilidCryptoPrivate.fromKeyPair(
      recordA.writer!,
      'community-info',
    );
    await Future.wait(
      chopPayloadChunks(
        Uint8List.fromList(communityInfoBytes),
        numChunks: communityInfoSubkeys,
      ).toList().asMap().entries.map(
        (e) => openedA.eventualWriteBytes(
          crypto: cryptoA,
          e.value,
          subkey: e.key,
        ),
      ),
    );

    // Write community info to member B's record
    final cryptoB = await VeilidCryptoPrivate.fromKeyPair(
      recordB.writer!,
      'community-info',
    );
    await Future.wait(
      chopPayloadChunks(
        Uint8List.fromList(communityInfoBytes),
        numChunks: communityInfoSubkeys,
      ).toList().asMap().entries.map(
        (e) => openedB.eventualWriteBytes(
          crypto: cryptoB,
          e.value,
          subkey: e.key,
        ),
      ),
    );

    debugPrint('ORGANIZER: Community info written to both member records');

    // Construct invite links for each member
    final inviteLinkA = CommunityInvite(recordA.key, recordA.writer!);
    final inviteLinkB = CommunityInvite(recordB.key, recordB.writer!);

    // USER A: Accept community invite
    debugPrint('---');
    debugPrint('USER A: Accepting community invite');
    final communityStorageA = MemoryStorage<Community>();
    final contactStorageA = MemoryStorage<CoagContact>();
    // ignore: unused_local_variable
    final communityDhtRepoA = CommunityDhtRepository(
      communityStorageA,
      contactStorageA,
    );

    // Simulate handleCommunityInvite for User A
    final communityA = Community(
      recordKey: inviteLinkA.recordKey,
      recordWriter: inviteLinkA.recordWriter,
      members: [],
      mostRecentUpdate: DateTime.now(),
    );
    await communityStorageA.set(
      communityA.recordKey.toString(),
      communityA,
    );

    // USER B: Accept community invite
    debugPrint('---');
    debugPrint('USER B: Accepting community invite');
    final communityStorageB = MemoryStorage<Community>();
    final contactStorageB = MemoryStorage<CoagContact>();
    // ignore: unused_local_variable
    final communityDhtRepoB = CommunityDhtRepository(
      communityStorageB,
      contactStorageB,
    );

    // Simulate handleCommunityInvite for User B
    final communityB = Community(
      recordKey: inviteLinkB.recordKey,
      recordWriter: inviteLinkB.recordWriter,
      members: [],
      mostRecentUpdate: DateTime.now(),
    );
    await communityStorageB.set(
      communityB.recordKey.toString(),
      communityB,
    );

    // Wait for community updates to propagate via DHT
    debugPrint('---');
    debugPrint('Waiting for community updates to propagate');

    // Check that User A sees User B as a pending community introduction
    await retryUntilTimeout(30, () async {
      final communitiesA = await communityStorageA.getAll();
      final contactsA = await contactStorageA.getAll();
      final introductionsA = pendingCommunityIntroductions(
        communitiesA.values,
        contactsA.values,
      );
      debugPrint(
        'User A introductions: ${introductionsA.length}, '
        'communities: ${communitiesA.length}, '
        'members: ${communitiesA.values.firstOrNull?.members.length ?? 0}',
      );
      expect(introductionsA, isNotEmpty, reason: 'User A should see User B');
      expect(
        introductionsA.any((i) => i.$2.name == 'UserB'),
        true,
        reason: 'User A should see UserB as community introduction',
      );
    });

    // Check that User B sees User A as a pending community introduction
    await retryUntilTimeout(30, () async {
      final communitiesB = await communityStorageB.getAll();
      final contactsB = await contactStorageB.getAll();
      final introductionsB = pendingCommunityIntroductions(
        communitiesB.values,
        contactsB.values,
      );
      debugPrint(
        'User B introductions: ${introductionsB.length}, '
        'communities: ${communitiesB.length}, '
        'members: ${communitiesB.values.firstOrNull?.members.length ?? 0}',
      );
      expect(introductionsB, isNotEmpty, reason: 'User B should see User A');
      expect(
        introductionsB.any((i) => i.$2.name == 'UserA'),
        true,
        reason: 'User B should see UserA as community introduction',
      );
    });

    debugPrint('Both users see each other as community member introductions');
  });
}
