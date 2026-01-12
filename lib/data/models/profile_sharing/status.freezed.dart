// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'status.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ProfileSharingStatus {

/// Timestamp of the most recent sharing success
 DateTime? get mostRecentSuccess;/// Timestamp of the most recent sharing attempt
 DateTime? get mostRecentAttempt;/// Successfully shared profile, not necessarily the most recent version
 ContactSharingSchema? get sharedProfile;
/// Create a copy of ProfileSharingStatus
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProfileSharingStatusCopyWith<ProfileSharingStatus> get copyWith => _$ProfileSharingStatusCopyWithImpl<ProfileSharingStatus>(this as ProfileSharingStatus, _$identity);

  /// Serializes this ProfileSharingStatus to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProfileSharingStatus&&(identical(other.mostRecentSuccess, mostRecentSuccess) || other.mostRecentSuccess == mostRecentSuccess)&&(identical(other.mostRecentAttempt, mostRecentAttempt) || other.mostRecentAttempt == mostRecentAttempt)&&(identical(other.sharedProfile, sharedProfile) || other.sharedProfile == sharedProfile));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,mostRecentSuccess,mostRecentAttempt,sharedProfile);

@override
String toString() {
  return 'ProfileSharingStatus(mostRecentSuccess: $mostRecentSuccess, mostRecentAttempt: $mostRecentAttempt, sharedProfile: $sharedProfile)';
}


}

/// @nodoc
abstract mixin class $ProfileSharingStatusCopyWith<$Res>  {
  factory $ProfileSharingStatusCopyWith(ProfileSharingStatus value, $Res Function(ProfileSharingStatus) _then) = _$ProfileSharingStatusCopyWithImpl;
@useResult
$Res call({
 DateTime? mostRecentSuccess, DateTime? mostRecentAttempt, ContactSharingSchema? sharedProfile
});


$ContactSharingSchemaV3CopyWith<$Res>? get sharedProfile;

}
/// @nodoc
class _$ProfileSharingStatusCopyWithImpl<$Res>
    implements $ProfileSharingStatusCopyWith<$Res> {
  _$ProfileSharingStatusCopyWithImpl(this._self, this._then);

  final ProfileSharingStatus _self;
  final $Res Function(ProfileSharingStatus) _then;

/// Create a copy of ProfileSharingStatus
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? mostRecentSuccess = freezed,Object? mostRecentAttempt = freezed,Object? sharedProfile = freezed,}) {
  return _then(_self.copyWith(
mostRecentSuccess: freezed == mostRecentSuccess ? _self.mostRecentSuccess : mostRecentSuccess // ignore: cast_nullable_to_non_nullable
as DateTime?,mostRecentAttempt: freezed == mostRecentAttempt ? _self.mostRecentAttempt : mostRecentAttempt // ignore: cast_nullable_to_non_nullable
as DateTime?,sharedProfile: freezed == sharedProfile ? _self.sharedProfile : sharedProfile // ignore: cast_nullable_to_non_nullable
as ContactSharingSchema?,
  ));
}
/// Create a copy of ProfileSharingStatus
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ContactSharingSchemaV3CopyWith<$Res>? get sharedProfile {
    if (_self.sharedProfile == null) {
    return null;
  }

  return $ContactSharingSchemaV3CopyWith<$Res>(_self.sharedProfile!, (value) {
    return _then(_self.copyWith(sharedProfile: value));
  });
}
}


