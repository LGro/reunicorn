// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cubit.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DashboardState _$DashboardStateFromJson(Map<String, dynamic> json) =>
    DashboardState(
      $enumDecode(_$DashboardStatusEnumMap, json['status']),
      contacts: (json['contacts'] as List<dynamic>?)
              ?.map((e) => CoagContact.fromJson(e as Map<String, dynamic>)) ??
          const [],
      updates: (json['updates'] as List<dynamic>?)
              ?.map((e) => ContactUpdate.fromJson(e as Map<String, dynamic>)) ??
          const [],
      circleMemberships:
          (json['circle_memberships'] as Map<String, dynamic>?)?.map(
                (k, e) => MapEntry(
                    k, (e as List<dynamic>).map((e) => e as String).toList()),
              ) ??
              const {},
      circles: (json['circles'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, e as String),
          ) ??
          const {},
    );

Map<String, dynamic> _$DashboardStateToJson(DashboardState instance) =>
    <String, dynamic>{
      'circle_memberships': instance.circleMemberships,
      'contacts': instance.contacts.map((e) => e.toJson()).toList(),
      'updates': instance.updates.map((e) => e.toJson()).toList(),
      'circles': instance.circles,
      'status': _$DashboardStatusEnumMap[instance.status]!,
    };

const _$DashboardStatusEnumMap = {
  DashboardStatus.initial: 'initial',
  DashboardStatus.success: 'success',
  DashboardStatus.denied: 'denied',
};
