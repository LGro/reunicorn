// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'community.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$OrganizerProvidedMemberInfo {

/// The DHT record where others can find connection and sharing info
 RecordKey get recordKey;/// Label or name for the member, could be email/name/nick, max length 50
 String get name;/// Comment by the organizer, e.g. to explain reason for expelling member
/// max length 100
 String? get comment;
/// Create a copy of OrganizerProvidedMemberInfo
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OrganizerProvidedMemberInfoCopyWith<OrganizerProvidedMemberInfo> get copyWith => _$OrganizerProvidedMemberInfoCopyWithImpl<OrganizerProvidedMemberInfo>(this as OrganizerProvidedMemberInfo, _$identity);

  /// Serializes this OrganizerProvidedMemberInfo to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OrganizerProvidedMemberInfo&&(identical(other.recordKey, recordKey) || other.recordKey == recordKey)&&(identical(other.name, name) || other.name == name)&&(identical(other.comment, comment) || other.comment == comment));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,recordKey,name,comment);

@override
String toString() {
  return 'OrganizerProvidedMemberInfo(recordKey: $recordKey, name: $name, comment: $comment)';
}


}

/// @nodoc
abstract mixin class $OrganizerProvidedMemberInfoCopyWith<$Res>  {
  factory $OrganizerProvidedMemberInfoCopyWith(OrganizerProvidedMemberInfo value, $Res Function(OrganizerProvidedMemberInfo) _then) = _$OrganizerProvidedMemberInfoCopyWithImpl;
@useResult
$Res call({
 RecordKey recordKey, String name, String? comment
});




}
/// @nodoc
class _$OrganizerProvidedMemberInfoCopyWithImpl<$Res>
    implements $OrganizerProvidedMemberInfoCopyWith<$Res> {
  _$OrganizerProvidedMemberInfoCopyWithImpl(this._self, this._then);

  final OrganizerProvidedMemberInfo _self;
  final $Res Function(OrganizerProvidedMemberInfo) _then;

/// Create a copy of OrganizerProvidedMemberInfo
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? recordKey = null,Object? name = null,Object? comment = freezed,}) {
  return _then(_self.copyWith(
recordKey: null == recordKey ? _self.recordKey : recordKey // ignore: cast_nullable_to_non_nullable
as RecordKey,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,comment: freezed == comment ? _self.comment : comment // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [OrganizerProvidedMemberInfo].
extension OrganizerProvidedMemberInfoPatterns on OrganizerProvidedMemberInfo {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _OrganizerProvidedMemberInfo value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _OrganizerProvidedMemberInfo() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _OrganizerProvidedMemberInfo value)  $default,){
final _that = this;
switch (_that) {
case _OrganizerProvidedMemberInfo():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _OrganizerProvidedMemberInfo value)?  $default,){
final _that = this;
switch (_that) {
case _OrganizerProvidedMemberInfo() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( RecordKey recordKey,  String name,  String? comment)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _OrganizerProvidedMemberInfo() when $default != null:
return $default(_that.recordKey,_that.name,_that.comment);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( RecordKey recordKey,  String name,  String? comment)  $default,) {final _that = this;
switch (_that) {
case _OrganizerProvidedMemberInfo():
return $default(_that.recordKey,_that.name,_that.comment);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( RecordKey recordKey,  String name,  String? comment)?  $default,) {final _that = this;
switch (_that) {
case _OrganizerProvidedMemberInfo() when $default != null:
return $default(_that.recordKey,_that.name,_that.comment);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _OrganizerProvidedMemberInfo implements OrganizerProvidedMemberInfo {
  const _OrganizerProvidedMemberInfo({required this.recordKey, required this.name, this.comment});
  factory _OrganizerProvidedMemberInfo.fromJson(Map<String, dynamic> json) => _$OrganizerProvidedMemberInfoFromJson(json);

/// The DHT record where others can find connection and sharing info
@override final  RecordKey recordKey;
/// Label or name for the member, could be email/name/nick, max length 50
@override final  String name;
/// Comment by the organizer, e.g. to explain reason for expelling member
/// max length 100
@override final  String? comment;

/// Create a copy of OrganizerProvidedMemberInfo
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OrganizerProvidedMemberInfoCopyWith<_OrganizerProvidedMemberInfo> get copyWith => __$OrganizerProvidedMemberInfoCopyWithImpl<_OrganizerProvidedMemberInfo>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$OrganizerProvidedMemberInfoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _OrganizerProvidedMemberInfo&&(identical(other.recordKey, recordKey) || other.recordKey == recordKey)&&(identical(other.name, name) || other.name == name)&&(identical(other.comment, comment) || other.comment == comment));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,recordKey,name,comment);

@override
String toString() {
  return 'OrganizerProvidedMemberInfo(recordKey: $recordKey, name: $name, comment: $comment)';
}


}

/// @nodoc
abstract mixin class _$OrganizerProvidedMemberInfoCopyWith<$Res> implements $OrganizerProvidedMemberInfoCopyWith<$Res> {
  factory _$OrganizerProvidedMemberInfoCopyWith(_OrganizerProvidedMemberInfo value, $Res Function(_OrganizerProvidedMemberInfo) _then) = __$OrganizerProvidedMemberInfoCopyWithImpl;
@override @useResult
$Res call({
 RecordKey recordKey, String name, String? comment
});




}
/// @nodoc
class __$OrganizerProvidedMemberInfoCopyWithImpl<$Res>
    implements _$OrganizerProvidedMemberInfoCopyWith<$Res> {
  __$OrganizerProvidedMemberInfoCopyWithImpl(this._self, this._then);

  final _OrganizerProvidedMemberInfo _self;
  final $Res Function(_OrganizerProvidedMemberInfo) _then;

/// Create a copy of OrganizerProvidedMemberInfo
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? recordKey = null,Object? name = null,Object? comment = freezed,}) {
  return _then(_OrganizerProvidedMemberInfo(
recordKey: null == recordKey ? _self.recordKey : recordKey // ignore: cast_nullable_to_non_nullable
as RecordKey,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,comment: freezed == comment ? _self.comment : comment // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$CommunityInfo {

/// Name of the community
 String get name;/// Community shared secret
 SharedSecret get secret;/// Organizer provided information about other community members
 List<OrganizerProvidedMemberInfo> get membersInfo;/// Optional expiration date after which this community is no longer to be
/// used for connecting members
 DateTime? get expiresAt;
/// Create a copy of CommunityInfo
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CommunityInfoCopyWith<CommunityInfo> get copyWith => _$CommunityInfoCopyWithImpl<CommunityInfo>(this as CommunityInfo, _$identity);

  /// Serializes this CommunityInfo to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CommunityInfo&&(identical(other.name, name) || other.name == name)&&(identical(other.secret, secret) || other.secret == secret)&&const DeepCollectionEquality().equals(other.membersInfo, membersInfo)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,secret,const DeepCollectionEquality().hash(membersInfo),expiresAt);

@override
String toString() {
  return 'CommunityInfo(name: $name, secret: $secret, membersInfo: $membersInfo, expiresAt: $expiresAt)';
}


}

/// @nodoc
abstract mixin class $CommunityInfoCopyWith<$Res>  {
  factory $CommunityInfoCopyWith(CommunityInfo value, $Res Function(CommunityInfo) _then) = _$CommunityInfoCopyWithImpl;
@useResult
$Res call({
 String name, SharedSecret secret, List<OrganizerProvidedMemberInfo> membersInfo, DateTime? expiresAt
});




}
/// @nodoc
class _$CommunityInfoCopyWithImpl<$Res>
    implements $CommunityInfoCopyWith<$Res> {
  _$CommunityInfoCopyWithImpl(this._self, this._then);

  final CommunityInfo _self;
  final $Res Function(CommunityInfo) _then;

/// Create a copy of CommunityInfo
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? secret = null,Object? membersInfo = null,Object? expiresAt = freezed,}) {
  return _then(_self.copyWith(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,secret: null == secret ? _self.secret : secret // ignore: cast_nullable_to_non_nullable
as SharedSecret,membersInfo: null == membersInfo ? _self.membersInfo : membersInfo // ignore: cast_nullable_to_non_nullable
as List<OrganizerProvidedMemberInfo>,expiresAt: freezed == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [CommunityInfo].
extension CommunityInfoPatterns on CommunityInfo {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CommunityInfo value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CommunityInfo() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CommunityInfo value)  $default,){
final _that = this;
switch (_that) {
case _CommunityInfo():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CommunityInfo value)?  $default,){
final _that = this;
switch (_that) {
case _CommunityInfo() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String name,  SharedSecret secret,  List<OrganizerProvidedMemberInfo> membersInfo,  DateTime? expiresAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CommunityInfo() when $default != null:
return $default(_that.name,_that.secret,_that.membersInfo,_that.expiresAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String name,  SharedSecret secret,  List<OrganizerProvidedMemberInfo> membersInfo,  DateTime? expiresAt)  $default,) {final _that = this;
switch (_that) {
case _CommunityInfo():
return $default(_that.name,_that.secret,_that.membersInfo,_that.expiresAt);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String name,  SharedSecret secret,  List<OrganizerProvidedMemberInfo> membersInfo,  DateTime? expiresAt)?  $default,) {final _that = this;
switch (_that) {
case _CommunityInfo() when $default != null:
return $default(_that.name,_that.secret,_that.membersInfo,_that.expiresAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CommunityInfo implements CommunityInfo {
  const _CommunityInfo({required this.name, required this.secret, required final  List<OrganizerProvidedMemberInfo> membersInfo, this.expiresAt}): _membersInfo = membersInfo;
  factory _CommunityInfo.fromJson(Map<String, dynamic> json) => _$CommunityInfoFromJson(json);

/// Name of the community
@override final  String name;
/// Community shared secret
@override final  SharedSecret secret;
/// Organizer provided information about other community members
 final  List<OrganizerProvidedMemberInfo> _membersInfo;
/// Organizer provided information about other community members
@override List<OrganizerProvidedMemberInfo> get membersInfo {
  if (_membersInfo is EqualUnmodifiableListView) return _membersInfo;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_membersInfo);
}

/// Optional expiration date after which this community is no longer to be
/// used for connecting members
@override final  DateTime? expiresAt;

/// Create a copy of CommunityInfo
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CommunityInfoCopyWith<_CommunityInfo> get copyWith => __$CommunityInfoCopyWithImpl<_CommunityInfo>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CommunityInfoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CommunityInfo&&(identical(other.name, name) || other.name == name)&&(identical(other.secret, secret) || other.secret == secret)&&const DeepCollectionEquality().equals(other._membersInfo, _membersInfo)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,secret,const DeepCollectionEquality().hash(_membersInfo),expiresAt);

@override
String toString() {
  return 'CommunityInfo(name: $name, secret: $secret, membersInfo: $membersInfo, expiresAt: $expiresAt)';
}


}

/// @nodoc
abstract mixin class _$CommunityInfoCopyWith<$Res> implements $CommunityInfoCopyWith<$Res> {
  factory _$CommunityInfoCopyWith(_CommunityInfo value, $Res Function(_CommunityInfo) _then) = __$CommunityInfoCopyWithImpl;
@override @useResult
$Res call({
 String name, SharedSecret secret, List<OrganizerProvidedMemberInfo> membersInfo, DateTime? expiresAt
});




}
/// @nodoc
class __$CommunityInfoCopyWithImpl<$Res>
    implements _$CommunityInfoCopyWith<$Res> {
  __$CommunityInfoCopyWithImpl(this._self, this._then);

  final _CommunityInfo _self;
  final $Res Function(_CommunityInfo) _then;

/// Create a copy of CommunityInfo
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? secret = null,Object? membersInfo = null,Object? expiresAt = freezed,}) {
  return _then(_CommunityInfo(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,secret: null == secret ? _self.secret : secret // ignore: cast_nullable_to_non_nullable
as SharedSecret,membersInfo: null == membersInfo ? _self._membersInfo : membersInfo // ignore: cast_nullable_to_non_nullable
as List<OrganizerProvidedMemberInfo>,expiresAt: freezed == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}


/// @nodoc
mixin _$MemberInfo {

/// The public key other community members are supposed to use for
/// encrypting the initial data sharing exchange, after which this key is
/// supposed to be and keep being rotated to a contact specific key.
 PublicKey get publicKey;/// For each other community member a hash of the shared secret derived from
/// the public key's corresponding private key and their public key, along
/// with a DHT record key where the matching member can find information
/// that is shared with them.
///
/// Using the hash here instead of e.g. the other member's member record key
/// prevents community members or organizers from discovering who is
/// offering to connect with whom.
 List<(HashDigest, RecordKey)> get sharingOffers;
/// Create a copy of MemberInfo
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MemberInfoCopyWith<MemberInfo> get copyWith => _$MemberInfoCopyWithImpl<MemberInfo>(this as MemberInfo, _$identity);

  /// Serializes this MemberInfo to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MemberInfo&&(identical(other.publicKey, publicKey) || other.publicKey == publicKey)&&const DeepCollectionEquality().equals(other.sharingOffers, sharingOffers));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,publicKey,const DeepCollectionEquality().hash(sharingOffers));

@override
String toString() {
  return 'MemberInfo(publicKey: $publicKey, sharingOffers: $sharingOffers)';
}


}

/// @nodoc
abstract mixin class $MemberInfoCopyWith<$Res>  {
  factory $MemberInfoCopyWith(MemberInfo value, $Res Function(MemberInfo) _then) = _$MemberInfoCopyWithImpl;
@useResult
$Res call({
 PublicKey publicKey, List<(HashDigest, RecordKey)> sharingOffers
});




}
/// @nodoc
class _$MemberInfoCopyWithImpl<$Res>
    implements $MemberInfoCopyWith<$Res> {
  _$MemberInfoCopyWithImpl(this._self, this._then);

  final MemberInfo _self;
  final $Res Function(MemberInfo) _then;

/// Create a copy of MemberInfo
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? publicKey = null,Object? sharingOffers = null,}) {
  return _then(_self.copyWith(
publicKey: null == publicKey ? _self.publicKey : publicKey // ignore: cast_nullable_to_non_nullable
as PublicKey,sharingOffers: null == sharingOffers ? _self.sharingOffers : sharingOffers // ignore: cast_nullable_to_non_nullable
as List<(HashDigest, RecordKey)>,
  ));
}

}


/// Adds pattern-matching-related methods to [MemberInfo].
extension MemberInfoPatterns on MemberInfo {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MemberInfo value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MemberInfo() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MemberInfo value)  $default,){
final _that = this;
switch (_that) {
case _MemberInfo():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MemberInfo value)?  $default,){
final _that = this;
switch (_that) {
case _MemberInfo() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( PublicKey publicKey,  List<(HashDigest, RecordKey)> sharingOffers)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MemberInfo() when $default != null:
return $default(_that.publicKey,_that.sharingOffers);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( PublicKey publicKey,  List<(HashDigest, RecordKey)> sharingOffers)  $default,) {final _that = this;
switch (_that) {
case _MemberInfo():
return $default(_that.publicKey,_that.sharingOffers);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( PublicKey publicKey,  List<(HashDigest, RecordKey)> sharingOffers)?  $default,) {final _that = this;
switch (_that) {
case _MemberInfo() when $default != null:
return $default(_that.publicKey,_that.sharingOffers);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MemberInfo implements MemberInfo {
  const _MemberInfo({required this.publicKey, required final  List<(HashDigest, RecordKey)> sharingOffers}): _sharingOffers = sharingOffers;
  factory _MemberInfo.fromJson(Map<String, dynamic> json) => _$MemberInfoFromJson(json);

/// The public key other community members are supposed to use for
/// encrypting the initial data sharing exchange, after which this key is
/// supposed to be and keep being rotated to a contact specific key.
@override final  PublicKey publicKey;
/// For each other community member a hash of the shared secret derived from
/// the public key's corresponding private key and their public key, along
/// with a DHT record key where the matching member can find information
/// that is shared with them.
///
/// Using the hash here instead of e.g. the other member's member record key
/// prevents community members or organizers from discovering who is
/// offering to connect with whom.
 final  List<(HashDigest, RecordKey)> _sharingOffers;
/// For each other community member a hash of the shared secret derived from
/// the public key's corresponding private key and their public key, along
/// with a DHT record key where the matching member can find information
/// that is shared with them.
///
/// Using the hash here instead of e.g. the other member's member record key
/// prevents community members or organizers from discovering who is
/// offering to connect with whom.
@override List<(HashDigest, RecordKey)> get sharingOffers {
  if (_sharingOffers is EqualUnmodifiableListView) return _sharingOffers;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_sharingOffers);
}


/// Create a copy of MemberInfo
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MemberInfoCopyWith<_MemberInfo> get copyWith => __$MemberInfoCopyWithImpl<_MemberInfo>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MemberInfoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MemberInfo&&(identical(other.publicKey, publicKey) || other.publicKey == publicKey)&&const DeepCollectionEquality().equals(other._sharingOffers, _sharingOffers));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,publicKey,const DeepCollectionEquality().hash(_sharingOffers));

@override
String toString() {
  return 'MemberInfo(publicKey: $publicKey, sharingOffers: $sharingOffers)';
}


}

/// @nodoc
abstract mixin class _$MemberInfoCopyWith<$Res> implements $MemberInfoCopyWith<$Res> {
  factory _$MemberInfoCopyWith(_MemberInfo value, $Res Function(_MemberInfo) _then) = __$MemberInfoCopyWithImpl;
@override @useResult
$Res call({
 PublicKey publicKey, List<(HashDigest, RecordKey)> sharingOffers
});




}
/// @nodoc
class __$MemberInfoCopyWithImpl<$Res>
    implements _$MemberInfoCopyWith<$Res> {
  __$MemberInfoCopyWithImpl(this._self, this._then);

  final _MemberInfo _self;
  final $Res Function(_MemberInfo) _then;

/// Create a copy of MemberInfo
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? publicKey = null,Object? sharingOffers = null,}) {
  return _then(_MemberInfo(
publicKey: null == publicKey ? _self.publicKey : publicKey // ignore: cast_nullable_to_non_nullable
as PublicKey,sharingOffers: null == sharingOffers ? _self._sharingOffers : sharingOffers // ignore: cast_nullable_to_non_nullable
as List<(HashDigest, RecordKey)>,
  ));
}


}


/// @nodoc
mixin _$ManagedCommunity {

/// Name of the community
 String get name;/// Unique ID of the community, usually UUID4 type
 String get communityUuid;/// Community shared secrets
 SharedSecret get communitySecret;/// Optional expiration date after which this community is no longer to be
/// used for connecting members
 DateTime? get expiresAt;/// List of all community members
 List<(OrganizerProvidedMemberInfo, KeyPair)> get membersWithWriters;
/// Create a copy of ManagedCommunity
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ManagedCommunityCopyWith<ManagedCommunity> get copyWith => _$ManagedCommunityCopyWithImpl<ManagedCommunity>(this as ManagedCommunity, _$identity);

  /// Serializes this ManagedCommunity to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ManagedCommunity&&(identical(other.name, name) || other.name == name)&&(identical(other.communityUuid, communityUuid) || other.communityUuid == communityUuid)&&(identical(other.communitySecret, communitySecret) || other.communitySecret == communitySecret)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt)&&const DeepCollectionEquality().equals(other.membersWithWriters, membersWithWriters));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,communityUuid,communitySecret,expiresAt,const DeepCollectionEquality().hash(membersWithWriters));

@override
String toString() {
  return 'ManagedCommunity(name: $name, communityUuid: $communityUuid, communitySecret: $communitySecret, expiresAt: $expiresAt, membersWithWriters: $membersWithWriters)';
}


}

/// @nodoc
abstract mixin class $ManagedCommunityCopyWith<$Res>  {
  factory $ManagedCommunityCopyWith(ManagedCommunity value, $Res Function(ManagedCommunity) _then) = _$ManagedCommunityCopyWithImpl;
@useResult
$Res call({
 String name, String communityUuid, SharedSecret communitySecret, DateTime? expiresAt, List<(OrganizerProvidedMemberInfo, KeyPair)> membersWithWriters
});




}
/// @nodoc
class _$ManagedCommunityCopyWithImpl<$Res>
    implements $ManagedCommunityCopyWith<$Res> {
  _$ManagedCommunityCopyWithImpl(this._self, this._then);

  final ManagedCommunity _self;
  final $Res Function(ManagedCommunity) _then;

/// Create a copy of ManagedCommunity
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? communityUuid = null,Object? communitySecret = null,Object? expiresAt = freezed,Object? membersWithWriters = null,}) {
  return _then(_self.copyWith(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,communityUuid: null == communityUuid ? _self.communityUuid : communityUuid // ignore: cast_nullable_to_non_nullable
as String,communitySecret: null == communitySecret ? _self.communitySecret : communitySecret // ignore: cast_nullable_to_non_nullable
as SharedSecret,expiresAt: freezed == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime?,membersWithWriters: null == membersWithWriters ? _self.membersWithWriters : membersWithWriters // ignore: cast_nullable_to_non_nullable
as List<(OrganizerProvidedMemberInfo, KeyPair)>,
  ));
}

}


/// Adds pattern-matching-related methods to [ManagedCommunity].
extension ManagedCommunityPatterns on ManagedCommunity {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ManagedCommunity value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ManagedCommunity() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ManagedCommunity value)  $default,){
final _that = this;
switch (_that) {
case _ManagedCommunity():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ManagedCommunity value)?  $default,){
final _that = this;
switch (_that) {
case _ManagedCommunity() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String name,  String communityUuid,  SharedSecret communitySecret,  DateTime? expiresAt,  List<(OrganizerProvidedMemberInfo, KeyPair)> membersWithWriters)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ManagedCommunity() when $default != null:
return $default(_that.name,_that.communityUuid,_that.communitySecret,_that.expiresAt,_that.membersWithWriters);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String name,  String communityUuid,  SharedSecret communitySecret,  DateTime? expiresAt,  List<(OrganizerProvidedMemberInfo, KeyPair)> membersWithWriters)  $default,) {final _that = this;
switch (_that) {
case _ManagedCommunity():
return $default(_that.name,_that.communityUuid,_that.communitySecret,_that.expiresAt,_that.membersWithWriters);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String name,  String communityUuid,  SharedSecret communitySecret,  DateTime? expiresAt,  List<(OrganizerProvidedMemberInfo, KeyPair)> membersWithWriters)?  $default,) {final _that = this;
switch (_that) {
case _ManagedCommunity() when $default != null:
return $default(_that.name,_that.communityUuid,_that.communitySecret,_that.expiresAt,_that.membersWithWriters);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ManagedCommunity implements ManagedCommunity {
  const _ManagedCommunity({required this.name, required this.communityUuid, required this.communitySecret, this.expiresAt, final  List<(OrganizerProvidedMemberInfo, KeyPair)> membersWithWriters = const []}): _membersWithWriters = membersWithWriters;
  factory _ManagedCommunity.fromJson(Map<String, dynamic> json) => _$ManagedCommunityFromJson(json);

/// Name of the community
@override final  String name;
/// Unique ID of the community, usually UUID4 type
@override final  String communityUuid;
/// Community shared secrets
@override final  SharedSecret communitySecret;
/// Optional expiration date after which this community is no longer to be
/// used for connecting members
@override final  DateTime? expiresAt;
/// List of all community members
 final  List<(OrganizerProvidedMemberInfo, KeyPair)> _membersWithWriters;
/// List of all community members
@override@JsonKey() List<(OrganizerProvidedMemberInfo, KeyPair)> get membersWithWriters {
  if (_membersWithWriters is EqualUnmodifiableListView) return _membersWithWriters;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_membersWithWriters);
}


/// Create a copy of ManagedCommunity
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ManagedCommunityCopyWith<_ManagedCommunity> get copyWith => __$ManagedCommunityCopyWithImpl<_ManagedCommunity>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ManagedCommunityToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ManagedCommunity&&(identical(other.name, name) || other.name == name)&&(identical(other.communityUuid, communityUuid) || other.communityUuid == communityUuid)&&(identical(other.communitySecret, communitySecret) || other.communitySecret == communitySecret)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt)&&const DeepCollectionEquality().equals(other._membersWithWriters, _membersWithWriters));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,communityUuid,communitySecret,expiresAt,const DeepCollectionEquality().hash(_membersWithWriters));

