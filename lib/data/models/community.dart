// Copyright 2025 - 2026 The Reunicorn Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

import 'dart:convert';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:veilid_support/veilid_support.dart';

import 'coag_contact.dart';
import 'contact_location.dart';
import 'utils.dart';

part 'community.freezed.dart';
part 'community.g.dart';

/// Maximum amount of members per community
const communityMaxMembers = 2500;

/// Number of subkeys for the first part of the community member DHT record
const communityInfoSubkeys = 21;

/// Number of subkeys for the second part of the community member DHT record
const memberInfoSubkeys = 32 - communityInfoSubkeys;

/// Maximum length of organizer comments in member info
const organizerCommentMaxLength = 100;

// Maximum length for member names
const memberNameMaxLength = 50;

// Maximum length for community names
const communityNameMaxLength = 50;

@freezed
sealed class OrganizerProvidedMemberInfo with _$OrganizerProvidedMemberInfo {
  const factory OrganizerProvidedMemberInfo({
    /// The DHT record where others can find connection and sharing info
    required RecordKey recordKey,

    /// Label or name for the member, could be email/name/nick, max length 50
    required String name,

    /// Comment by the organizer, e.g. to explain reason for expelling member
    /// max length 100
    String? comment,
  }) = _OrganizerProvidedMemberInfo;

  factory OrganizerProvidedMemberInfo.fromJson(Map<String, dynamic> json) =>
      _$OrganizerProvidedMemberInfoFromJson(json);
}

@freezed
sealed class CommunityInfo with _$CommunityInfo {
  const factory CommunityInfo({
    /// Name of the community
    required String name,

    /// Community shared secret
    required SharedSecret secret,

    /// Organizer provided information about other community members
    required List<OrganizerProvidedMemberInfo> membersInfo,

    /// Optional expiration date after which this community is no longer to be
    /// used for connecting members
    DateTime? expiresAt,
  }) = _CommunityInfo;
  factory CommunityInfo.fromJson(Map<String, dynamic> json) =>
      _$CommunityInfoFromJson(json);
}

@freezed
sealed class MemberInfo with _$MemberInfo {
  const factory MemberInfo({
    /// The public key other community members are supposed to use for
    /// encrypting the initial data sharing exchange, after which this key is
    /// supposed to be and keep being rotated to a contact specific key.
    required PublicKey publicKey,

    /// For each other community member a hash of the shared secret derived from
    /// the public key's corresponding private key and their public key, along
    /// with a DHT record key where the matching member can find information
    /// that is shared with them.
    ///
    /// Using the hash here instead of e.g. the other member's member record key
    /// prevents community members or organizers from discovering who is
    /// offering to connect with whom.
    required List<(HashDigest, RecordKey)> sharingOffers,
  }) = _MemberInfo;
  factory MemberInfo.fromJson(Map<String, dynamic> json) =>
      _$MemberInfoFromJson(json);
}

@freezed
sealed class ManagedCommunity with _$ManagedCommunity {
  const factory ManagedCommunity({
    /// Name of the community
    required String name,

    /// Unique ID of the community, usually UUID4 type
    required String communityUuid,

    /// Community shared secrets
    required SharedSecret communitySecret,

    /// Optional expiration date after which this community is no longer to be
    /// used for connecting members
    DateTime? expiresAt,

    /// List of all community members
    @Default([])
    List<(OrganizerProvidedMemberInfo, KeyPair)> membersWithWriters,
  }) = _ManagedCommunity;

  factory ManagedCommunity.fromJson(Map<String, dynamic> json) =>
      _$ManagedCommunityFromJson(json);
}

/// REPO LAYER

// The member itself does not contain my sharing record and writer info,
// because as soon as that happens, a contact exists which has this member as
// origin an all relevant info. So just including the sharing record is enough.
@freezed
sealed class Member with _$Member {
  const factory Member({
    required RecordKey communityRecordKey,
    required RecordKey infoRecordKey,

    /// Label or name for the member, could be email/name/nick
    required String name,

    /// Comment by the organizer, e.g. to explain reason for expelling member
    String? comment,

    /// Timestamp of the most recent comment change
    DateTime? mostRecentCommentUpdate,

    /// Their public key for initial sharing encryption
    PublicKey? publicKey,

    /// The record key where they share information with me
    RecordKey? sharingRecordKey,

    /// After a community member was added as a contact, my sharing record key
    /// is stored here as well to allow construction of my `MemberInfo`
    RecordKey? mySharingRecordKey,
  }) = _Member;

  factory Member.fromJson(Map<String, dynamic> json) => _$MemberFromJson(json);
}

