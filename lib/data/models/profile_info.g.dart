// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile_info.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProfileInfo _$ProfileInfoFromJson(Map<String, dynamic> json) => ProfileInfo(
  json['id'] as String,
  details: json['details'] == null
      ? const ContactDetails()
      : ContactDetails.fromJson(json['details'] as Map<String, dynamic>),
  pictures:
      (json['pictures'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(
          k,
          (e as List<dynamic>).map((e) => (e as num).toInt()).toList(),
        ),
      ) ??
      const {},
  addressLocations:
      (json['address_locations'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(
          k,
          ContactAddressLocation.fromJson(e as Map<String, dynamic>),
        ),
      ) ??
      const {},
  temporaryLocations:
      (json['temporary_locations'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(
          k,
          ContactTemporaryLocation.fromJson(e as Map<String, dynamic>),
        ),
      ) ??
      const {},
  sharingSettings: json['sharing_settings'] == null
      ? ProfileSharingSettings()
      : ProfileSharingSettings.fromJson(
          json['sharing_settings'] as Map<String, dynamic>,
        ),
  mainKeyPair: json['main_key_pair'] == null
      ? null
      : KeyPair.fromJson(json['main_key_pair']),
);

Map<String, dynamic> _$ProfileInfoToJson(ProfileInfo instance) =>
    <String, dynamic>{
      'id': instance.id,
      'details': instance.details.toJson(),
      'pictures': instance.pictures,
      'address_locations': instance.addressLocations.map(
        (k, e) => MapEntry(k, e.toJson()),
      ),
      'temporary_locations': instance.temporaryLocations.map(
        (k, e) => MapEntry(k, e.toJson()),
      ),
      'sharing_settings': instance.sharingSettings.toJson(),
      'main_key_pair': instance.mainKeyPair?.toJson(),
    };