@override
String toString() {
  return 'ManagedCommunity(name: $name, communityUuid: $communityUuid, communitySecret: $communitySecret, expiresAt: $expiresAt, membersWithWriters: $membersWithWriters)';
}


}

/// @nodoc
abstract mixin class _$ManagedCommunityCopyWith<$Res> implements $ManagedCommunityCopyWith<$Res> {
  factory _$ManagedCommunityCopyWith(_ManagedCommunity value, $Res Function(_ManagedCommunity) _then) = __$ManagedCommunityCopyWithImpl;
@override @useResult
$Res call({
 String name, String communityUuid, SharedSecret communitySecret, DateTime? expiresAt, List<(OrganizerProvidedMemberInfo, KeyPair)> membersWithWriters
});




}
/// @nodoc
class __$ManagedCommunityCopyWithImpl<$Res>
    implements _$ManagedCommunityCopyWith<$Res> {
  __$ManagedCommunityCopyWithImpl(this._self, this._then);

  final _ManagedCommunity _self;
  final $Res Function(_ManagedCommunity) _then;

/// Create a copy of ManagedCommunity
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? communityUuid = null,Object? communitySecret = null,Object? expiresAt = freezed,Object? membersWithWriters = null,}) {
  return _then(_ManagedCommunity(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,communityUuid: null == communityUuid ? _self.communityUuid : communityUuid // ignore: cast_nullable_to_non_nullable
as String,communitySecret: null == communitySecret ? _self.communitySecret : communitySecret // ignore: cast_nullable_to_non_nullable
as SharedSecret,expiresAt: freezed == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime?,membersWithWriters: null == membersWithWriters ? _self._membersWithWriters : membersWithWriters // ignore: cast_nullable_to_non_nullable
as List<(OrganizerProvidedMemberInfo, KeyPair)>,
  ));
}


}


