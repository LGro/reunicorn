// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'identity_instance.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$IdentityInstance {

// Private DHT record storing identity account mapping
 RecordKey get recordKey;// Public key of identity instance
@JsonKey(name: 'public_key') BarePublicKey get barePublicKey;// Secret key of identity instance
// Encrypted with appended salt, key is DeriveSharedSecret(
//    password = SuperIdentity.secret,
//    salt = publicKey)
// Used to recover accounts without generating a new instance
@Uint8ListJsonConverter() Uint8List get encryptedSecretKey;// Signature of SuperInstance recordKey and SuperInstance publicKey
// by publicKey
@JsonKey(name: 'super_signature') BareSignature get bareSuperSignature;// Signature of recordKey, publicKey, encryptedSecretKey, and superSignature
// by SuperIdentity publicKey
@JsonKey(name: 'signature') BareSignature get bareSignature;
/// Create a copy of IdentityInstance
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$IdentityInstanceCopyWith<IdentityInstance> get copyWith => _$IdentityInstanceCopyWithImpl<IdentityInstance>(this as IdentityInstance, _$identity);

  /// Serializes this IdentityInstance to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is IdentityInstance&&(identical(other.recordKey, recordKey) || other.recordKey == recordKey)&&(identical(other.barePublicKey, barePublicKey) || other.barePublicKey == barePublicKey)&&const DeepCollectionEquality().equals(other.encryptedSecretKey, encryptedSecretKey)&&(identical(other.bareSuperSignature, bareSuperSignature) || other.bareSuperSignature == bareSuperSignature)&&(identical(other.bareSignature, bareSignature) || other.bareSignature == bareSignature));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,recordKey,barePublicKey,const DeepCollectionEquality().hash(encryptedSecretKey),bareSuperSignature,bareSignature);

@override
String toString() {
  return 'IdentityInstance(recordKey: $recordKey, barePublicKey: $barePublicKey, encryptedSecretKey: $encryptedSecretKey, bareSuperSignature: $bareSuperSignature, bareSignature: $bareSignature)';
}


}

/// @nodoc
abstract mixin class $IdentityInstanceCopyWith<$Res>  {
  factory $IdentityInstanceCopyWith(IdentityInstance value, $Res Function(IdentityInstance) _then) = _$IdentityInstanceCopyWithImpl;
@useResult
$Res call({
 RecordKey recordKey,@JsonKey(name: 'public_key') BarePublicKey barePublicKey,@Uint8ListJsonConverter() Uint8List encryptedSecretKey,@JsonKey(name: 'super_signature') BareSignature bareSuperSignature,@JsonKey(name: 'signature') BareSignature bareSignature
});




}
/// @nodoc
class _$IdentityInstanceCopyWithImpl<$Res>
    implements $IdentityInstanceCopyWith<$Res> {
  _$IdentityInstanceCopyWithImpl(this._self, this._then);

  final IdentityInstance _self;
  final $Res Function(IdentityInstance) _then;

/// Create a copy of IdentityInstance
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? recordKey = null,Object? barePublicKey = null,Object? encryptedSecretKey = null,Object? bareSuperSignature = null,Object? bareSignature = null,}) {
  return _then(_self.copyWith(
recordKey: null == recordKey ? _self.recordKey : recordKey // ignore: cast_nullable_to_non_nullable
as RecordKey,barePublicKey: null == barePublicKey ? _self.barePublicKey : barePublicKey // ignore: cast_nullable_to_non_nullable
as BarePublicKey,encryptedSecretKey: null == encryptedSecretKey ? _self.encryptedSecretKey : encryptedSecretKey // ignore: cast_nullable_to_non_nullable
as Uint8List,bareSuperSignature: null == bareSuperSignature ? _self.bareSuperSignature : bareSuperSignature // ignore: cast_nullable_to_non_nullable
as BareSignature,bareSignature: null == bareSignature ? _self.bareSignature : bareSignature // ignore: cast_nullable_to_non_nullable
as BareSignature,
  ));
}

}


