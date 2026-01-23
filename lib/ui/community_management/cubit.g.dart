// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cubit.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CommunityManagementState _$CommunityManagementStateFromJson(
  Map<String, dynamic> json,
) => _CommunityManagementState(
  community: json['community'] == null
      ? null
      : ManagedCommunity.fromJson(json['community'] as Map<String, dynamic>),
  iSelectedMember: (json['i_selected_member'] as num?)?.toInt(),
  isProcessing: json['is_processing'] as bool? ?? false,
);

Map<String, dynamic> _$CommunityManagementStateToJson(
  _CommunityManagementState instance,
) => <String, dynamic>{
  'community': instance.community?.toJson(),
  'i_selected_member': instance.iSelectedMember,
  'is_processing': instance.isProcessing,
};
