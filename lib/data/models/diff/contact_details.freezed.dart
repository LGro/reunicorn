// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'contact_details.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ContactDetailsDiff {

 DiffStatus get picture; Map<String, DiffStatus> get names; Map<String, DiffStatus> get phones; Map<String, DiffStatus> get emails; Map<String, DiffStatus> get websites; Map<String, DiffStatus> get socialMedias; Map<String, DiffStatus> get events; Map<String, DiffStatus> get organizations; Map<String, DiffStatus> get misc; Map<String, DiffStatus> get tags;
/// Create a copy of ContactDetailsDiff
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ContactDetailsDiffCopyWith<ContactDetailsDiff> get copyWith => _$ContactDetailsDiffCopyWithImpl<ContactDetailsDiff>(this as ContactDetailsDiff, _$identity);

  /// Serializes this ContactDetailsDiff to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ContactDetailsDiff&&(identical(other.picture, picture) || other.picture == picture)&&const DeepCollectionEquality().equals(other.names, names)&&const DeepCollectionEquality().equals(other.phones, phones)&&const DeepCollectionEquality().equals(other.emails, emails)&&const DeepCollectionEquality().equals(other.websites, websites)&&const DeepCollectionEquality().equals(other.socialMedias, socialMedias)&&const DeepCollectionEquality().equals(other.events, events)&&const DeepCollectionEquality().equals(other.organizations, organizations)&&const DeepCollectionEquality().equals(other.misc, misc)&&const DeepCollectionEquality().equals(other.tags, tags));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,picture,const DeepCollectionEquality().hash(names),const DeepCollectionEquality().hash(phones),const DeepCollectionEquality().hash(emails),const DeepCollectionEquality().hash(websites),const DeepCollectionEquality().hash(socialMedias),const DeepCollectionEquality().hash(events),const DeepCollectionEquality().hash(organizations),const DeepCollectionEquality().hash(misc),const DeepCollectionEquality().hash(tags));

@override
String toString() {
  return 'ContactDetailsDiff(picture: $picture, names: $names, phones: $phones, emails: $emails, websites: $websites, socialMedias: $socialMedias, events: $events, organizations: $organizations, misc: $misc, tags: $tags)';
}


}

/// @nodoc
abstract mixin class $ContactDetailsDiffCopyWith<$Res>  {
  factory $ContactDetailsDiffCopyWith(ContactDetailsDiff value, $Res Function(ContactDetailsDiff) _then) = _$ContactDetailsDiffCopyWithImpl;
@useResult
$Res call({
 DiffStatus picture, Map<String, DiffStatus> names, Map<String, DiffStatus> phones, Map<String, DiffStatus> emails, Map<String, DiffStatus> websites, Map<String, DiffStatus> socialMedias, Map<String, DiffStatus> events, Map<String, DiffStatus> organizations, Map<String, DiffStatus> misc, Map<String, DiffStatus> tags
});




}
/// @nodoc
class _$ContactDetailsDiffCopyWithImpl<$Res>
    implements $ContactDetailsDiffCopyWith<$Res> {
  _$ContactDetailsDiffCopyWithImpl(this._self, this._then);

  final ContactDetailsDiff _self;
  final $Res Function(ContactDetailsDiff) _then;

/// Create a copy of ContactDetailsDiff
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? picture = null,Object? names = null,Object? phones = null,Object? emails = null,Object? websites = null,Object? socialMedias = null,Object? events = null,Object? organizations = null,Object? misc = null,Object? tags = null,}) {
  return _then(_self.copyWith(
picture: null == picture ? _self.picture : picture // ignore: cast_nullable_to_non_nullable
as DiffStatus,names: null == names ? _self.names : names // ignore: cast_nullable_to_non_nullable
as Map<String, DiffStatus>,phones: null == phones ? _self.phones : phones // ignore: cast_nullable_to_non_nullable
as Map<String, DiffStatus>,emails: null == emails ? _self.emails : emails // ignore: cast_nullable_to_non_nullable
as Map<String, DiffStatus>,websites: null == websites ? _self.websites : websites // ignore: cast_nullable_to_non_nullable
as Map<String, DiffStatus>,socialMedias: null == socialMedias ? _self.socialMedias : socialMedias // ignore: cast_nullable_to_non_nullable
as Map<String, DiffStatus>,events: null == events ? _self.events : events // ignore: cast_nullable_to_non_nullable
as Map<String, DiffStatus>,organizations: null == organizations ? _self.organizations : organizations // ignore: cast_nullable_to_non_nullable
as Map<String, DiffStatus>,misc: null == misc ? _self.misc : misc // ignore: cast_nullable_to_non_nullable
as Map<String, DiffStatus>,tags: null == tags ? _self.tags : tags // ignore: cast_nullable_to_non_nullable
as Map<String, DiffStatus>,
  ));
}

}


