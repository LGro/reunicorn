// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'schema.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ContactSharingSchemaV3 {

/// Shared contact details of author
 ContactDetails get details;/// Shared address locations of author
 Map<String, ContactAddressLocation> get addressLocations;/// Shared temporary locations of author
 Map<String, ContactTemporaryLocation> get temporaryLocations;/// Attestations for connections between the author and their contacts
 List<String> get connectionAttestations;/// Introduction proposals by the author for the recipient
 List<ContactIntroduction> get introductions;/// Long lived identity key, used for example to derive a connection
/// attestation for enabling others to discover shared contacts
 PublicKey? get identityKey;/// Author's public key the recipient can use to securely introduce them to
/// others
 PublicKey? get introductionKey;/// Recipient specific push notification topic the recipient can use to
/// trigger notifications for the author via the Reunicorn Veilid Push Bridge
 String? get pushNotificationTopic;// TODO(LGro): In case we bring this back, make sure it is excluded from the equality and hash checks to not trigger unwanted profile update writes
// late final DateTime? mostRecentUpdate;?? DateTime.now();
/// Schema version to facilitate data migration
 int get schemaVersion;
/// Create a copy of ContactSharingSchemaV3
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ContactSharingSchemaV3CopyWith<ContactSharingSchemaV3> get copyWith => _$ContactSharingSchemaV3CopyWithImpl<ContactSharingSchemaV3>(this as ContactSharingSchemaV3, _$identity);

  /// Serializes this ContactSharingSchemaV3 to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ContactSharingSchemaV3&&(identical(other.details, details) || other.details == details)&&const DeepCollectionEquality().equals(other.addressLocations, addressLocations)&&const DeepCollectionEquality().equals(other.temporaryLocations, temporaryLocations)&&const DeepCollectionEquality().equals(other.connectionAttestations, connectionAttestations)&&const DeepCollectionEquality().equals(other.introductions, introductions)&&(identical(other.identityKey, identityKey) || other.identityKey == identityKey)&&(identical(other.introductionKey, introductionKey) || other.introductionKey == introductionKey)&&(identical(other.pushNotificationTopic, pushNotificationTopic) || other.pushNotificationTopic == pushNotificationTopic)&&(identical(other.schemaVersion, schemaVersion) || other.schemaVersion == schemaVersion));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,details,const DeepCollectionEquality().hash(addressLocations),const DeepCollectionEquality().hash(temporaryLocations),const DeepCollectionEquality().hash(connectionAttestations),const DeepCollectionEquality().hash(introductions),identityKey,introductionKey,pushNotificationTopic,schemaVersion);

@override
String toString() {
  return 'ContactSharingSchemaV3(details: $details, addressLocations: $addressLocations, temporaryLocations: $temporaryLocations, connectionAttestations: $connectionAttestations, introductions: $introductions, identityKey: $identityKey, introductionKey: $introductionKey, pushNotificationTopic: $pushNotificationTopic, schemaVersion: $schemaVersion)';
}


}

