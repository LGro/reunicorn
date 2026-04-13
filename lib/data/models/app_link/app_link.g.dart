// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_link.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AppLink _$AppLinkFromJson(Map<String, dynamic> json) => _AppLink(
  appId: json['app_id'] as String,
  label: json['label'] as String,
  autoAddContacts: json['auto_add_contacts'] as bool,
  circles: (json['circles'] as List<dynamic>).map((e) => e as String).toList(),
  sharingRecord: RecordKey.fromJson(json['sharing_record']),
  sharingWriter: KeyPair.fromJson(json['sharing_writer']),
  receivingRecord: RecordKey.fromJson(json['receiving_record']),
  receivingWriter: json['receiving_writer'] == null
      ? null
      : KeyPair.fromJson(json['receiving_writer']),
);

Map<String, dynamic> _$AppLinkToJson(_AppLink instance) => <String, dynamic>{
  'app_id': instance.appId,
  'label': instance.label,
  'auto_add_contacts': instance.autoAddContacts,
  'circles': instance.circles,
  'sharing_record': instance.sharingRecord.toJson(),
  'sharing_writer': instance.sharingWriter.toJson(),
  'receiving_record': instance.receivingRecord.toJson(),
  'receiving_writer': instance.receivingWriter?.toJson(),
};