/// Adds pattern-matching-related methods to [ContactDetailsDiff].
extension ContactDetailsDiffPatterns on ContactDetailsDiff {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ContactDetailsDiff value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ContactDetailsDiff() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ContactDetailsDiff value)  $default,){
final _that = this;
switch (_that) {
case _ContactDetailsDiff():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ContactDetailsDiff value)?  $default,){
final _that = this;
switch (_that) {
case _ContactDetailsDiff() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( DiffStatus picture,  Map<String, DiffStatus> names,  Map<String, DiffStatus> phones,  Map<String, DiffStatus> emails,  Map<String, DiffStatus> websites,  Map<String, DiffStatus> socialMedias,  Map<String, DiffStatus> events,  Map<String, DiffStatus> organizations,  Map<String, DiffStatus> misc,  Map<String, DiffStatus> tags)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ContactDetailsDiff() when $default != null:
return $default(_that.picture,_that.names,_that.phones,_that.emails,_that.websites,_that.socialMedias,_that.events,_that.organizations,_that.misc,_that.tags);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( DiffStatus picture,  Map<String, DiffStatus> names,  Map<String, DiffStatus> phones,  Map<String, DiffStatus> emails,  Map<String, DiffStatus> websites,  Map<String, DiffStatus> socialMedias,  Map<String, DiffStatus> events,  Map<String, DiffStatus> organizations,  Map<String, DiffStatus> misc,  Map<String, DiffStatus> tags)  $default,) {final _that = this;
switch (_that) {
case _ContactDetailsDiff():
return $default(_that.picture,_that.names,_that.phones,_that.emails,_that.websites,_that.socialMedias,_that.events,_that.organizations,_that.misc,_that.tags);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( DiffStatus picture,  Map<String, DiffStatus> names,  Map<String, DiffStatus> phones,  Map<String, DiffStatus> emails,  Map<String, DiffStatus> websites,  Map<String, DiffStatus> socialMedias,  Map<String, DiffStatus> events,  Map<String, DiffStatus> organizations,  Map<String, DiffStatus> misc,  Map<String, DiffStatus> tags)?  $default,) {final _that = this;
switch (_that) {
case _ContactDetailsDiff() when $default != null:
return $default(_that.picture,_that.names,_that.phones,_that.emails,_that.websites,_that.socialMedias,_that.events,_that.organizations,_that.misc,_that.tags);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ContactDetailsDiff extends ContactDetailsDiff {
  const _ContactDetailsDiff({required this.picture, required final  Map<String, DiffStatus> names, required final  Map<String, DiffStatus> phones, required final  Map<String, DiffStatus> emails, required final  Map<String, DiffStatus> websites, required final  Map<String, DiffStatus> socialMedias, required final  Map<String, DiffStatus> events, required final  Map<String, DiffStatus> organizations, required final  Map<String, DiffStatus> misc, required final  Map<String, DiffStatus> tags}): _names = names,_phones = phones,_emails = emails,_websites = websites,_socialMedias = socialMedias,_events = events,_organizations = organizations,_misc = misc,_tags = tags,super._();
  factory _ContactDetailsDiff.fromJson(Map<String, dynamic> json) => _$ContactDetailsDiffFromJson(json);

@override final  DiffStatus picture;
 final  Map<String, DiffStatus> _names;
@override Map<String, DiffStatus> get names {
  if (_names is EqualUnmodifiableMapView) return _names;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_names);
}

 final  Map<String, DiffStatus> _phones;
@override Map<String, DiffStatus> get phones {
  if (_phones is EqualUnmodifiableMapView) return _phones;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_phones);
}

 final  Map<String, DiffStatus> _emails;
@override Map<String, DiffStatus> get emails {
  if (_emails is EqualUnmodifiableMapView) return _emails;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_emails);
}

 final  Map<String, DiffStatus> _websites;
@override Map<String, DiffStatus> get websites {
  if (_websites is EqualUnmodifiableMapView) return _websites;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_websites);
}

 final  Map<String, DiffStatus> _socialMedias;
@override Map<String, DiffStatus> get socialMedias {
  if (_socialMedias is EqualUnmodifiableMapView) return _socialMedias;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_socialMedias);
}

 final  Map<String, DiffStatus> _events;
@override Map<String, DiffStatus> get events {
  if (_events is EqualUnmodifiableMapView) return _events;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_events);
}

 final  Map<String, DiffStatus> _organizations;
@override Map<String, DiffStatus> get organizations {
  if (_organizations is EqualUnmodifiableMapView) return _organizations;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_organizations);
}

 final  Map<String, DiffStatus> _misc;
