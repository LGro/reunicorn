// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'encrypted_communication.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$MessageWithEncryptionMetaData implements DiagnosticableTreeMixin {

/// DHT record key for recipient to share back
 RecordKey? get shareBackDHTKey;/// DHT record writer for recipient to share back
 KeyPair? get shareBackDHTWriter;/// DHT record writer of sender to support deniability of shared info
 KeyPair? get deniabilitySharingWriter;/// Base64 encoded vodozemac curve25519 one-time-key
 String? get oneTimeKey;/// JSON message
 Map<String, dynamic>? get message;
/// Create a copy of MessageWithEncryptionMetaData
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MessageWithEncryptionMetaDataCopyWith<MessageWithEncryptionMetaData> get copyWith => _$MessageWithEncryptionMetaDataCopyWithImpl<MessageWithEncryptionMetaData>(this as MessageWithEncryptionMetaData, _$identity);

  /// Serializes this MessageWithEncryptionMetaData to a JSON map.
  Map<String, dynamic> toJson();

@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'MessageWithEncryptionMetaData'))
    ..add(DiagnosticsProperty('shareBackDHTKey', shareBackDHTKey))..add(DiagnosticsProperty('shareBackDHTWriter', shareBackDHTWriter))..add(DiagnosticsProperty('deniabilitySharingWriter', deniabilitySharingWriter))..add(DiagnosticsProperty('oneTimeKey', oneTimeKey))..add(DiagnosticsProperty('message', message));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MessageWithEncryptionMetaData&&(identical(other.shareBackDHTKey, shareBackDHTKey) || other.shareBackDHTKey == shareBackDHTKey)&&(identical(other.shareBackDHTWriter, shareBackDHTWriter) || other.shareBackDHTWriter == shareBackDHTWriter)&&(identical(other.deniabilitySharingWriter, deniabilitySharingWriter) || other.deniabilitySharingWriter == deniabilitySharingWriter)&&(identical(other.oneTimeKey, oneTimeKey) || other.oneTimeKey == oneTimeKey)&&const DeepCollectionEquality().equals(other.message, message));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,shareBackDHTKey,shareBackDHTWriter,deniabilitySharingWriter,oneTimeKey,const DeepCollectionEquality().hash(message));

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'MessageWithEncryptionMetaData(shareBackDHTKey: $shareBackDHTKey, shareBackDHTWriter: $shareBackDHTWriter, deniabilitySharingWriter: $deniabilitySharingWriter, oneTimeKey: $oneTimeKey, message: $message)';
}


}

/// @nodoc
abstract mixin class $MessageWithEncryptionMetaDataCopyWith<$Res>  {
  factory $MessageWithEncryptionMetaDataCopyWith(MessageWithEncryptionMetaData value, $Res Function(MessageWithEncryptionMetaData) _then) = _$MessageWithEncryptionMetaDataCopyWithImpl;
@useResult
$Res call({
 RecordKey? shareBackDHTKey, KeyPair? shareBackDHTWriter, KeyPair? deniabilitySharingWriter, String? oneTimeKey, Map<String, dynamic>? message
});




}
/// @nodoc
class _$MessageWithEncryptionMetaDataCopyWithImpl<$Res>
    implements $MessageWithEncryptionMetaDataCopyWith<$Res> {
  _$MessageWithEncryptionMetaDataCopyWithImpl(this._self, this._then);

  final MessageWithEncryptionMetaData _self;
  final $Res Function(MessageWithEncryptionMetaData) _then;

/// Create a copy of MessageWithEncryptionMetaData
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? shareBackDHTKey = freezed,Object? shareBackDHTWriter = freezed,Object? deniabilitySharingWriter = freezed,Object? oneTimeKey = freezed,Object? message = freezed,}) {
  return _then(_self.copyWith(
shareBackDHTKey: freezed == shareBackDHTKey ? _self.shareBackDHTKey : shareBackDHTKey // ignore: cast_nullable_to_non_nullable
as RecordKey?,shareBackDHTWriter: freezed == shareBackDHTWriter ? _self.shareBackDHTWriter : shareBackDHTWriter // ignore: cast_nullable_to_non_nullable
as KeyPair?,deniabilitySharingWriter: freezed == deniabilitySharingWriter ? _self.deniabilitySharingWriter : deniabilitySharingWriter // ignore: cast_nullable_to_non_nullable
as KeyPair?,oneTimeKey: freezed == oneTimeKey ? _self.oneTimeKey : oneTimeKey // ignore: cast_nullable_to_non_nullable
as String?,message: freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,
  ));
}

}


