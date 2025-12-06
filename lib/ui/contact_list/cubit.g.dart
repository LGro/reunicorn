// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cubit.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ContactListState _$ContactListStateFromJson(Map<String, dynamic> json) =>
    ContactListState(
      $enumDecode(_$ContactListStatusEnumMap, json['status']),
      contacts:
          (json['contacts'] as List<dynamic>?)?.map(
            (e) => CoagContact.fromJson(e as Map<String, dynamic>),
          ) ??
          const [],
      circleMemberships:
          (json['circle_memberships'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(
              k,
              (e as List<dynamic>).map((e) => e as String).toList(),
            ),
          ) ??
          const {},
      circles:
          (json['circles'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, Circle.fromJson(e as Map<String, dynamic>)),
          ) ??
          const {},
    );

Map<String, dynamic> _$ContactListStateToJson(ContactListState instance) =>
    <String, dynamic>{
      'circle_memberships': instance.circleMemberships,
      'contacts': instance.contacts.map((e) => e.toJson()).toList(),
      'circles': instance.circles.map((k, e) => MapEntry(k, e.toJson())),
      'status': _$ContactListStatusEnumMap[instance.status]!,
    };

const _$ContactListStatusEnumMap = {
  ContactListStatus.initial: 'initial',
  ContactListStatus.success: 'success',
  ContactListStatus.denied: 'denied',
};
