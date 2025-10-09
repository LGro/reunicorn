// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'super_identity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SuperIdentity _$SuperIdentityFromJson(Map<String, dynamic> json) =>
    _SuperIdentity(
      recordKey: RecordKey.fromJson(json['record_key']),
      barePublicKey: BarePublicKey.fromJson(json['public_key']),
      currentInstance: IdentityInstance.fromJson(json['current_instance']),
      deprecatedInstances: (json['deprecated_instances'] as List<dynamic>)
          .map(IdentityInstance.fromJson)
          .toList(),
      deprecatedSuperRecordKeys:
          (json['deprecated_super_record_keys'] as List<dynamic>)
              .map(RecordKey.fromJson)
              .toList(),
      bareSignature: BareSignature.fromJson(json['signature']),
    );

Map<String, dynamic> _$SuperIdentityToJson(_SuperIdentity instance) =>
    <String, dynamic>{
      'record_key': instance.recordKey.toJson(),
      'public_key': instance.barePublicKey.toJson(),
      'current_instance': instance.currentInstance.toJson(),
      'deprecated_instances': instance.deprecatedInstances
          .map((e) => e.toJson())
          .toList(),
      'deprecated_super_record_keys': instance.deprecatedSuperRecordKeys
          .map((e) => e.toJson())
          .toList(),
      'signature': instance.bareSignature.toJson(),
    };
