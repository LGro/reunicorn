// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cubit.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SkelState _$SkelStateFromJson(Map<String, dynamic> json) => SkelState(
  $enumDecode(_$SkelStatusEnumMap, json['status']),
  contacts:
      (json['contacts'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, CoagContact.fromJson(e as Map<String, dynamic>)),
      ) ??
      const {},
);

Map<String, dynamic> _$SkelStateToJson(SkelState instance) => <String, dynamic>{
  'status': _$SkelStatusEnumMap[instance.status]!,
  'contacts': instance.contacts.map((k, e) => MapEntry(k, e.toJson())),
};

const _$SkelStatusEnumMap = {
  SkelStatus.initial: 'initial',
  SkelStatus.success: 'success',
  SkelStatus.denied: 'denied',
};