@override Map<String, DiffStatus> get misc {
  if (_misc is EqualUnmodifiableMapView) return _misc;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_misc);
}

 final  Map<String, DiffStatus> _tags;
@override Map<String, DiffStatus> get tags {
  if (_tags is EqualUnmodifiableMapView) return _tags;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_tags);
}


/// Create a copy of ContactDetailsDiff
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ContactDetailsDiffCopyWith<_ContactDetailsDiff> get copyWith => __$ContactDetailsDiffCopyWithImpl<_ContactDetailsDiff>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ContactDetailsDiffToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ContactDetailsDiff&&(identical(other.picture, picture) || other.picture == picture)&&const DeepCollectionEquality().equals(other._names, _names)&&const DeepCollectionEquality().equals(other._phones, _phones)&&const DeepCollectionEquality().equals(other._emails, _emails)&&const DeepCollectionEquality().equals(other._websites, _websites)&&const DeepCollectionEquality().equals(other._socialMedias, _socialMedias)&&const DeepCollectionEquality().equals(other._events, _events)&&const DeepCollectionEquality().equals(other._organizations, _organizations)&&const DeepCollectionEquality().equals(other._misc, _misc)&&const DeepCollectionEquality().equals(other._tags, _tags));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,picture,const DeepCollectionEquality().hash(_names),const DeepCollectionEquality().hash(_phones),const DeepCollectionEquality().hash(_emails),const DeepCollectionEquality().hash(_websites),const DeepCollectionEquality().hash(_socialMedias),const DeepCollectionEquality().hash(_events),const DeepCollectionEquality().hash(_organizations),const DeepCollectionEquality().hash(_misc),const DeepCollectionEquality().hash(_tags));

@override
String toString() {
  return 'ContactDetailsDiff(picture: $picture, names: $names, phones: $phones, emails: $emails, websites: $websites, socialMedias: $socialMedias, events: $events, organizations: $organizations, misc: $misc, tags: $tags)';
}


}

/// @nodoc
abstract mixin class _$ContactDetailsDiffCopyWith<$Res> implements $ContactDetailsDiffCopyWith<$Res> {
  factory _$ContactDetailsDiffCopyWith(_ContactDetailsDiff value, $Res Function(_ContactDetailsDiff) _then) = __$ContactDetailsDiffCopyWithImpl;
@override @useResult
$Res call({
 DiffStatus picture, Map<String, DiffStatus> names, Map<String, DiffStatus> phones, Map<String, DiffStatus> emails, Map<String, DiffStatus> websites, Map<String, DiffStatus> socialMedias, Map<String, DiffStatus> events, Map<String, DiffStatus> organizations, Map<String, DiffStatus> misc, Map<String, DiffStatus> tags
});




}
/// @nodoc
class __$ContactDetailsDiffCopyWithImpl<$Res>
    implements _$ContactDetailsDiffCopyWith<$Res> {
  __$ContactDetailsDiffCopyWithImpl(this._self, this._then);

  final _ContactDetailsDiff _self;
  final $Res Function(_ContactDetailsDiff) _then;

/// Create a copy of ContactDetailsDiff
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? picture = null,Object? names = null,Object? phones = null,Object? emails = null,Object? websites = null,Object? socialMedias = null,Object? events = null,Object? organizations = null,Object? misc = null,Object? tags = null,}) {
  return _then(_ContactDetailsDiff(
picture: null == picture ? _self.picture : picture // ignore: cast_nullable_to_non_nullable
as DiffStatus,names: null == names ? _self._names : names // ignore: cast_nullable_to_non_nullable
as Map<String, DiffStatus>,phones: null == phones ? _self._phones : phones // ignore: cast_nullable_to_non_nullable
as Map<String, DiffStatus>,emails: null == emails ? _self._emails : emails // ignore: cast_nullable_to_non_nullable
as Map<String, DiffStatus>,websites: null == websites ? _self._websites : websites // ignore: cast_nullable_to_non_nullable
as Map<String, DiffStatus>,socialMedias: null == socialMedias ? _self._socialMedias : socialMedias // ignore: cast_nullable_to_non_nullable
as Map<String, DiffStatus>,events: null == events ? _self._events : events // ignore: cast_nullable_to_non_nullable
as Map<String, DiffStatus>,organizations: null == organizations ? _self._organizations : organizations // ignore: cast_nullable_to_non_nullable
as Map<String, DiffStatus>,misc: null == misc ? _self._misc : misc // ignore: cast_nullable_to_non_nullable
as Map<String, DiffStatus>,tags: null == tags ? _self._tags : tags // ignore: cast_nullable_to_non_nullable
as Map<String, DiffStatus>,
  ));
}


}

// dart format on
