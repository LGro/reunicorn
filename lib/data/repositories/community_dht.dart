// Copyright 2025 - 2026 The Reunicorn Authors. All rights reserved.
// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:async';
import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:multiple_result/multiple_result.dart';
import 'package:veilid_support/veilid_support.dart';

import '../models/community.dart';
import '../models/models.dart';
import '../services/dht/veilid_dht.dart';
import '../services/storage/base.dart';
import 'base_dht.dart';

extension CommunityExtension on Community {
  bool isExpired() => info?.expiresAt?.isBefore(mostRecentUpdate) ?? false;
}

class CommunityOrigin {
  static const separator = '|';
  static const prefix = 'COMMUNITY';

  final RecordKey communityRecordKey;
  final RecordKey memberInfoRecordKey;

  CommunityOrigin({
    required this.communityRecordKey,
    required this.memberInfoRecordKey,
  });

  factory CommunityOrigin.fromMember(Member member) => CommunityOrigin(
    communityRecordKey: member.communityRecordKey,
    memberInfoRecordKey: member.infoRecordKey,
  );

  static CommunityOrigin? fromString(String string) {
    if (!string.startsWith(prefix)) {
      return null;
    }

    final parts = string.split(separator);
    try {
      return CommunityOrigin(
        communityRecordKey: RecordKey.fromString(parts[1]),
        memberInfoRecordKey: RecordKey.fromString(parts[2]),
      );
    } catch (e) {
      return null;
    }
  }

  @override
  String toString() =>
      [prefix, communityRecordKey, memberInfoRecordKey].join(separator);
}

Future<HashDigest> generateMemberSecretHash(
  PublicKey memberPublicKey,
  SecretKey mySecretKey,
) async {
  final cryptoSystem = await Veilid.instance.getCryptoSystem(cryptoKindVLD0);
  return cryptoSystem
      .generateSharedSecret(
        memberPublicKey,
        mySecretKey,
        utf8.encode('community-members-initial-sharing'),
      )
      .then((ourSecret) => cryptoSystem.generateHash(ourSecret.toBytes()));
}

// update member from my member record community info part
// -> check comment changed, update last comment changed timestamp
// update member from their member record
// TODO: Should this be part of Member.copyWith()?
Member updateMemberComment(Member member, String? comment) => member.copyWith(
  comment: comment,
  mostRecentCommentUpdate: (member.comment != comment) ? DateTime.now() : null,
);

/// Generate sharing offers for my member info based for all community members
Future<List<(HashDigest, RecordKey)>> sharingOffers(
  List<Member> members,
  SecretKey mySecretKey,
) => Future.wait(
  members
      .where((m) => m.theirPublicKey != null && m.recordKeyMeSharing != null)
      .map(
        (m) async => (
          await generateMemberSecretHash(m.theirPublicKey!, mySecretKey),
          m.recordKeyMeSharing!,
        ),
      ),
);

class CommunityDhtRepository extends BaseDhtRepository {
  final BaseDht _dhtStorage;
  final Storage<Community> _communityStorage;
  final Storage<CoagContact> _contactStorage;
  var veilidNetworkAvailable = false;

  // TODO: Add information about which community is currently being synced / was synced last

  CommunityDhtRepository(
    this._communityStorage,
    this._contactStorage,
    this._dhtStorage,
  ) {
    _communityStorage.changeEvents.listen((e) async {
      await e.when(
        set: (oldCommunity, newCommunity) =>
            (oldCommunity?.copyWith(mostRecentUpdate: DateTime(0)) !=
                newCommunity.copyWith(mostRecentUpdate: DateTime(0)))
            ? _updateCommunityFromDht(newCommunity.recordKey)
            : null,
        delete: _onDeleteCommunity,
      );
    });
    _communityStorage.getEvents.listen(
      (community) => _watchCommunity(community.recordKey),
    );
    _contactStorage.changeEvents.listen((e) async {
      if (e is SetEvent<CoagContact>) {
        await _onContactSet(e.newValue);
      }
    });
  }

  // TODO: What happens with watch if we're offline? does it watch as soon as we go online or fail?
  // TODO: Do we need to build up a watch queue when offline to then start watch when online?
  /// Watch for community updates via the DHT
  Future<bool> _watchCommunity(RecordKey recordKey) => _dhtStorage.watch(
    recordKey,
    () => _updateCommunityFromDht(recordKey, useLocalCache: true),
  );

  Future<void> _updateCommunityFromDht(
    RecordKey recordKey, {
    bool useLocalCache = false,
  }) async {
    final community = await _communityStorage.get(recordKey.toString());
    if (community == null) {
      return;
    }

    // TODO(LGro): pass on useLocalCache
    final updatedCommunity = await updateCommunity(community);

    if (community.copyWith(mostRecentUpdate: DateTime(0)) !=
        updatedCommunity.copyWith(mostRecentUpdate: DateTime(0))) {
      await _communityStorage.set(
        community.recordKey.toString(),
        updatedCommunity,
      );
    }
  }