/// Adds pattern-matching-related methods to [IdentityInstance].
extension IdentityInstancePatterns on IdentityInstance {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _IdentityInstance value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _IdentityInstance() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _IdentityInstance value)  $default,){
final _that = this;
switch (_that) {
case _IdentityInstance():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _IdentityInstance value)?  $default,){
final _that = this;
switch (_that) {
case _IdentityInstance() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( RecordKey recordKey, @JsonKey(name: 'public_key')  BarePublicKey barePublicKey, @Uint8ListJsonConverter()  Uint8List encryptedSecretKey, @JsonKey(name: 'super_signature')  BareSignature bareSuperSignature, @JsonKey(name: 'signature')  BareSignature bareSignature)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _IdentityInstance() when $default != null:
return $default(_that.recordKey,_that.barePublicKey,_that.encryptedSecretKey,_that.bareSuperSignature,_that.bareSignature);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( RecordKey recordKey, @JsonKey(name: 'public_key')  BarePublicKey barePublicKey, @Uint8ListJsonConverter()  Uint8List encryptedSecretKey, @JsonKey(name: 'super_signature')  BareSignature bareSuperSignature, @JsonKey(name: 'signature')  BareSignature bareSignature)  $default,) {final _that = this;
switch (_that) {
case _IdentityInstance():
return $default(_that.recordKey,_that.barePublicKey,_that.encryptedSecretKey,_that.bareSuperSignature,_that.bareSignature);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( RecordKey recordKey, @JsonKey(name: 'public_key')  BarePublicKey barePublicKey, @Uint8ListJsonConverter()  Uint8List encryptedSecretKey, @JsonKey(name: 'super_signature')  BareSignature bareSuperSignature, @JsonKey(name: 'signature')  BareSignature bareSignature)?  $default,) {final _that = this;
switch (_that) {
case _IdentityInstance() when $default != null:
return $default(_that.recordKey,_that.barePublicKey,_that.encryptedSecretKey,_that.bareSuperSignature,_that.bareSignature);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _IdentityInstance extends IdentityInstance {
  const _IdentityInstance({required this.recordKey, @JsonKey(name: 'public_key') required this.barePublicKey, @Uint8ListJsonConverter() required this.encryptedSecretKey, @JsonKey(name: 'super_signature') required this.bareSuperSignature, @JsonKey(name: 'signature') required this.bareSignature}): super._();
  factory _IdentityInstance.fromJson(Map<String, dynamic> json) => _$IdentityInstanceFromJson(json);

// Private DHT record storing identity account mapping
@override final  RecordKey recordKey;
// Public key of identity instance
@override@JsonKey(name: 'public_key') final  BarePublicKey barePublicKey;
// Secret key of identity instance
// Encrypted with appended salt, key is DeriveSharedSecret(
//    password = SuperIdentity.secret,
//    salt = publicKey)
// Used to recover accounts without generating a new instance
@override@Uint8ListJsonConverter() final  Uint8List encryptedSecretKey;
// Signature of SuperInstance recordKey and SuperInstance publicKey
// by publicKey
@override@JsonKey(name: 'super_signature') final  BareSignature bareSuperSignature;
// Signature of recordKey, publicKey, encryptedSecretKey, and superSignature
// by SuperIdentity publicKey
@override@JsonKey(name: 'signature') final  BareSignature bareSignature;

/// Create a copy of IdentityInstance
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$IdentityInstanceCopyWith<_IdentityInstance> get copyWith => __$IdentityInstanceCopyWithImpl<_IdentityInstance>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$IdentityInstanceToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _IdentityInstance&&(identical(other.recordKey, recordKey) || other.recordKey == recordKey)&&(identical(other.barePublicKey, barePublicKey) || other.barePublicKey == barePublicKey)&&const DeepCollectionEquality().equals(other.encryptedSecretKey, encryptedSecretKey)&&(identical(other.bareSuperSignature, bareSuperSignature) || other.bareSuperSignature == bareSuperSignature)&&(identical(other.bareSignature, bareSignature) || other.bareSignature == bareSignature));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,recordKey,barePublicKey,const DeepCollectionEquality().hash(encryptedSecretKey),bareSuperSignature,bareSignature);

@override
String toString() {
  return 'IdentityInstance(recordKey: $recordKey, barePublicKey: $barePublicKey, encryptedSecretKey: $encryptedSecretKey, bareSuperSignature: $bareSuperSignature, bareSignature: $bareSignature)';
}


}

/// @nodoc
abstract mixin class _$IdentityInstanceCopyWith<$Res> implements $IdentityInstanceCopyWith<$Res> {
  factory _$IdentityInstanceCopyWith(_IdentityInstance value, $Res Function(_IdentityInstance) _then) = __$IdentityInstanceCopyWithImpl;
@override @useResult
$Res call({
 RecordKey recordKey,@JsonKey(name: 'public_key') BarePublicKey barePublicKey,@Uint8ListJsonConverter() Uint8List encryptedSecretKey,@JsonKey(name: 'super_signature') BareSignature bareSuperSignature,@JsonKey(name: 'signature') BareSignature bareSignature
});




}
/// @nodoc
class __$IdentityInstanceCopyWithImpl<$Res>
    implements _$IdentityInstanceCopyWith<$Res> {
  __$IdentityInstanceCopyWithImpl(this._self, this._then);

  final _IdentityInstance _self;
  final $Res Function(_IdentityInstance) _then;

/// Create a copy of IdentityInstance
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? recordKey = null,Object? barePublicKey = null,Object? encryptedSecretKey = null,Object? bareSuperSignature = null,Object? bareSignature = null,}) {
  return _then(_IdentityInstance(
recordKey: null == recordKey ? _self.recordKey : recordKey // ignore: cast_nullable_to_non_nullable
as RecordKey,barePublicKey: null == barePublicKey ? _self.barePublicKey : barePublicKey // ignore: cast_nullable_to_non_nullable
as BarePublicKey,encryptedSecretKey: null == encryptedSecretKey ? _self.encryptedSecretKey : encryptedSecretKey // ignore: cast_nullable_to_non_nullable
as Uint8List,bareSuperSignature: null == bareSuperSignature ? _self.bareSuperSignature : bareSuperSignature // ignore: cast_nullable_to_non_nullable
as BareSignature,bareSignature: null == bareSignature ? _self.bareSignature : bareSignature // ignore: cast_nullable_to_non_nullable
as BareSignature,
  ));
}


}

// dart format on