/// @nodoc
mixin _$Member {

 RecordKey get communityRecordKey; RecordKey get infoRecordKey;/// Label or name for the member, could be email/name/nick
 String get name;/// Comment by the organizer, e.g. to explain reason for expelling member
 String? get comment;/// Timestamp of the most recent comment change
 DateTime? get mostRecentCommentUpdate;/// Their public key for initial sharing encryption
 PublicKey? get publicKey;/// The record key where they share information with me
 RecordKey? get sharingRecordKey;/// After a community member was added as a contact, my sharing record key
/// is stored here as well to allow construction of my `MemberInfo`
 RecordKey? get mySharingRecordKey;
/// Create a copy of Member
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MemberCopyWith<Member> get copyWith => _$MemberCopyWithImpl<Member>(this as Member, _$identity);

  /// Serializes this Member to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Member&&(identical(other.communityRecordKey, communityRecordKey) || other.communityRecordKey == communityRecordKey)&&(identical(other.infoRecordKey, infoRecordKey) || other.infoRecordKey == infoRecordKey)&&(identical(other.name, name) || other.name == name)&&(identical(other.comment, comment) || other.comment == comment)&&(identical(other.mostRecentCommentUpdate, mostRecentCommentUpdate) || other.mostRecentCommentUpdate == mostRecentCommentUpdate)&&(identical(other.publicKey, publicKey) || other.publicKey == publicKey)&&(identical(other.sharingRecordKey, sharingRecordKey) || other.sharingRecordKey == sharingRecordKey)&&(identical(other.mySharingRecordKey, mySharingRecordKey) || other.mySharingRecordKey == mySharingRecordKey));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,communityRecordKey,infoRecordKey,name,comment,mostRecentCommentUpdate,publicKey,sharingRecordKey,mySharingRecordKey);

@override
String toString() {
  return 'Member(communityRecordKey: $communityRecordKey, infoRecordKey: $infoRecordKey, name: $name, comment: $comment, mostRecentCommentUpdate: $mostRecentCommentUpdate, publicKey: $publicKey, sharingRecordKey: $sharingRecordKey, mySharingRecordKey: $mySharingRecordKey)';
}


}