  Future<void> _onDeleteCommunity(Community community) async {
    // TODO: Indicate leaving community
    throw UnimplementedError();
  }

  Future<void> _onContactSet(CoagContact contact) async {
    // Try to parse contact origin
    final origin = (contact.origin == null)
        ? null
        : CommunityOrigin.fromString(contact.origin!);
    if (origin == null) {
      return;
    }

    // Only if sharing settings are available, does it make sense to continue
    if (contact.dhtConnection is DhtConnectionInvited) {
      return;
    }

    // Get community and check if active
    final community = await _communityStorage.get(
      origin.communityRecordKey.toString(),
    );
    if (community == null || community.isExpired()) {
      return;
    }

    // Get full community member data
    final member = community.members.firstWhereOrNull(
      (m) => m.infoRecordKey == origin.memberInfoRecordKey,
    );
    if (member == null) {
      return;
    }

    final updatedMember = member.copyWith(
      recordKeyMeSharing: (contact.dhtConnection as DhtConnectionEstablished)
          .recordKeyMeSharing,
    );
    if (member.copyWith(mostRecentCommentUpdate: DateTime(0)) ==
        updatedMember.copyWith(mostRecentCommentUpdate: DateTime(0))) {
      return;
    }

    // Add sharing settings to member and update community
    await _communityStorage.set(
      community.recordKey.toString(),
      community.copyWith(
        members: community.members
          ..remove(member)
          ..add(updatedMember),
      ),
    );
  }

  @override
  Future<void> dhtBecameAvailableCallback() => _communityStorage.getAll().then(
    (communities) => communities.values.map(
      (community) => _updateCommunityFromDht(community.recordKey),
    ),
  );

  //// MEMBER COMMUNITY FEATURES ////

  Future<Result<MemberInfo, Exception>> setMemberInfo(
    MemberInfo info,
    RecordKey recordKey,
    KeyPair recordWriter,
    SharedSecret communitySecret,
  ) async {
    final communityCrypto = await VeilidCryptoPrivate.fromSharedSecret(
      communitySecret.kind,
      communitySecret,
    );

    try {
      // TODO: Make this transactional so that either all or nothing
      await _dhtStorage.write(
        recordKey,
        recordWriter,
        await communityCrypto.encrypt(utf8.encode(jsonEncode(info.toJson()))),
        numChunks: memberInfoSubkeys,
        chunkOffset: communityInfoSubkeys,
      );

      return Success(info);
    } on Exception catch (e) {
      return Error(e);
    }
  }

  Future<Community> updateCommunity(Community community) async {
    if (community.isExpired()) {
      return community;
    }

    // Update community info if available
    community = community.copyWith(
      info: await getCommunityInfo(community.recordKey, community.recordWriter),
    );

    // Update community members
    final allMembers = await getMembers(community);
    community = community.copyWith(
      // Filter out current user's member entry
      members: allMembers
          .where((m) => m.infoRecordKey != community.recordKey)
          .toList(),
    );

    // TODO: Do we do this here or elsewhere? Seems to only make sense when we add a new member as contact, right?
    //       However, it might also not take super long and it's a nice place to ensure it's set up
    if (community.info != null) {
      await setMemberInfo(
        MemberInfo(
          publicKey: community.recordWriter.key,
          sharingOffers: await sharingOffers(
            community.members,
            community.recordWriter.secret,
          ),
        ),
        community.recordKey,
        community.recordWriter,
        community.info!.secret,
      );
    }

    return community.copyWith(mostRecentUpdate: DateTime.now());
  }

  Future<Community?> acceptCommunityFromInvite(
    RecordKey recordKey,
    KeyPair recordWriter,
  ) async {
    final communityInfo = await getCommunityInfo(recordKey, recordWriter);

    if (communityInfo == null) {
      return null;
    }

    final community = Community(
      recordKey: recordKey,
      recordWriter: recordWriter,
      info: communityInfo,
      members: [],
      mostRecentUpdate: DateTime.now(),
    );

    await _communityStorage.set(community.recordKey.toString(), community);

    return community;
  }

  Future<CommunityInfo?> getCommunityInfo(
    RecordKey recordKey,
    KeyPair memberKeyPair,
  ) async {
    final memberCrypto = await VeilidCryptoPrivate.fromKeyPair(
      memberKeyPair,
      'community-info',
    );
    try {
      final value = await _dhtStorage.read(
        recordKey,
        numChunks: communityInfoSubkeys,
        chunkOffset: 0,
        local: false,
      );
      if (value == null) {
        return null;
      }
      return CommunityInfo.fromJson(
        jsonDecode(utf8.decode(await memberCrypto.decrypt(value)))
            as Map<String, dynamic>,
      );
    } catch (e) {
      // TODO: log error
      return null;
    }
  }