/// @nodoc
abstract mixin class $ContactSharingSchemaV3CopyWith<$Res>  {
  factory $ContactSharingSchemaV3CopyWith(ContactSharingSchemaV3 value, $Res Function(ContactSharingSchemaV3) _then) = _$ContactSharingSchemaV3CopyWithImpl;
@useResult
$Res call({
 ContactDetails details, Map<String, ContactAddressLocation> addressLocations, Map<String, ContactTemporaryLocation> temporaryLocations, List<String> connectionAttestations, List<ContactIntroduction> introductions, PublicKey? identityKey, PublicKey? introductionKey, String? pushNotificationTopic, int schemaVersion
});


$ContactDetailsCopyWith<$Res> get details;

}
/// @nodoc
class _$ContactSharingSchemaV3CopyWithImpl<$Res>
    implements $ContactSharingSchemaV3CopyWith<$Res> {
  _$ContactSharingSchemaV3CopyWithImpl(this._self, this._then);

  final ContactSharingSchemaV3 _self;
  final $Res Function(ContactSharingSchemaV3) _then;

/// Create a copy of ContactSharingSchemaV3
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? details = null,Object? addressLocations = null,Object? temporaryLocations = null,Object? connectionAttestations = null,Object? introductions = null,Object? identityKey = freezed,Object? introductionKey = freezed,Object? pushNotificationTopic = freezed,Object? schemaVersion = null,}) {
  return _then(_self.copyWith(
details: null == details ? _self.details : details // ignore: cast_nullable_to_non_nullable
as ContactDetails,addressLocations: null == addressLocations ? _self.addressLocations : addressLocations // ignore: cast_nullable_to_non_nullable
as Map<String, ContactAddressLocation>,temporaryLocations: null == temporaryLocations ? _self.temporaryLocations : temporaryLocations // ignore: cast_nullable_to_non_nullable
as Map<String, ContactTemporaryLocation>,connectionAttestations: null == connectionAttestations ? _self.connectionAttestations : connectionAttestations // ignore: cast_nullable_to_non_nullable
as List<String>,introductions: null == introductions ? _self.introductions : introductions // ignore: cast_nullable_to_non_nullable
as List<ContactIntroduction>,identityKey: freezed == identityKey ? _self.identityKey : identityKey // ignore: cast_nullable_to_non_nullable
as PublicKey?,introductionKey: freezed == introductionKey ? _self.introductionKey : introductionKey // ignore: cast_nullable_to_non_nullable
as PublicKey?,pushNotificationTopic: freezed == pushNotificationTopic ? _self.pushNotificationTopic : pushNotificationTopic // ignore: cast_nullable_to_non_nullable
as String?,schemaVersion: null == schemaVersion ? _self.schemaVersion : schemaVersion // ignore: cast_nullable_to_non_nullable
as int,
  ));
}
/// Create a copy of ContactSharingSchemaV3
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ContactDetailsCopyWith<$Res> get details {
  
  return $ContactDetailsCopyWith<$Res>(_self.details, (value) {
    return _then(_self.copyWith(details: value));
  });
}
}


