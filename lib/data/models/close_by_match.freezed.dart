// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'close_by_match.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CloseByMatch {

 String get myLocationLabel; String get theirLocationId; String get theirLocationLabel; String get coagContactId; String get coagContactName; DateTime get start; DateTime get end; Duration get offset; bool get theyKnow;
/// Create a copy of CloseByMatch
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CloseByMatchCopyWith<CloseByMatch> get copyWith => _$CloseByMatchCopyWithImpl<CloseByMatch>(this as CloseByMatch, _$identity);

  /// Serializes this CloseByMatch to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CloseByMatch&&(identical(other.myLocationLabel, myLocationLabel) || other.myLocationLabel == myLocationLabel)&&(identical(other.theirLocationId, theirLocationId) || other.theirLocationId == theirLocationId)&&(identical(other.theirLocationLabel, theirLocationLabel) || other.theirLocationLabel == theirLocationLabel)&&(identical(other.coagContactId, coagContactId) || other.coagContactId == coagContactId)&&(identical(other.coagContactName, coagContactName) || other.coagContactName == coagContactName)&&(identical(other.start, start) || other.start == start)&&(identical(other.end, end) || other.end == end)&&(identical(other.offset, offset) || other.offset == offset)&&(identical(other.theyKnow, theyKnow) || other.theyKnow == theyKnow));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,myLocationLabel,theirLocationId,theirLocationLabel,coagContactId,coagContactName,start,end,offset,theyKnow);

@override
String toString() {
  return 'CloseByMatch(myLocationLabel: $myLocationLabel, theirLocationId: $theirLocationId, theirLocationLabel: $theirLocationLabel, coagContactId: $coagContactId, coagContactName: $coagContactName, start: $start, end: $end, offset: $offset, theyKnow: $theyKnow)';
}


}

