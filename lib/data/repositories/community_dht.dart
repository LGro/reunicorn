// Copyright 2025 - 2026 The Reunicorn Authors. All rights reserved.
// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:async';
import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter/foundation.dart';
import 'package:multiple_result/multiple_result.dart';
import 'package:reunicorn/data/utils.dart';
import 'package:uuid/uuid.dart';
import 'package:veilid_support/veilid_support.dart';
import 'package:vodozemac/vodozemac.dart' as vod;

import '../models/community.dart';
import '../models/models.dart';
import '../services/dht/encrypted_communication.dart';
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

Future<(HashDigest, VeilidCryptoPrivate)> generateMemberHashAndCrypto(
  PublicKey theirPublicKey,
  SecretKey mySecretKey,
) async {
  final cryptoSystem = await Veilid.instance.getCryptoSystem(cryptoKindVLD0);
  final sharedSecret = await cryptoSystem.generateSharedSecret(
    theirPublicKey,
    mySecretKey,
    utf8.encode('community-member-sharing-offer-matching'),
  );
  final hashedSecret = await cryptoSystem.generateHash(sharedSecret.toBytes());
  final crypto = await VeilidCryptoPrivate.fromSharedSecret(
    sharedSecret.kind,
    sharedSecret,
  );
  return (hashedSecret, crypto);
}

Future<String> generateMemberEncryptedSecretHashB64(
  PublicKey theirPublicKey,
  SecretKey mySecretKey,
) async {
  final (hashedSecret, crypto) = await generateMemberHashAndCrypto(
    theirPublicKey,
    mySecretKey,
  );
  return base64Encode(await crypto.encrypt(hashedSecret.toBytes()));
}

Future<MemberSharingOffer?> getMemberSharingOffer(
  MemberInfo memberInfo,
  SecretKey mySecretKey,
) async {
  final (memberHash, crypto) = await generateMemberHashAndCrypto(
    memberInfo.publicKey,
    mySecretKey,
  );

  final sharingOffersWithDecryptedKeys = Map.fromEntries(
    await Future.wait(
      memberInfo.sharingOffers.entries.map(
        (e) async => MapEntry(
          base64Encode(await crypto.decrypt(base64Decode(e.key))),
          e.value,
        ),
      ),
    ),
  );

  return sharingOffersWithDecryptedKeys[base64Encode(memberHash.toBytes())];
}

// update member from my member record community info part
// -> check comment changed, update last comment changed timestamp
// update member from their member record
// TODO: Should this be part of Member.copyWith()?
Member updateMemberComment(Member member, String? comment) => member.copyWith(
  comment: (comment == null)
      ? null
      : MemberComment(
          comment: comment,
          mostRecentUpdate: (member.comment?.comment != comment)
              ? DateTime.now()
              : member.comment!.mostRecentUpdate,
        ),
);

