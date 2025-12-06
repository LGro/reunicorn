// Copyright 2024 - 2025 The Reunicorn Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:reunicorn/data/models/community.dart';
import 'package:uuid/uuid.dart';
import 'package:veilid/veilid.dart';

void main() {
  test('test member record organizer info for me size limit', () {
    final info = CommunityInfo(
      name: 'A@' * (memberNameMaxLength ~/ 2),
      id: const Uuid().v4(),
      expiresAt: DateTime(9000),
      secret: SharedSecret.fromString(
        'VLD0:gnUrDivmlpvzonJ0Wwu2PR3x1Y3m3MtocD0kPWZqSa0',
      ),
      membersInfo: List.filled(
        communityMaxMembers,
        OrganizerProvidedMemberInfo(
          name: 'A' * memberNameMaxLength,
          recordKey: RecordKey.fromString(
            'VLD0:gnUrDivmlpvzonJ0Wwu2PR3x1Y3m3MtocD0kPWZqSa0',
          ),
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

  test('test member record my info for members size limit', () {
    final info = MemberInfo(
      publicKey: PublicKey.fromString('VLD0:'),
      sharingOffers: List.filled(communityMaxMembers - 1, (
        HashDigest.fromString(
          'VLD0:gnUrDivmlpvzonJ0Wwu2PR3x1Y3m3MtocD0kPWZqSa0',
        ),
        RecordKey.fromString(
          'VLD0:gnUrDivmlpvzonJ0Wwu2PR3x1Y3m3MtocD0kPWZqSa0',
        ),
      )),
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