/// @nodoc
abstract mixin class $CloseByMatchCopyWith<$Res>  {
  factory $CloseByMatchCopyWith(CloseByMatch value, $Res Function(CloseByMatch) _then) = _$CloseByMatchCopyWithImpl;
@useResult
$Res call({
 String myLocationLabel, String theirLocationId, String theirLocationLabel, String coagContactId, String coagContactName, DateTime start, DateTime end, Duration offset, bool theyKnow
});




}
/// @nodoc
class _$CloseByMatchCopyWithImpl<$Res>
    implements $CloseByMatchCopyWith<$Res> {
  _$CloseByMatchCopyWithImpl(this._self, this._then);

  final CloseByMatch _self;
  final $Res Function(CloseByMatch) _then;

/// Create a copy of CloseByMatch
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? myLocationLabel = null,Object? theirLocationId = null,Object? theirLocationLabel = null,Object? coagContactId = null,Object? coagContactName = null,Object? start = null,Object? end = null,Object? offset = null,Object? theyKnow = null,}) {
  return _then(_self.copyWith(
myLocationLabel: null == myLocationLabel ? _self.myLocationLabel : myLocationLabel // ignore: cast_nullable_to_non_nullable
as String,theirLocationId: null == theirLocationId ? _self.theirLocationId : theirLocationId // ignore: cast_nullable_to_non_nullable
as String,theirLocationLabel: null == theirLocationLabel ? _self.theirLocationLabel : theirLocationLabel // ignore: cast_nullable_to_non_nullable
as String,coagContactId: null == coagContactId ? _self.coagContactId : coagContactId // ignore: cast_nullable_to_non_nullable
as String,coagContactName: null == coagContactName ? _self.coagContactName : coagContactName // ignore: cast_nullable_to_non_nullable
as String,start: null == start ? _self.start : start // ignore: cast_nullable_to_non_nullable
as DateTime,end: null == end ? _self.end : end // ignore: cast_nullable_to_non_nullable
as DateTime,offset: null == offset ? _self.offset : offset // ignore: cast_nullable_to_non_nullable
as Duration,theyKnow: null == theyKnow ? _self.theyKnow : theyKnow // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [CloseByMatch].
extension CloseByMatchPatterns on CloseByMatch {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CloseByMatch value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CloseByMatch() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CloseByMatch value)  $default,){
final _that = this;
switch (_that) {
case _CloseByMatch():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CloseByMatch value)?  $default,){
final _that = this;
switch (_that) {
case _CloseByMatch() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String myLocationLabel,  String theirLocationId,  String theirLocationLabel,  String coagContactId,  String coagContactName,  DateTime start,  DateTime end,  Duration offset,  bool theyKnow)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CloseByMatch() when $default != null:
return $default(_that.myLocationLabel,_that.theirLocationId,_that.theirLocationLabel,_that.coagContactId,_that.coagContactName,_that.start,_that.end,_that.offset,_that.theyKnow);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String myLocationLabel,  String theirLocationId,  String theirLocationLabel,  String coagContactId,  String coagContactName,  DateTime start,  DateTime end,  Duration offset,  bool theyKnow)  $default,) {final _that = this;
switch (_that) {
case _CloseByMatch():
return $default(_that.myLocationLabel,_that.theirLocationId,_that.theirLocationLabel,_that.coagContactId,_that.coagContactName,_that.start,_that.end,_that.offset,_that.theyKnow);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String myLocationLabel,  String theirLocationId,  String theirLocationLabel,  String coagContactId,  String coagContactName,  DateTime start,  DateTime end,  Duration offset,  bool theyKnow)?  $default,) {final _that = this;
switch (_that) {
case _CloseByMatch() when $default != null:
return $default(_that.myLocationLabel,_that.theirLocationId,_that.theirLocationLabel,_that.coagContactId,_that.coagContactName,_that.start,_that.end,_that.offset,_that.theyKnow);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CloseByMatch implements CloseByMatch {
   _CloseByMatch({required this.myLocationLabel, required this.theirLocationId, required this.theirLocationLabel, required this.coagContactId, required this.coagContactName, required this.start, required this.end, required this.offset, required this.theyKnow});
  factory _CloseByMatch.fromJson(Map<String, dynamic> json) => _$CloseByMatchFromJson(json);

@override final  String myLocationLabel;
@override final  String theirLocationId;
@override final  String theirLocationLabel;
@override final  String coagContactId;
@override final  String coagContactName;
@override final  DateTime start;
@override final  DateTime end;
@override final  Duration offset;
@override final  bool theyKnow;

/// Create a copy of CloseByMatch
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CloseByMatchCopyWith<_CloseByMatch> get copyWith => __$CloseByMatchCopyWithImpl<_CloseByMatch>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CloseByMatchToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CloseByMatch&&(identical(other.myLocationLabel, myLocationLabel) || other.myLocationLabel == myLocationLabel)&&(identical(other.theirLocationId, theirLocationId) || other.theirLocationId == theirLocationId)&&(identical(other.theirLocationLabel, theirLocationLabel) || other.theirLocationLabel == theirLocationLabel)&&(identical(other.coagContactId, coagContactId) || other.coagContactId == coagContactId)&&(identical(other.coagContactName, coagContactName) || other.coagContactName == coagContactName)&&(identical(other.start, start) || other.start == start)&&(identical(other.end, end) || other.end == end)&&(identical(other.offset, offset) || other.offset == offset)&&(identical(other.theyKnow, theyKnow) || other.theyKnow == theyKnow));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,myLocationLabel,theirLocationId,theirLocationLabel,coagContactId,coagContactName,start,end,offset,theyKnow);

@override
String toString() {
  return 'CloseByMatch(myLocationLabel: $myLocationLabel, theirLocationId: $theirLocationId, theirLocationLabel: $theirLocationLabel, coagContactId: $coagContactId, coagContactName: $coagContactName, start: $start, end: $end, offset: $offset, theyKnow: $theyKnow)';
}


}

/// @nodoc
abstract mixin class _$CloseByMatchCopyWith<$Res> implements $CloseByMatchCopyWith<$Res> {
  factory _$CloseByMatchCopyWith(_CloseByMatch value, $Res Function(_CloseByMatch) _then) = __$CloseByMatchCopyWithImpl;
@override @useResult
$Res call({
 String myLocationLabel, String theirLocationId, String theirLocationLabel, String coagContactId, String coagContactName, DateTime start, DateTime end, Duration offset, bool theyKnow
});




}
/// @nodoc
class __$CloseByMatchCopyWithImpl<$Res>
    implements _$CloseByMatchCopyWith<$Res> {
  __$CloseByMatchCopyWithImpl(this._self, this._then);

  final _CloseByMatch _self;
  final $Res Function(_CloseByMatch) _then;

/// Create a copy of CloseByMatch
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? myLocationLabel = null,Object? theirLocationId = null,Object? theirLocationLabel = null,Object? coagContactId = null,Object? coagContactName = null,Object? start = null,Object? end = null,Object? offset = null,Object? theyKnow = null,}) {
  return _then(_CloseByMatch(
myLocationLabel: null == myLocationLabel ? _self.myLocationLabel : myLocationLabel // ignore: cast_nullable_to_non_nullable
as String,theirLocationId: null == theirLocationId ? _self.theirLocationId : theirLocationId // ignore: cast_nullable_to_non_nullable
as String,theirLocationLabel: null == theirLocationLabel ? _self.theirLocationLabel : theirLocationLabel // ignore: cast_nullable_to_non_nullable
as String,coagContactId: null == coagContactId ? _self.coagContactId : coagContactId // ignore: cast_nullable_to_non_nullable
as String,coagContactName: null == coagContactName ? _self.coagContactName : coagContactName // ignore: cast_nullable_to_non_nullable
as String,start: null == start ? _self.start : start // ignore: cast_nullable_to_non_nullable
as DateTime,end: null == end ? _self.end : end // ignore: cast_nullable_to_non_nullable
as DateTime,offset: null == offset ? _self.offset : offset // ignore: cast_nullable_to_non_nullable
as Duration,theyKnow: null == theyKnow ? _self.theyKnow : theyKnow // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
