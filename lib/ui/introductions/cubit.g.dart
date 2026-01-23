// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cubit.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_IntroductionsState _$IntroductionsStateFromJson(Map<String, dynamic> json) =>
    _IntroductionsState(
      contacts:
          (json['contacts'] as Map<String, dynamic>?)?.map(
            (k, e) =>
                MapEntry(k, CoagContact.fromJson(e as Map<String, dynamic>)),
          ) ??
          const {},
      communities:
          (json['communities'] as Map<String, dynamic>?)?.map(
            (k, e) =>
                MapEntry(k, Community.fromJson(e as Map<String, dynamic>)),
          ) ??
          const {},
    );

Map<String, dynamic> _$IntroductionsStateToJson(
  _IntroductionsState instance,
) => <String, dynamic>{
  'contacts': instance.contacts.map((k, e) => MapEntry(k, e.toJson())),
  'communities': instance.communities.map((k, e) => MapEntry(k, e.toJson())),
};