/// @nodoc
abstract mixin class $MemberCopyWith<$Res>  {
  factory $MemberCopyWith(Member value, $Res Function(Member) _then) = _$MemberCopyWithImpl;
@useResult
$Res call({
 RecordKey communityRecordKey, RecordKey infoRecordKey, String name, String? comment, DateTime? mostRecentCommentUpdate, PublicKey? publicKey, RecordKey? sharingRecordKey, RecordKey? mySharingRecordKey
});




}
/// @nodoc
class _$MemberCopyWithImpl<$Res>
    implements $MemberCopyWith<$Res> {
  _$MemberCopyWithImpl(this._self, this._then);

  final Member _self;
  final $Res Function(Member) _then;

/// Create a copy of Member
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? communityRecordKey = null,Object? infoRecordKey = null,Object? name = null,Object? comment = freezed,Object? mostRecentCommentUpdate = freezed,Object? publicKey = freezed,Object? sharingRecordKey = freezed,Object? mySharingRecordKey = freezed,}) {
  return _then(_self.copyWith(
communityRecordKey: null == communityRecordKey ? _self.communityRecordKey : communityRecordKey // ignore: cast_nullable_to_non_nullable
as RecordKey,infoRecordKey: null == infoRecordKey ? _self.infoRecordKey : infoRecordKey // ignore: cast_nullable_to_non_nullable
as RecordKey,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,comment: freezed == comment ? _self.comment : comment // ignore: cast_nullable_to_non_nullable
as String?,mostRecentCommentUpdate: freezed == mostRecentCommentUpdate ? _self.mostRecentCommentUpdate : mostRecentCommentUpdate // ignore: cast_nullable_to_non_nullable
as DateTime?,publicKey: freezed == publicKey ? _self.publicKey : publicKey // ignore: cast_nullable_to_non_nullable
as PublicKey?,sharingRecordKey: freezed == sharingRecordKey ? _self.sharingRecordKey : sharingRecordKey // ignore: cast_nullable_to_non_nullable
as RecordKey?,mySharingRecordKey: freezed == mySharingRecordKey ? _self.mySharingRecordKey : mySharingRecordKey // ignore: cast_nullable_to_non_nullable
as RecordKey?,
  ));
}

}


