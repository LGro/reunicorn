// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'contact_details.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ContactDetailsDiff _$ContactDetailsDiffFromJson(Map<String, dynamic> json) =>
    _ContactDetailsDiff(
      picture: $enumDecode(_$DiffStatusEnumMap, json['picture']),
      names: (json['names'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(k, $enumDecode(_$DiffStatusEnumMap, e)),
      ),
      phones: (json['phones'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(k, $enumDecode(_$DiffStatusEnumMap, e)),
      ),
      emails: (json['emails'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(k, $enumDecode(_$DiffStatusEnumMap, e)),
      ),
      websites: (json['websites'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(k, $enumDecode(_$DiffStatusEnumMap, e)),
      ),
      socialMedias: (json['social_medias'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(k, $enumDecode(_$DiffStatusEnumMap, e)),
      ),
      events: (json['events'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(k, $enumDecode(_$DiffStatusEnumMap, e)),
      ),
      organizations: (json['organizations'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(k, $enumDecode(_$DiffStatusEnumMap, e)),
      ),
      misc: (json['misc'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(k, $enumDecode(_$DiffStatusEnumMap, e)),
      ),
      tags: (json['tags'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(k, $enumDecode(_$DiffStatusEnumMap, e)),
      ),
    );

Map<String, dynamic> _$ContactDetailsDiffToJson(
  _ContactDetailsDiff instance,
) => <String, dynamic>{
  'picture': _$DiffStatusEnumMap[instance.picture]!,
  'names': instance.names.map((k, e) => MapEntry(k, _$DiffStatusEnumMap[e]!)),
  'phones': instance.phones.map((k, e) => MapEntry(k, _$DiffStatusEnumMap[e]!)),
  'emails': instance.emails.map((k, e) => MapEntry(k, _$DiffStatusEnumMap[e]!)),
  'websites': instance.websites.map(
    (k, e) => MapEntry(k, _$DiffStatusEnumMap[e]!),
  ),
  'social_medias': instance.socialMedias.map(
    (k, e) => MapEntry(k, _$DiffStatusEnumMap[e]!),
  ),
  'events': instance.events.map((k, e) => MapEntry(k, _$DiffStatusEnumMap[e]!)),
  'organizations': instance.organizations.map(
    (k, e) => MapEntry(k, _$DiffStatusEnumMap[e]!),
  ),
  'misc': instance.misc.map((k, e) => MapEntry(k, _$DiffStatusEnumMap[e]!)),
  'tags': instance.tags.map((k, e) => MapEntry(k, _$DiffStatusEnumMap[e]!)),
};

const _$DiffStatusEnumMap = {
  DiffStatus.add: 'add',
  DiffStatus.change: 'change',
  DiffStatus.remove: 'remove',
  DiffStatus.keep: 'keep',
};
