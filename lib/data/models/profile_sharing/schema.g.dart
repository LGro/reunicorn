// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'schema.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ContactSharingSchemaV3 _$ContactSharingSchemaV3FromJson(
  Map<String, dynamic> json,
) => _ContactSharingSchemaV3(
  details: ContactDetails.fromJson(json['details'] as Map<String, dynamic>),
  addressLocations: (json['address_locations'] as Map<String, dynamic>).map(
    (k, e) =>
        MapEntry(k, ContactAddressLocation.fromJson(e as Map<String, dynamic>)),
  ),
  temporaryLocations: (json['temporary_locations'] as Map<String, dynamic>).map(
    (k, e) => MapEntry(
      k,
      ContactTemporaryLocation.fromJson(e as Map<String, dynamic>),
    ),
  ),
  connectionAttestations: (json['connection_attestations'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  introductions: (json['introductions'] as List<dynamic>)
      .map((e) => ContactIntroduction.fromJson(e as Map<String, dynamic>))
      .toList(),
  identityKey: json['identity_key'] == null
      ? null
      : Typed<BarePublicKey>.fromJson(json['identity_key']),
  introductionKey: json['introduction_key'] == null
      ? null
      : Typed<BarePublicKey>.fromJson(json['introduction_key']),
  pushNotificationTopic: json['push_notification_topic'] as String?,
  schemaVersion: (json['schema_version'] as num?)?.toInt() ?? 3,
);

Map<String, dynamic> _$ContactSharingSchemaV3ToJson(
  _ContactSharingSchemaV3 instance,
) => <String, dynamic>{
  'details': instance.details.toJson(),
  'address_locations': instance.addressLocations.map(
    (k, e) => MapEntry(k, e.toJson()),
  ),
  'temporary_locations': instance.temporaryLocations.map(
    (k, e) => MapEntry(k, e.toJson()),
  ),
  'connection_attestations': instance.connectionAttestations,
  'introductions': instance.introductions.map((e) => e.toJson()).toList(),
  'identity_key': instance.identityKey?.toJson(),
  'introduction_key': instance.introductionKey?.toJson(),
  'push_notification_topic': instance.pushNotificationTopic,
  'schema_version': instance.schemaVersion,
};