@freezed
sealed class Community with _$Community implements JsonEncodable {
  const factory Community({
    /// Key of my community member DHT record
    required RecordKey recordKey,

    /// Writer of my community member DHT record
    required KeyPair recordWriter,

    /// Community members
    required List<Member> members,

    /// Timestamp of most recent update
    required DateTime mostRecentUpdate,

    /// Community information, might not directly be available at invite time
    CommunityInfo? info,
  }) = _Community;

  factory Community.fromJson(Map<String, dynamic> json) =>
      _$CommunityFromJson(json);
}

Future<Community> communityMigrateFromJson(String json) async =>
    Community.fromJson(jsonDecode(json) as Map<String, dynamic>);

// }
// Update community info

/*
    initially and recurring: get community info to update or add if first run, get other members' info
    if already created contact but missing receiving info but sharing dht record present in their member record, add
    */

// Update members:
//  - mark existing invites/contacts according to status + add comment
//  - check other member records for pub key
//  - add sharing info
//  - check other member records for receiving info

/*
- Read community DHT record
- If expiration date reached, stop
- For each deactivated member DHT record key
	- If already handled previously, skip
	- If new and corresponding contact exists, mark stop sharing until user has made a choice
- For each member DHT record key
	- If corresponding contact exists, skip
	- If no entry in own member DHT record
		- Initialize sharing setup based on known pubkey crypto incl. DHT record for direct sharing
		- Add contact proposal for user to accept / deny (differentiate between who is already sharing, if they are sharing a well, already show some info from them)
	- How to handle declined proposals?

// TODO: Do we start sharing before both have accepted?

// TODO: Is there a use case where member dht record needs to be rotated out? -> do we need a member id?

// TODO: Enforce names unique to help with disambiguating?
*/

/// VIEW MODEL

// communitiesWithPendingOrDeferredIntroductions = Map<communityId,List<CommunityIntroduction>>

@freezed
sealed class CommunityIntroduction with _$CommunityIntroduction {
  factory CommunityIntroduction({
    required String communityName,
    required String theirName,
    required String organizerComment,
    required KeyPair myKeyPair,
    @Default(false) bool deferred,
    DhtSettings? theirSharingSettings,
    ContactDetails? theirDetails,
    Map<String, ContactAddressLocation>? addressLocations,
    Map<String, ContactTemporaryLocation>? temporaryLocations,
  }) = _CommunityIntroduction;
}

/*
open introduction
-> there is no contact with matching origin and no record of declining
-> display member name and community name, if set comment, if available summary of num shared details / locations or sneak peek into shared details?
-> on accept, add contact with name and sharing record, write sharing record with hashed derived secret into my member info
  -> create contact, set name, init sharing record, if available set receiving record and details
  -> 
  (required info name and pubkey, which is preset writer pubkey, optionally receiving dht record from their member info)

not right now / declined introduction
-> there is a list somewhere that contains the XXX for the declined ones
-> display at the bottom of the list / greyed out / recoverable

accepted introduction
-> there is a contact with matching origin
-> hide
*/

// display dashboard / contacts / contact details: mark (newly) community commented that haven't been reviewed yet; offer users to stop sharing easily

// TODO: Allow people to indicate they left a community




/*

SqliteStorageService / HiveStorageServices
- delete for key
- upsert for key
- get for key

DhtService
- create record
- write record
- write record range
- read record
- read record range

---

CommunityStorage
- init (load from disk and clean up stragglers)
- community update stream
- member update stream
- set/update community

CommunityDhtSync
- listens to DHT community updates
- listens to storage member updates

CommunityManagement
- listen to storage community updates
- listen to storage member updates
- update member

----

ContactStorage
- init (load from disk and clean up stragglers)
- contact update stream
- set/update/delete contact
- get contact(s)

ContactDhtSync
- listens to DHT contact record updates
- listens to storage contact updates (shared profile is handled on ui side, integrating circles and stuff)

ContactManagement
- listen to storage contact updates
- add contact
- update contact
- delete contact

----

only clean up stragglers if contacts are available at all to avoid cascading error!!!

CircleStorage
- init (load from disk and clean up stragglers)
- circle update stream
- set/update/delete circle
- get circle(s)

CircleManagement
- listen to storage circle updates
- add circle
- update circle
- delete circle

---

ProfileStorage
- init (load from disk and clean up stragglers)
- profile update stream
- get profile
- update profile

ProfileManagement
- listen to storage circle updates
- update profile

---

SettingsStorage
- init (load from disk and clean up stragglers)
- get profile
- update profile

SettingsManagement
- update setting

*/