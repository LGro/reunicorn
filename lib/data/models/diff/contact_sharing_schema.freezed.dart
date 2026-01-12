// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'contact_sharing_schema.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ContactSharingSchemaDiff {

 ContactDetailsDiff get details; Map<String, DiffStatus> get addressLocations; Map<String, DiffStatus> get temporaryLocations; DiffStatus get introductions;
/// Create a copy of ContactSharingSchemaDiff
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ContactSharingSchemaDiffCopyWith<ContactSharingSchemaDiff> get copyWith => _$ContactSharingSchemaDiffCopyWithImpl<ContactSharingSchemaDiff>(this as ContactSharingSchemaDiff, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ContactSharingSchemaDiff&&(identical(other.details, details) || other.details == details)&&const DeepCollectionEquality().equals(other.addressLocations, addressLocations)&&const DeepCollectionEquality().equals(other.temporaryLocations, temporaryLocations)&&(identical(other.introductions, introductions) || other.introductions == introductions));
}


@override
int get hashCode => Object.hash(runtimeType,details,const DeepCollectionEquality().hash(addressLocations),const DeepCollectionEquality().hash(temporaryLocations),introductions);

@override
String toString() {
  return 'ContactSharingSchemaDiff(details: $details, addressLocations: $addressLocations, temporaryLocations: $temporaryLocations, introductions: $introductions)';
}


}

/// @nodoc
abstract mixin class $ContactSharingSchemaDiffCopyWith<$Res>  {
  factory $ContactSharingSchemaDiffCopyWith(ContactSharingSchemaDiff value, $Res Function(ContactSharingSchemaDiff) _then) = _$ContactSharingSchemaDiffCopyWithImpl;
@useResult
$Res call({
 ContactDetailsDiff details, Map<String, DiffStatus> addressLocations, Map<String, DiffStatus> temporaryLocations, DiffStatus introductions
});


$ContactDetailsDiffCopyWith<$Res> get details;

}
/// @nodoc
class _$ContactSharingSchemaDiffCopyWithImpl<$Res>
    implements $ContactSharingSchemaDiffCopyWith<$Res> {
  _$ContactSharingSchemaDiffCopyWithImpl(this._self, this._then);

  final ContactSharingSchemaDiff _self;
  final $Res Function(ContactSharingSchemaDiff) _then;

/// Create a copy of ContactSharingSchemaDiff
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? details = null,Object? addressLocations = null,Object? temporaryLocations = null,Object? introductions = null,}) {
  return _then(_self.copyWith(
details: null == details ? _self.details : details // ignore: cast_nullable_to_non_nullable
as ContactDetailsDiff,addressLocations: null == addressLocations ? _self.addressLocations : addressLocations // ignore: cast_nullable_to_non_nullable
as Map<String, DiffStatus>,temporaryLocations: null == temporaryLocations ? _self.temporaryLocations : temporaryLocations // ignore: cast_nullable_to_non_nullable
as Map<String, DiffStatus>,introductions: null == introductions ? _self.introductions : introductions // ignore: cast_nullable_to_non_nullable
as DiffStatus,
  ));
}
/// Create a copy of ContactSharingSchemaDiff
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ContactDetailsDiffCopyWith<$Res> get details {
  
  return $ContactDetailsDiffCopyWith<$Res>(_self.details, (value) {
    return _then(_self.copyWith(details: value));
  });
}
}


