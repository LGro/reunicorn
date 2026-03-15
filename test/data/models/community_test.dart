// Copyright 2024 - 2025 The Reunicorn Authors. All rights reserved.
// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:reunicorn/data/models/community.dart';
import 'package:veilid/veilid.dart';

import '../../mocked_providers.dart';

void main() {
  test('test member record organizer info for me size limit', () {
    final info = CommunityInfo(
      name: 'A@' * (memberNameMaxLength ~/ 2),
      expiresAt: DateTime(9000),
      secret: fakePsk(0),
      membersInfo: List.filled(
        communityMaxMembers,
        OrganizerProvidedMemberInfo(
          name: 'A' * memberNameMaxLength,
          recordKey: fakeDhtRecordKey(),
          comment: 'A' * organizerCommentMaxLength,
        ),
      ),
    );

    final utf8Bytes = utf8.encode(jsonEncode(info.toJson()));
    final sizeInMB = utf8Bytes.length / (1024 * 1024);
    const sizeLimit = 1.0 / 32 * communityInfoSubkeys;

    expect(
      sizeInMB,
      lessThan(sizeLimit),
      reason:
          'OrganizerInfoForMe JSON size should be < '
          '${sizeLimit.toStringAsFixed(2)}MB at size limit, '
          'but was ${sizeInMB.toStringAsFixed(2)}MB',
    );
  });

  test('equals ignores updated timestamps', () {
    final c1 = Community(
      recordKey: fakeDhtRecordKey(1),
      recordWriter: fakeKeyPair(0, 1),
      members: [
        Member(
          communityRecordKey: fakeDhtRecordKey(10),
          infoRecordKey: fakeDhtRecordKey(11),
          name: 'm1',
          myVodozemacAccount: '',
          comment: MemberComment(
            comment: 'commi',
            mostRecentUpdate: DateTime(0),
          ),
        ),
      ],
      mostRecentUpdate: DateTime(0),
    );
    final c2 = Community(
      recordKey: fakeDhtRecordKey(1),
      recordWriter: fakeKeyPair(0, 1),
      members: [
        Member(
          communityRecordKey: fakeDhtRecordKey(10),
          infoRecordKey: fakeDhtRecordKey(11),
          name: 'm1',
          myVodozemacAccount: '',
          comment: MemberComment(
            comment: 'commi',
            mostRecentUpdate: DateTime(1),
          ),
        ),
      ],
      mostRecentUpdate: DateTime(0),
    );
    expect(c1, equals(c1));
    expect(c1, equals(c1.copyWith(mostRecentUpdate: DateTime(1))));
    expect(c1, equals(c2));
  });

  test('test member record my info for members size limit', () {
    final recordKey = fakeDhtRecordKey().toString();
    final info = MemberInfo(
      publicKey: PublicKey.fromString('VLD0:'),
      sharingOffers: Map.fromEntries(
        List.filled(
          communityMaxMembers - 1,
          (
          // This is missing the encryption step, which might influence the byte size
          MapEntry(
            base64Encode(HashDigest.fromString(recordKey).toBytes()),
            // TODO: What length a vodozemac identity and onetime keys
            MemberSharingOffer(
              identityKey: '',
              recordKey: RecordKey.fromString(recordKey),
              oneTimeKey: '',
            ),
          )),
        ),
      ),
    );

    final utf8Bytes = utf8.encode(jsonEncode(info.toJson()));
    final sizeInMB = utf8Bytes.length / (1024 * 1024);
    const sizeLimit = 1.0 / 32 * memberInfoSubkeys;

    expect(
      sizeInMB,
      lessThan(sizeLimit),
      reason:
          'MyInfoForMembers JSON size should be < '
          '${sizeLimit.toStringAsFixed(2)}MB at size limit, '
          'but was ${sizeInMB.toStringAsFixed(2)}MB',
    );
  });
}