/// Generate sharing offers for my member info based for all community members
Future<Map<String, MemberSharingOffer>> generateSharingOffers(
  List<Member> members,
  SecretKey mySecretKey,
) async => Map.fromEntries(
  await Future.wait(
    members.where((m) => m.theirPublicKey != null).map((m) async {
      final offerId = await generateMemberEncryptedSecretHashB64(
        m.theirPublicKey!,
        mySecretKey,
      );
      final account = vod.Account.fromPickleEncrypted(
        pickle: m.myVodozemacAccount,
        pickleKey: Uint8List(32),
      );
      return MapEntry(
        offerId,
        MemberSharingOffer(
          recordKey: m.recordKeyMeSharing,
          oneTimeKey: account.oneTimeKeys.values.first.toBase64(),
          identityKey: account.identityKeys.curve25519.toBase64(),
        ),
      );
    }),
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
        set: (oldCommunity, newCommunity) => (oldCommunity != newCommunity)
            ? updateCommunityFromDht(newCommunity.recordKey)
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
    () => updateCommunityFromDht(recordKey, useLocalCache: true),
  );

  Future<void> updateCommunityFromDht(
    RecordKey recordKey, {
    bool useLocalCache = false,
  }) async {
    await _communityStorage.lock.synchronized(recordKey.toString(), () async {
      final community = await _communityStorage.get(recordKey.toString());
      if (community == null) {
        return;
      }

      // TODO(LGro): pass on useLocalCache
      final updatedCommunity = await updateCommunity(community);

      if (community != updatedCommunity) {
        await _communityStorage.set(
          community.recordKey.toString(),
          updatedCommunity,
        );
      }
    });
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
    if (contact.dhtConnection?.recordKeyMeSharingOrNull == null) {
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
      recordKeyMeSharing:
          contact.dhtConnection?.recordKeyMeSharingOrNull ??
          member.recordKeyMeSharing,
    );
    if (member == updatedMember) {
      return;
    }

    // Add sharing settings to member and update community
    await _communityStorage.set(
      community.recordKey.toString(),
      community.copyWith(
        members: [...community.members]
          ..remove(member)
          ..add(updatedMember),
      ),
    );
  }

  @override
  Future<void> dhtBecameAvailableCallback() => _communityStorage.getAll().then(
    (communities) => communities.values.map(
      (community) => updateCommunityFromDht(community.recordKey),
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
      debugPrint(
        'set member info succeeded for ${recordKey.toString().substring(0, 12)}',
      );

      return Success(info);
    } on Exception catch (e) {
      debugPrint(
        'set member info failed for ${recordKey.toString().substring(0, 12)} with $e',
      );
      return Error(e);
    }
  }

  Future<Community> updateCommunity(Community community) async {
    if (community.isExpired()) {
      return community;
    }

    // Update community info if available, otherwise keep previous info
    community = community.copyWith(
      info:
          (await getCommunityInfo(
            community.recordKey,
            community.recordWriter,
          )) ??
          community.info,
    );

    // Update community members
    // TODO(LGro): Should we in case of partial success only override members
    // instead of all, causing temporarily missing members? Would require
    // deactivating rather than deleting members.
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
      final sharingOffers = await generateSharingOffers(
        community.members,
        community.recordWriter.secret,
      );
      debugPrint('Generated ${sharingOffers.length} sharing offers');
      await setMemberInfo(
        MemberInfo(
          publicKey: community.recordWriter.key,
          sharingOffers: sharingOffers,
        ),
        community.recordKey,
        community.recordWriter,
        community.info!.secret,
      );
    }

    return community.copyWith(mostRecentUpdate: DateTime.now());
  }

  // Light weight adding of a new community, might only be fully populated later
  Future<Community> acceptCommunityFromInvite(
    RecordKey recordKey,
    KeyPair recordWriter,
  ) async {
    final communityInfo = await getCommunityInfo(recordKey, recordWriter);

    final community = Community(
      recordKey: recordKey,
      recordWriter: recordWriter,
      info: communityInfo,
      members: [],
      mostRecentUpdate: DateTime.now(),
    );

    await _communityStorage.set(community.recordKey.toString(), community);

    await _watchCommunity(community.recordKey);

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
      debugPrint('get community info failed with $e for $recordKey');
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
  Future<(PublicKey?, MemberSharingOffer?)> getMemberSharingPubAndOffer(
    RecordKey memberRecord,
    SharedSecret communitySecret,
    SecretKey mySecretKey,
  ) async {
    final memberInfoResult = await getMemberInfo(memberRecord, communitySecret);
    switch (memberInfoResult) {
      case Error():
        // TODO: log memberInfoResult.error
        debugPrint(
          'failed to get member info result: ${memberInfoResult.error}',
        );
        return (null, null);
      case Success():
        final memberInfo = memberInfoResult.success;

        final memberSharingOffer = await getMemberSharingOffer(
          memberInfo,
          mySecretKey,
        );

        debugPrint(
          'member sharing record identity key '
          '${memberSharingOffer?.identityKey.toString().substring(0, 12)} for '
          '${memberRecord.toString().substring(0, 12)}',
        );

        return (memberInfo.publicKey, memberSharingOffer);
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
      myVodozemacAccount: (vod.Account()..generateOneTimeKeys(1))
          .toPickleEncrypted(Uint8List(32)),
    );

    // Update member with organizer provided comment
    member = updateMemberComment(member, memberInfo.comment);

    if (community.info == null) {
      return member;
    }

    // Update member public key and sharing record key if available
    final (
      memberPublicKey,
      memberSharingOffer,
    ) = await getMemberSharingPubAndOffer(
      member.infoRecordKey,
      community.info!.secret,
      community.recordWriter.secret,
    );
    return member.copyWith(
      theirPublicKey: memberPublicKey ?? member.theirPublicKey,
      recordKeyThemSharing:
          memberSharingOffer?.recordKey ?? member.recordKeyThemSharing,
      theirIdentityKey:
          memberSharingOffer?.identityKey ?? member.theirIdentityKey,
      theirOneTimeKey: memberSharingOffer?.oneTimeKey ?? member.theirOneTimeKey,
    );
  }

  Future<List<Member>> getMembers(Community community) => Future.wait(
    (community.info?.membersInfo ?? []).map(
      (memberInfo) => getMember(community, memberInfo),
    ),
  );

  Future<CoagContact?> addContactForMember(Member member) async {
    final account = vod.Account.fromPickleEncrypted(
      pickle: member.myVodozemacAccount,
      pickleKey: Uint8List(32),
    );
    final origin = CommunityOrigin(
      communityRecordKey: member.communityRecordKey,
      memberInfoRecordKey: member.infoRecordKey,
    );

    // Check if they have already started sharing with us
    if (member.recordKeyThemSharing != null) {
      debugPrint(
        'Attempting to read (inbound session) for community member '
        '${member.infoRecordKey.toString().substring(0, 12)}',
      );
      // TODO: Could we also just use any share back dht record they sent us?
      var dhtConnection = DhtConnectionState.invited(
        recordKeyThemSharing: member.recordKeyThemSharing!,
      );
      var connectionCrypto = CryptoState.symmetric(
        accountVod: member.myVodozemacAccount,
        // This is just a placeholder, since we expect readEncrypted to
        // initialize an inbound session straight away
        sharedSecret: await generateRandomSharedSecretBest(),
      );
      final ContactSharingSchema? dhtContact;
      (dhtContact, dhtConnection, connectionCrypto) = await readEncrypted(
        _dhtStorage,
        dhtConnection,
        connectionCrypto,
        ContactSharingSchema.fromJson,
      );
      if (dhtContact != null) {
        final contact = CoagContact(
          coagContactId: Uuid().v4(),
          myIdentity: await generateKeyPairBest(),
          origin: origin.toString(),
          name: dhtContact.details.names.values.firstOrNull ?? '???',
          theirIdentity: dhtContact.identityKey,
          connectionAttestations: dhtContact.connectionAttestations,
          details: dhtContact.details,
          addressLocations: dhtContact.addressLocations,
          temporaryLocations: dhtContact.temporaryLocations,
          introductionsByThem: dhtContact.introductions,
          dhtConnection: dhtConnection,
          connectionCrypto: connectionCrypto,
        );
        await _contactStorage.set(contact.coagContactId, contact);
        return contact;
      }
    }

    if (member.theirIdentityKey == null) {
      debugPrint('${member.name} is missing vod identity key');
      return null;
    }
    debugPrint(
      'Adding contact with outbound session for community member '
      '${member.infoRecordKey.toString().substring(0, 12)}',
    );
    final session = account.createOutboundSession(
      identityKey: account.identityKeys.curve25519,
      oneTimeKey: account.oneTimeKeys.values.first,
    );
    try {
      final (recordKeyMeSharing, writerMeSharing) = await _dhtStorage.create();
      final (recordKeyThemSharing, writerThemSharing) = await _dhtStorage
          .create();
      final dhtConnection = DhtConnectionState.initialized(
        recordKeyMeSharing: recordKeyMeSharing,
        writerMeSharing: writerMeSharing,
        recordKeyThemSharing: recordKeyThemSharing,
        writerThemSharing: writerThemSharing,
      );
      final connectionCrypto = CryptoState.vodozemacInitial(
        theirIdentityKey: member.theirIdentityKey!,
        myIdentityKey: account.identityKeys.curve25519.toBase64(),
        accountVod: member.myVodozemacAccount,
        sessionVod: session.toPickleEncrypted(Uint8List(32)),
      );
      final contact = CoagContact(
        coagContactId: Uuid().v4(),
        name: member.name,
        origin: origin.toString(),
        dhtConnection: dhtConnection,
        connectionCrypto: connectionCrypto,
        myIdentity: await generateKeyPairBest(),
      );
      await _contactStorage.set(contact.coagContactId, contact);
      return contact;
    } catch (e) {
      debugPrint('${member.name} failed with $e');
      return null;
    }
  }

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