/// Adds pattern-matching-related methods to [ContactSharingSchemaDiff].
extension ContactSharingSchemaDiffPatterns on ContactSharingSchemaDiff {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ContactSharingSchemaDiff value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ContactSharingSchemaDiff() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ContactSharingSchemaDiff value)  $default,){
final _that = this;
switch (_that) {
case _ContactSharingSchemaDiff():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ContactSharingSchemaDiff value)?  $default,){
final _that = this;
switch (_that) {
case _ContactSharingSchemaDiff() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( ContactDetailsDiff details,  Map<String, DiffStatus> addressLocations,  Map<String, DiffStatus> temporaryLocations,  DiffStatus introductions)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ContactSharingSchemaDiff() when $default != null:
return $default(_that.details,_that.addressLocations,_that.temporaryLocations,_that.introductions);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( ContactDetailsDiff details,  Map<String, DiffStatus> addressLocations,  Map<String, DiffStatus> temporaryLocations,  DiffStatus introductions)  $default,) {final _that = this;
switch (_that) {
case _ContactSharingSchemaDiff():
return $default(_that.details,_that.addressLocations,_that.temporaryLocations,_that.introductions);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( ContactDetailsDiff details,  Map<String, DiffStatus> addressLocations,  Map<String, DiffStatus> temporaryLocations,  DiffStatus introductions)?  $default,) {final _that = this;
switch (_that) {
case _ContactSharingSchemaDiff() when $default != null:
return $default(_that.details,_that.addressLocations,_that.temporaryLocations,_that.introductions);case _:
  return null;

}
}

}

/// @nodoc


class _ContactSharingSchemaDiff implements ContactSharingSchemaDiff {
  const _ContactSharingSchemaDiff({required this.details, required final  Map<String, DiffStatus> addressLocations, required final  Map<String, DiffStatus> temporaryLocations, required this.introductions}): _addressLocations = addressLocations,_temporaryLocations = temporaryLocations;
  

@override final  ContactDetailsDiff details;
 final  Map<String, DiffStatus> _addressLocations;
@override Map<String, DiffStatus> get addressLocations {
  if (_addressLocations is EqualUnmodifiableMapView) return _addressLocations;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_addressLocations);
}

 final  Map<String, DiffStatus> _temporaryLocations;
@override Map<String, DiffStatus> get temporaryLocations {
  if (_temporaryLocations is EqualUnmodifiableMapView) return _temporaryLocations;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_temporaryLocations);
}

@override final  DiffStatus introductions;

/// Create a copy of ContactSharingSchemaDiff
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ContactSharingSchemaDiffCopyWith<_ContactSharingSchemaDiff> get copyWith => __$ContactSharingSchemaDiffCopyWithImpl<_ContactSharingSchemaDiff>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ContactSharingSchemaDiff&&(identical(other.details, details) || other.details == details)&&const DeepCollectionEquality().equals(other._addressLocations, _addressLocations)&&const DeepCollectionEquality().equals(other._temporaryLocations, _temporaryLocations)&&(identical(other.introductions, introductions) || other.introductions == introductions));
}


@override
int get hashCode => Object.hash(runtimeType,details,const DeepCollectionEquality().hash(_addressLocations),const DeepCollectionEquality().hash(_temporaryLocations),introductions);

@override
String toString() {
  return 'ContactSharingSchemaDiff(details: $details, addressLocations: $addressLocations, temporaryLocations: $temporaryLocations, introductions: $introductions)';
}


}

/// @nodoc
abstract mixin class _$ContactSharingSchemaDiffCopyWith<$Res> implements $ContactSharingSchemaDiffCopyWith<$Res> {
  factory _$ContactSharingSchemaDiffCopyWith(_ContactSharingSchemaDiff value, $Res Function(_ContactSharingSchemaDiff) _then) = __$ContactSharingSchemaDiffCopyWithImpl;
@override @useResult
$Res call({
 ContactDetailsDiff details, Map<String, DiffStatus> addressLocations, Map<String, DiffStatus> temporaryLocations, DiffStatus introductions
});


@override $ContactDetailsDiffCopyWith<$Res> get details;

}
/// @nodoc
class __$ContactSharingSchemaDiffCopyWithImpl<$Res>
    implements _$ContactSharingSchemaDiffCopyWith<$Res> {
  __$ContactSharingSchemaDiffCopyWithImpl(this._self, this._then);

  final _ContactSharingSchemaDiff _self;
  final $Res Function(_ContactSharingSchemaDiff) _then;

/// Create a copy of ContactSharingSchemaDiff
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? details = null,Object? addressLocations = null,Object? temporaryLocations = null,Object? introductions = null,}) {
  return _then(_ContactSharingSchemaDiff(
details: null == details ? _self.details : details // ignore: cast_nullable_to_non_nullable
as ContactDetailsDiff,addressLocations: null == addressLocations ? _self._addressLocations : addressLocations // ignore: cast_nullable_to_non_nullable
as Map<String, DiffStatus>,temporaryLocations: null == temporaryLocations ? _self._temporaryLocations : temporaryLocations // ignore: cast_nullable_to_non_nullable
as Map<String, DiffStatus>,introductions: null == introductions ? _self.introductions : introductions // ignore: cast_nullable_to_non_nullable
as DiffStatus,
  ));
}

/// Create a copy of ContactSharingSchemaDiff
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ContactDetailsDiffCopyWith<$Res> get details {
  
  return $ContactDetailsDiffCopyWith<$Res>(_self.details, (value) {
    return _then(_self.copyWith(details: value));
  });
}
}

// dart format on
