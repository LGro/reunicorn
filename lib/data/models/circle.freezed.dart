// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'circle.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Circle {

/// Label or name for the circle
 String get id;/// Label or name for the circle
 String get name;/// Contact IDs of the circle members
 List<String> get memberIds;
/// Create a copy of Circle
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CircleCopyWith<Circle> get copyWith => _$CircleCopyWithImpl<Circle>(this as Circle, _$identity);

  /// Serializes this Circle to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Circle&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&const DeepCollectionEquality().equals(other.memberIds, memberIds));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,const DeepCollectionEquality().hash(memberIds));

@override
String toString() {
  return 'Circle(id: $id, name: $name, memberIds: $memberIds)';
}


}

/// @nodoc
abstract mixin class $CircleCopyWith<$Res>  {
  factory $CircleCopyWith(Circle value, $Res Function(Circle) _then) = _$CircleCopyWithImpl;
@useResult
$Res call({
 String id, String name, List<String> memberIds
});




}
/// @nodoc
class _$CircleCopyWithImpl<$Res>
    implements $CircleCopyWith<$Res> {
  _$CircleCopyWithImpl(this._self, this._then);

  final Circle _self;
  final $Res Function(Circle) _then;

/// Create a copy of Circle
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? memberIds = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,memberIds: null == memberIds ? _self.memberIds : memberIds // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}

}


/// Adds pattern-matching-related methods to [Circle].
extension CirclePatterns on Circle {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Circle value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Circle() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Circle value)  $default,){
final _that = this;
switch (_that) {
case _Circle():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Circle value)?  $default,){
final _that = this;
switch (_that) {
case _Circle() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  List<String> memberIds)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Circle() when $default != null:
return $default(_that.id,_that.name,_that.memberIds);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  List<String> memberIds)  $default,) {final _that = this;
switch (_that) {
case _Circle():
return $default(_that.id,_that.name,_that.memberIds);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  List<String> memberIds)?  $default,) {final _that = this;
switch (_that) {
case _Circle() when $default != null:
return $default(_that.id,_that.name,_that.memberIds);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Circle implements Circle {
   _Circle({required this.id, required this.name, required final  List<String> memberIds}): _memberIds = memberIds;
  factory _Circle.fromJson(Map<String, dynamic> json) => _$CircleFromJson(json);

/// Label or name for the circle
@override final  String id;
/// Label or name for the circle
@override final  String name;
/// Contact IDs of the circle members
 final  List<String> _memberIds;
/// Contact IDs of the circle members
@override List<String> get memberIds {
  if (_memberIds is EqualUnmodifiableListView) return _memberIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_memberIds);
}


/// Create a copy of Circle
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CircleCopyWith<_Circle> get copyWith => __$CircleCopyWithImpl<_Circle>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CircleToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Circle&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&const DeepCollectionEquality().equals(other._memberIds, _memberIds));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,const DeepCollectionEquality().hash(_memberIds));

@override
String toString() {
  return 'Circle(id: $id, name: $name, memberIds: $memberIds)';
}


}

/// @nodoc
abstract mixin class _$CircleCopyWith<$Res> implements $CircleCopyWith<$Res> {
  factory _$CircleCopyWith(_Circle value, $Res Function(_Circle) _then) = __$CircleCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, List<String> memberIds
});




}
/// @nodoc
class __$CircleCopyWithImpl<$Res>
    implements _$CircleCopyWith<$Res> {
  __$CircleCopyWithImpl(this._self, this._then);

  final _Circle _self;
  final $Res Function(_Circle) _then;

/// Create a copy of Circle
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? memberIds = null,}) {
  return _then(_Circle(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,memberIds: null == memberIds ? _self._memberIds : memberIds // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}

// dart format on
