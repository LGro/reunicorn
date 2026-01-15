// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cubit.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CreateNewContactState _$CreateNewContactStateFromJson(
  Map<String, dynamic> json,
) => _CreateNewContactState(
  contact: json['contact'] == null
      ? null
      : CoagContact.fromJson(json['contact'] as Map<String, dynamic>),
);

Map<String, dynamic> _$CreateNewContactStateToJson(
  _CreateNewContactState instance,
) => <String, dynamic>{'contact': instance.contact?.toJson()};
