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
mixin _$IntroductionsState {

 Map<String, CoagContact> get contacts; Map<String, Community> get communities;
/// Create a copy of IntroductionsState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$IntroductionsStateCopyWith<IntroductionsState> get copyWith => _$IntroductionsStateCopyWithImpl<IntroductionsState>(this as IntroductionsState, _$identity);

  /// Serializes this IntroductionsState to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is IntroductionsState&&const DeepCollectionEquality().equals(other.contacts, contacts)&&const DeepCollectionEquality().equals(other.communities, communities));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(contacts),const DeepCollectionEquality().hash(communities));

@override
String toString() {
  return 'IntroductionsState(contacts: $contacts, communities: $communities)';
}


}

/// @nodoc
abstract mixin class $IntroductionsStateCopyWith<$Res>  {
  factory $IntroductionsStateCopyWith(IntroductionsState value, $Res Function(IntroductionsState) _then) = _$IntroductionsStateCopyWithImpl;
@useResult
$Res call({
 Map<String, CoagContact> contacts, Map<String, Community> communities
});




}
/// @nodoc
class _$IntroductionsStateCopyWithImpl<$Res>
    implements $IntroductionsStateCopyWith<$Res> {
  _$IntroductionsStateCopyWithImpl(this._self, this._then);

  final IntroductionsState _self;
  final $Res Function(IntroductionsState) _then;

/// Create a copy of IntroductionsState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? contacts = null,Object? communities = null,}) {
  return _then(_self.copyWith(
contacts: null == contacts ? _self.contacts : contacts // ignore: cast_nullable_to_non_nullable
as Map<String, CoagContact>,communities: null == communities ? _self.communities : communities // ignore: cast_nullable_to_non_nullable
as Map<String, Community>,
  ));
}

}


/// Adds pattern-matching-related methods to [IntroductionsState].
extension IntroductionsStatePatterns on IntroductionsState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _IntroductionsState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _IntroductionsState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _IntroductionsState value)  $default,){
final _that = this;
switch (_that) {
case _IntroductionsState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _IntroductionsState value)?  $default,){
final _that = this;
switch (_that) {
case _IntroductionsState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Map<String, CoagContact> contacts,  Map<String, Community> communities)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _IntroductionsState() when $default != null:
return $default(_that.contacts,_that.communities);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Map<String, CoagContact> contacts,  Map<String, Community> communities)  $default,) {final _that = this;
switch (_that) {
case _IntroductionsState():
return $default(_that.contacts,_that.communities);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Map<String, CoagContact> contacts,  Map<String, Community> communities)?  $default,) {final _that = this;
switch (_that) {
case _IntroductionsState() when $default != null:
return $default(_that.contacts,_that.communities);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _IntroductionsState implements IntroductionsState {
  const _IntroductionsState({final  Map<String, CoagContact> contacts = const {}, final  Map<String, Community> communities = const {}}): _contacts = contacts,_communities = communities;
  factory _IntroductionsState.fromJson(Map<String, dynamic> json) => _$IntroductionsStateFromJson(json);

 final  Map<String, CoagContact> _contacts;
@override@JsonKey() Map<String, CoagContact> get contacts {
  if (_contacts is EqualUnmodifiableMapView) return _contacts;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_contacts);
}

 final  Map<String, Community> _communities;
@override@JsonKey() Map<String, Community> get communities {
  if (_communities is EqualUnmodifiableMapView) return _communities;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_communities);
}


/// Create a copy of IntroductionsState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$IntroductionsStateCopyWith<_IntroductionsState> get copyWith => __$IntroductionsStateCopyWithImpl<_IntroductionsState>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$IntroductionsStateToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _IntroductionsState&&const DeepCollectionEquality().equals(other._contacts, _contacts)&&const DeepCollectionEquality().equals(other._communities, _communities));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_contacts),const DeepCollectionEquality().hash(_communities));

@override
String toString() {
  return 'IntroductionsState(contacts: $contacts, communities: $communities)';
}


}

/// @nodoc
abstract mixin class _$IntroductionsStateCopyWith<$Res> implements $IntroductionsStateCopyWith<$Res> {
  factory _$IntroductionsStateCopyWith(_IntroductionsState value, $Res Function(_IntroductionsState) _then) = __$IntroductionsStateCopyWithImpl;
@override @useResult
$Res call({
 Map<String, CoagContact> contacts, Map<String, Community> communities
});




}
/// @nodoc
class __$IntroductionsStateCopyWithImpl<$Res>
    implements _$IntroductionsStateCopyWith<$Res> {
  __$IntroductionsStateCopyWithImpl(this._self, this._then);

  final _IntroductionsState _self;
  final $Res Function(_IntroductionsState) _then;

/// Create a copy of IntroductionsState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? contacts = null,Object? communities = null,}) {
  return _then(_IntroductionsState(
contacts: null == contacts ? _self._contacts : contacts // ignore: cast_nullable_to_non_nullable
as Map<String, CoagContact>,communities: null == communities ? _self._communities : communities // ignore: cast_nullable_to_non_nullable
as Map<String, Community>,
  ));
}


}

// dart format on
