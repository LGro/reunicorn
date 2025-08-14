// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cubit.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

IntroductionsState _$IntroductionsStateFromJson(Map<String, dynamic> json) =>
    IntroductionsState(
      $enumDecode(_$IntroductionsStatusEnumMap, json['status']),
      contacts: (json['contacts'] as List<dynamic>?)
              ?.map((e) => CoagContact.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$IntroductionsStateToJson(IntroductionsState instance) =>
    <String, dynamic>{
      'status': _$IntroductionsStatusEnumMap[instance.status]!,
      'contacts': instance.contacts.map((e) => e.toJson()).toList(),
    };

const _$IntroductionsStatusEnumMap = {
  IntroductionsStatus.initial: 'initial',
  IntroductionsStatus.success: 'success',
  IntroductionsStatus.denied: 'denied',
};
