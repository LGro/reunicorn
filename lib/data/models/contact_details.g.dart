// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'contact_details.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ContactDetails _$ContactDetailsFromJson(Map<String, dynamic> json) =>
    _ContactDetails(
      picture: (json['picture'] as List<dynamic>?)
          ?.map((e) => (e as num).toInt())
          .toList(),
      publicKey: json['public_key'] as String?,
      names:
          (json['names'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, e as String),
          ) ??
          const {},
      phones:
          (json['phones'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, e as String),
          ) ??
          const {},
      emails:
          (json['emails'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, e as String),
          ) ??
          const {},
      websites:
          (json['websites'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, e as String),
          ) ??
          const {},
      socialMedias:
          (json['social_medias'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, e as String),
          ) ??
          const {},
      events:
          (json['events'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, DateTime.parse(e as String)),
          ) ??
          const {},
      organizations:
          (json['organizations'] as Map<String, dynamic>?)?.map(
            (k, e) =>
                MapEntry(k, Organization.fromJson(e as Map<String, dynamic>)),
          ) ??
          const {},
      misc:
          (json['misc'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, e as String),
          ) ??
          const {},
      tags:
          (json['tags'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, e as String),
          ) ??
          const {},
    );

Map<String, dynamic> _$ContactDetailsToJson(_ContactDetails instance) =>
    <String, dynamic>{
      'picture': instance.picture,
      'public_key': instance.publicKey,
      'names': instance.names,
      'phones': instance.phones,
      'emails': instance.emails,
      'websites': instance.websites,
      'social_medias': instance.socialMedias,
      'events': instance.events.map((k, e) => MapEntry(k, e.toIso8601String())),
      'organizations': instance.organizations.map(
        (k, e) => MapEntry(k, e.toJson()),
      ),
      'misc': instance.misc,
      'tags': instance.tags,
    };