/// Adds pattern-matching-related methods to [Member].
extension MemberPatterns on Member {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Member value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Member() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Member value)  $default,){
final _that = this;
switch (_that) {
case _Member():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Member value)?  $default,){
final _that = this;
switch (_that) {
case _Member() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( RecordKey communityRecordKey,  RecordKey infoRecordKey,  String name,  String? comment,  DateTime? mostRecentCommentUpdate,  PublicKey? publicKey,  RecordKey? sharingRecordKey,  RecordKey? mySharingRecordKey)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Member() when $default != null:
return $default(_that.communityRecordKey,_that.infoRecordKey,_that.name,_that.comment,_that.mostRecentCommentUpdate,_that.publicKey,_that.sharingRecordKey,_that.mySharingRecordKey);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( RecordKey communityRecordKey,  RecordKey infoRecordKey,  String name,  String? comment,  DateTime? mostRecentCommentUpdate,  PublicKey? publicKey,  RecordKey? sharingRecordKey,  RecordKey? mySharingRecordKey)  $default,) {final _that = this;
switch (_that) {
case _Member():
return $default(_that.communityRecordKey,_that.infoRecordKey,_that.name,_that.comment,_that.mostRecentCommentUpdate,_that.publicKey,_that.sharingRecordKey,_that.mySharingRecordKey);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( RecordKey communityRecordKey,  RecordKey infoRecordKey,  String name,  String? comment,  DateTime? mostRecentCommentUpdate,  PublicKey? publicKey,  RecordKey? sharingRecordKey,  RecordKey? mySharingRecordKey)?  $default,) {final _that = this;
switch (_that) {
case _Member() when $default != null:
return $default(_that.communityRecordKey,_that.infoRecordKey,_that.name,_that.comment,_that.mostRecentCommentUpdate,_that.publicKey,_that.sharingRecordKey,_that.mySharingRecordKey);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Member implements Member {
  const _Member({required this.communityRecordKey, required this.infoRecordKey, required this.name, this.comment, this.mostRecentCommentUpdate, this.publicKey, this.sharingRecordKey, this.mySharingRecordKey});
  factory _Member.fromJson(Map<String, dynamic> json) => _$MemberFromJson(json);

@override final  RecordKey communityRecordKey;
@override final  RecordKey infoRecordKey;
/// Label or name for the member, could be email/name/nick
@override final  String name;
/// Comment by the organizer, e.g. to explain reason for expelling member
@override final  String? comment;
/// Timestamp of the most recent comment change
@override final  DateTime? mostRecentCommentUpdate;
/// Their public key for initial sharing encryption
@override final  PublicKey? publicKey;
/// The record key where they share information with me
@override final  RecordKey? sharingRecordKey;
/// After a community member was added as a contact, my sharing record key
/// is stored here as well to allow construction of my `MemberInfo`
@override final  RecordKey? mySharingRecordKey;

/// Create a copy of Member
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MemberCopyWith<_Member> get copyWith => __$MemberCopyWithImpl<_Member>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MemberToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Member&&(identical(other.communityRecordKey, communityRecordKey) || other.communityRecordKey == communityRecordKey)&&(identical(other.infoRecordKey, infoRecordKey) || other.infoRecordKey == infoRecordKey)&&(identical(other.name, name) || other.name == name)&&(identical(other.comment, comment) || other.comment == comment)&&(identical(other.mostRecentCommentUpdate, mostRecentCommentUpdate) || other.mostRecentCommentUpdate == mostRecentCommentUpdate)&&(identical(other.publicKey, publicKey) || other.publicKey == publicKey)&&(identical(other.sharingRecordKey, sharingRecordKey) || other.sharingRecordKey == sharingRecordKey)&&(identical(other.mySharingRecordKey, mySharingRecordKey) || other.mySharingRecordKey == mySharingRecordKey));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,communityRecordKey,infoRecordKey,name,comment,mostRecentCommentUpdate,publicKey,sharingRecordKey,mySharingRecordKey);

@override
String toString() {
  return 'Member(communityRecordKey: $communityRecordKey, infoRecordKey: $infoRecordKey, name: $name, comment: $comment, mostRecentCommentUpdate: $mostRecentCommentUpdate, publicKey: $publicKey, sharingRecordKey: $sharingRecordKey, mySharingRecordKey: $mySharingRecordKey)';
}


}

/// @nodoc
abstract mixin class _$MemberCopyWith<$Res> implements $MemberCopyWith<$Res> {
  factory _$MemberCopyWith(_Member value, $Res Function(_Member) _then) = __$MemberCopyWithImpl;
@override @useResult
$Res call({
 RecordKey communityRecordKey, RecordKey infoRecordKey, String name, String? comment, DateTime? mostRecentCommentUpdate, PublicKey? publicKey, RecordKey? sharingRecordKey, RecordKey? mySharingRecordKey
});




}
/// @nodoc
class __$MemberCopyWithImpl<$Res>
    implements _$MemberCopyWith<$Res> {
  __$MemberCopyWithImpl(this._self, this._then);

  final _Member _self;
  final $Res Function(_Member) _then;

/// Create a copy of Member
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? communityRecordKey = null,Object? infoRecordKey = null,Object? name = null,Object? comment = freezed,Object? mostRecentCommentUpdate = freezed,Object? publicKey = freezed,Object? sharingRecordKey = freezed,Object? mySharingRecordKey = freezed,}) {
  return _then(_Member(
communityRecordKey: null == communityRecordKey ? _self.communityRecordKey : communityRecordKey // ignore: cast_nullable_to_non_nullable
as RecordKey,infoRecordKey: null == infoRecordKey ? _self.infoRecordKey : infoRecordKey // ignore: cast_nullable_to_non_nullable
as RecordKey,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,comment: freezed == comment ? _self.comment : comment // ignore: cast_nullable_to_non_nullable
as String?,mostRecentCommentUpdate: freezed == mostRecentCommentUpdate ? _self.mostRecentCommentUpdate : mostRecentCommentUpdate // ignore: cast_nullable_to_non_nullable
as DateTime?,publicKey: freezed == publicKey ? _self.publicKey : publicKey // ignore: cast_nullable_to_non_nullable
as PublicKey?,sharingRecordKey: freezed == sharingRecordKey ? _self.sharingRecordKey : sharingRecordKey // ignore: cast_nullable_to_non_nullable
as RecordKey?,mySharingRecordKey: freezed == mySharingRecordKey ? _self.mySharingRecordKey : mySharingRecordKey // ignore: cast_nullable_to_non_nullable
as RecordKey?,
  ));
}


}


