// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'schema.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Connection _$ConnectionFromJson(Map<String, dynamic> json) => _Connection(
  theirName: json['their_name'] as String,
  myRecord: RecordKey.fromJson(json['my_record']),
  myWriter: KeyPair.fromJson(json['my_writer']),
  theirRecord: RecordKey.fromJson(json['their_record']),
);

Map<String, dynamic> _$ConnectionToJson(_Connection instance) =>
    <String, dynamic>{
      'their_name': instance.theirName,
      'my_record': instance.myRecord.toJson(),
      'my_writer': instance.myWriter.toJson(),
      'their_record': instance.theirRecord.toJson(),
    };

_AppLinkSchema _$AppLinkSchemaFromJson(Map<String, dynamic> json) =>
    _AppLinkSchema(
      appId: json['app_id'] as String? ?? "app.reunicorn",
      connections:
          (json['connections'] as Map<String, dynamic>?)?.map(
            (k, e) =>
                MapEntry(k, Connection.fromJson(e as Map<String, dynamic>)),
          ) ??
          const {},
    );

Map<String, dynamic> _$AppLinkSchemaToJson(
  _AppLinkSchema instance,
) => <String, dynamic>{
  'app_id': instance.appId,
  'connections': instance.connections.map((k, e) => MapEntry(k, e.toJson())),
};
