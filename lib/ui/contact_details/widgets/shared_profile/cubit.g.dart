// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cubit.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SharedProfileState _$SharedProfileStateFromJson(Map<String, dynamic> json) =>
    SharedProfileState(
      current: json['current'] == null
          ? null
          : ContactSharingSchemaV3.fromJson(
              json['current'] as Map<String, dynamic>,
            ),
      pending: json['pending'] == null
          ? null
          : ContactSharingSchemaV3.fromJson(
              json['pending'] as Map<String, dynamic>,
            ),
      diff: json['diff'] == null
          ? null
          : ContactSharingSchemaDiff.fromJson(
              json['diff'] as Map<String, dynamic>,
            ),
    );

Map<String, dynamic> _$SharedProfileStateToJson(SharedProfileState instance) =>
    <String, dynamic>{
      'current': instance.current?.toJson(),
      'pending': instance.pending?.toJson(),
      'diff': instance.diff?.toJson(),
    };