/// @nodoc
mixin _$Community {

/// Key of my community member DHT record
 RecordKey get recordKey;/// Writer of my community member DHT record
 KeyPair get recordWriter;/// Community members
 List<Member> get members;/// Timestamp of most recent update
 DateTime get mostRecentUpdate;/// Community information, might not directly be available at invite time
 CommunityInfo? get info;
/// Create a copy of Community
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CommunityCopyWith<Community> get copyWith => _$CommunityCopyWithImpl<Community>(this as Community, _$identity);

  /// Serializes this Community to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Community&&(identical(other.recordKey, recordKey) || other.recordKey == recordKey)&&(identical(other.recordWriter, recordWriter) || other.recordWriter == recordWriter)&&const DeepCollectionEquality().equals(other.members, members)&&(identical(other.mostRecentUpdate, mostRecentUpdate) || other.mostRecentUpdate == mostRecentUpdate)&&(identical(other.info, info) || other.info == info));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,recordKey,recordWriter,const DeepCollectionEquality().hash(members),mostRecentUpdate,info);

@override
String toString() {
  return 'Community(recordKey: $recordKey, recordWriter: $recordWriter, members: $members, mostRecentUpdate: $mostRecentUpdate, info: $info)';
}


}

/// @nodoc
abstract mixin class $CommunityCopyWith<$Res>  {
  factory $CommunityCopyWith(Community value, $Res Function(Community) _then) = _$CommunityCopyWithImpl;
@useResult
$Res call({
 RecordKey recordKey, KeyPair recordWriter, List<Member> members, DateTime mostRecentUpdate, CommunityInfo? info
});


$CommunityInfoCopyWith<$Res>? get info;

}
/// @nodoc
class _$CommunityCopyWithImpl<$Res>
    implements $CommunityCopyWith<$Res> {
  _$CommunityCopyWithImpl(this._self, this._then);

  final Community _self;
  final $Res Function(Community) _then;

/// Create a copy of Community
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? recordKey = null,Object? recordWriter = null,Object? members = null,Object? mostRecentUpdate = null,Object? info = freezed,}) {
  return _then(_self.copyWith(
recordKey: null == recordKey ? _self.recordKey : recordKey // ignore: cast_nullable_to_non_nullable
as RecordKey,recordWriter: null == recordWriter ? _self.recordWriter : recordWriter // ignore: cast_nullable_to_non_nullable
as KeyPair,members: null == members ? _self.members : members // ignore: cast_nullable_to_non_nullable
as List<Member>,mostRecentUpdate: null == mostRecentUpdate ? _self.mostRecentUpdate : mostRecentUpdate // ignore: cast_nullable_to_non_nullable
as DateTime,info: freezed == info ? _self.info : info // ignore: cast_nullable_to_non_nullable
as CommunityInfo?,
  ));
}
/// Create a copy of Community
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CommunityInfoCopyWith<$Res>? get info {
    if (_self.info == null) {
    return null;
  }

  return $CommunityInfoCopyWith<$Res>(_self.info!, (value) {
    return _then(_self.copyWith(info: value));
  });
}
}


/// Adds pattern-matching-related methods to [Community].
extension CommunityPatterns on Community {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Community value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Community() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Community value)  $default,){
final _that = this;
switch (_that) {
case _Community():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Community value)?  $default,){
final _that = this;
switch (_that) {
case _Community() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( RecordKey recordKey,  KeyPair recordWriter,  List<Member> members,  DateTime mostRecentUpdate,  CommunityInfo? info)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Community() when $default != null:
return $default(_that.recordKey,_that.recordWriter,_that.members,_that.mostRecentUpdate,_that.info);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( RecordKey recordKey,  KeyPair recordWriter,  List<Member> members,  DateTime mostRecentUpdate,  CommunityInfo? info)  $default,) {final _that = this;
switch (_that) {
case _Community():
return $default(_that.recordKey,_that.recordWriter,_that.members,_that.mostRecentUpdate,_that.info);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( RecordKey recordKey,  KeyPair recordWriter,  List<Member> members,  DateTime mostRecentUpdate,  CommunityInfo? info)?  $default,) {final _that = this;
switch (_that) {
case _Community() when $default != null:
return $default(_that.recordKey,_that.recordWriter,_that.members,_that.mostRecentUpdate,_that.info);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Community implements Community {
  const _Community({required this.recordKey, required this.recordWriter, required final  List<Member> members, required this.mostRecentUpdate, this.info}): _members = members;
  factory _Community.fromJson(Map<String, dynamic> json) => _$CommunityFromJson(json);

/// Key of my community member DHT record
@override final  RecordKey recordKey;
/// Writer of my community member DHT record
@override final  KeyPair recordWriter;
/// Community members
 final  List<Member> _members;
/// Community members
@override List<Member> get members {
  if (_members is EqualUnmodifiableListView) return _members;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_members);
}

/// Timestamp of most recent update
@override final  DateTime mostRecentUpdate;
/// Community information, might not directly be available at invite time
@override final  CommunityInfo? info;

/// Create a copy of Community
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CommunityCopyWith<_Community> get copyWith => __$CommunityCopyWithImpl<_Community>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CommunityToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Community&&(identical(other.recordKey, recordKey) || other.recordKey == recordKey)&&(identical(other.recordWriter, recordWriter) || other.recordWriter == recordWriter)&&const DeepCollectionEquality().equals(other._members, _members)&&(identical(other.mostRecentUpdate, mostRecentUpdate) || other.mostRecentUpdate == mostRecentUpdate)&&(identical(other.info, info) || other.info == info));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,recordKey,recordWriter,const DeepCollectionEquality().hash(_members),mostRecentUpdate,info);

@override
String toString() {
  return 'Community(recordKey: $recordKey, recordWriter: $recordWriter, members: $members, mostRecentUpdate: $mostRecentUpdate, info: $info)';
}


}

/// @nodoc
abstract mixin class _$CommunityCopyWith<$Res> implements $CommunityCopyWith<$Res> {
  factory _$CommunityCopyWith(_Community value, $Res Function(_Community) _then) = __$CommunityCopyWithImpl;
@override @useResult
$Res call({
 RecordKey recordKey, KeyPair recordWriter, List<Member> members, DateTime mostRecentUpdate, CommunityInfo? info
});


@override $CommunityInfoCopyWith<$Res>? get info;

}
/// @nodoc
class __$CommunityCopyWithImpl<$Res>
    implements _$CommunityCopyWith<$Res> {
  __$CommunityCopyWithImpl(this._self, this._then);

  final _Community _self;
  final $Res Function(_Community) _then;

/// Create a copy of Community
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? recordKey = null,Object? recordWriter = null,Object? members = null,Object? mostRecentUpdate = null,Object? info = freezed,}) {
  return _then(_Community(
recordKey: null == recordKey ? _self.recordKey : recordKey // ignore: cast_nullable_to_non_nullable
as RecordKey,recordWriter: null == recordWriter ? _self.recordWriter : recordWriter // ignore: cast_nullable_to_non_nullable
as KeyPair,members: null == members ? _self._members : members // ignore: cast_nullable_to_non_nullable
as List<Member>,mostRecentUpdate: null == mostRecentUpdate ? _self.mostRecentUpdate : mostRecentUpdate // ignore: cast_nullable_to_non_nullable
as DateTime,info: freezed == info ? _self.info : info // ignore: cast_nullable_to_non_nullable
as CommunityInfo?,
  ));
}