/// Adds pattern-matching-related methods to [ProfileSharingStatus].
extension ProfileSharingStatusPatterns on ProfileSharingStatus {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ProfileSharingStatus value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ProfileSharingStatus() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ProfileSharingStatus value)  $default,){
final _that = this;
switch (_that) {
case _ProfileSharingStatus():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ProfileSharingStatus value)?  $default,){
final _that = this;
switch (_that) {
case _ProfileSharingStatus() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( DateTime? mostRecentSuccess,  DateTime? mostRecentAttempt,  ContactSharingSchema? sharedProfile)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ProfileSharingStatus() when $default != null:
return $default(_that.mostRecentSuccess,_that.mostRecentAttempt,_that.sharedProfile);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( DateTime? mostRecentSuccess,  DateTime? mostRecentAttempt,  ContactSharingSchema? sharedProfile)  $default,) {final _that = this;
switch (_that) {
case _ProfileSharingStatus():
return $default(_that.mostRecentSuccess,_that.mostRecentAttempt,_that.sharedProfile);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( DateTime? mostRecentSuccess,  DateTime? mostRecentAttempt,  ContactSharingSchema? sharedProfile)?  $default,) {final _that = this;
switch (_that) {
case _ProfileSharingStatus() when $default != null:
return $default(_that.mostRecentSuccess,_that.mostRecentAttempt,_that.sharedProfile);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ProfileSharingStatus implements ProfileSharingStatus {
  const _ProfileSharingStatus({this.mostRecentSuccess, this.mostRecentAttempt, this.sharedProfile});
  factory _ProfileSharingStatus.fromJson(Map<String, dynamic> json) => _$ProfileSharingStatusFromJson(json);

/// Timestamp of the most recent sharing success
@override final  DateTime? mostRecentSuccess;
/// Timestamp of the most recent sharing attempt
@override final  DateTime? mostRecentAttempt;
/// Successfully shared profile, not necessarily the most recent version
@override final  ContactSharingSchema? sharedProfile;

/// Create a copy of ProfileSharingStatus
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProfileSharingStatusCopyWith<_ProfileSharingStatus> get copyWith => __$ProfileSharingStatusCopyWithImpl<_ProfileSharingStatus>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ProfileSharingStatusToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProfileSharingStatus&&(identical(other.mostRecentSuccess, mostRecentSuccess) || other.mostRecentSuccess == mostRecentSuccess)&&(identical(other.mostRecentAttempt, mostRecentAttempt) || other.mostRecentAttempt == mostRecentAttempt)&&(identical(other.sharedProfile, sharedProfile) || other.sharedProfile == sharedProfile));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,mostRecentSuccess,mostRecentAttempt,sharedProfile);

@override
String toString() {
  return 'ProfileSharingStatus(mostRecentSuccess: $mostRecentSuccess, mostRecentAttempt: $mostRecentAttempt, sharedProfile: $sharedProfile)';
}


}

/// @nodoc
abstract mixin class _$ProfileSharingStatusCopyWith<$Res> implements $ProfileSharingStatusCopyWith<$Res> {
  factory _$ProfileSharingStatusCopyWith(_ProfileSharingStatus value, $Res Function(_ProfileSharingStatus) _then) = __$ProfileSharingStatusCopyWithImpl;
@override @useResult
$Res call({
 DateTime? mostRecentSuccess, DateTime? mostRecentAttempt, ContactSharingSchema? sharedProfile
});


@override $ContactSharingSchemaV3CopyWith<$Res>? get sharedProfile;

}
/// @nodoc
class __$ProfileSharingStatusCopyWithImpl<$Res>
    implements _$ProfileSharingStatusCopyWith<$Res> {
  __$ProfileSharingStatusCopyWithImpl(this._self, this._then);

  final _ProfileSharingStatus _self;
  final $Res Function(_ProfileSharingStatus) _then;

/// Create a copy of ProfileSharingStatus
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? mostRecentSuccess = freezed,Object? mostRecentAttempt = freezed,Object? sharedProfile = freezed,}) {
  return _then(_ProfileSharingStatus(
mostRecentSuccess: freezed == mostRecentSuccess ? _self.mostRecentSuccess : mostRecentSuccess // ignore: cast_nullable_to_non_nullable
as DateTime?,mostRecentAttempt: freezed == mostRecentAttempt ? _self.mostRecentAttempt : mostRecentAttempt // ignore: cast_nullable_to_non_nullable
as DateTime?,sharedProfile: freezed == sharedProfile ? _self.sharedProfile : sharedProfile // ignore: cast_nullable_to_non_nullable
as ContactSharingSchema?,
  ));
}

/// Create a copy of ProfileSharingStatus
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ContactSharingSchemaV3CopyWith<$Res>? get sharedProfile {
    if (_self.sharedProfile == null) {
    return null;
  }

  return $ContactSharingSchemaV3CopyWith<$Res>(_self.sharedProfile!, (value) {
    return _then(_self.copyWith(sharedProfile: value));
  });
}
}

// dart format on
