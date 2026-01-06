// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'dht_communication.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$EncryptionMetaData implements DiagnosticableTreeMixin {

/// DHT record key for recipient to share back
 RecordKey? get shareBackDHTKey;/// DHT record writer for recipient to share back
 KeyPair? get shareBackDHTWriter;/// The next author public key for the recipient to use when encrypting
/// their shared back information and to try when decrypting the next update
 PublicKey? get shareBackPubKey; bool get ackHandshakeComplete;
/// Create a copy of EncryptionMetaData
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EncryptionMetaDataCopyWith<EncryptionMetaData> get copyWith => _$EncryptionMetaDataCopyWithImpl<EncryptionMetaData>(this as EncryptionMetaData, _$identity);

  /// Serializes this EncryptionMetaData to a JSON map.
  Map<String, dynamic> toJson();

@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'EncryptionMetaData'))
    ..add(DiagnosticsProperty('shareBackDHTKey', shareBackDHTKey))..add(DiagnosticsProperty('shareBackDHTWriter', shareBackDHTWriter))..add(DiagnosticsProperty('shareBackPubKey', shareBackPubKey))..add(DiagnosticsProperty('ackHandshakeComplete', ackHandshakeComplete));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EncryptionMetaData&&(identical(other.shareBackDHTKey, shareBackDHTKey) || other.shareBackDHTKey == shareBackDHTKey)&&(identical(other.shareBackDHTWriter, shareBackDHTWriter) || other.shareBackDHTWriter == shareBackDHTWriter)&&(identical(other.shareBackPubKey, shareBackPubKey) || other.shareBackPubKey == shareBackPubKey)&&(identical(other.ackHandshakeComplete, ackHandshakeComplete) || other.ackHandshakeComplete == ackHandshakeComplete));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,shareBackDHTKey,shareBackDHTWriter,shareBackPubKey,ackHandshakeComplete);

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'EncryptionMetaData(shareBackDHTKey: $shareBackDHTKey, shareBackDHTWriter: $shareBackDHTWriter, shareBackPubKey: $shareBackPubKey, ackHandshakeComplete: $ackHandshakeComplete)';
}


}

