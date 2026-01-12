// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dht_connection_state.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DhtConnectionInitialized _$DhtConnectionInitializedFromJson(
  Map<String, dynamic> json,
) => DhtConnectionInitialized(
  recordKeyMeSharing: RecordKey.fromJson(json['record_key_me_sharing']),
  writerMeSharing: KeyPair.fromJson(json['writer_me_sharing']),
  recordKeyThemSharing: RecordKey.fromJson(json['record_key_them_sharing']),
  writerThemSharing: KeyPair.fromJson(json['writer_them_sharing']),
  $type: json['runtimeType'] as String?,
);

Map<String, dynamic> _$DhtConnectionInitializedToJson(
  DhtConnectionInitialized instance,
) => <String, dynamic>{
  'record_key_me_sharing': instance.recordKeyMeSharing.toJson(),
  'writer_me_sharing': instance.writerMeSharing.toJson(),
  'record_key_them_sharing': instance.recordKeyThemSharing.toJson(),
  'writer_them_sharing': instance.writerThemSharing.toJson(),
  'runtimeType': instance.$type,
};

DhtConnectionInvited _$DhtConnectionInvitedFromJson(
  Map<String, dynamic> json,
) => DhtConnectionInvited(
  recordKeyThemSharing: RecordKey.fromJson(json['record_key_them_sharing']),
  $type: json['runtimeType'] as String?,
);

Map<String, dynamic> _$DhtConnectionInvitedToJson(
  DhtConnectionInvited instance,
) => <String, dynamic>{
  'record_key_them_sharing': instance.recordKeyThemSharing.toJson(),
  'runtimeType': instance.$type,
};

DhtConnectionEstablished _$DhtConnectionEstablishedFromJson(
  Map<String, dynamic> json,
) => DhtConnectionEstablished(
  recordKeyMeSharing: RecordKey.fromJson(json['record_key_me_sharing']),
  writerMeSharing: KeyPair.fromJson(json['writer_me_sharing']),
  recordKeyThemSharing: RecordKey.fromJson(json['record_key_them_sharing']),
  $type: json['runtimeType'] as String?,
);

Map<String, dynamic> _$DhtConnectionEstablishedToJson(
  DhtConnectionEstablished instance,
) => <String, dynamic>{
  'record_key_me_sharing': instance.recordKeyMeSharing.toJson(),
  'writer_me_sharing': instance.writerMeSharing.toJson(),
  'record_key_them_sharing': instance.recordKeyThemSharing.toJson(),
  'runtimeType': instance.$type,
};
