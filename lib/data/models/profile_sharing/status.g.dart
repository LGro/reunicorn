// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'status.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ProfileSharingStatus _$ProfileSharingStatusFromJson(
  Map<String, dynamic> json,
) => _ProfileSharingStatus(
  mostRecentSuccess: json['most_recent_success'] == null
      ? null
      : DateTime.parse(json['most_recent_success'] as String),
  mostRecentAttempt: json['most_recent_attempt'] == null
      ? null
      : DateTime.parse(json['most_recent_attempt'] as String),
  sharedProfile: json['shared_profile'] == null
      ? null
      : ContactSharingSchemaV3.fromJson(
          json['shared_profile'] as Map<String, dynamic>,
        ),
);

Map<String, dynamic> _$ProfileSharingStatusToJson(
  _ProfileSharingStatus instance,
) => <String, dynamic>{
  'most_recent_success': instance.mostRecentSuccess?.toIso8601String(),
  'most_recent_attempt': instance.mostRecentAttempt?.toIso8601String(),
  'shared_profile': instance.sharedProfile?.toJson(),
};
