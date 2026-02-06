// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'contact_introduction.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ContactIntroduction _$ContactIntroductionFromJson(Map<String, dynamic> json) =>
    _ContactIntroduction(
      otherName: json['other_name'] as String,
      sharedSecret: Typed<BareSharedSecret>.fromJson(json['shared_secret']),
      dhtRecordKeyReceiving: RecordKey.fromJson(
        json['dht_record_key_receiving'],
      ),
      dhtRecordKeySharing: RecordKey.fromJson(json['dht_record_key_sharing']),
      dhtWriterSharing: KeyPair.fromJson(json['dht_writer_sharing']),
      message: json['message'] as String?,
    );

Map<String, dynamic> _$ContactIntroductionToJson(
  _ContactIntroduction instance,
) => <String, dynamic>{
  'other_name': instance.otherName,
  'shared_secret': instance.sharedSecret.toJson(),
  'dht_record_key_receiving': instance.dhtRecordKeyReceiving.toJson(),
  'dht_record_key_sharing': instance.dhtRecordKeySharing.toJson(),
  'dht_writer_sharing': instance.dhtWriterSharing.toJson(),
  'message': instance.message,
};
