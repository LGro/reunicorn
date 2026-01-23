// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'cubit.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CommunityManagementState {

 ManagedCommunity? get community; int? get iSelectedMember; bool get isProcessing;
/// Create a copy of CommunityManagementState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CommunityManagementStateCopyWith<CommunityManagementState> get copyWith => _$CommunityManagementStateCopyWithImpl<CommunityManagementState>(this as CommunityManagementState, _$identity);

  /// Serializes this CommunityManagementState to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CommunityManagementState&&(identical(other.community, community) || other.community == community)&&(identical(other.iSelectedMember, iSelectedMember) || other.iSelectedMember == iSelectedMember)&&(identical(other.isProcessing, isProcessing) || other.isProcessing == isProcessing));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,community,iSelectedMember,isProcessing);

@override
String toString() {
  return 'CommunityManagementState(community: $community, iSelectedMember: $iSelectedMember, isProcessing: $isProcessing)';
}


}

/// @nodoc
abstract mixin class $CommunityManagementStateCopyWith<$Res>  {
  factory $CommunityManagementStateCopyWith(CommunityManagementState value, $Res Function(CommunityManagementState) _then) = _$CommunityManagementStateCopyWithImpl;
@useResult
$Res call({
 ManagedCommunity? community, int? iSelectedMember, bool isProcessing
});


$ManagedCommunityCopyWith<$Res>? get community;

}
/// @nodoc
class _$CommunityManagementStateCopyWithImpl<$Res>
    implements $CommunityManagementStateCopyWith<$Res> {
  _$CommunityManagementStateCopyWithImpl(this._self, this._then);

  final CommunityManagementState _self;
  final $Res Function(CommunityManagementState) _then;

/// Create a copy of CommunityManagementState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? community = freezed,Object? iSelectedMember = freezed,Object? isProcessing = null,}) {
  return _then(_self.copyWith(
community: freezed == community ? _self.community : community // ignore: cast_nullable_to_non_nullable
as ManagedCommunity?,iSelectedMember: freezed == iSelectedMember ? _self.iSelectedMember : iSelectedMember // ignore: cast_nullable_to_non_nullable
as int?,isProcessing: null == isProcessing ? _self.isProcessing : isProcessing // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}
/// Create a copy of CommunityManagementState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ManagedCommunityCopyWith<$Res>? get community {
    if (_self.community == null) {
    return null;
  }

  return $ManagedCommunityCopyWith<$Res>(_self.community!, (value) {
    return _then(_self.copyWith(community: value));
  });
}
}


/// Adds pattern-matching-related methods to [CommunityManagementState].
extension CommunityManagementStatePatterns on CommunityManagementState {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CommunityManagementState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CommunityManagementState() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CommunityManagementState value)  $default,){
final _that = this;
switch (_that) {
case _CommunityManagementState():
return $default(_that);}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CommunityManagementState value)?  $default,){
final _that = this;
switch (_that) {
case _CommunityManagementState() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( ManagedCommunity? community,  int? iSelectedMember,  bool isProcessing)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CommunityManagementState() when $default != null:
return $default(_that.community,_that.iSelectedMember,_that.isProcessing);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( ManagedCommunity? community,  int? iSelectedMember,  bool isProcessing)  $default,) {final _that = this;
switch (_that) {
case _CommunityManagementState():
return $default(_that.community,_that.iSelectedMember,_that.isProcessing);}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( ManagedCommunity? community,  int? iSelectedMember,  bool isProcessing)?  $default,) {final _that = this;
switch (_that) {
case _CommunityManagementState() when $default != null:
return $default(_that.community,_that.iSelectedMember,_that.isProcessing);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CommunityManagementState implements CommunityManagementState {
  const _CommunityManagementState({this.community, this.iSelectedMember, this.isProcessing = false});
  factory _CommunityManagementState.fromJson(Map<String, dynamic> json) => _$CommunityManagementStateFromJson(json);

@override final  ManagedCommunity? community;
@override final  int? iSelectedMember;
@override@JsonKey() final  bool isProcessing;

/// Create a copy of CommunityManagementState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CommunityManagementStateCopyWith<_CommunityManagementState> get copyWith => __$CommunityManagementStateCopyWithImpl<_CommunityManagementState>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CommunityManagementStateToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CommunityManagementState&&(identical(other.community, community) || other.community == community)&&(identical(other.iSelectedMember, iSelectedMember) || other.iSelectedMember == iSelectedMember)&&(identical(other.isProcessing, isProcessing) || other.isProcessing == isProcessing));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,community,iSelectedMember,isProcessing);

@override
String toString() {
  return 'CommunityManagementState(community: $community, iSelectedMember: $iSelectedMember, isProcessing: $isProcessing)';
}


}

/// @nodoc
abstract mixin class _$CommunityManagementStateCopyWith<$Res> implements $CommunityManagementStateCopyWith<$Res> {
  factory _$CommunityManagementStateCopyWith(_CommunityManagementState value, $Res Function(_CommunityManagementState) _then) = __$CommunityManagementStateCopyWithImpl;
@override @useResult
$Res call({
 ManagedCommunity? community, int? iSelectedMember, bool isProcessing
});


@override $ManagedCommunityCopyWith<$Res>? get community;

}
/// @nodoc
class __$CommunityManagementStateCopyWithImpl<$Res>
    implements _$CommunityManagementStateCopyWith<$Res> {
  __$CommunityManagementStateCopyWithImpl(this._self, this._then);

  final _CommunityManagementState _self;
  final $Res Function(_CommunityManagementState) _then;

/// Create a copy of CommunityManagementState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? community = freezed,Object? iSelectedMember = freezed,Object? isProcessing = null,}) {
  return _then(_CommunityManagementState(
community: freezed == community ? _self.community : community // ignore: cast_nullable_to_non_nullable
as ManagedCommunity?,iSelectedMember: freezed == iSelectedMember ? _self.iSelectedMember : iSelectedMember // ignore: cast_nullable_to_non_nullable
as int?,isProcessing: null == isProcessing ? _self.isProcessing : isProcessing // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

/// Create a copy of CommunityManagementState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ManagedCommunityCopyWith<$Res>? get community {
    if (_self.community == null) {
    return null;
  }

  return $ManagedCommunityCopyWith<$Res>(_self.community!, (value) {
    return _then(_self.copyWith(community: value));
  });
}
}

// dart format on
