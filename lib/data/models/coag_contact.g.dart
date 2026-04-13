// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'coag_contact.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CoagContact _$CoagContactFromJson(Map<String, dynamic> json) => CoagContact(
  coagContactId: json['coag_contact_id'] as String,
  name: json['name'] as String,
  connectionCrypto: CryptoState.fromJson(
    json['connection_crypto'] as Map<String, dynamic>,
  ),
  myIdentity: KeyPair.fromJson(json['my_identity']),
  details: json['details'] == null
      ? null
      : ContactDetails.fromJson(json['details'] as Map<String, dynamic>),
  dhtConnection: json['dht_connection'] == null
      ? null
      : DhtConnectionState.fromJson(
          json['dht_connection'] as Map<String, dynamic>,
        ),
  theirIdentity: json['their_identity'] == null
      ? null
      : Typed<BarePublicKey>.fromJson(json['their_identity']),
  connectionAttestations:
      (json['connection_attestations'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  systemContactId: json['system_contact_id'] as String?,
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
  comment: json['comment'] as String? ?? '',
  profileSharingStatus: json['profile_sharing_status'] == null
      ? const ProfileSharingStatus()
      : ProfileSharingStatus.fromJson(
          json['profile_sharing_status'] as Map<String, dynamic>,
        ),
  introductionsForThem:
      (json['introductions_for_them'] as List<dynamic>?)
          ?.map((e) => ContactIntroduction.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  introductionsByThem:
      (json['introductions_by_them'] as List<dynamic>?)
          ?.map((e) => ContactIntroduction.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  myLinkedAppConnections:
      (json['my_linked_app_connections'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(
          k,
          _$recordConvert(
            e,
            ($jsonValue) => (
              RecordKey.fromJson($jsonValue[r'$1']),
              KeyPair.fromJson($jsonValue[r'$2']),
            ),
          ),
        ),
      ) ??
      const {},
  theirLinkedAppConnections:
      (json['their_linked_app_connections'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, RecordKey.fromJson(e)),
      ) ??
      const {},
  origin: json['origin'] as String?,
  verified: json['verified'] as bool? ?? false,
);

Map<String, dynamic> _$CoagContactToJson(CoagContact instance) =>
    <String, dynamic>{
      'coag_contact_id': instance.coagContactId,
      'their_identity': instance.theirIdentity?.toJson(),
      'my_identity': instance.myIdentity.toJson(),
      'connection_attestations': instance.connectionAttestations,
      'name': instance.name,
      'system_contact_id': instance.systemContactId,
      'details': instance.details?.toJson(),
      'comment': instance.comment,
      'address_locations': instance.addressLocations.map(
        (k, e) => MapEntry(k, e.toJson()),
      ),
      'temporary_locations': instance.temporaryLocations.map(
        (k, e) => MapEntry(k, e.toJson()),
      ),
      'dht_connection': instance.dhtConnection?.toJson(),
      'my_linked_app_connections': instance.myLinkedAppConnections.map(
        (k, e) => MapEntry(k, <String, dynamic>{
          r'$1': e.$1.toJson(),
          r'$2': e.$2.toJson(),
        }),
      ),
      'their_linked_app_connections': instance.theirLinkedAppConnections.map(
        (k, e) => MapEntry(k, e.toJson()),
      ),
      'connection_crypto': instance.connectionCrypto.toJson(),
      'profile_sharing_status': instance.profileSharingStatus.toJson(),
      'introductions_for_them': instance.introductionsForThem
          .map((e) => e.toJson())
          .toList(),
      'introductions_by_them': instance.introductionsByThem
          .map((e) => e.toJson())
          .toList(),
      'origin': instance.origin,
      'verified': instance.verified,
    };

$Rec _$recordConvert<$Rec>(Object? value, $Rec Function(Map) convert) =>
    convert(value as Map<String, dynamic>);
