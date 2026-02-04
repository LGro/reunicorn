// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'encrypted_communication.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_MessageWithEncryptionMetaData _$MessageWithEncryptionMetaDataFromJson(
  Map<String, dynamic> json,
) => _MessageWithEncryptionMetaData(
  shareBackDHTKey: json['share_back_d_h_t_key'] == null
      ? null
      : RecordKey.fromJson(json['share_back_d_h_t_key']),
  shareBackDHTWriter: json['share_back_d_h_t_writer'] == null
      ? null
      : KeyPair.fromJson(json['share_back_d_h_t_writer']),
  deniabilitySharingWriter: json['deniability_sharing_writer'] == null
      ? null
      : KeyPair.fromJson(json['deniability_sharing_writer']),
  oneTimeKey: json['one_time_key'] as String?,
  message: json['message'] as Map<String, dynamic>?,
);

Map<String, dynamic> _$MessageWithEncryptionMetaDataToJson(
  _MessageWithEncryptionMetaData instance,
) => <String, dynamic>{
  'share_back_d_h_t_key': instance.shareBackDHTKey?.toJson(),
  'share_back_d_h_t_writer': instance.shareBackDHTWriter?.toJson(),
  'deniability_sharing_writer': instance.deniabilitySharingWriter?.toJson(),
  'one_time_key': instance.oneTimeKey,
  'message': instance.message,
};
