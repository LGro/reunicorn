// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'close_by_match.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CloseByMatch _$CloseByMatchFromJson(Map<String, dynamic> json) =>
    _CloseByMatch(
      myLocationLabel: json['my_location_label'] as String,
      theirLocationId: json['their_location_id'] as String,
      theirLocationLabel: json['their_location_label'] as String,
      contact: CoagContact.fromJson(json['contact'] as Map<String, dynamic>),
      start: DateTime.parse(json['start'] as String),
      end: DateTime.parse(json['end'] as String),
      offset: Duration(microseconds: (json['offset'] as num).toInt()),
      theyKnow: json['they_know'] as bool,
    );

Map<String, dynamic> _$CloseByMatchToJson(_CloseByMatch instance) =>
    <String, dynamic>{
      'my_location_label': instance.myLocationLabel,
      'their_location_id': instance.theirLocationId,
      'their_location_label': instance.theirLocationLabel,
      'contact': instance.contact.toJson(),
      'start': instance.start.toIso8601String(),
      'end': instance.end.toIso8601String(),
      'offset': instance.offset.inMicroseconds,
      'they_know': instance.theyKnow,
    };
