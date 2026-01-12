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
mixin _$ContactDetails {

/// Binary integer representation of an image
 List<int>? get picture;/// Public identity key
 String? get publicKey;/// Names with unique key
 Map<String, String> get names;/// Phone numbers
 Map<String, String> get phones;/// E-mail addresses
 Map<String, String> get emails;/// Websites
 Map<String, String> get websites;/// Social media / instant messaging profiles
 Map<String, String> get socialMedias;/// Events / birthdays
 Map<String, DateTime> get events;/// Organizations like companies with role info
 Map<String, Organization> get organizations;/// Miscellaneous fields
 Map<String, String> get misc;/// Tags to indicate topics, preferences with unique key
 Map<String, String> get tags;
/// Create a copy of ContactDetails
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ContactDetailsCopyWith<ContactDetails> get copyWith => _$ContactDetailsCopyWithImpl<ContactDetails>(this as ContactDetails, _$identity);

  /// Serializes this ContactDetails to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ContactDetails&&const DeepCollectionEquality().equals(other.picture, picture)&&(identical(other.publicKey, publicKey) || other.publicKey == publicKey)&&const DeepCollectionEquality().equals(other.names, names)&&const DeepCollectionEquality().equals(other.phones, phones)&&const DeepCollectionEquality().equals(other.emails, emails)&&const DeepCollectionEquality().equals(other.websites, websites)&&const DeepCollectionEquality().equals(other.socialMedias, socialMedias)&&const DeepCollectionEquality().equals(other.events, events)&&const DeepCollectionEquality().equals(other.organizations, organizations)&&const DeepCollectionEquality().equals(other.misc, misc)&&const DeepCollectionEquality().equals(other.tags, tags));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(picture),publicKey,const DeepCollectionEquality().hash(names),const DeepCollectionEquality().hash(phones),const DeepCollectionEquality().hash(emails),const DeepCollectionEquality().hash(websites),const DeepCollectionEquality().hash(socialMedias),const DeepCollectionEquality().hash(events),const DeepCollectionEquality().hash(organizations),const DeepCollectionEquality().hash(misc),const DeepCollectionEquality().hash(tags));

@override
String toString() {
  return 'ContactDetails(picture: $picture, publicKey: $publicKey, names: $names, phones: $phones, emails: $emails, websites: $websites, socialMedias: $socialMedias, events: $events, organizations: $organizations, misc: $misc, tags: $tags)';
}


}

/// @nodoc
abstract mixin class $ContactDetailsCopyWith<$Res>  {
  factory $ContactDetailsCopyWith(ContactDetails value, $Res Function(ContactDetails) _then) = _$ContactDetailsCopyWithImpl;
@useResult
$Res call({
 List<int>? picture, String? publicKey, Map<String, String> names, Map<String, String> phones, Map<String, String> emails, Map<String, String> websites, Map<String, String> socialMedias, Map<String, DateTime> events, Map<String, Organization> organizations, Map<String, String> misc, Map<String, String> tags
});




}
/// @nodoc
class _$ContactDetailsCopyWithImpl<$Res>
    implements $ContactDetailsCopyWith<$Res> {
  _$ContactDetailsCopyWithImpl(this._self, this._then);

  final ContactDetails _self;
  final $Res Function(ContactDetails) _then;

/// Create a copy of ContactDetails
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? picture = freezed,Object? publicKey = freezed,Object? names = null,Object? phones = null,Object? emails = null,Object? websites = null,Object? socialMedias = null,Object? events = null,Object? organizations = null,Object? misc = null,Object? tags = null,}) {
  return _then(_self.copyWith(
picture: freezed == picture ? _self.picture : picture // ignore: cast_nullable_to_non_nullable
as List<int>?,publicKey: freezed == publicKey ? _self.publicKey : publicKey // ignore: cast_nullable_to_non_nullable
as String?,names: null == names ? _self.names : names // ignore: cast_nullable_to_non_nullable
as Map<String, String>,phones: null == phones ? _self.phones : phones // ignore: cast_nullable_to_non_nullable
as Map<String, String>,emails: null == emails ? _self.emails : emails // ignore: cast_nullable_to_non_nullable
as Map<String, String>,websites: null == websites ? _self.websites : websites // ignore: cast_nullable_to_non_nullable
as Map<String, String>,socialMedias: null == socialMedias ? _self.socialMedias : socialMedias // ignore: cast_nullable_to_non_nullable
as Map<String, String>,events: null == events ? _self.events : events // ignore: cast_nullable_to_non_nullable
as Map<String, DateTime>,organizations: null == organizations ? _self.organizations : organizations // ignore: cast_nullable_to_non_nullable
as Map<String, Organization>,misc: null == misc ? _self.misc : misc // ignore: cast_nullable_to_non_nullable
as Map<String, String>,tags: null == tags ? _self.tags : tags // ignore: cast_nullable_to_non_nullable
as Map<String, String>,
  ));
}

}


