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
mixin _$RestoreState {

 RestoreStatus get status;
/// Create a copy of RestoreState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RestoreStateCopyWith<RestoreState> get copyWith => _$RestoreStateCopyWithImpl<RestoreState>(this as RestoreState, _$identity);

  /// Serializes this RestoreState to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RestoreState&&(identical(other.status, status) || other.status == status));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,status);

@override
String toString() {
  return 'RestoreState(status: $status)';
}


}

/// @nodoc
abstract mixin class $RestoreStateCopyWith<$Res>  {
  factory $RestoreStateCopyWith(RestoreState value, $Res Function(RestoreState) _then) = _$RestoreStateCopyWithImpl;
@useResult
$Res call({
 RestoreStatus status
});




}
/// @nodoc
class _$RestoreStateCopyWithImpl<$Res>
    implements $RestoreStateCopyWith<$Res> {
  _$RestoreStateCopyWithImpl(this._self, this._then);

  final RestoreState _self;
  final $Res Function(RestoreState) _then;

/// Create a copy of RestoreState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? status = null,}) {
  return _then(_self.copyWith(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as RestoreStatus,
  ));
}

}


/// Adds pattern-matching-related methods to [RestoreState].
extension RestoreStatePatterns on RestoreState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RestoreState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RestoreState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RestoreState value)  $default,){
final _that = this;
switch (_that) {
case _RestoreState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RestoreState value)?  $default,){
final _that = this;
switch (_that) {
case _RestoreState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( RestoreStatus status)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RestoreState() when $default != null:
return $default(_that.status);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( RestoreStatus status)  $default,) {final _that = this;
switch (_that) {
case _RestoreState():
return $default(_that.status);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( RestoreStatus status)?  $default,) {final _that = this;
switch (_that) {
case _RestoreState() when $default != null:
return $default(_that.status);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RestoreState implements RestoreState {
  const _RestoreState({required this.status});
  factory _RestoreState.fromJson(Map<String, dynamic> json) => _$RestoreStateFromJson(json);

@override final  RestoreStatus status;

/// Create a copy of RestoreState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RestoreStateCopyWith<_RestoreState> get copyWith => __$RestoreStateCopyWithImpl<_RestoreState>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RestoreStateToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RestoreState&&(identical(other.status, status) || other.status == status));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,status);

@override
String toString() {
  return 'RestoreState(status: $status)';
}


}

/// @nodoc
abstract mixin class _$RestoreStateCopyWith<$Res> implements $RestoreStateCopyWith<$Res> {
  factory _$RestoreStateCopyWith(_RestoreState value, $Res Function(_RestoreState) _then) = __$RestoreStateCopyWithImpl;
@override @useResult
$Res call({
 RestoreStatus status
});




}
/// @nodoc
class __$RestoreStateCopyWithImpl<$Res>
    implements _$RestoreStateCopyWith<$Res> {
  __$RestoreStateCopyWithImpl(this._self, this._then);

  final _RestoreState _self;
  final $Res Function(_RestoreState) _then;

/// Create a copy of RestoreState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? status = null,}) {
  return _then(_RestoreState(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as RestoreStatus,
  ));
}


}

// dart format on
