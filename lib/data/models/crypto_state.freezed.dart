// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'crypto_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
CryptoState _$CryptoStateFromJson(
  Map<String, dynamic> json
) {
        switch (json['runtimeType']) {
                  case 'initializedSymmetric':
          return CryptoInitializedSymmetric.fromJson(
            json
          );
                case 'establishedSymmetric':
          return CryptoEstablishedSymmetric.fromJson(
            json
          );
                case 'pendingAsymmetric':
          return CryptoPendingAsymmetric.fromJson(
            json
          );
                case 'initializedAsymmetric':
          return CryptoInitializedAsymmetric.fromJson(
            json
          );
                case 'establishedAsymmetric':
          return CryptoEstablishedAsymmetric.fromJson(
            json
          );
        
          default:
            throw CheckedFromJsonException(
  json,
  'runtimeType',
  'CryptoState',
  'Invalid union type "${json['runtimeType']}"!'
);
        }
      
}

/// @nodoc
mixin _$CryptoState {

/// My key pair for transition to asymmetric cryptography
 KeyPair get myNextKeyPair;
/// Create a copy of CryptoState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CryptoStateCopyWith<CryptoState> get copyWith => _$CryptoStateCopyWithImpl<CryptoState>(this as CryptoState, _$identity);

  /// Serializes this CryptoState to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CryptoState&&(identical(other.myNextKeyPair, myNextKeyPair) || other.myNextKeyPair == myNextKeyPair));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,myNextKeyPair);

@override
String toString() {
  return 'CryptoState(myNextKeyPair: $myNextKeyPair)';
}


}

/// @nodoc
abstract mixin class $CryptoStateCopyWith<$Res>  {
  factory $CryptoStateCopyWith(CryptoState value, $Res Function(CryptoState) _then) = _$CryptoStateCopyWithImpl;
@useResult
$Res call({
 KeyPair myNextKeyPair
});




}
/// @nodoc
class _$CryptoStateCopyWithImpl<$Res>
    implements $CryptoStateCopyWith<$Res> {
  _$CryptoStateCopyWithImpl(this._self, this._then);

  final CryptoState _self;
  final $Res Function(CryptoState) _then;

/// Create a copy of CryptoState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? myNextKeyPair = null,}) {
  return _then(_self.copyWith(
myNextKeyPair: null == myNextKeyPair ? _self.myNextKeyPair : myNextKeyPair // ignore: cast_nullable_to_non_nullable
as KeyPair,
  ));
}

}


