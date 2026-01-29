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
                  case 'symmetric':
          return CryptoSymmetric.fromJson(
            json
          );
                case 'symToVod':
          return CryptoSymToVod.fromJson(
            json
          );
                case 'vodozemac':
          return CryptoVodozemac.fromJson(
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



  /// Serializes this CryptoState to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CryptoState);
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'CryptoState()';
}


}

/// @nodoc
class $CryptoStateCopyWith<$Res>  {
$CryptoStateCopyWith(CryptoState _, $Res Function(CryptoState) __);
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( CryptoSymmetric value)?  symmetric,TResult Function( CryptoSymToVod value)?  symToVod,TResult Function( CryptoVodozemac value)?  vodozemac,required TResult orElse(),}){
final _that = this;
switch (_that) {
case CryptoSymmetric() when symmetric != null:
return symmetric(_that);case CryptoSymToVod() when symToVod != null:
return symToVod(_that);case CryptoVodozemac() when vodozemac != null:
return vodozemac(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( CryptoSymmetric value)  symmetric,required TResult Function( CryptoSymToVod value)  symToVod,required TResult Function( CryptoVodozemac value)  vodozemac,}){
final _that = this;
switch (_that) {
case CryptoSymmetric():
return symmetric(_that);case CryptoSymToVod():
return symToVod(_that);case CryptoVodozemac():
return vodozemac(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( CryptoSymmetric value)?  symmetric,TResult? Function( CryptoSymToVod value)?  symToVod,TResult? Function( CryptoVodozemac value)?  vodozemac,}){
final _that = this;
switch (_that) {
case CryptoSymmetric() when symmetric != null:
return symmetric(_that);case CryptoSymToVod() when symToVod != null:
return symToVod(_that);case CryptoVodozemac() when vodozemac != null:
return vodozemac(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( SharedSecret sharedSecret,  String accountVod)?  symmetric,TResult Function( SharedSecret sharedSecret,  String theirIdentityKey,  String myIdentityKey,  String sessionVod)?  symToVod,TResult Function( String theirIdentityKey,  String myIdentityKey,  String sessionVod)?  vodozemac,required TResult orElse(),}) {final _that = this;
switch (_that) {
case CryptoSymmetric() when symmetric != null:
return symmetric(_that.sharedSecret,_that.accountVod);case CryptoSymToVod() when symToVod != null:
return symToVod(_that.sharedSecret,_that.theirIdentityKey,_that.myIdentityKey,_that.sessionVod);case CryptoVodozemac() when vodozemac != null:
return vodozemac(_that.theirIdentityKey,_that.myIdentityKey,_that.sessionVod);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( SharedSecret sharedSecret,  String accountVod)  symmetric,required TResult Function( SharedSecret sharedSecret,  String theirIdentityKey,  String myIdentityKey,  String sessionVod)  symToVod,required TResult Function( String theirIdentityKey,  String myIdentityKey,  String sessionVod)  vodozemac,}) {final _that = this;
switch (_that) {
case CryptoSymmetric():
return symmetric(_that.sharedSecret,_that.accountVod);case CryptoSymToVod():
return symToVod(_that.sharedSecret,_that.theirIdentityKey,_that.myIdentityKey,_that.sessionVod);case CryptoVodozemac():
return vodozemac(_that.theirIdentityKey,_that.myIdentityKey,_that.sessionVod);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( SharedSecret sharedSecret,  String accountVod)?  symmetric,TResult? Function( SharedSecret sharedSecret,  String theirIdentityKey,  String myIdentityKey,  String sessionVod)?  symToVod,TResult? Function( String theirIdentityKey,  String myIdentityKey,  String sessionVod)?  vodozemac,}) {final _that = this;
switch (_that) {
case CryptoSymmetric() when symmetric != null:
return symmetric(_that.sharedSecret,_that.accountVod);case CryptoSymToVod() when symToVod != null:
return symToVod(_that.sharedSecret,_that.theirIdentityKey,_that.myIdentityKey,_that.sessionVod);case CryptoVodozemac() when vodozemac != null:
return vodozemac(_that.theirIdentityKey,_that.myIdentityKey,_that.sessionVod);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class CryptoSymmetric implements CryptoState {
  const CryptoSymmetric({required this.sharedSecret, required this.accountVod, final  String? $type}): $type = $type ?? 'symmetric';
  factory CryptoSymmetric.fromJson(Map<String, dynamic> json) => _$CryptoSymmetricFromJson(json);

 final  SharedSecret sharedSecret;
 final  String accountVod;

@JsonKey(name: 'runtimeType')
final String $type;


/// Create a copy of CryptoState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CryptoSymmetricCopyWith<CryptoSymmetric> get copyWith => _$CryptoSymmetricCopyWithImpl<CryptoSymmetric>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CryptoSymmetricToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CryptoSymmetric&&(identical(other.sharedSecret, sharedSecret) || other.sharedSecret == sharedSecret)&&(identical(other.accountVod, accountVod) || other.accountVod == accountVod));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,sharedSecret,accountVod);

@override
String toString() {
  return 'CryptoState.symmetric(sharedSecret: $sharedSecret, accountVod: $accountVod)';
}


}

/// @nodoc
abstract mixin class $CryptoSymmetricCopyWith<$Res> implements $CryptoStateCopyWith<$Res> {
  factory $CryptoSymmetricCopyWith(CryptoSymmetric value, $Res Function(CryptoSymmetric) _then) = _$CryptoSymmetricCopyWithImpl;
@useResult
$Res call({
 SharedSecret sharedSecret, String accountVod
});




}
/// @nodoc
class _$CryptoSymmetricCopyWithImpl<$Res>
    implements $CryptoSymmetricCopyWith<$Res> {
  _$CryptoSymmetricCopyWithImpl(this._self, this._then);

  final CryptoSymmetric _self;
  final $Res Function(CryptoSymmetric) _then;

/// Create a copy of CryptoState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? sharedSecret = null,Object? accountVod = null,}) {
  return _then(CryptoSymmetric(
sharedSecret: null == sharedSecret ? _self.sharedSecret : sharedSecret // ignore: cast_nullable_to_non_nullable
as SharedSecret,accountVod: null == accountVod ? _self.accountVod : accountVod // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc
@JsonSerializable()

class CryptoSymToVod implements CryptoState {
  const CryptoSymToVod({required this.sharedSecret, required this.theirIdentityKey, required this.myIdentityKey, required this.sessionVod, final  String? $type}): $type = $type ?? 'symToVod';
  factory CryptoSymToVod.fromJson(Map<String, dynamic> json) => _$CryptoSymToVodFromJson(json);

 final  SharedSecret sharedSecret;
 final  String theirIdentityKey;
 final  String myIdentityKey;
 final  String sessionVod;

@JsonKey(name: 'runtimeType')
final String $type;


/// Create a copy of CryptoState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CryptoSymToVodCopyWith<CryptoSymToVod> get copyWith => _$CryptoSymToVodCopyWithImpl<CryptoSymToVod>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CryptoSymToVodToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CryptoSymToVod&&(identical(other.sharedSecret, sharedSecret) || other.sharedSecret == sharedSecret)&&(identical(other.theirIdentityKey, theirIdentityKey) || other.theirIdentityKey == theirIdentityKey)&&(identical(other.myIdentityKey, myIdentityKey) || other.myIdentityKey == myIdentityKey)&&(identical(other.sessionVod, sessionVod) || other.sessionVod == sessionVod));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,sharedSecret,theirIdentityKey,myIdentityKey,sessionVod);

@override
String toString() {
  return 'CryptoState.symToVod(sharedSecret: $sharedSecret, theirIdentityKey: $theirIdentityKey, myIdentityKey: $myIdentityKey, sessionVod: $sessionVod)';
}


}

/// @nodoc
abstract mixin class $CryptoSymToVodCopyWith<$Res> implements $CryptoStateCopyWith<$Res> {
  factory $CryptoSymToVodCopyWith(CryptoSymToVod value, $Res Function(CryptoSymToVod) _then) = _$CryptoSymToVodCopyWithImpl;
@useResult
$Res call({
 SharedSecret sharedSecret, String theirIdentityKey, String myIdentityKey, String sessionVod
});




}
/// @nodoc
class _$CryptoSymToVodCopyWithImpl<$Res>
    implements $CryptoSymToVodCopyWith<$Res> {
  _$CryptoSymToVodCopyWithImpl(this._self, this._then);

  final CryptoSymToVod _self;
  final $Res Function(CryptoSymToVod) _then;

/// Create a copy of CryptoState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? sharedSecret = null,Object? theirIdentityKey = null,Object? myIdentityKey = null,Object? sessionVod = null,}) {
  return _then(CryptoSymToVod(
sharedSecret: null == sharedSecret ? _self.sharedSecret : sharedSecret // ignore: cast_nullable_to_non_nullable
as SharedSecret,theirIdentityKey: null == theirIdentityKey ? _self.theirIdentityKey : theirIdentityKey // ignore: cast_nullable_to_non_nullable
as String,myIdentityKey: null == myIdentityKey ? _self.myIdentityKey : myIdentityKey // ignore: cast_nullable_to_non_nullable
as String,sessionVod: null == sessionVod ? _self.sessionVod : sessionVod // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc
@JsonSerializable()

class CryptoVodozemac implements CryptoState {
  const CryptoVodozemac({required this.theirIdentityKey, required this.myIdentityKey, required this.sessionVod, final  String? $type}): $type = $type ?? 'vodozemac';
  factory CryptoVodozemac.fromJson(Map<String, dynamic> json) => _$CryptoVodozemacFromJson(json);

 final  String theirIdentityKey;
 final  String myIdentityKey;
 final  String sessionVod;

@JsonKey(name: 'runtimeType')
final String $type;


/// Create a copy of CryptoState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CryptoVodozemacCopyWith<CryptoVodozemac> get copyWith => _$CryptoVodozemacCopyWithImpl<CryptoVodozemac>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CryptoVodozemacToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CryptoVodozemac&&(identical(other.theirIdentityKey, theirIdentityKey) || other.theirIdentityKey == theirIdentityKey)&&(identical(other.myIdentityKey, myIdentityKey) || other.myIdentityKey == myIdentityKey)&&(identical(other.sessionVod, sessionVod) || other.sessionVod == sessionVod));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,theirIdentityKey,myIdentityKey,sessionVod);

@override
String toString() {
  return 'CryptoState.vodozemac(theirIdentityKey: $theirIdentityKey, myIdentityKey: $myIdentityKey, sessionVod: $sessionVod)';
}


}

/// @nodoc
abstract mixin class $CryptoVodozemacCopyWith<$Res> implements $CryptoStateCopyWith<$Res> {
  factory $CryptoVodozemacCopyWith(CryptoVodozemac value, $Res Function(CryptoVodozemac) _then) = _$CryptoVodozemacCopyWithImpl;
@useResult
$Res call({
 String theirIdentityKey, String myIdentityKey, String sessionVod
});




}
/// @nodoc
class _$CryptoVodozemacCopyWithImpl<$Res>
    implements $CryptoVodozemacCopyWith<$Res> {
  _$CryptoVodozemacCopyWithImpl(this._self, this._then);

  final CryptoVodozemac _self;
  final $Res Function(CryptoVodozemac) _then;

/// Create a copy of CryptoState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? theirIdentityKey = null,Object? myIdentityKey = null,Object? sessionVod = null,}) {
  return _then(CryptoVodozemac(
theirIdentityKey: null == theirIdentityKey ? _self.theirIdentityKey : theirIdentityKey // ignore: cast_nullable_to_non_nullable
as String,myIdentityKey: null == myIdentityKey ? _self.myIdentityKey : myIdentityKey // ignore: cast_nullable_to_non_nullable
as String,sessionVod: null == sessionVod ? _self.sessionVod : sessionVod // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
