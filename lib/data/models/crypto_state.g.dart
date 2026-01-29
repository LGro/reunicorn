// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'crypto_state.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CryptoSymmetric _$CryptoSymmetricFromJson(Map<String, dynamic> json) =>
    CryptoSymmetric(
      sharedSecret: Typed<BareSharedSecret>.fromJson(json['shared_secret']),
      accountVod: json['account_vod'] as String,
      $type: json['runtimeType'] as String?,
    );

Map<String, dynamic> _$CryptoSymmetricToJson(CryptoSymmetric instance) =>
    <String, dynamic>{
      'shared_secret': instance.sharedSecret.toJson(),
      'account_vod': instance.accountVod,
      'runtimeType': instance.$type,
    };

CryptoSymToVod _$CryptoSymToVodFromJson(Map<String, dynamic> json) =>
    CryptoSymToVod(
      sharedSecret: Typed<BareSharedSecret>.fromJson(json['shared_secret']),
      theirIdentityKey: json['their_identity_key'] as String,
      myIdentityKey: json['my_identity_key'] as String,
      sessionVod: json['session_vod'] as String,
      $type: json['runtimeType'] as String?,
    );

Map<String, dynamic> _$CryptoSymToVodToJson(CryptoSymToVod instance) =>
    <String, dynamic>{
      'shared_secret': instance.sharedSecret.toJson(),
      'their_identity_key': instance.theirIdentityKey,
      'my_identity_key': instance.myIdentityKey,
      'session_vod': instance.sessionVod,
      'runtimeType': instance.$type,
    };

CryptoVodozemac _$CryptoVodozemacFromJson(Map<String, dynamic> json) =>
    CryptoVodozemac(
      theirIdentityKey: json['their_identity_key'] as String,
      myIdentityKey: json['my_identity_key'] as String,
      sessionVod: json['session_vod'] as String,
      $type: json['runtimeType'] as String?,
    );

Map<String, dynamic> _$CryptoVodozemacToJson(CryptoVodozemac instance) =>
    <String, dynamic>{
      'their_identity_key': instance.theirIdentityKey,
      'my_identity_key': instance.myIdentityKey,
      'session_vod': instance.sessionVod,
      'runtimeType': instance.$type,
    };
