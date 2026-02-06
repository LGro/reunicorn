// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'contact_introduction.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ContactIntroduction {

/// Name of the contact this is not the introduction for
 String get otherName;/// Initial shared secret for encrypted communication
 SharedSecret get sharedSecret;/// Record key where the contact this is not the introduction for is sharing
 RecordKey get dhtRecordKeyReceiving;/// Record key where the contact this is the introduction for can share
 RecordKey get dhtRecordKeySharing;/// Writer for the key where the contact this is the introduction for can share
 KeyPair get dhtWriterSharing;/// Optional message for the introduction
 String? get message;
/// Create a copy of ContactIntroduction
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ContactIntroductionCopyWith<ContactIntroduction> get copyWith => _$ContactIntroductionCopyWithImpl<ContactIntroduction>(this as ContactIntroduction, _$identity);

  /// Serializes this ContactIntroduction to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ContactIntroduction&&(identical(other.otherName, otherName) || other.otherName == otherName)&&(identical(other.sharedSecret, sharedSecret) || other.sharedSecret == sharedSecret)&&(identical(other.dhtRecordKeyReceiving, dhtRecordKeyReceiving) || other.dhtRecordKeyReceiving == dhtRecordKeyReceiving)&&(identical(other.dhtRecordKeySharing, dhtRecordKeySharing) || other.dhtRecordKeySharing == dhtRecordKeySharing)&&(identical(other.dhtWriterSharing, dhtWriterSharing) || other.dhtWriterSharing == dhtWriterSharing)&&(identical(other.message, message) || other.message == message));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,otherName,sharedSecret,dhtRecordKeyReceiving,dhtRecordKeySharing,dhtWriterSharing,message);

@override
String toString() {
  return 'ContactIntroduction(otherName: $otherName, sharedSecret: $sharedSecret, dhtRecordKeyReceiving: $dhtRecordKeyReceiving, dhtRecordKeySharing: $dhtRecordKeySharing, dhtWriterSharing: $dhtWriterSharing, message: $message)';
}


}