/// Adds pattern-matching-related methods to [MessageWithEncryptionMetaData].
extension MessageWithEncryptionMetaDataPatterns on MessageWithEncryptionMetaData {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MessageWithEncryptionMetaData value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MessageWithEncryptionMetaData() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MessageWithEncryptionMetaData value)  $default,){
final _that = this;
switch (_that) {
case _MessageWithEncryptionMetaData():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MessageWithEncryptionMetaData value)?  $default,){
final _that = this;
switch (_that) {
case _MessageWithEncryptionMetaData() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( RecordKey? shareBackDHTKey,  KeyPair? shareBackDHTWriter,  KeyPair? deniabilitySharingWriter,  String? oneTimeKey,  Map<String, dynamic>? message)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MessageWithEncryptionMetaData() when $default != null:
return $default(_that.shareBackDHTKey,_that.shareBackDHTWriter,_that.deniabilitySharingWriter,_that.oneTimeKey,_that.message);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( RecordKey? shareBackDHTKey,  KeyPair? shareBackDHTWriter,  KeyPair? deniabilitySharingWriter,  String? oneTimeKey,  Map<String, dynamic>? message)  $default,) {final _that = this;
switch (_that) {
case _MessageWithEncryptionMetaData():
return $default(_that.shareBackDHTKey,_that.shareBackDHTWriter,_that.deniabilitySharingWriter,_that.oneTimeKey,_that.message);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( RecordKey? shareBackDHTKey,  KeyPair? shareBackDHTWriter,  KeyPair? deniabilitySharingWriter,  String? oneTimeKey,  Map<String, dynamic>? message)?  $default,) {final _that = this;
switch (_that) {
case _MessageWithEncryptionMetaData() when $default != null:
return $default(_that.shareBackDHTKey,_that.shareBackDHTWriter,_that.deniabilitySharingWriter,_that.oneTimeKey,_that.message);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MessageWithEncryptionMetaData extends MessageWithEncryptionMetaData with DiagnosticableTreeMixin {
  const _MessageWithEncryptionMetaData({this.shareBackDHTKey, this.shareBackDHTWriter, this.deniabilitySharingWriter, this.oneTimeKey, final  Map<String, dynamic>? message}): _message = message,super._();
  factory _MessageWithEncryptionMetaData.fromJson(Map<String, dynamic> json) => _$MessageWithEncryptionMetaDataFromJson(json);

/// DHT record key for recipient to share back
@override final  RecordKey? shareBackDHTKey;
/// DHT record writer for recipient to share back
@override final  KeyPair? shareBackDHTWriter;
/// DHT record writer of sender to support deniability of shared info
@override final  KeyPair? deniabilitySharingWriter;
/// Base64 encoded vodozemac curve25519 one-time-key
@override final  String? oneTimeKey;
/// JSON message
 final  Map<String, dynamic>? _message;
/// JSON message
@override Map<String, dynamic>? get message {
  final value = _message;
  if (value == null) return null;
  if (_message is EqualUnmodifiableMapView) return _message;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}


/// Create a copy of MessageWithEncryptionMetaData
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MessageWithEncryptionMetaDataCopyWith<_MessageWithEncryptionMetaData> get copyWith => __$MessageWithEncryptionMetaDataCopyWithImpl<_MessageWithEncryptionMetaData>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MessageWithEncryptionMetaDataToJson(this, );
}
@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'MessageWithEncryptionMetaData'))
    ..add(DiagnosticsProperty('shareBackDHTKey', shareBackDHTKey))..add(DiagnosticsProperty('shareBackDHTWriter', shareBackDHTWriter))..add(DiagnosticsProperty('deniabilitySharingWriter', deniabilitySharingWriter))..add(DiagnosticsProperty('oneTimeKey', oneTimeKey))..add(DiagnosticsProperty('message', message));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MessageWithEncryptionMetaData&&(identical(other.shareBackDHTKey, shareBackDHTKey) || other.shareBackDHTKey == shareBackDHTKey)&&(identical(other.shareBackDHTWriter, shareBackDHTWriter) || other.shareBackDHTWriter == shareBackDHTWriter)&&(identical(other.deniabilitySharingWriter, deniabilitySharingWriter) || other.deniabilitySharingWriter == deniabilitySharingWriter)&&(identical(other.oneTimeKey, oneTimeKey) || other.oneTimeKey == oneTimeKey)&&const DeepCollectionEquality().equals(other._message, _message));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,shareBackDHTKey,shareBackDHTWriter,deniabilitySharingWriter,oneTimeKey,const DeepCollectionEquality().hash(_message));

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'MessageWithEncryptionMetaData(shareBackDHTKey: $shareBackDHTKey, shareBackDHTWriter: $shareBackDHTWriter, deniabilitySharingWriter: $deniabilitySharingWriter, oneTimeKey: $oneTimeKey, message: $message)';
}


}

