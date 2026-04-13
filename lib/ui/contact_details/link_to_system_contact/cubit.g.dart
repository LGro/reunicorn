// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cubit.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_LinkToSystemContactState _$LinkToSystemContactStateFromJson(
  Map<String, dynamic> json,
) => _LinkToSystemContactState(
  status:
      $enumDecodeNullable(_$LinkToSystemContactStatusEnumMap, json['status']) ??
      LinkToSystemContactStatus.initial,
  permissionGranted: json['permission_granted'] as bool? ?? false,
  contact: json['contact'] == null
      ? null
      : CoagContact.fromJson(json['contact'] as Map<String, dynamic>),
  contacts:
      (json['contacts'] as List<dynamic>?)
          ?.map(
            (e) => const ContactConverter().fromJson(e as Map<String, dynamic>),
          )
          .toList() ??
      const [],
  accounts:
      (json['accounts'] as List<dynamic>?)
          ?.map(
            (e) => const AccountConverter().fromJson(e as Map<String, dynamic>),
          )
          .toSet() ??
      const {},
  selectedAccount: _$JsonConverterFromJson<Map<String, dynamic>, Account>(
    json['selected_account'],
    const AccountConverter().fromJson,
  ),
  linkedSystemContactIds:
      (json['linked_system_contact_ids'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toSet() ??
      const {},
);

Map<String, dynamic> _$LinkToSystemContactStateToJson(
  _LinkToSystemContactState instance,
) => <String, dynamic>{
  'status': _$LinkToSystemContactStatusEnumMap[instance.status]!,
  'permission_granted': instance.permissionGranted,
  'contact': instance.contact?.toJson(),
  'contacts': instance.contacts.map(const ContactConverter().toJson).toList(),
  'accounts': instance.accounts.map(const AccountConverter().toJson).toList(),
  'selected_account': _$JsonConverterToJson<Map<String, dynamic>, Account>(
    instance.selectedAccount,
    const AccountConverter().toJson,
  ),
  'linked_system_contact_ids': instance.linkedSystemContactIds.toList(),
};

const _$LinkToSystemContactStatusEnumMap = {
  LinkToSystemContactStatus.initial: 'initial',
  LinkToSystemContactStatus.success: 'success',
  LinkToSystemContactStatus.denied: 'denied',
};

Value? _$JsonConverterFromJson<Json, Value>(
  Object? json,
  Value? Function(Json json) fromJson,
) => json == null ? null : fromJson(json as Json);

Json? _$JsonConverterToJson<Json, Value>(
  Value? value,
  Json? Function(Value value) toJson,
) => value == null ? null : toJson(value);