  Future<Result<MemberInfo, Exception>> getMemberInfo(
    RecordKey recordKey,
    SharedSecret communitySecret,
  ) async {
    final communityCrypto = await VeilidCryptoPrivate.fromSharedSecret(
      communitySecret.kind,
      communitySecret,
    );
    try {
      final value = await _dhtStorage.read(
        recordKey,
        chunkOffset: communityInfoSubkeys,
        numChunks: memberInfoSubkeys,
        local: false,
      );
      if (value == null) {
        return Error(Exception('Record empty after read'));
      }
      return Success(
        MemberInfo.fromJson(
          jsonDecode(utf8.decode(await communityCrypto.decrypt(value)))
              as Map<String, dynamic>,
        ),
      );
    } on Exception catch (e) {
      return Error(e);
    }
  }

  // -> set/update public key
  // -> contains hash of our derived key? save record key, optionally retrieve shared info
  Future<(PublicKey?, RecordKey?)> getMemberSharingPubAndRecordKey(
    RecordKey memberRecord,
    SharedSecret communitySecret,
    SecretKey mySecretKey,
  ) async {
    final memberInfoResult = await getMemberInfo(memberRecord, communitySecret);
    switch (memberInfoResult) {
      case Error():
        // TODO: log memberInfoResult.error
        return (null, null);
      case Success():
        final memberInfo = memberInfoResult.success;

        final memberSecretHash = await generateMemberSecretHash(
          memberInfo.publicKey,
          mySecretKey,
        );

        final memberSharingRecord = memberInfo.sharingOffers
            .firstWhereOrNull((o) => o.$1 == memberSecretHash)
            ?.$2;

        return (memberInfo.publicKey, memberSharingRecord);
    }
  }

  Future<Member> getMember(
    Community community,
    OrganizerProvidedMemberInfo memberInfo,
  ) async {
    // Find existing member instance or initialize a new one
    var member = community.members.firstWhereOrNull(
      // TODO: Do we need a UUID or is matching based on record keys fine?
      (member) => member.infoRecordKey == memberInfo.recordKey,
    );
    member ??= Member(
      communityRecordKey: community.recordKey,
      infoRecordKey: memberInfo.recordKey,
      name: memberInfo.name,
    );

    // Update member with organizer provided comment
    member = updateMemberComment(member, memberInfo.comment);

    if (community.info == null) {
      return member;
    }

    // Update member public key and sharing record key if available
    final (
      memberPublicKey,
      memberSharingRecordKey,
    ) = await getMemberSharingPubAndRecordKey(
      member.infoRecordKey,
      community.info!.secret,
      community.recordWriter.secret,
    );
    return member.copyWith(
      theirPublicKey: memberPublicKey,
      recordKeyThemSharing: memberSharingRecordKey,
    );
  }

  Future<List<Member>> getMembers(Community community) => Future.wait(
    (community.info?.membersInfo ?? []).map(
      (memberInfo) => getMember(community, memberInfo),
    ),
  );

  //// COMMUNITY MANAGEMENT FEATURES ////
  // TODO(LGro): Do we separate them out from the regular member user facing?

  Future<bool> updateManagedCommunityToDht(ManagedCommunity community) async {
    final membersInfo = community.membersWithWriters.map(
      (m) => OrganizerProvidedMemberInfo(
        recordKey: m.$1.recordKey,
        name: m.$1.name,
        comment: m.$1.comment,
      ),
    );
    final communityInfo = CommunityInfo(
      name: community.name,
      secret: community.communitySecret,
      expiresAt: community.expiresAt,
      // Filter out member this belongs to or keep to enable comparison of
      // members info hash to e.g. detect tampering?
      membersInfo: membersInfo.toList(),
    );
    final statuses = await Future.wait<bool>(
      community.membersWithWriters.map((m) async {
        try {
          final memberCrypto = await VeilidCryptoPrivate.fromKeyPair(
            m.$2,
            'community-info',
          );
          final value = await memberCrypto.encrypt(
            utf8.encode(jsonEncode(communityInfo.toJson())),
          );
          await _dhtStorage.write(
            m.$1.recordKey,
            m.$2,
            value,
            numChunks: memberInfoSubkeys,
            chunkOffset: 0,
          );
          return true;
        } catch (e) {
          return false;
        }
      }),
    );
    return !statuses.anyIs(false);
  }

  Future<(RecordKey, KeyPair)> createMemberRecord() async =>
      _dhtStorage.create();
}