/// @nodoc
abstract mixin class _$MessageWithEncryptionMetaDataCopyWith<$Res> implements $MessageWithEncryptionMetaDataCopyWith<$Res> {
  factory _$MessageWithEncryptionMetaDataCopyWith(_MessageWithEncryptionMetaData value, $Res Function(_MessageWithEncryptionMetaData) _then) = __$MessageWithEncryptionMetaDataCopyWithImpl;
@override @useResult
$Res call({
 RecordKey? shareBackDHTKey, KeyPair? shareBackDHTWriter, KeyPair? deniabilitySharingWriter, String? oneTimeKey, Map<String, dynamic>? message
});




}
/// @nodoc
class __$MessageWithEncryptionMetaDataCopyWithImpl<$Res>
    implements _$MessageWithEncryptionMetaDataCopyWith<$Res> {
  __$MessageWithEncryptionMetaDataCopyWithImpl(this._self, this._then);

  final _MessageWithEncryptionMetaData _self;
  final $Res Function(_MessageWithEncryptionMetaData) _then;

/// Create a copy of MessageWithEncryptionMetaData
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? shareBackDHTKey = freezed,Object? shareBackDHTWriter = freezed,Object? deniabilitySharingWriter = freezed,Object? oneTimeKey = freezed,Object? message = freezed,}) {
  return _then(_MessageWithEncryptionMetaData(
shareBackDHTKey: freezed == shareBackDHTKey ? _self.shareBackDHTKey : shareBackDHTKey // ignore: cast_nullable_to_non_nullable
as RecordKey?,shareBackDHTWriter: freezed == shareBackDHTWriter ? _self.shareBackDHTWriter : shareBackDHTWriter // ignore: cast_nullable_to_non_nullable
as KeyPair?,deniabilitySharingWriter: freezed == deniabilitySharingWriter ? _self.deniabilitySharingWriter : deniabilitySharingWriter // ignore: cast_nullable_to_non_nullable
as KeyPair?,oneTimeKey: freezed == oneTimeKey ? _self.oneTimeKey : oneTimeKey // ignore: cast_nullable_to_non_nullable
as String?,message: freezed == message ? _self._message : message // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,
  ));
}


}

// dart format on