/// Adds pattern-matching-related methods to [CryptoState].
extension CryptoStatePatterns on CryptoState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( CryptoInitializedSymmetric value)?  initializedSymmetric,TResult Function( CryptoEstablishedSymmetric value)?  establishedSymmetric,TResult Function( CryptoPendingAsymmetric value)?  pendingAsymmetric,TResult Function( CryptoInitializedAsymmetric value)?  initializedAsymmetric,TResult Function( CryptoEstablishedAsymmetric value)?  establishedAsymmetric,required TResult orElse(),}){
final _that = this;
switch (_that) {
case CryptoInitializedSymmetric() when initializedSymmetric != null:
return initializedSymmetric(_that);case CryptoEstablishedSymmetric() when establishedSymmetric != null:
return establishedSymmetric(_that);case CryptoPendingAsymmetric() when pendingAsymmetric != null:
return pendingAsymmetric(_that);case CryptoInitializedAsymmetric() when initializedAsymmetric != null:
return initializedAsymmetric(_that);case CryptoEstablishedAsymmetric() when establishedAsymmetric != null:
return establishedAsymmetric(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( CryptoInitializedSymmetric value)  initializedSymmetric,required TResult Function( CryptoEstablishedSymmetric value)  establishedSymmetric,required TResult Function( CryptoPendingAsymmetric value)  pendingAsymmetric,required TResult Function( CryptoInitializedAsymmetric value)  initializedAsymmetric,required TResult Function( CryptoEstablishedAsymmetric value)  establishedAsymmetric,}){
final _that = this;
switch (_that) {
case CryptoInitializedSymmetric():
return initializedSymmetric(_that);case CryptoEstablishedSymmetric():
return establishedSymmetric(_that);case CryptoPendingAsymmetric():
return pendingAsymmetric(_that);case CryptoInitializedAsymmetric():
return initializedAsymmetric(_that);case CryptoEstablishedAsymmetric():
return establishedAsymmetric(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( CryptoInitializedSymmetric value)?  initializedSymmetric,TResult? Function( CryptoEstablishedSymmetric value)?  establishedSymmetric,TResult? Function( CryptoPendingAsymmetric value)?  pendingAsymmetric,TResult? Function( CryptoInitializedAsymmetric value)?  initializedAsymmetric,TResult? Function( CryptoEstablishedAsymmetric value)?  establishedAsymmetric,}){
final _that = this;
switch (_that) {
case CryptoInitializedSymmetric() when initializedSymmetric != null:
return initializedSymmetric(_that);case CryptoEstablishedSymmetric() when establishedSymmetric != null:
return establishedSymmetric(_that);case CryptoPendingAsymmetric() when pendingAsymmetric != null:
return pendingAsymmetric(_that);case CryptoInitializedAsymmetric() when initializedAsymmetric != null:
return initializedAsymmetric(_that);case CryptoEstablishedAsymmetric() when establishedAsymmetric != null:
return establishedAsymmetric(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( SharedSecret initialSharedSecret,  KeyPair myNextKeyPair)?  initializedSymmetric,TResult Function( SharedSecret initialSharedSecret,  KeyPair myNextKeyPair,  PublicKey theirNextPublicKey)?  establishedSymmetric,TResult Function( KeyPair myNextKeyPair)?  pendingAsymmetric,TResult Function( SharedSecret initialSharedSecret,  KeyPair myKeyPair,  KeyPair myNextKeyPair,  PublicKey theirNextPublicKey)?  initializedAsymmetric,TResult Function( KeyPair myKeyPair,  KeyPair myNextKeyPair,  PublicKey theirPublicKey,  PublicKey theirNextPublicKey)?  establishedAsymmetric,required TResult orElse(),}) {final _that = this;
switch (_that) {
case CryptoInitializedSymmetric() when initializedSymmetric != null:
return initializedSymmetric(_that.initialSharedSecret,_that.myNextKeyPair);case CryptoEstablishedSymmetric() when establishedSymmetric != null:
return establishedSymmetric(_that.initialSharedSecret,_that.myNextKeyPair,_that.theirNextPublicKey);case CryptoPendingAsymmetric() when pendingAsymmetric != null:
return pendingAsymmetric(_that.myNextKeyPair);case CryptoInitializedAsymmetric() when initializedAsymmetric != null:
return initializedAsymmetric(_that.initialSharedSecret,_that.myKeyPair,_that.myNextKeyPair,_that.theirNextPublicKey);case CryptoEstablishedAsymmetric() when establishedAsymmetric != null:
return establishedAsymmetric(_that.myKeyPair,_that.myNextKeyPair,_that.theirPublicKey,_that.theirNextPublicKey);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( SharedSecret initialSharedSecret,  KeyPair myNextKeyPair)  initializedSymmetric,required TResult Function( SharedSecret initialSharedSecret,  KeyPair myNextKeyPair,  PublicKey theirNextPublicKey)  establishedSymmetric,required TResult Function( KeyPair myNextKeyPair)  pendingAsymmetric,required TResult Function( SharedSecret initialSharedSecret,  KeyPair myKeyPair,  KeyPair myNextKeyPair,  PublicKey theirNextPublicKey)  initializedAsymmetric,required TResult Function( KeyPair myKeyPair,  KeyPair myNextKeyPair,  PublicKey theirPublicKey,  PublicKey theirNextPublicKey)  establishedAsymmetric,}) {final _that = this;
switch (_that) {
case CryptoInitializedSymmetric():
return initializedSymmetric(_that.initialSharedSecret,_that.myNextKeyPair);case CryptoEstablishedSymmetric():
return establishedSymmetric(_that.initialSharedSecret,_that.myNextKeyPair,_that.theirNextPublicKey);case CryptoPendingAsymmetric():
return pendingAsymmetric(_that.myNextKeyPair);case CryptoInitializedAsymmetric():
return initializedAsymmetric(_that.initialSharedSecret,_that.myKeyPair,_that.myNextKeyPair,_that.theirNextPublicKey);case CryptoEstablishedAsymmetric():
return establishedAsymmetric(_that.myKeyPair,_that.myNextKeyPair,_that.theirPublicKey,_that.theirNextPublicKey);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( SharedSecret initialSharedSecret,  KeyPair myNextKeyPair)?  initializedSymmetric,TResult? Function( SharedSecret initialSharedSecret,  KeyPair myNextKeyPair,  PublicKey theirNextPublicKey)?  establishedSymmetric,TResult? Function( KeyPair myNextKeyPair)?  pendingAsymmetric,TResult? Function( SharedSecret initialSharedSecret,  KeyPair myKeyPair,  KeyPair myNextKeyPair,  PublicKey theirNextPublicKey)?  initializedAsymmetric,TResult? Function( KeyPair myKeyPair,  KeyPair myNextKeyPair,  PublicKey theirPublicKey,  PublicKey theirNextPublicKey)?  establishedAsymmetric,}) {final _that = this;
switch (_that) {
case CryptoInitializedSymmetric() when initializedSymmetric != null:
return initializedSymmetric(_that.initialSharedSecret,_that.myNextKeyPair);case CryptoEstablishedSymmetric() when establishedSymmetric != null:
return establishedSymmetric(_that.initialSharedSecret,_that.myNextKeyPair,_that.theirNextPublicKey);case CryptoPendingAsymmetric() when pendingAsymmetric != null:
return pendingAsymmetric(_that.myNextKeyPair);case CryptoInitializedAsymmetric() when initializedAsymmetric != null:
return initializedAsymmetric(_that.initialSharedSecret,_that.myKeyPair,_that.myNextKeyPair,_that.theirNextPublicKey);case CryptoEstablishedAsymmetric() when establishedAsymmetric != null:
return establishedAsymmetric(_that.myKeyPair,_that.myNextKeyPair,_that.theirPublicKey,_that.theirNextPublicKey);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class CryptoInitializedSymmetric implements CryptoState {
  const CryptoInitializedSymmetric({required this.initialSharedSecret, required this.myNextKeyPair, final  String? $type}): $type = $type ?? 'initializedSymmetric';
  factory CryptoInitializedSymmetric.fromJson(Map<String, dynamic> json) => _$CryptoInitializedSymmetricFromJson(json);

/// Initial shared secret for symmetric cryptography
 final  SharedSecret initialSharedSecret;
/// My key pair for transition to asymmetric cryptography
@override final  KeyPair myNextKeyPair;

@JsonKey(name: 'runtimeType')
final String $type;


/// Create a copy of CryptoState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CryptoInitializedSymmetricCopyWith<CryptoInitializedSymmetric> get copyWith => _$CryptoInitializedSymmetricCopyWithImpl<CryptoInitializedSymmetric>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CryptoInitializedSymmetricToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CryptoInitializedSymmetric&&(identical(other.initialSharedSecret, initialSharedSecret) || other.initialSharedSecret == initialSharedSecret)&&(identical(other.myNextKeyPair, myNextKeyPair) || other.myNextKeyPair == myNextKeyPair));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,initialSharedSecret,myNextKeyPair);

@override
String toString() {
  return 'CryptoState.initializedSymmetric(initialSharedSecret: $initialSharedSecret, myNextKeyPair: $myNextKeyPair)';
}


}

/// @nodoc
abstract mixin class $CryptoInitializedSymmetricCopyWith<$Res> implements $CryptoStateCopyWith<$Res> {
  factory $CryptoInitializedSymmetricCopyWith(CryptoInitializedSymmetric value, $Res Function(CryptoInitializedSymmetric) _then) = _$CryptoInitializedSymmetricCopyWithImpl;
@override @useResult
$Res call({
 SharedSecret initialSharedSecret, KeyPair myNextKeyPair
});




}
/// @nodoc
class _$CryptoInitializedSymmetricCopyWithImpl<$Res>
    implements $CryptoInitializedSymmetricCopyWith<$Res> {
  _$CryptoInitializedSymmetricCopyWithImpl(this._self, this._then);

  final CryptoInitializedSymmetric _self;
  final $Res Function(CryptoInitializedSymmetric) _then;

/// Create a copy of CryptoState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? initialSharedSecret = null,Object? myNextKeyPair = null,}) {
  return _then(CryptoInitializedSymmetric(
initialSharedSecret: null == initialSharedSecret ? _self.initialSharedSecret : initialSharedSecret // ignore: cast_nullable_to_non_nullable
as SharedSecret,myNextKeyPair: null == myNextKeyPair ? _self.myNextKeyPair : myNextKeyPair // ignore: cast_nullable_to_non_nullable
as KeyPair,
  ));
}


}

/// @nodoc
@JsonSerializable()

class CryptoEstablishedSymmetric implements CryptoState {
  const CryptoEstablishedSymmetric({required this.initialSharedSecret, required this.myNextKeyPair, required this.theirNextPublicKey, final  String? $type}): $type = $type ?? 'establishedSymmetric';
  factory CryptoEstablishedSymmetric.fromJson(Map<String, dynamic> json) => _$CryptoEstablishedSymmetricFromJson(json);

/// Initial shared secret for symmetric cryptography
 final  SharedSecret initialSharedSecret;
/// My key pair for transition to asymmetric cryptography
@override final  KeyPair myNextKeyPair;
/// Their public key for transition to asymmetric cryptography
 final  PublicKey theirNextPublicKey;

@JsonKey(name: 'runtimeType')
final String $type;


/// Create a copy of CryptoState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CryptoEstablishedSymmetricCopyWith<CryptoEstablishedSymmetric> get copyWith => _$CryptoEstablishedSymmetricCopyWithImpl<CryptoEstablishedSymmetric>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CryptoEstablishedSymmetricToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CryptoEstablishedSymmetric&&(identical(other.initialSharedSecret, initialSharedSecret) || other.initialSharedSecret == initialSharedSecret)&&(identical(other.myNextKeyPair, myNextKeyPair) || other.myNextKeyPair == myNextKeyPair)&&(identical(other.theirNextPublicKey, theirNextPublicKey) || other.theirNextPublicKey == theirNextPublicKey));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,initialSharedSecret,myNextKeyPair,theirNextPublicKey);

@override
String toString() {
  return 'CryptoState.establishedSymmetric(initialSharedSecret: $initialSharedSecret, myNextKeyPair: $myNextKeyPair, theirNextPublicKey: $theirNextPublicKey)';
}


}

/// @nodoc
abstract mixin class $CryptoEstablishedSymmetricCopyWith<$Res> implements $CryptoStateCopyWith<$Res> {
  factory $CryptoEstablishedSymmetricCopyWith(CryptoEstablishedSymmetric value, $Res Function(CryptoEstablishedSymmetric) _then) = _$CryptoEstablishedSymmetricCopyWithImpl;
@override @useResult
$Res call({
 SharedSecret initialSharedSecret, KeyPair myNextKeyPair, PublicKey theirNextPublicKey
});




}
/// @nodoc
class _$CryptoEstablishedSymmetricCopyWithImpl<$Res>
    implements $CryptoEstablishedSymmetricCopyWith<$Res> {
  _$CryptoEstablishedSymmetricCopyWithImpl(this._self, this._then);

  final CryptoEstablishedSymmetric _self;
  final $Res Function(CryptoEstablishedSymmetric) _then;

/// Create a copy of CryptoState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? initialSharedSecret = null,Object? myNextKeyPair = null,Object? theirNextPublicKey = null,}) {
  return _then(CryptoEstablishedSymmetric(
initialSharedSecret: null == initialSharedSecret ? _self.initialSharedSecret : initialSharedSecret // ignore: cast_nullable_to_non_nullable
as SharedSecret,myNextKeyPair: null == myNextKeyPair ? _self.myNextKeyPair : myNextKeyPair // ignore: cast_nullable_to_non_nullable
as KeyPair,theirNextPublicKey: null == theirNextPublicKey ? _self.theirNextPublicKey : theirNextPublicKey // ignore: cast_nullable_to_non_nullable
as PublicKey,
  ));
}


}

/// @nodoc
@JsonSerializable()

class CryptoPendingAsymmetric implements CryptoState {
  const CryptoPendingAsymmetric({required this.myNextKeyPair, final  String? $type}): $type = $type ?? 'pendingAsymmetric';
  factory CryptoPendingAsymmetric.fromJson(Map<String, dynamic> json) => _$CryptoPendingAsymmetricFromJson(json);

/// My key pair for asymmetric cryptography
@override final  KeyPair myNextKeyPair;

@JsonKey(name: 'runtimeType')
final String $type;


/// Create a copy of CryptoState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CryptoPendingAsymmetricCopyWith<CryptoPendingAsymmetric> get copyWith => _$CryptoPendingAsymmetricCopyWithImpl<CryptoPendingAsymmetric>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CryptoPendingAsymmetricToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CryptoPendingAsymmetric&&(identical(other.myNextKeyPair, myNextKeyPair) || other.myNextKeyPair == myNextKeyPair));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,myNextKeyPair);

@override
String toString() {
  return 'CryptoState.pendingAsymmetric(myNextKeyPair: $myNextKeyPair)';
}


}

/// @nodoc
abstract mixin class $CryptoPendingAsymmetricCopyWith<$Res> implements $CryptoStateCopyWith<$Res> {
  factory $CryptoPendingAsymmetricCopyWith(CryptoPendingAsymmetric value, $Res Function(CryptoPendingAsymmetric) _then) = _$CryptoPendingAsymmetricCopyWithImpl;
@override @useResult
$Res call({
 KeyPair myNextKeyPair
});




}
/// @nodoc
class _$CryptoPendingAsymmetricCopyWithImpl<$Res>
    implements $CryptoPendingAsymmetricCopyWith<$Res> {
  _$CryptoPendingAsymmetricCopyWithImpl(this._self, this._then);

  final CryptoPendingAsymmetric _self;
  final $Res Function(CryptoPendingAsymmetric) _then;

/// Create a copy of CryptoState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? myNextKeyPair = null,}) {
  return _then(CryptoPendingAsymmetric(
myNextKeyPair: null == myNextKeyPair ? _self.myNextKeyPair : myNextKeyPair // ignore: cast_nullable_to_non_nullable
as KeyPair,
  ));
}


}

/// @nodoc
@JsonSerializable()

class CryptoInitializedAsymmetric implements CryptoState {
  const CryptoInitializedAsymmetric({required this.initialSharedSecret, required this.myKeyPair, required this.myNextKeyPair, required this.theirNextPublicKey, final  String? $type}): $type = $type ?? 'initializedAsymmetric';
  factory CryptoInitializedAsymmetric.fromJson(Map<String, dynamic> json) => _$CryptoInitializedAsymmetricFromJson(json);

/// Initial shared secret for symmetric cryptography
 final  SharedSecret initialSharedSecret;
/// My key pair, of which they used the public key successfully
 final  KeyPair myKeyPair;
/// My key pair for transition to asymmetric cryptography
@override final  KeyPair myNextKeyPair;
/// Their public key for transition to asymmetric cryptography
 final  PublicKey theirNextPublicKey;

@JsonKey(name: 'runtimeType')
final String $type;


/// Create a copy of CryptoState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CryptoInitializedAsymmetricCopyWith<CryptoInitializedAsymmetric> get copyWith => _$CryptoInitializedAsymmetricCopyWithImpl<CryptoInitializedAsymmetric>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CryptoInitializedAsymmetricToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CryptoInitializedAsymmetric&&(identical(other.initialSharedSecret, initialSharedSecret) || other.initialSharedSecret == initialSharedSecret)&&(identical(other.myKeyPair, myKeyPair) || other.myKeyPair == myKeyPair)&&(identical(other.myNextKeyPair, myNextKeyPair) || other.myNextKeyPair == myNextKeyPair)&&(identical(other.theirNextPublicKey, theirNextPublicKey) || other.theirNextPublicKey == theirNextPublicKey));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,initialSharedSecret,myKeyPair,myNextKeyPair,theirNextPublicKey);

@override
String toString() {
  return 'CryptoState.initializedAsymmetric(initialSharedSecret: $initialSharedSecret, myKeyPair: $myKeyPair, myNextKeyPair: $myNextKeyPair, theirNextPublicKey: $theirNextPublicKey)';
}


}

/// @nodoc
abstract mixin class $CryptoInitializedAsymmetricCopyWith<$Res> implements $CryptoStateCopyWith<$Res> {
  factory $CryptoInitializedAsymmetricCopyWith(CryptoInitializedAsymmetric value, $Res Function(CryptoInitializedAsymmetric) _then) = _$CryptoInitializedAsymmetricCopyWithImpl;
@override @useResult
$Res call({
 SharedSecret initialSharedSecret, KeyPair myKeyPair, KeyPair myNextKeyPair, PublicKey theirNextPublicKey
});




}
/// @nodoc
class _$CryptoInitializedAsymmetricCopyWithImpl<$Res>
    implements $CryptoInitializedAsymmetricCopyWith<$Res> {
  _$CryptoInitializedAsymmetricCopyWithImpl(this._self, this._then);

  final CryptoInitializedAsymmetric _self;
  final $Res Function(CryptoInitializedAsymmetric) _then;

/// Create a copy of CryptoState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? initialSharedSecret = null,Object? myKeyPair = null,Object? myNextKeyPair = null,Object? theirNextPublicKey = null,}) {
  return _then(CryptoInitializedAsymmetric(
initialSharedSecret: null == initialSharedSecret ? _self.initialSharedSecret : initialSharedSecret // ignore: cast_nullable_to_non_nullable
as SharedSecret,myKeyPair: null == myKeyPair ? _self.myKeyPair : myKeyPair // ignore: cast_nullable_to_non_nullable
as KeyPair,myNextKeyPair: null == myNextKeyPair ? _self.myNextKeyPair : myNextKeyPair // ignore: cast_nullable_to_non_nullable
as KeyPair,theirNextPublicKey: null == theirNextPublicKey ? _self.theirNextPublicKey : theirNextPublicKey // ignore: cast_nullable_to_non_nullable
as PublicKey,
  ));
}


}

/// @nodoc
@JsonSerializable()

class CryptoEstablishedAsymmetric implements CryptoState {
  const CryptoEstablishedAsymmetric({required this.myKeyPair, required this.myNextKeyPair, required this.theirPublicKey, required this.theirNextPublicKey, final  String? $type}): $type = $type ?? 'establishedAsymmetric';
  factory CryptoEstablishedAsymmetric.fromJson(Map<String, dynamic> json) => _$CryptoEstablishedAsymmetricFromJson(json);

/// My key pair, of which they used the public key successfully
 final  KeyPair myKeyPair;
/// My key pair for the next rotation
@override final  KeyPair myNextKeyPair;
/// Their public key I used successfully
 final  PublicKey theirPublicKey;
/// Their public key for the next rotation
 final  PublicKey theirNextPublicKey;

@JsonKey(name: 'runtimeType')
final String $type;


/// Create a copy of CryptoState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CryptoEstablishedAsymmetricCopyWith<CryptoEstablishedAsymmetric> get copyWith => _$CryptoEstablishedAsymmetricCopyWithImpl<CryptoEstablishedAsymmetric>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CryptoEstablishedAsymmetricToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CryptoEstablishedAsymmetric&&(identical(other.myKeyPair, myKeyPair) || other.myKeyPair == myKeyPair)&&(identical(other.myNextKeyPair, myNextKeyPair) || other.myNextKeyPair == myNextKeyPair)&&(identical(other.theirPublicKey, theirPublicKey) || other.theirPublicKey == theirPublicKey)&&(identical(other.theirNextPublicKey, theirNextPublicKey) || other.theirNextPublicKey == theirNextPublicKey));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,myKeyPair,myNextKeyPair,theirPublicKey,theirNextPublicKey);

@override
String toString() {
  return 'CryptoState.establishedAsymmetric(myKeyPair: $myKeyPair, myNextKeyPair: $myNextKeyPair, theirPublicKey: $theirPublicKey, theirNextPublicKey: $theirNextPublicKey)';
}


}

/// @nodoc
abstract mixin class $CryptoEstablishedAsymmetricCopyWith<$Res> implements $CryptoStateCopyWith<$Res> {
  factory $CryptoEstablishedAsymmetricCopyWith(CryptoEstablishedAsymmetric value, $Res Function(CryptoEstablishedAsymmetric) _then) = _$CryptoEstablishedAsymmetricCopyWithImpl;
@override @useResult
$Res call({
 KeyPair myKeyPair, KeyPair myNextKeyPair, PublicKey theirPublicKey, PublicKey theirNextPublicKey
});




}
/// @nodoc
class _$CryptoEstablishedAsymmetricCopyWithImpl<$Res>
    implements $CryptoEstablishedAsymmetricCopyWith<$Res> {
  _$CryptoEstablishedAsymmetricCopyWithImpl(this._self, this._then);

  final CryptoEstablishedAsymmetric _self;
  final $Res Function(CryptoEstablishedAsymmetric) _then;

/// Create a copy of CryptoState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? myKeyPair = null,Object? myNextKeyPair = null,Object? theirPublicKey = null,Object? theirNextPublicKey = null,}) {
  return _then(CryptoEstablishedAsymmetric(
myKeyPair: null == myKeyPair ? _self.myKeyPair : myKeyPair // ignore: cast_nullable_to_non_nullable
as KeyPair,myNextKeyPair: null == myNextKeyPair ? _self.myNextKeyPair : myNextKeyPair // ignore: cast_nullable_to_non_nullable
as KeyPair,theirPublicKey: null == theirPublicKey ? _self.theirPublicKey : theirPublicKey // ignore: cast_nullable_to_non_nullable
as PublicKey,theirNextPublicKey: null == theirNextPublicKey ? _self.theirNextPublicKey : theirNextPublicKey // ignore: cast_nullable_to_non_nullable
as PublicKey,
  ));
}


}

// dart format on
