// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cubit.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DashboardState _$DashboardStateFromJson(Map<String, dynamic> json) =>
    DashboardState(
      $enumDecode(_$DashboardStatusEnumMap, json['status']),
      contacts:
          (json['contacts'] as List<dynamic>?)?.map(
            (e) => CoagContact.fromJson(e as Map<String, dynamic>),
          ) ??
          const [],
      updates:
          (json['updates'] as List<dynamic>?)?.map(
            (e) => ContactUpdate.fromJson(e as Map<String, dynamic>),
          ) ??
          const [],
      closeByMatches:
          (json['close_by_matches'] as List<dynamic>?)
              ?.map((e) => CloseByMatch.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      circles:
          (json['circles'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, e as String),
          ) ??
          const {},
    );

Map<String, dynamic> _$DashboardStateToJson(
  DashboardState instance,
) => <String, dynamic>{
  'contacts': instance.contacts.map((e) => e.toJson()).toList(),
  'updates': instance.updates.map((e) => e.toJson()).toList(),
  'circles': instance.circles,
  'close_by_matches': instance.closeByMatches.map((e) => e.toJson()).toList(),
  'status': _$DashboardStatusEnumMap[instance.status]!,
};

const _$DashboardStatusEnumMap = {
  DashboardStatus.initial: 'initial',
  DashboardStatus.success: 'success',
  DashboardStatus.denied: 'denied',
};