/// Create a copy of Community
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CommunityInfoCopyWith<$Res>? get info {
    if (_self.info == null) {
    return null;
  }

  return $CommunityInfoCopyWith<$Res>(_self.info!, (value) {
    return _then(_self.copyWith(info: value));
  });
}
}

/// @nodoc
mixin _$CommunityIntroduction {

 String get communityName; String get theirName; String get organizerComment; KeyPair get myKeyPair; bool get deferred;// FIXME(LGro)
// DhtSettings? theirSharingSettings,
 ContactDetails? get theirDetails; Map<String, ContactAddressLocation>? get addressLocations; Map<String, ContactTemporaryLocation>? get temporaryLocations;
/// Create a copy of CommunityIntroduction
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CommunityIntroductionCopyWith<CommunityIntroduction> get copyWith => _$CommunityIntroductionCopyWithImpl<CommunityIntroduction>(this as CommunityIntroduction, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CommunityIntroduction&&(identical(other.communityName, communityName) || other.communityName == communityName)&&(identical(other.theirName, theirName) || other.theirName == theirName)&&(identical(other.organizerComment, organizerComment) || other.organizerComment == organizerComment)&&(identical(other.myKeyPair, myKeyPair) || other.myKeyPair == myKeyPair)&&(identical(other.deferred, deferred) || other.deferred == deferred)&&(identical(other.theirDetails, theirDetails) || other.theirDetails == theirDetails)&&const DeepCollectionEquality().equals(other.addressLocations, addressLocations)&&const DeepCollectionEquality().equals(other.temporaryLocations, temporaryLocations));
}


@override
int get hashCode => Object.hash(runtimeType,communityName,theirName,organizerComment,myKeyPair,deferred,theirDetails,const DeepCollectionEquality().hash(addressLocations),const DeepCollectionEquality().hash(temporaryLocations));

@override
String toString() {
  return 'CommunityIntroduction(communityName: $communityName, theirName: $theirName, organizerComment: $organizerComment, myKeyPair: $myKeyPair, deferred: $deferred, theirDetails: $theirDetails, addressLocations: $addressLocations, temporaryLocations: $temporaryLocations)';
}


}

/// @nodoc
abstract mixin class $CommunityIntroductionCopyWith<$Res>  {
  factory $CommunityIntroductionCopyWith(CommunityIntroduction value, $Res Function(CommunityIntroduction) _then) = _$CommunityIntroductionCopyWithImpl;
@useResult
$Res call({
 String communityName, String theirName, String organizerComment, KeyPair myKeyPair, bool deferred, ContactDetails? theirDetails, Map<String, ContactAddressLocation>? addressLocations, Map<String, ContactTemporaryLocation>? temporaryLocations
});


$ContactDetailsCopyWith<$Res>? get theirDetails;

}
/// @nodoc
class _$CommunityIntroductionCopyWithImpl<$Res>
    implements $CommunityIntroductionCopyWith<$Res> {
  _$CommunityIntroductionCopyWithImpl(this._self, this._then);

  final CommunityIntroduction _self;
  final $Res Function(CommunityIntroduction) _then;

/// Create a copy of CommunityIntroduction
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? communityName = null,Object? theirName = null,Object? organizerComment = null,Object? myKeyPair = null,Object? deferred = null,Object? theirDetails = freezed,Object? addressLocations = freezed,Object? temporaryLocations = freezed,}) {
  return _then(_self.copyWith(
communityName: null == communityName ? _self.communityName : communityName // ignore: cast_nullable_to_non_nullable
as String,theirName: null == theirName ? _self.theirName : theirName // ignore: cast_nullable_to_non_nullable
as String,organizerComment: null == organizerComment ? _self.organizerComment : organizerComment // ignore: cast_nullable_to_non_nullable
as String,myKeyPair: null == myKeyPair ? _self.myKeyPair : myKeyPair // ignore: cast_nullable_to_non_nullable
as KeyPair,deferred: null == deferred ? _self.deferred : deferred // ignore: cast_nullable_to_non_nullable
as bool,theirDetails: freezed == theirDetails ? _self.theirDetails : theirDetails // ignore: cast_nullable_to_non_nullable
as ContactDetails?,addressLocations: freezed == addressLocations ? _self.addressLocations : addressLocations // ignore: cast_nullable_to_non_nullable
as Map<String, ContactAddressLocation>?,temporaryLocations: freezed == temporaryLocations ? _self.temporaryLocations : temporaryLocations // ignore: cast_nullable_to_non_nullable
as Map<String, ContactTemporaryLocation>?,
  ));
}
/// Create a copy of CommunityIntroduction
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ContactDetailsCopyWith<$Res>? get theirDetails {
    if (_self.theirDetails == null) {
    return null;
  }

  return $ContactDetailsCopyWith<$Res>(_self.theirDetails!, (value) {
    return _then(_self.copyWith(theirDetails: value));
  });
}
}


