// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cubit.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProfileState _$ProfileStateFromJson(Map<String, dynamic> json) => ProfileState(
  profileInfo: json['profile_info'] == null
      ? null
      : ProfileInfo.fromJson(json['profile_info'] as Map<String, dynamic>),
  status:
      $enumDecodeNullable(_$ProfileStatusEnumMap, json['status']) ??
      ProfileStatus.initial,
  circles:
      (json['circles'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, e as String),
      ) ??
      const {},
  circleMemberships:
      (json['circle_memberships'] as Map<String, dynamic>?)?.map(
        (k, e) =>
            MapEntry(k, (e as List<dynamic>).map((e) => e as String).toList()),
      ) ??
      const {},
);

Map<String, dynamic> _$ProfileStateToJson(ProfileState instance) =>
    <String, dynamic>{
      'status': _$ProfileStatusEnumMap[instance.status]!,
      'profile_info': instance.profileInfo?.toJson(),
      'circles': instance.circles,
      'circle_memberships': instance.circleMemberships,
    };

const _$ProfileStatusEnumMap = {
  ProfileStatus.initial: 'initial',
  ProfileStatus.success: 'success',
};
