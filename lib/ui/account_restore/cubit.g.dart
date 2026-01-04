// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cubit.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_RestoreState _$RestoreStateFromJson(Map<String, dynamic> json) =>
    _RestoreState(status: $enumDecode(_$RestoreStatusEnumMap, json['status']));

Map<String, dynamic> _$RestoreStateToJson(_RestoreState instance) =>
    <String, dynamic>{'status': _$RestoreStatusEnumMap[instance.status]!};

const _$RestoreStatusEnumMap = {
  RestoreStatus.ready: 'ready',
  RestoreStatus.attaching: 'attaching',
  RestoreStatus.success: 'success',
  RestoreStatus.restoring: 'restoring',
  RestoreStatus.failure: 'failure',
};