/// Adds pattern-matching-related methods to [ContactSharingSchemaV3].
extension ContactSharingSchemaV3Patterns on ContactSharingSchemaV3 {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ContactSharingSchemaV3 value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ContactSharingSchemaV3() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ContactSharingSchemaV3 value)  $default,){
final _that = this;
switch (_that) {
case _ContactSharingSchemaV3():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ContactSharingSchemaV3 value)?  $default,){
final _that = this;
switch (_that) {
case _ContactSharingSchemaV3() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( ContactDetails details,  Map<String, ContactAddressLocation> addressLocations,  Map<String, ContactTemporaryLocation> temporaryLocations,  List<String> connectionAttestations,  List<ContactIntroduction> introductions,  PublicKey? identityKey,  PublicKey? introductionKey,  String? pushNotificationTopic,  int schemaVersion)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ContactSharingSchemaV3() when $default != null:
return $default(_that.details,_that.addressLocations,_that.temporaryLocations,_that.connectionAttestations,_that.introductions,_that.identityKey,_that.introductionKey,_that.pushNotificationTopic,_that.schemaVersion);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( ContactDetails details,  Map<String, ContactAddressLocation> addressLocations,  Map<String, ContactTemporaryLocation> temporaryLocations,  List<String> connectionAttestations,  List<ContactIntroduction> introductions,  PublicKey? identityKey,  PublicKey? introductionKey,  String? pushNotificationTopic,  int schemaVersion)  $default,) {final _that = this;
switch (_that) {
case _ContactSharingSchemaV3():
return $default(_that.details,_that.addressLocations,_that.temporaryLocations,_that.connectionAttestations,_that.introductions,_that.identityKey,_that.introductionKey,_that.pushNotificationTopic,_that.schemaVersion);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( ContactDetails details,  Map<String, ContactAddressLocation> addressLocations,  Map<String, ContactTemporaryLocation> temporaryLocations,  List<String> connectionAttestations,  List<ContactIntroduction> introductions,  PublicKey? identityKey,  PublicKey? introductionKey,  String? pushNotificationTopic,  int schemaVersion)?  $default,) {final _that = this;
switch (_that) {
case _ContactSharingSchemaV3() when $default != null:
return $default(_that.details,_that.addressLocations,_that.temporaryLocations,_that.connectionAttestations,_that.introductions,_that.identityKey,_that.introductionKey,_that.pushNotificationTopic,_that.schemaVersion);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ContactSharingSchemaV3 extends ContactSharingSchemaV3 {
  const _ContactSharingSchemaV3({required this.details, final  Map<String, ContactAddressLocation> addressLocations = const {}, final  Map<String, ContactTemporaryLocation> temporaryLocations = const {}, final  List<String> connectionAttestations = const [], final  List<ContactIntroduction> introductions = const [], this.identityKey, this.introductionKey, this.pushNotificationTopic, this.schemaVersion = 3}): _addressLocations = addressLocations,_temporaryLocations = temporaryLocations,_connectionAttestations = connectionAttestations,_introductions = introductions,super._();
  factory _ContactSharingSchemaV3.fromJson(Map<String, dynamic> json) => _$ContactSharingSchemaV3FromJson(json);

/// Shared contact details of author
@override final  ContactDetails details;
/// Shared address locations of author
 final  Map<String, ContactAddressLocation> _addressLocations;
/// Shared address locations of author
@override@JsonKey() Map<String, ContactAddressLocation> get addressLocations {
  if (_addressLocations is EqualUnmodifiableMapView) return _addressLocations;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_addressLocations);
}

/// Shared temporary locations of author
 final  Map<String, ContactTemporaryLocation> _temporaryLocations;
/// Shared temporary locations of author
@override@JsonKey() Map<String, ContactTemporaryLocation> get temporaryLocations {
  if (_temporaryLocations is EqualUnmodifiableMapView) return _temporaryLocations;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_temporaryLocations);
}

/// Attestations for connections between the author and their contacts
 final  List<String> _connectionAttestations;
/// Attestations for connections between the author and their contacts
@override@JsonKey() List<String> get connectionAttestations {
  if (_connectionAttestations is EqualUnmodifiableListView) return _connectionAttestations;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_connectionAttestations);
}

/// Introduction proposals by the author for the recipient
 final  List<ContactIntroduction> _introductions;
/// Introduction proposals by the author for the recipient
@override@JsonKey() List<ContactIntroduction> get introductions {
  if (_introductions is EqualUnmodifiableListView) return _introductions;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_introductions);
}

/// Long lived identity key, used for example to derive a connection
/// attestation for enabling others to discover shared contacts
@override final  PublicKey? identityKey;
/// Author's public key the recipient can use to securely introduce them to
/// others
@override final  PublicKey? introductionKey;
/// Recipient specific push notification topic the recipient can use to
/// trigger notifications for the author via the Reunicorn Veilid Push Bridge
@override final  String? pushNotificationTopic;
// TODO(LGro): In case we bring this back, make sure it is excluded from the equality and hash checks to not trigger unwanted profile update writes
// late final DateTime? mostRecentUpdate;?? DateTime.now();
/// Schema version to facilitate data migration
@override@JsonKey() final  int schemaVersion;

/// Create a copy of ContactSharingSchemaV3
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ContactSharingSchemaV3CopyWith<_ContactSharingSchemaV3> get copyWith => __$ContactSharingSchemaV3CopyWithImpl<_ContactSharingSchemaV3>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ContactSharingSchemaV3ToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ContactSharingSchemaV3&&(identical(other.details, details) || other.details == details)&&const DeepCollectionEquality().equals(other._addressLocations, _addressLocations)&&const DeepCollectionEquality().equals(other._temporaryLocations, _temporaryLocations)&&const DeepCollectionEquality().equals(other._connectionAttestations, _connectionAttestations)&&const DeepCollectionEquality().equals(other._introductions, _introductions)&&(identical(other.identityKey, identityKey) || other.identityKey == identityKey)&&(identical(other.introductionKey, introductionKey) || other.introductionKey == introductionKey)&&(identical(other.pushNotificationTopic, pushNotificationTopic) || other.pushNotificationTopic == pushNotificationTopic)&&(identical(other.schemaVersion, schemaVersion) || other.schemaVersion == schemaVersion));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,details,const DeepCollectionEquality().hash(_addressLocations),const DeepCollectionEquality().hash(_temporaryLocations),const DeepCollectionEquality().hash(_connectionAttestations),const DeepCollectionEquality().hash(_introductions),identityKey,introductionKey,pushNotificationTopic,schemaVersion);