/// Adds pattern-matching-related methods to [ContactDetails].
extension ContactDetailsPatterns on ContactDetails {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ContactDetails value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ContactDetails() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ContactDetails value)  $default,){
final _that = this;
switch (_that) {
case _ContactDetails():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ContactDetails value)?  $default,){
final _that = this;
switch (_that) {
case _ContactDetails() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<int>? picture,  String? publicKey,  Map<String, String> names,  Map<String, String> phones,  Map<String, String> emails,  Map<String, String> websites,  Map<String, String> socialMedias,  Map<String, DateTime> events,  Map<String, Organization> organizations,  Map<String, String> misc,  Map<String, String> tags)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ContactDetails() when $default != null:
return $default(_that.picture,_that.publicKey,_that.names,_that.phones,_that.emails,_that.websites,_that.socialMedias,_that.events,_that.organizations,_that.misc,_that.tags);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<int>? picture,  String? publicKey,  Map<String, String> names,  Map<String, String> phones,  Map<String, String> emails,  Map<String, String> websites,  Map<String, String> socialMedias,  Map<String, DateTime> events,  Map<String, Organization> organizations,  Map<String, String> misc,  Map<String, String> tags)  $default,) {final _that = this;
switch (_that) {
case _ContactDetails():
return $default(_that.picture,_that.publicKey,_that.names,_that.phones,_that.emails,_that.websites,_that.socialMedias,_that.events,_that.organizations,_that.misc,_that.tags);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<int>? picture,  String? publicKey,  Map<String, String> names,  Map<String, String> phones,  Map<String, String> emails,  Map<String, String> websites,  Map<String, String> socialMedias,  Map<String, DateTime> events,  Map<String, Organization> organizations,  Map<String, String> misc,  Map<String, String> tags)?  $default,) {final _that = this;
switch (_that) {
case _ContactDetails() when $default != null:
return $default(_that.picture,_that.publicKey,_that.names,_that.phones,_that.emails,_that.websites,_that.socialMedias,_that.events,_that.organizations,_that.misc,_that.tags);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ContactDetails extends ContactDetails {
  const _ContactDetails({final  List<int>? picture, this.publicKey, final  Map<String, String> names = const {}, final  Map<String, String> phones = const {}, final  Map<String, String> emails = const {}, final  Map<String, String> websites = const {}, final  Map<String, String> socialMedias = const {}, final  Map<String, DateTime> events = const {}, final  Map<String, Organization> organizations = const {}, final  Map<String, String> misc = const {}, final  Map<String, String> tags = const {}}): _picture = picture,_names = names,_phones = phones,_emails = emails,_websites = websites,_socialMedias = socialMedias,_events = events,_organizations = organizations,_misc = misc,_tags = tags,super._();
  factory _ContactDetails.fromJson(Map<String, dynamic> json) => _$ContactDetailsFromJson(json);

/// Binary integer representation of an image
 final  List<int>? _picture;
/// Binary integer representation of an image
@override List<int>? get picture {
  final value = _picture;
  if (value == null) return null;
  if (_picture is EqualUnmodifiableListView) return _picture;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

/// Public identity key
@override final  String? publicKey;
/// Names with unique key
 final  Map<String, String> _names;
/// Names with unique key
@override@JsonKey() Map<String, String> get names {
  if (_names is EqualUnmodifiableMapView) return _names;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_names);
}

/// Phone numbers
 final  Map<String, String> _phones;
/// Phone numbers
@override@JsonKey() Map<String, String> get phones {
  if (_phones is EqualUnmodifiableMapView) return _phones;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_phones);
}

/// E-mail addresses
 final  Map<String, String> _emails;
/// E-mail addresses
@override@JsonKey() Map<String, String> get emails {
  if (_emails is EqualUnmodifiableMapView) return _emails;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_emails);
}

/// Websites
 final  Map<String, String> _websites;
/// Websites
@override@JsonKey() Map<String, String> get websites {
  if (_websites is EqualUnmodifiableMapView) return _websites;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_websites);
}

/// Social media / instant messaging profiles
 final  Map<String, String> _socialMedias;
/// Social media / instant messaging profiles
@override@JsonKey() Map<String, String> get socialMedias {
  if (_socialMedias is EqualUnmodifiableMapView) return _socialMedias;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_socialMedias);
}

/// Events / birthdays
 final  Map<String, DateTime> _events;
/// Events / birthdays
@override@JsonKey() Map<String, DateTime> get events {
  if (_events is EqualUnmodifiableMapView) return _events;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_events);
}

/// Organizations like companies with role info
 final  Map<String, Organization> _organizations;
/// Organizations like companies with role info
@override@JsonKey() Map<String, Organization> get organizations {
  if (_organizations is EqualUnmodifiableMapView) return _organizations;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_organizations);
}