/// @nodoc
abstract mixin class $ContactIntroductionCopyWith<$Res>  {
  factory $ContactIntroductionCopyWith(ContactIntroduction value, $Res Function(ContactIntroduction) _then) = _$ContactIntroductionCopyWithImpl;
@useResult
$Res call({
 String otherName, SharedSecret sharedSecret, RecordKey dhtRecordKeyReceiving, RecordKey dhtRecordKeySharing, KeyPair dhtWriterSharing, String? message
});




}
/// @nodoc
class _$ContactIntroductionCopyWithImpl<$Res>
    implements $ContactIntroductionCopyWith<$Res> {
  _$ContactIntroductionCopyWithImpl(this._self, this._then);

  final ContactIntroduction _self;
  final $Res Function(ContactIntroduction) _then;

/// Create a copy of ContactIntroduction
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? otherName = null,Object? sharedSecret = null,Object? dhtRecordKeyReceiving = null,Object? dhtRecordKeySharing = null,Object? dhtWriterSharing = null,Object? message = freezed,}) {
  return _then(_self.copyWith(
otherName: null == otherName ? _self.otherName : otherName // ignore: cast_nullable_to_non_nullable
as String,sharedSecret: null == sharedSecret ? _self.sharedSecret : sharedSecret // ignore: cast_nullable_to_non_nullable
as SharedSecret,dhtRecordKeyReceiving: null == dhtRecordKeyReceiving ? _self.dhtRecordKeyReceiving : dhtRecordKeyReceiving // ignore: cast_nullable_to_non_nullable
as RecordKey,dhtRecordKeySharing: null == dhtRecordKeySharing ? _self.dhtRecordKeySharing : dhtRecordKeySharing // ignore: cast_nullable_to_non_nullable
as RecordKey,dhtWriterSharing: null == dhtWriterSharing ? _self.dhtWriterSharing : dhtWriterSharing // ignore: cast_nullable_to_non_nullable
as KeyPair,message: freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [ContactIntroduction].
extension ContactIntroductionPatterns on ContactIntroduction {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ContactIntroduction value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ContactIntroduction() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ContactIntroduction value)  $default,){
final _that = this;
switch (_that) {
case _ContactIntroduction():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ContactIntroduction value)?  $default,){
final _that = this;
switch (_that) {
case _ContactIntroduction() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String otherName,  SharedSecret sharedSecret,  RecordKey dhtRecordKeyReceiving,  RecordKey dhtRecordKeySharing,  KeyPair dhtWriterSharing,  String? message)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ContactIntroduction() when $default != null:
return $default(_that.otherName,_that.sharedSecret,_that.dhtRecordKeyReceiving,_that.dhtRecordKeySharing,_that.dhtWriterSharing,_that.message);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String otherName,  SharedSecret sharedSecret,  RecordKey dhtRecordKeyReceiving,  RecordKey dhtRecordKeySharing,  KeyPair dhtWriterSharing,  String? message)  $default,) {final _that = this;
switch (_that) {
case _ContactIntroduction():
return $default(_that.otherName,_that.sharedSecret,_that.dhtRecordKeyReceiving,_that.dhtRecordKeySharing,_that.dhtWriterSharing,_that.message);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String otherName,  SharedSecret sharedSecret,  RecordKey dhtRecordKeyReceiving,  RecordKey dhtRecordKeySharing,  KeyPair dhtWriterSharing,  String? message)?  $default,) {final _that = this;
switch (_that) {
case _ContactIntroduction() when $default != null:
return $default(_that.otherName,_that.sharedSecret,_that.dhtRecordKeyReceiving,_that.dhtRecordKeySharing,_that.dhtWriterSharing,_that.message);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ContactIntroduction extends ContactIntroduction {
  const _ContactIntroduction({required this.otherName, required this.sharedSecret, required this.dhtRecordKeyReceiving, required this.dhtRecordKeySharing, required this.dhtWriterSharing, this.message}): super._();
  factory _ContactIntroduction.fromJson(Map<String, dynamic> json) => _$ContactIntroductionFromJson(json);

/// Name of the contact this is not the introduction for
@override final  String otherName;
/// Initial shared secret for encrypted communication
@override final  SharedSecret sharedSecret;
/// Record key where the contact this is not the introduction for is sharing
@override final  RecordKey dhtRecordKeyReceiving;
/// Record key where the contact this is the introduction for can share
@override final  RecordKey dhtRecordKeySharing;
/// Writer for the key where the contact this is the introduction for can share
@override final  KeyPair dhtWriterSharing;
/// Optional message for the introduction
@override final  String? message;

/// Create a copy of ContactIntroduction
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ContactIntroductionCopyWith<_ContactIntroduction> get copyWith => __$ContactIntroductionCopyWithImpl<_ContactIntroduction>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ContactIntroductionToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ContactIntroduction&&(identical(other.otherName, otherName) || other.otherName == otherName)&&(identical(other.sharedSecret, sharedSecret) || other.sharedSecret == sharedSecret)&&(identical(other.dhtRecordKeyReceiving, dhtRecordKeyReceiving) || other.dhtRecordKeyReceiving == dhtRecordKeyReceiving)&&(identical(other.dhtRecordKeySharing, dhtRecordKeySharing) || other.dhtRecordKeySharing == dhtRecordKeySharing)&&(identical(other.dhtWriterSharing, dhtWriterSharing) || other.dhtWriterSharing == dhtWriterSharing)&&(identical(other.message, message) || other.message == message));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,otherName,sharedSecret,dhtRecordKeyReceiving,dhtRecordKeySharing,dhtWriterSharing,message);

@override
String toString() {
  return 'ContactIntroduction(otherName: $otherName, sharedSecret: $sharedSecret, dhtRecordKeyReceiving: $dhtRecordKeyReceiving, dhtRecordKeySharing: $dhtRecordKeySharing, dhtWriterSharing: $dhtWriterSharing, message: $message)';
}


}

/// @nodoc
abstract mixin class _$ContactIntroductionCopyWith<$Res> implements $ContactIntroductionCopyWith<$Res> {
  factory _$ContactIntroductionCopyWith(_ContactIntroduction value, $Res Function(_ContactIntroduction) _then) = __$ContactIntroductionCopyWithImpl;
@override @useResult
$Res call({
 String otherName, SharedSecret sharedSecret, RecordKey dhtRecordKeyReceiving, RecordKey dhtRecordKeySharing, KeyPair dhtWriterSharing, String? message
});




}
/// @nodoc
class __$ContactIntroductionCopyWithImpl<$Res>
    implements _$ContactIntroductionCopyWith<$Res> {
  __$ContactIntroductionCopyWithImpl(this._self, this._then);

  final _ContactIntroduction _self;
  final $Res Function(_ContactIntroduction) _then;

/// Create a copy of ContactIntroduction
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? otherName = null,Object? sharedSecret = null,Object? dhtRecordKeyReceiving = null,Object? dhtRecordKeySharing = null,Object? dhtWriterSharing = null,Object? message = freezed,}) {
  return _then(_ContactIntroduction(
otherName: null == otherName ? _self.otherName : otherName // ignore: cast_nullable_to_non_nullable
as String,sharedSecret: null == sharedSecret ? _self.sharedSecret : sharedSecret // ignore: cast_nullable_to_non_nullable
as SharedSecret,dhtRecordKeyReceiving: null == dhtRecordKeyReceiving ? _self.dhtRecordKeyReceiving : dhtRecordKeyReceiving // ignore: cast_nullable_to_non_nullable
as RecordKey,dhtRecordKeySharing: null == dhtRecordKeySharing ? _self.dhtRecordKeySharing : dhtRecordKeySharing // ignore: cast_nullable_to_non_nullable
as RecordKey,dhtWriterSharing: null == dhtWriterSharing ? _self.dhtWriterSharing : dhtWriterSharing // ignore: cast_nullable_to_non_nullable
as KeyPair,message: freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
