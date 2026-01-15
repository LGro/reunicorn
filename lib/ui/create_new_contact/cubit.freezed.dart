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
mixin _$CreateNewContactState {

 CoagContact? get contact;
/// Create a copy of CreateNewContactState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CreateNewContactStateCopyWith<CreateNewContactState> get copyWith => _$CreateNewContactStateCopyWithImpl<CreateNewContactState>(this as CreateNewContactState, _$identity);

  /// Serializes this CreateNewContactState to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CreateNewContactState&&(identical(other.contact, contact) || other.contact == contact));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,contact);

@override
String toString() {
  return 'CreateNewContactState(contact: $contact)';
}


}

/// @nodoc
abstract mixin class $CreateNewContactStateCopyWith<$Res>  {
  factory $CreateNewContactStateCopyWith(CreateNewContactState value, $Res Function(CreateNewContactState) _then) = _$CreateNewContactStateCopyWithImpl;
@useResult
$Res call({
 CoagContact? contact
});




}
/// @nodoc
class _$CreateNewContactStateCopyWithImpl<$Res>
    implements $CreateNewContactStateCopyWith<$Res> {
  _$CreateNewContactStateCopyWithImpl(this._self, this._then);

  final CreateNewContactState _self;
  final $Res Function(CreateNewContactState) _then;

/// Create a copy of CreateNewContactState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? contact = freezed,}) {
  return _then(_self.copyWith(
contact: freezed == contact ? _self.contact : contact // ignore: cast_nullable_to_non_nullable
as CoagContact?,
  ));
}

}


/// Adds pattern-matching-related methods to [CreateNewContactState].
extension CreateNewContactStatePatterns on CreateNewContactState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CreateNewContactState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CreateNewContactState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CreateNewContactState value)  $default,){
final _that = this;
switch (_that) {
case _CreateNewContactState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CreateNewContactState value)?  $default,){
final _that = this;
switch (_that) {
case _CreateNewContactState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( CoagContact? contact)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CreateNewContactState() when $default != null:
return $default(_that.contact);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( CoagContact? contact)  $default,) {final _that = this;
switch (_that) {
case _CreateNewContactState():
return $default(_that.contact);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( CoagContact? contact)?  $default,) {final _that = this;
switch (_that) {
case _CreateNewContactState() when $default != null:
return $default(_that.contact);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CreateNewContactState implements CreateNewContactState {
  const _CreateNewContactState({this.contact});
  factory _CreateNewContactState.fromJson(Map<String, dynamic> json) => _$CreateNewContactStateFromJson(json);

@override final  CoagContact? contact;

/// Create a copy of CreateNewContactState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CreateNewContactStateCopyWith<_CreateNewContactState> get copyWith => __$CreateNewContactStateCopyWithImpl<_CreateNewContactState>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CreateNewContactStateToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CreateNewContactState&&(identical(other.contact, contact) || other.contact == contact));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,contact);

@override
String toString() {
  return 'CreateNewContactState(contact: $contact)';
}


}

/// @nodoc
abstract mixin class _$CreateNewContactStateCopyWith<$Res> implements $CreateNewContactStateCopyWith<$Res> {
  factory _$CreateNewContactStateCopyWith(_CreateNewContactState value, $Res Function(_CreateNewContactState) _then) = __$CreateNewContactStateCopyWithImpl;
@override @useResult
$Res call({
 CoagContact? contact
});




}
/// @nodoc
class __$CreateNewContactStateCopyWithImpl<$Res>
    implements _$CreateNewContactStateCopyWith<$Res> {
  __$CreateNewContactStateCopyWithImpl(this._self, this._then);

  final _CreateNewContactState _self;
  final $Res Function(_CreateNewContactState) _then;

/// Create a copy of CreateNewContactState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? contact = freezed,}) {
  return _then(_CreateNewContactState(
contact: freezed == contact ? _self.contact : contact // ignore: cast_nullable_to_non_nullable
as CoagContact?,
  ));
}


}

// dart format on
