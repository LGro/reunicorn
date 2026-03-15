// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'encrypted_communication.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_EncryptionMetaData _$EncryptionMetaDataFromJson(Map<String, dynamic> json) =>
    _EncryptionMetaData(
      shareBackDHTKey: json['share_back_d_h_t_key'] == null
          ? null
          : RecordKey.fromJson(json['share_back_d_h_t_key']),
      shareBackDHTWriter: json['share_back_d_h_t_writer'] == null
          ? null
          : KeyPair.fromJson(json['share_back_d_h_t_writer']),
      shareBackPubKey: json['share_back_pub_key'] == null
          ? null
          : Typed<BarePublicKey>.fromJson(json['share_back_pub_key']),
      ackHandshakeComplete: json['ack_handshake_complete'] as bool? ?? false,
    );

Map<String, dynamic> _$EncryptionMetaDataToJson(_EncryptionMetaData instance) =>
    <String, dynamic>{
      'share_back_d_h_t_key': instance.shareBackDHTKey?.toJson(),
      'share_back_d_h_t_writer': instance.shareBackDHTWriter?.toJson(),
      'share_back_pub_key': instance.shareBackPubKey?.toJson(),
      'ack_handshake_complete': instance.ackHandshakeComplete,
    };
