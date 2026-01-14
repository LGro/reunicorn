// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'contact_sharing_schema.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ContactSharingSchemaDiff _$ContactSharingSchemaDiffFromJson(
  Map<String, dynamic> json,
) => _ContactSharingSchemaDiff(
  details: ContactDetailsDiff.fromJson(json['details'] as Map<String, dynamic>),
  addressLocations: (json['address_locations'] as Map<String, dynamic>).map(
    (k, e) => MapEntry(k, $enumDecode(_$DiffStatusEnumMap, e)),
  ),
  temporaryLocations: (json['temporary_locations'] as Map<String, dynamic>).map(
    (k, e) => MapEntry(k, $enumDecode(_$DiffStatusEnumMap, e)),
  ),
  introductions: $enumDecode(_$DiffStatusEnumMap, json['introductions']),
);

Map<String, dynamic> _$ContactSharingSchemaDiffToJson(
  _ContactSharingSchemaDiff instance,
) => <String, dynamic>{
  'details': instance.details.toJson(),
  'address_locations': instance.addressLocations.map(
    (k, e) => MapEntry(k, _$DiffStatusEnumMap[e]!),
  ),
  'temporary_locations': instance.temporaryLocations.map(
    (k, e) => MapEntry(k, _$DiffStatusEnumMap[e]!),
  ),
  'introductions': _$DiffStatusEnumMap[instance.introductions]!,
};

const _$DiffStatusEnumMap = {
  DiffStatus.add: 'add',
  DiffStatus.change: 'change',
  DiffStatus.remove: 'remove',
  DiffStatus.keep: 'keep',
};