@override
String toString() {
  return 'ContactSharingSchemaV3(details: $details, addressLocations: $addressLocations, temporaryLocations: $temporaryLocations, connectionAttestations: $connectionAttestations, introductions: $introductions, identityKey: $identityKey, introductionKey: $introductionKey, pushNotificationTopic: $pushNotificationTopic, schemaVersion: $schemaVersion)';
}


}

/// @nodoc
abstract mixin class _$ContactSharingSchemaV3CopyWith<$Res> implements $ContactSharingSchemaV3CopyWith<$Res> {
  factory _$ContactSharingSchemaV3CopyWith(_ContactSharingSchemaV3 value, $Res Function(_ContactSharingSchemaV3) _then) = __$ContactSharingSchemaV3CopyWithImpl;
@override @useResult
$Res call({
 ContactDetails details, Map<String, ContactAddressLocation> addressLocations, Map<String, ContactTemporaryLocation> temporaryLocations, List<String> connectionAttestations, List<ContactIntroduction> introductions, PublicKey? identityKey, PublicKey? introductionKey, String? pushNotificationTopic, int schemaVersion
});


@override $ContactDetailsCopyWith<$Res> get details;

}
/// @nodoc
class __$ContactSharingSchemaV3CopyWithImpl<$Res>
    implements _$ContactSharingSchemaV3CopyWith<$Res> {
  __$ContactSharingSchemaV3CopyWithImpl(this._self, this._then);

  final _ContactSharingSchemaV3 _self;
  final $Res Function(_ContactSharingSchemaV3) _then;

/// Create a copy of ContactSharingSchemaV3
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? details = null,Object? addressLocations = null,Object? temporaryLocations = null,Object? connectionAttestations = null,Object? introductions = null,Object? identityKey = freezed,Object? introductionKey = freezed,Object? pushNotificationTopic = freezed,Object? schemaVersion = null,}) {
  return _then(_ContactSharingSchemaV3(
details: null == details ? _self.details : details // ignore: cast_nullable_to_non_nullable
as ContactDetails,addressLocations: null == addressLocations ? _self._addressLocations : addressLocations // ignore: cast_nullable_to_non_nullable
as Map<String, ContactAddressLocation>,temporaryLocations: null == temporaryLocations ? _self._temporaryLocations : temporaryLocations // ignore: cast_nullable_to_non_nullable
as Map<String, ContactTemporaryLocation>,connectionAttestations: null == connectionAttestations ? _self._connectionAttestations : connectionAttestations // ignore: cast_nullable_to_non_nullable
as List<String>,introductions: null == introductions ? _self._introductions : introductions // ignore: cast_nullable_to_non_nullable
as List<ContactIntroduction>,identityKey: freezed == identityKey ? _self.identityKey : identityKey // ignore: cast_nullable_to_non_nullable
as PublicKey?,introductionKey: freezed == introductionKey ? _self.introductionKey : introductionKey // ignore: cast_nullable_to_non_nullable
as PublicKey?,pushNotificationTopic: freezed == pushNotificationTopic ? _self.pushNotificationTopic : pushNotificationTopic // ignore: cast_nullable_to_non_nullable
as String?,schemaVersion: null == schemaVersion ? _self.schemaVersion : schemaVersion // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

/// Create a copy of ContactSharingSchemaV3
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ContactDetailsCopyWith<$Res> get details {
  
  return $ContactDetailsCopyWith<$Res>(_self.details, (value) {
    return _then(_self.copyWith(details: value));
  });
}
}

// dart format on
