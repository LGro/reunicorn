// Copyright 2025 - 2026 The Reunicorn Authors. All rights reserved.
// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:collection/collection.dart';
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

Future<CommunityInfo?> getCommunityInfo(
  RecordKey recordKey,
  KeyPair memberKeyPair,
) async {
  final memberCrypto = await VeilidCryptoPrivate.fromKeyPair(
    memberKeyPair,
    'community-info',
  );

  try {
    final record = await DHTRecordPool.instance.openRecordRead(
      recordKey,
      debugName: 'rcrn-community-info-read',
    );

    final communityInfo = await getChunkedPayload(
      record,
      DHTRecordRefreshMode.network,
      numChunks: communityInfoSubkeys,
      crypto: memberCrypto,
    );

    return CommunityInfo.fromJson(
      jsonDecode(utf8.decode(communityInfo)) as Map<String, dynamic>,
    );
  } on Exception catch (_) {
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
    final record = await DHTRecordPool.instance.openRecordRead(
      recordKey,
      debugName: 'rcrn-community-member-read',
    );

    final memberInfo = await getChunkedPayload(
      record,
      DHTRecordRefreshMode.network,
      chunkOffset: communityInfoSubkeys,
      numChunks: memberInfoSubkeys,
      crypto: communityCrypto,
    );

    return Success(
      MemberInfo.fromJson(
        jsonDecode(utf8.decode(memberInfo)) as Map<String, dynamic>,
      ),
    );
  } on Exception catch (e) {
    return Error(e);
  }
}

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
    final record = await DHTRecordPool.instance.openRecordWrite(
      recordKey,
      recordWriter,
      debugName: 'rcrn-community-member-write',
    );

    // TODO: Make this transactional so that either all or nothing
    await Future.wait(
      chopPayloadChunks(
        utf8.encode(jsonEncode(info.toJson())),
        numChunks: memberInfoSubkeys,
      ).toList().asMap().entries.map(
        (e) => record.eventualWriteBytes(
          crypto: communityCrypto,
          e.value,
          subkey: communityInfoSubkeys + e.key,
        ),
      ),
    );

    return Success(info);
  } on Exception catch (e) {
    return Error(e);
  }
}

// update member from my member record community info part
// -> check comment changed, update last comment changed timestamp
// update member from their member record
// TODO: Should this be part of Member.copyWith()?
Member updateMemberComment(Member member, String? comment) => member.copyWith(
  comment: comment,
  mostRecentCommentUpdate: (member.comment != comment) ? DateTime.now() : null,
);

Future<HashDigest> generateMemberSecretHash(
  PublicKey memberPublicKey,
  SecretKey mySecretKey,
) async {
  final cryptoSystem = await DHTRecordPool.instance.veilid.getCryptoSystem(
    cryptoKindVLD0,
  );
  return cryptoSystem
      .generateSharedSecret(
        memberPublicKey,
        mySecretKey,
        utf8.encode('community-members-initial-sharing'),
      )
      .then((ourSecret) => cryptoSystem.generateHash(ourSecret.toBytes()));
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

// TODO: figure out redudancy between this and updateCommunity below
Future<Community?> getCommunityFromInvite(
  RecordKey recordKey,
  KeyPair recordWriter,
) async {
  final communityInfo = await getCommunityInfo(recordKey, recordWriter);

  if (communityInfo == null) {
    return null;
  }

  return Community(
    recordKey: recordKey,
    recordWriter: recordWriter,
    info: communityInfo,
    members: [],
    mostRecentUpdate: DateTime.now(),
  );
}

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

Future<Community> updateCommunity(Community community) async {
  if (community.isExpired()) {
    return community;
  }

  // Update community info if available
  community = community.copyWith(
    info: await getCommunityInfo(community.recordKey, community.recordWriter),
  );

  // Update community members
  community = community.copyWith(members: await getMembers(community));

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

class CommunityDhtRepository extends BaseDhtRepository {
  final _watchedRecords = <RecordKey>{};
  final Storage<Community> _communityStorage;
  final Storage<CoagContact> _contactStorage;
  var veilidNetworkAvailable = false;

  // TODO: Add information about which community is currently being synced / was synced last

  CommunityDhtRepository(this._communityStorage, this._contactStorage) {
    _communityStorage.changeEvents.listen((e) async {
      await e.when(
        set: (oldCommunity, newCommunity) =>
            _updateCommunityFromDht(newCommunity.recordKey),
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

  /// Watch for community updates via the DHT
  Future<void> _watchCommunity(RecordKey recordKey) async {
    // TODO: What happens with watch if we're offline? does it watch as soon as we go online or fail?
    // TODO: Do we need to build up a watch queue when offline to then start watch when online?
    _watchedRecords.add(recordKey);

    try {
      final record = await DHTRecordPool.instance.openRecordRead(
        recordKey,
        debugName: 'coag::read-to-watch',
      );

      await record.watch(subkeys: [const ValueSubkeyRange(low: 0, high: 32)]);

      await record.listen(
        // TODO: If we want to make use of data here, we also likely need to pass crypto to decrypt it
        (record, data, subkeys) =>
            _updateCommunityFromDht(record.key, useLocalCache: true),
        localChanges: false,
      );
    } catch (e) {
      _watchedRecords.remove(recordKey);
    }
  }

  Future<void> _updateCommunityFromDht(
    RecordKey recordKey, {
    bool useLocalCache = false,
  }) async {
    final community = await _communityStorage.get(recordKey.toString());
    if (community == null) {
      return;
    }

    final updatedCommunity = await updateCommunity(community);

    await _communityStorage.set(
      community.recordKey.toString(),
      updatedCommunity,
    );
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

    // Add sharing settings to member and update community
    await _communityStorage.set(
      community.recordKey.toString(),
      community.copyWith(
        members: community.members
          ..remove(member)
          ..add(
            member.copyWith(
              recordKeyMeSharing:
                  (contact.dhtConnection as DhtConnectionEstablished)
                      .recordKeyMeSharing,
            ),
          ),
      ),
    );
  }

  @override
  Future<void> dhtBecameAvailableCallback() => _communityStorage.getAll().then(
    (communities) => communities.values.map(
      (community) => _updateCommunityFromDht(community.recordKey),
    ),
  );

  //// COMMUNITY MANAGEMENT FEATURES ////
  // TODO(LGro): Do we separate them out from the regular member user facing?

  Future<bool> updateManagedCommunityToDht(ManagedCommunity community) async {
    return false;
  }

  Future<(RecordKey, KeyPair)> createMemberRecord() async {
    final record = await DHTRecordPool.instance.createRecord(
      debugName: 'rcrn::create-member',
    );
    final opened = await DHTRecordPool.instance.openRecordWrite(
      record.key,
      record.writer!,
      debugName: 'rcrn::open-write-member',
    );
    // TODO(LGro): do we need to write it once to be available on the network?
    await opened.eventualWriteBytes(Uint8List(0));
    // TODO(LGro): when don't we ge a writer?
    return (record.key, record.writer!);
  }
}
