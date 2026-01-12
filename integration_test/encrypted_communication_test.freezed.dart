// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'encrypted_communication_test.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ExamplePayload implements DiagnosticableTreeMixin {

 String get message;
/// Create a copy of ExamplePayload
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ExamplePayloadCopyWith<ExamplePayload> get copyWith => _$ExamplePayloadCopyWithImpl<ExamplePayload>(this as ExamplePayload, _$identity);

  /// Serializes this ExamplePayload to a JSON map.
  Map<String, dynamic> toJson();

@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'ExamplePayload'))
    ..add(DiagnosticsProperty('message', message));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ExamplePayload&&(identical(other.message, message) || other.message == message));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,message);

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'ExamplePayload(message: $message)';
}


}

/// @nodoc
abstract mixin class $ExamplePayloadCopyWith<$Res>  {
  factory $ExamplePayloadCopyWith(ExamplePayload value, $Res Function(ExamplePayload) _then) = _$ExamplePayloadCopyWithImpl;
@useResult
$Res call({
 String message
});




}
/// @nodoc
class _$ExamplePayloadCopyWithImpl<$Res>
    implements $ExamplePayloadCopyWith<$Res> {
  _$ExamplePayloadCopyWithImpl(this._self, this._then);

  final ExamplePayload _self;
  final $Res Function(ExamplePayload) _then;

/// Create a copy of ExamplePayload
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? message = null,}) {
  return _then(_self.copyWith(
message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [ExamplePayload].
extension ExamplePayloadPatterns on ExamplePayload {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ExamplePayload value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ExamplePayload() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ExamplePayload value)  $default,){
final _that = this;
switch (_that) {
case _ExamplePayload():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ExamplePayload value)?  $default,){
final _that = this;
switch (_that) {
case _ExamplePayload() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String message)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ExamplePayload() when $default != null:
return $default(_that.message);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String message)  $default,) {final _that = this;
switch (_that) {
case _ExamplePayload():
return $default(_that.message);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String message)?  $default,) {final _that = this;
switch (_that) {
case _ExamplePayload() when $default != null:
return $default(_that.message);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ExamplePayload extends ExamplePayload with DiagnosticableTreeMixin {
  const _ExamplePayload({required this.message}): super._();
  factory _ExamplePayload.fromJson(Map<String, dynamic> json) => _$ExamplePayloadFromJson(json);

@override final  String message;

/// Create a copy of ExamplePayload
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ExamplePayloadCopyWith<_ExamplePayload> get copyWith => __$ExamplePayloadCopyWithImpl<_ExamplePayload>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ExamplePayloadToJson(this, );
}
@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'ExamplePayload'))
    ..add(DiagnosticsProperty('message', message));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ExamplePayload&&(identical(other.message, message) || other.message == message));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,message);

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'ExamplePayload(message: $message)';
}


}

/// @nodoc
abstract mixin class _$ExamplePayloadCopyWith<$Res> implements $ExamplePayloadCopyWith<$Res> {
  factory _$ExamplePayloadCopyWith(_ExamplePayload value, $Res Function(_ExamplePayload) _then) = __$ExamplePayloadCopyWithImpl;
@override @useResult
$Res call({
 String message
});




}
/// @nodoc
class __$ExamplePayloadCopyWithImpl<$Res>
    implements _$ExamplePayloadCopyWith<$Res> {
  __$ExamplePayloadCopyWithImpl(this._self, this._then);

  final _ExamplePayload _self;
  final $Res Function(_ExamplePayload) _then;

/// Create a copy of ExamplePayload
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? message = null,}) {
  return _then(_ExamplePayload(
message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