/// Miscellaneous fields
 final  Map<String, String> _misc;
/// Miscellaneous fields
@override@JsonKey() Map<String, String> get misc {
  if (_misc is EqualUnmodifiableMapView) return _misc;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_misc);
}

/// Tags to indicate topics, preferences with unique key
 final  Map<String, String> _tags;
/// Tags to indicate topics, preferences with unique key
@override@JsonKey() Map<String, String> get tags {
  if (_tags is EqualUnmodifiableMapView) return _tags;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_tags);
}


/// Create a copy of ContactDetails
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ContactDetailsCopyWith<_ContactDetails> get copyWith => __$ContactDetailsCopyWithImpl<_ContactDetails>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ContactDetailsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ContactDetails&&const DeepCollectionEquality().equals(other._picture, _picture)&&(identical(other.publicKey, publicKey) || other.publicKey == publicKey)&&const DeepCollectionEquality().equals(other._names, _names)&&const DeepCollectionEquality().equals(other._phones, _phones)&&const DeepCollectionEquality().equals(other._emails, _emails)&&const DeepCollectionEquality().equals(other._websites, _websites)&&const DeepCollectionEquality().equals(other._socialMedias, _socialMedias)&&const DeepCollectionEquality().equals(other._events, _events)&&const DeepCollectionEquality().equals(other._organizations, _organizations)&&const DeepCollectionEquality().equals(other._misc, _misc)&&const DeepCollectionEquality().equals(other._tags, _tags));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_picture),publicKey,const DeepCollectionEquality().hash(_names),const DeepCollectionEquality().hash(_phones),const DeepCollectionEquality().hash(_emails),const DeepCollectionEquality().hash(_websites),const DeepCollectionEquality().hash(_socialMedias),const DeepCollectionEquality().hash(_events),const DeepCollectionEquality().hash(_organizations),const DeepCollectionEquality().hash(_misc),const DeepCollectionEquality().hash(_tags));

@override
String toString() {
  return 'ContactDetails(picture: $picture, publicKey: $publicKey, names: $names, phones: $phones, emails: $emails, websites: $websites, socialMedias: $socialMedias, events: $events, organizations: $organizations, misc: $misc, tags: $tags)';
}


}

/// @nodoc
abstract mixin class _$ContactDetailsCopyWith<$Res> implements $ContactDetailsCopyWith<$Res> {
  factory _$ContactDetailsCopyWith(_ContactDetails value, $Res Function(_ContactDetails) _then) = __$ContactDetailsCopyWithImpl;
@override @useResult
$Res call({
 List<int>? picture, String? publicKey, Map<String, String> names, Map<String, String> phones, Map<String, String> emails, Map<String, String> websites, Map<String, String> socialMedias, Map<String, DateTime> events, Map<String, Organization> organizations, Map<String, String> misc, Map<String, String> tags
});




}
/// @nodoc
class __$ContactDetailsCopyWithImpl<$Res>
    implements _$ContactDetailsCopyWith<$Res> {
  __$ContactDetailsCopyWithImpl(this._self, this._then);

  final _ContactDetails _self;
  final $Res Function(_ContactDetails) _then;

/// Create a copy of ContactDetails
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? picture = freezed,Object? publicKey = freezed,Object? names = null,Object? phones = null,Object? emails = null,Object? websites = null,Object? socialMedias = null,Object? events = null,Object? organizations = null,Object? misc = null,Object? tags = null,}) {
  return _then(_ContactDetails(
picture: freezed == picture ? _self._picture : picture // ignore: cast_nullable_to_non_nullable
as List<int>?,publicKey: freezed == publicKey ? _self.publicKey : publicKey // ignore: cast_nullable_to_non_nullable
as String?,names: null == names ? _self._names : names // ignore: cast_nullable_to_non_nullable
as Map<String, String>,phones: null == phones ? _self._phones : phones // ignore: cast_nullable_to_non_nullable
as Map<String, String>,emails: null == emails ? _self._emails : emails // ignore: cast_nullable_to_non_nullable
as Map<String, String>,websites: null == websites ? _self._websites : websites // ignore: cast_nullable_to_non_nullable
as Map<String, String>,socialMedias: null == socialMedias ? _self._socialMedias : socialMedias // ignore: cast_nullable_to_non_nullable
as Map<String, String>,events: null == events ? _self._events : events // ignore: cast_nullable_to_non_nullable
as Map<String, DateTime>,organizations: null == organizations ? _self._organizations : organizations // ignore: cast_nullable_to_non_nullable
as Map<String, Organization>,misc: null == misc ? _self._misc : misc // ignore: cast_nullable_to_non_nullable
as Map<String, String>,tags: null == tags ? _self._tags : tags // ignore: cast_nullable_to_non_nullable
as Map<String, String>,
  ));
}


}

// dart format on