/// @nodoc
abstract mixin class $EncryptionMetaDataCopyWith<$Res>  {
  factory $EncryptionMetaDataCopyWith(EncryptionMetaData value, $Res Function(EncryptionMetaData) _then) = _$EncryptionMetaDataCopyWithImpl;
@useResult
$Res call({
 RecordKey? shareBackDHTKey, KeyPair? shareBackDHTWriter, PublicKey? shareBackPubKey, bool ackHandshakeComplete
});




}
/// @nodoc
class _$EncryptionMetaDataCopyWithImpl<$Res>
    implements $EncryptionMetaDataCopyWith<$Res> {
  _$EncryptionMetaDataCopyWithImpl(this._self, this._then);

  final EncryptionMetaData _self;
  final $Res Function(EncryptionMetaData) _then;

/// Create a copy of EncryptionMetaData
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? shareBackDHTKey = freezed,Object? shareBackDHTWriter = freezed,Object? shareBackPubKey = freezed,Object? ackHandshakeComplete = null,}) {
  return _then(_self.copyWith(
shareBackDHTKey: freezed == shareBackDHTKey ? _self.shareBackDHTKey : shareBackDHTKey // ignore: cast_nullable_to_non_nullable
as RecordKey?,shareBackDHTWriter: freezed == shareBackDHTWriter ? _self.shareBackDHTWriter : shareBackDHTWriter // ignore: cast_nullable_to_non_nullable
as KeyPair?,shareBackPubKey: freezed == shareBackPubKey ? _self.shareBackPubKey : shareBackPubKey // ignore: cast_nullable_to_non_nullable
as PublicKey?,ackHandshakeComplete: null == ackHandshakeComplete ? _self.ackHandshakeComplete : ackHandshakeComplete // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [EncryptionMetaData].
extension EncryptionMetaDataPatterns on EncryptionMetaData {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _EncryptionMetaData value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _EncryptionMetaData() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _EncryptionMetaData value)  $default,){
final _that = this;
switch (_that) {
case _EncryptionMetaData():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _EncryptionMetaData value)?  $default,){
final _that = this;
switch (_that) {
case _EncryptionMetaData() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( RecordKey? shareBackDHTKey,  KeyPair? shareBackDHTWriter,  PublicKey? shareBackPubKey,  bool ackHandshakeComplete)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _EncryptionMetaData() when $default != null:
return $default(_that.shareBackDHTKey,_that.shareBackDHTWriter,_that.shareBackPubKey,_that.ackHandshakeComplete);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( RecordKey? shareBackDHTKey,  KeyPair? shareBackDHTWriter,  PublicKey? shareBackPubKey,  bool ackHandshakeComplete)  $default,) {final _that = this;
switch (_that) {
case _EncryptionMetaData():
return $default(_that.shareBackDHTKey,_that.shareBackDHTWriter,_that.shareBackPubKey,_that.ackHandshakeComplete);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( RecordKey? shareBackDHTKey,  KeyPair? shareBackDHTWriter,  PublicKey? shareBackPubKey,  bool ackHandshakeComplete)?  $default,) {final _that = this;
switch (_that) {
case _EncryptionMetaData() when $default != null:
return $default(_that.shareBackDHTKey,_that.shareBackDHTWriter,_that.shareBackPubKey,_that.ackHandshakeComplete);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _EncryptionMetaData extends EncryptionMetaData with DiagnosticableTreeMixin {
  const _EncryptionMetaData({this.shareBackDHTKey, this.shareBackDHTWriter, this.shareBackPubKey, this.ackHandshakeComplete = false}): super._();
  factory _EncryptionMetaData.fromJson(Map<String, dynamic> json) => _$EncryptionMetaDataFromJson(json);

/// DHT record key for recipient to share back
@override final  RecordKey? shareBackDHTKey;
/// DHT record writer for recipient to share back
@override final  KeyPair? shareBackDHTWriter;
/// The next author public key for the recipient to use when encrypting
/// their shared back information and to try when decrypting the next update
@override final  PublicKey? shareBackPubKey;
@override@JsonKey() final  bool ackHandshakeComplete;

/// Create a copy of EncryptionMetaData
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EncryptionMetaDataCopyWith<_EncryptionMetaData> get copyWith => __$EncryptionMetaDataCopyWithImpl<_EncryptionMetaData>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$EncryptionMetaDataToJson(this, );
}
@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'EncryptionMetaData'))
    ..add(DiagnosticsProperty('shareBackDHTKey', shareBackDHTKey))..add(DiagnosticsProperty('shareBackDHTWriter', shareBackDHTWriter))..add(DiagnosticsProperty('shareBackPubKey', shareBackPubKey))..add(DiagnosticsProperty('ackHandshakeComplete', ackHandshakeComplete));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _EncryptionMetaData&&(identical(other.shareBackDHTKey, shareBackDHTKey) || other.shareBackDHTKey == shareBackDHTKey)&&(identical(other.shareBackDHTWriter, shareBackDHTWriter) || other.shareBackDHTWriter == shareBackDHTWriter)&&(identical(other.shareBackPubKey, shareBackPubKey) || other.shareBackPubKey == shareBackPubKey)&&(identical(other.ackHandshakeComplete, ackHandshakeComplete) || other.ackHandshakeComplete == ackHandshakeComplete));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,shareBackDHTKey,shareBackDHTWriter,shareBackPubKey,ackHandshakeComplete);

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'EncryptionMetaData(shareBackDHTKey: $shareBackDHTKey, shareBackDHTWriter: $shareBackDHTWriter, shareBackPubKey: $shareBackPubKey, ackHandshakeComplete: $ackHandshakeComplete)';
}


}

/// @nodoc
abstract mixin class _$EncryptionMetaDataCopyWith<$Res> implements $EncryptionMetaDataCopyWith<$Res> {
  factory _$EncryptionMetaDataCopyWith(_EncryptionMetaData value, $Res Function(_EncryptionMetaData) _then) = __$EncryptionMetaDataCopyWithImpl;
@override @useResult
$Res call({
 RecordKey? shareBackDHTKey, KeyPair? shareBackDHTWriter, PublicKey? shareBackPubKey, bool ackHandshakeComplete
});




}
/// @nodoc
class __$EncryptionMetaDataCopyWithImpl<$Res>
    implements _$EncryptionMetaDataCopyWith<$Res> {
  __$EncryptionMetaDataCopyWithImpl(this._self, this._then);

  final _EncryptionMetaData _self;
  final $Res Function(_EncryptionMetaData) _then;

/// Create a copy of EncryptionMetaData
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? shareBackDHTKey = freezed,Object? shareBackDHTWriter = freezed,Object? shareBackPubKey = freezed,Object? ackHandshakeComplete = null,}) {
  return _then(_EncryptionMetaData(
shareBackDHTKey: freezed == shareBackDHTKey ? _self.shareBackDHTKey : shareBackDHTKey // ignore: cast_nullable_to_non_nullable
as RecordKey?,shareBackDHTWriter: freezed == shareBackDHTWriter ? _self.shareBackDHTWriter : shareBackDHTWriter // ignore: cast_nullable_to_non_nullable
as KeyPair?,shareBackPubKey: freezed == shareBackPubKey ? _self.shareBackPubKey : shareBackPubKey // ignore: cast_nullable_to_non_nullable
as PublicKey?,ackHandshakeComplete: null == ackHandshakeComplete ? _self.ackHandshakeComplete : ackHandshakeComplete // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
