// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'circle.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Circle _$CircleFromJson(Map<String, dynamic> json) => _Circle(
  id: json['id'] as String,
  name: json['name'] as String,
  memberIds: (json['member_ids'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
);

Map<String, dynamic> _$CircleToJson(_Circle instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'member_ids': instance.memberIds,
};