/// Adds pattern-matching-related methods to [CommunityIntroduction].
extension CommunityIntroductionPatterns on CommunityIntroduction {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CommunityIntroduction value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CommunityIntroduction() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CommunityIntroduction value)  $default,){
final _that = this;
switch (_that) {
case _CommunityIntroduction():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CommunityIntroduction value)?  $default,){
final _that = this;
switch (_that) {
case _CommunityIntroduction() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String communityName,  String theirName,  String organizerComment,  KeyPair myKeyPair,  bool deferred,  ContactDetails? theirDetails,  Map<String, ContactAddressLocation>? addressLocations,  Map<String, ContactTemporaryLocation>? temporaryLocations)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CommunityIntroduction() when $default != null:
return $default(_that.communityName,_that.theirName,_that.organizerComment,_that.myKeyPair,_that.deferred,_that.theirDetails,_that.addressLocations,_that.temporaryLocations);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String communityName,  String theirName,  String organizerComment,  KeyPair myKeyPair,  bool deferred,  ContactDetails? theirDetails,  Map<String, ContactAddressLocation>? addressLocations,  Map<String, ContactTemporaryLocation>? temporaryLocations)  $default,) {final _that = this;
switch (_that) {
case _CommunityIntroduction():
return $default(_that.communityName,_that.theirName,_that.organizerComment,_that.myKeyPair,_that.deferred,_that.theirDetails,_that.addressLocations,_that.temporaryLocations);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String communityName,  String theirName,  String organizerComment,  KeyPair myKeyPair,  bool deferred,  ContactDetails? theirDetails,  Map<String, ContactAddressLocation>? addressLocations,  Map<String, ContactTemporaryLocation>? temporaryLocations)?  $default,) {final _that = this;
switch (_that) {
case _CommunityIntroduction() when $default != null:
return $default(_that.communityName,_that.theirName,_that.organizerComment,_that.myKeyPair,_that.deferred,_that.theirDetails,_that.addressLocations,_that.temporaryLocations);case _:
  return null;

}
}

}

/// @nodoc


class _CommunityIntroduction implements CommunityIntroduction {
   _CommunityIntroduction({required this.communityName, required this.theirName, required this.organizerComment, required this.myKeyPair, this.deferred = false, this.theirDetails, final  Map<String, ContactAddressLocation>? addressLocations, final  Map<String, ContactTemporaryLocation>? temporaryLocations}): _addressLocations = addressLocations,_temporaryLocations = temporaryLocations;
  

@override final  String communityName;
@override final  String theirName;
@override final  String organizerComment;
@override final  KeyPair myKeyPair;
@override@JsonKey() final  bool deferred;
// FIXME(LGro)
// DhtSettings? theirSharingSettings,
@override final  ContactDetails? theirDetails;
 final  Map<String, ContactAddressLocation>? _addressLocations;
@override Map<String, ContactAddressLocation>? get addressLocations {
  final value = _addressLocations;
  if (value == null) return null;
  if (_addressLocations is EqualUnmodifiableMapView) return _addressLocations;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

 final  Map<String, ContactTemporaryLocation>? _temporaryLocations;
@override Map<String, ContactTemporaryLocation>? get temporaryLocations {
  final value = _temporaryLocations;
  if (value == null) return null;
  if (_temporaryLocations is EqualUnmodifiableMapView) return _temporaryLocations;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}


/// Create a copy of CommunityIntroduction
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CommunityIntroductionCopyWith<_CommunityIntroduction> get copyWith => __$CommunityIntroductionCopyWithImpl<_CommunityIntroduction>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CommunityIntroduction&&(identical(other.communityName, communityName) || other.communityName == communityName)&&(identical(other.theirName, theirName) || other.theirName == theirName)&&(identical(other.organizerComment, organizerComment) || other.organizerComment == organizerComment)&&(identical(other.myKeyPair, myKeyPair) || other.myKeyPair == myKeyPair)&&(identical(other.deferred, deferred) || other.deferred == deferred)&&(identical(other.theirDetails, theirDetails) || other.theirDetails == theirDetails)&&const DeepCollectionEquality().equals(other._addressLocations, _addressLocations)&&const DeepCollectionEquality().equals(other._temporaryLocations, _temporaryLocations));
}


@override
int get hashCode => Object.hash(runtimeType,communityName,theirName,organizerComment,myKeyPair,deferred,theirDetails,const DeepCollectionEquality().hash(_addressLocations),const DeepCollectionEquality().hash(_temporaryLocations));

@override
String toString() {
  return 'CommunityIntroduction(communityName: $communityName, theirName: $theirName, organizerComment: $organizerComment, myKeyPair: $myKeyPair, deferred: $deferred, theirDetails: $theirDetails, addressLocations: $addressLocations, temporaryLocations: $temporaryLocations)';
}


}

/// @nodoc
abstract mixin class _$CommunityIntroductionCopyWith<$Res> implements $CommunityIntroductionCopyWith<$Res> {
  factory _$CommunityIntroductionCopyWith(_CommunityIntroduction value, $Res Function(_CommunityIntroduction) _then) = __$CommunityIntroductionCopyWithImpl;
@override @useResult
$Res call({
 String communityName, String theirName, String organizerComment, KeyPair myKeyPair, bool deferred, ContactDetails? theirDetails, Map<String, ContactAddressLocation>? addressLocations, Map<String, ContactTemporaryLocation>? temporaryLocations
});


@override $ContactDetailsCopyWith<$Res>? get theirDetails;

}
/// @nodoc
class __$CommunityIntroductionCopyWithImpl<$Res>
    implements _$CommunityIntroductionCopyWith<$Res> {
  __$CommunityIntroductionCopyWithImpl(this._self, this._then);

  final _CommunityIntroduction _self;
  final $Res Function(_CommunityIntroduction) _then;

/// Create a copy of CommunityIntroduction
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? communityName = null,Object? theirName = null,Object? organizerComment = null,Object? myKeyPair = null,Object? deferred = null,Object? theirDetails = freezed,Object? addressLocations = freezed,Object? temporaryLocations = freezed,}) {
  return _then(_CommunityIntroduction(
communityName: null == communityName ? _self.communityName : communityName // ignore: cast_nullable_to_non_nullable
as String,theirName: null == theirName ? _self.theirName : theirName // ignore: cast_nullable_to_non_nullable
as String,organizerComment: null == organizerComment ? _self.organizerComment : organizerComment // ignore: cast_nullable_to_non_nullable
as String,myKeyPair: null == myKeyPair ? _self.myKeyPair : myKeyPair // ignore: cast_nullable_to_non_nullable
as KeyPair,deferred: null == deferred ? _self.deferred : deferred // ignore: cast_nullable_to_non_nullable
as bool,theirDetails: freezed == theirDetails ? _self.theirDetails : theirDetails // ignore: cast_nullable_to_non_nullable
as ContactDetails?,addressLocations: freezed == addressLocations ? _self._addressLocations : addressLocations // ignore: cast_nullable_to_non_nullable
as Map<String, ContactAddressLocation>?,temporaryLocations: freezed == temporaryLocations ? _self._temporaryLocations : temporaryLocations // ignore: cast_nullable_to_non_nullable
as Map<String, ContactTemporaryLocation>?,
  ));
}

/// Create a copy of CommunityIntroduction
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ContactDetailsCopyWith<$Res>? get theirDetails {
    if (_self.theirDetails == null) {
    return null;
  }

  return $ContactDetailsCopyWith<$Res>(_self.theirDetails!, (value) {
    return _then(_self.copyWith(theirDetails: value));
  });
}
}

// dart format on
