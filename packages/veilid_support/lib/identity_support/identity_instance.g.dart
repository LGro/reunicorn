// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'identity_instance.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_IdentityInstance _$IdentityInstanceFromJson(Map<String, dynamic> json) =>
    _IdentityInstance(
      recordKey: RecordKey.fromJson(json['record_key']),
      barePublicKey: BarePublicKey.fromJson(json['public_key']),
      encryptedSecretKey: const Uint8ListJsonConverter().fromJson(
        json['encrypted_secret_key'],
      ),
      bareSuperSignature: BareSignature.fromJson(json['super_signature']),
      bareSignature: BareSignature.fromJson(json['signature']),
    );

Map<String, dynamic> _$IdentityInstanceToJson(_IdentityInstance instance) =>
    <String, dynamic>{
      'record_key': instance.recordKey.toJson(),
      'public_key': instance.barePublicKey.toJson(),
      'encrypted_secret_key': const Uint8ListJsonConverter().toJson(
        instance.encryptedSecretKey,
      ),
      'super_signature': instance.bareSuperSignature.toJson(),
      'signature': instance.bareSignature.toJson(),
    };
