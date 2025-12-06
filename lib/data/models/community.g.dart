// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'community.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_OrganizerProvidedMemberInfo _$OrganizerProvidedMemberInfoFromJson(
  Map<String, dynamic> json,
) => _OrganizerProvidedMemberInfo(
  recordKey: RecordKey.fromJson(json['record_key']),
  name: json['name'] as String,
  comment: json['comment'] as String?,
);

Map<String, dynamic> _$OrganizerProvidedMemberInfoToJson(
  _OrganizerProvidedMemberInfo instance,
) => <String, dynamic>{
  'record_key': instance.recordKey.toJson(),
  'name': instance.name,
  'comment': instance.comment,
};

_CommunityInfo _$CommunityInfoFromJson(Map<String, dynamic> json) =>
    _CommunityInfo(
      name: json['name'] as String,
      secret: Typed<BareSharedSecret>.fromJson(json['secret']),
      membersInfo: (json['members_info'] as List<dynamic>)
          .map(
            (e) =>
                OrganizerProvidedMemberInfo.fromJson(e as Map<String, dynamic>),
          )
          .toList(),
      expiresAt: json['expires_at'] == null
          ? null
          : DateTime.parse(json['expires_at'] as String),
    );

Map<String, dynamic> _$CommunityInfoToJson(_CommunityInfo instance) =>
    <String, dynamic>{
      'name': instance.name,
      'secret': instance.secret.toJson(),
      'members_info': instance.membersInfo.map((e) => e.toJson()).toList(),
      'expires_at': instance.expiresAt?.toIso8601String(),
    };

_MemberInfo _$MemberInfoFromJson(Map<String, dynamic> json) => _MemberInfo(
  publicKey: Typed<BarePublicKey>.fromJson(json['public_key']),
  sharingOffers: (json['sharing_offers'] as List<dynamic>)
      .map(
        (e) => _$recordConvert(
          e,
          ($jsonValue) => (
            Typed<BareHashDigest>.fromJson($jsonValue[r'$1']),
            RecordKey.fromJson($jsonValue[r'$2']),
          ),
        ),
      )
      .toList(),
);

Map<String, dynamic> _$MemberInfoToJson(
  _MemberInfo instance,
) => <String, dynamic>{
  'public_key': instance.publicKey.toJson(),
  'sharing_offers': instance.sharingOffers
      .map((e) => <String, dynamic>{r'$1': e.$1.toJson(), r'$2': e.$2.toJson()})
      .toList(),
};

$Rec _$recordConvert<$Rec>(Object? value, $Rec Function(Map) convert) =>
    convert(value as Map<String, dynamic>);

_ManagedCommunity _$ManagedCommunityFromJson(Map<String, dynamic> json) =>
    _ManagedCommunity(
      name: json['name'] as String,
      communityUuid: json['community_uuid'] as String,
      communitySecret: Typed<BareSharedSecret>.fromJson(
        json['community_secret'],
      ),
      expiresAt: json['expires_at'] == null
          ? null
          : DateTime.parse(json['expires_at'] as String),
      membersWithWriters:
          (json['members_with_writers'] as List<dynamic>?)
              ?.map(
                (e) => _$recordConvert(
                  e,
                  ($jsonValue) => (
                    OrganizerProvidedMemberInfo.fromJson(
                      $jsonValue[r'$1'] as Map<String, dynamic>,
                    ),
                    KeyPair.fromJson($jsonValue[r'$2']),
                  ),
                ),
              )
              .toList() ??
          const [],
    );

Map<String, dynamic> _$ManagedCommunityToJson(
  _ManagedCommunity instance,
) => <String, dynamic>{
  'name': instance.name,
  'community_uuid': instance.communityUuid,
  'community_secret': instance.communitySecret.toJson(),
  'expires_at': instance.expiresAt?.toIso8601String(),
  'members_with_writers': instance.membersWithWriters
      .map((e) => <String, dynamic>{r'$1': e.$1.toJson(), r'$2': e.$2.toJson()})
      .toList(),
};

_Member _$MemberFromJson(Map<String, dynamic> json) => _Member(
  communityRecordKey: RecordKey.fromJson(json['community_record_key']),
  infoRecordKey: RecordKey.fromJson(json['info_record_key']),
  name: json['name'] as String,
  comment: json['comment'] as String?,
  mostRecentCommentUpdate: json['most_recent_comment_update'] == null
      ? null
      : DateTime.parse(json['most_recent_comment_update'] as String),
  publicKey: json['public_key'] == null
      ? null
      : Typed<BarePublicKey>.fromJson(json['public_key']),
  sharingRecordKey: json['sharing_record_key'] == null
      ? null
      : RecordKey.fromJson(json['sharing_record_key']),
  mySharingRecordKey: json['my_sharing_record_key'] == null
      ? null
      : RecordKey.fromJson(json['my_sharing_record_key']),
);

Map<String, dynamic> _$MemberToJson(_Member instance) => <String, dynamic>{
  'community_record_key': instance.communityRecordKey.toJson(),
  'info_record_key': instance.infoRecordKey.toJson(),
  'name': instance.name,
  'comment': instance.comment,
  'most_recent_comment_update': instance.mostRecentCommentUpdate
      ?.toIso8601String(),
  'public_key': instance.publicKey?.toJson(),
  'sharing_record_key': instance.sharingRecordKey?.toJson(),
  'my_sharing_record_key': instance.mySharingRecordKey?.toJson(),
};

_Community _$CommunityFromJson(Map<String, dynamic> json) => _Community(
  recordKey: RecordKey.fromJson(json['record_key']),
  recordWriter: KeyPair.fromJson(json['record_writer']),
  members: (json['members'] as List<dynamic>)
      .map((e) => Member.fromJson(e as Map<String, dynamic>))
      .toList(),
  mostRecentUpdate: DateTime.parse(json['most_recent_update'] as String),
  info: json['info'] == null
      ? null
      : CommunityInfo.fromJson(json['info'] as Map<String, dynamic>),
);

Map<String, dynamic> _$CommunityToJson(_Community instance) =>
    <String, dynamic>{
      'record_key': instance.recordKey.toJson(),
      'record_writer': instance.recordWriter.toJson(),
      'members': instance.members.map((e) => e.toJson()).toList(),
      'most_recent_update': instance.mostRecentUpdate.toIso8601String(),
      'info': instance.info?.toJson(),
    };
