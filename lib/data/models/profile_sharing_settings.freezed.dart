// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'profile_sharing_settings.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ProfileSharingSettings {

/// Map of name ID to circle IDs that have access to names
 Map<String, List<String>> get names;/// Map of phone label to circle IDs that have access to phones
 Map<String, List<String>> get phones;/// Map of email label to circle IDs that have access to emails
 Map<String, List<String>> get emails;/// Map of address label to circle IDs that have access to addresses
 Map<String, List<String>> get addresses;/// Map of ??? to circle IDs that have access to organizations
// TODO: Do organizations even have labels?
 Map<String, List<String>> get organizations;/// Map of website label to circle IDs that have access to websites
 Map<String, List<String>> get websites;/// Map of social media label to circle IDs that have access to socialMedias
 Map<String, List<String>> get socialMedias;/// Map of event label to circle IDs that have access to events
 Map<String, List<String>> get events;/// Map of misc ID to circle IDs that have access to misc field
 Map<String, List<String>> get misc;/// Map of tag ID to circle IDs that have access to tag
 Map<String, List<String>> get tags;
/// Create a copy of ProfileSharingSettings
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProfileSharingSettingsCopyWith<ProfileSharingSettings> get copyWith => _$ProfileSharingSettingsCopyWithImpl<ProfileSharingSettings>(this as ProfileSharingSettings, _$identity);

  /// Serializes this ProfileSharingSettings to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProfileSharingSettings&&const DeepCollectionEquality().equals(other.names, names)&&const DeepCollectionEquality().equals(other.phones, phones)&&const DeepCollectionEquality().equals(other.emails, emails)&&const DeepCollectionEquality().equals(other.addresses, addresses)&&const DeepCollectionEquality().equals(other.organizations, organizations)&&const DeepCollectionEquality().equals(other.websites, websites)&&const DeepCollectionEquality().equals(other.socialMedias, socialMedias)&&const DeepCollectionEquality().equals(other.events, events)&&const DeepCollectionEquality().equals(other.misc, misc)&&const DeepCollectionEquality().equals(other.tags, tags));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(names),const DeepCollectionEquality().hash(phones),const DeepCollectionEquality().hash(emails),const DeepCollectionEquality().hash(addresses),const DeepCollectionEquality().hash(organizations),const DeepCollectionEquality().hash(websites),const DeepCollectionEquality().hash(socialMedias),const DeepCollectionEquality().hash(events),const DeepCollectionEquality().hash(misc),const DeepCollectionEquality().hash(tags));

@override
String toString() {
  return 'ProfileSharingSettings(names: $names, phones: $phones, emails: $emails, addresses: $addresses, organizations: $organizations, websites: $websites, socialMedias: $socialMedias, events: $events, misc: $misc, tags: $tags)';
}


}

/// @nodoc
abstract mixin class $ProfileSharingSettingsCopyWith<$Res>  {
  factory $ProfileSharingSettingsCopyWith(ProfileSharingSettings value, $Res Function(ProfileSharingSettings) _then) = _$ProfileSharingSettingsCopyWithImpl;
@useResult
$Res call({
 Map<String, List<String>> names, Map<String, List<String>> phones, Map<String, List<String>> emails, Map<String, List<String>> addresses, Map<String, List<String>> organizations, Map<String, List<String>> websites, Map<String, List<String>> socialMedias, Map<String, List<String>> events, Map<String, List<String>> misc, Map<String, List<String>> tags
});




}
/// @nodoc
class _$ProfileSharingSettingsCopyWithImpl<$Res>
    implements $ProfileSharingSettingsCopyWith<$Res> {
  _$ProfileSharingSettingsCopyWithImpl(this._self, this._then);

  final ProfileSharingSettings _self;
  final $Res Function(ProfileSharingSettings) _then;

/// Create a copy of ProfileSharingSettings
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? names = null,Object? phones = null,Object? emails = null,Object? addresses = null,Object? organizations = null,Object? websites = null,Object? socialMedias = null,Object? events = null,Object? misc = null,Object? tags = null,}) {
  return _then(_self.copyWith(
names: null == names ? _self.names : names // ignore: cast_nullable_to_non_nullable
as Map<String, List<String>>,phones: null == phones ? _self.phones : phones // ignore: cast_nullable_to_non_nullable
as Map<String, List<String>>,emails: null == emails ? _self.emails : emails // ignore: cast_nullable_to_non_nullable
as Map<String, List<String>>,addresses: null == addresses ? _self.addresses : addresses // ignore: cast_nullable_to_non_nullable
as Map<String, List<String>>,organizations: null == organizations ? _self.organizations : organizations // ignore: cast_nullable_to_non_nullable
as Map<String, List<String>>,websites: null == websites ? _self.websites : websites // ignore: cast_nullable_to_non_nullable
as Map<String, List<String>>,socialMedias: null == socialMedias ? _self.socialMedias : socialMedias // ignore: cast_nullable_to_non_nullable
as Map<String, List<String>>,events: null == events ? _self.events : events // ignore: cast_nullable_to_non_nullable
as Map<String, List<String>>,misc: null == misc ? _self.misc : misc // ignore: cast_nullable_to_non_nullable
as Map<String, List<String>>,tags: null == tags ? _self.tags : tags // ignore: cast_nullable_to_non_nullable
as Map<String, List<String>>,
  ));
}

}


/// Adds pattern-matching-related methods to [ProfileSharingSettings].
extension ProfileSharingSettingsPatterns on ProfileSharingSettings {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ProfileSharingSettings value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ProfileSharingSettings() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ProfileSharingSettings value)  $default,){
final _that = this;
switch (_that) {
case _ProfileSharingSettings():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ProfileSharingSettings value)?  $default,){
final _that = this;
switch (_that) {
case _ProfileSharingSettings() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Map<String, List<String>> names,  Map<String, List<String>> phones,  Map<String, List<String>> emails,  Map<String, List<String>> addresses,  Map<String, List<String>> organizations,  Map<String, List<String>> websites,  Map<String, List<String>> socialMedias,  Map<String, List<String>> events,  Map<String, List<String>> misc,  Map<String, List<String>> tags)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ProfileSharingSettings() when $default != null:
return $default(_that.names,_that.phones,_that.emails,_that.addresses,_that.organizations,_that.websites,_that.socialMedias,_that.events,_that.misc,_that.tags);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Map<String, List<String>> names,  Map<String, List<String>> phones,  Map<String, List<String>> emails,  Map<String, List<String>> addresses,  Map<String, List<String>> organizations,  Map<String, List<String>> websites,  Map<String, List<String>> socialMedias,  Map<String, List<String>> events,  Map<String, List<String>> misc,  Map<String, List<String>> tags)  $default,) {final _that = this;
switch (_that) {
case _ProfileSharingSettings():
return $default(_that.names,_that.phones,_that.emails,_that.addresses,_that.organizations,_that.websites,_that.socialMedias,_that.events,_that.misc,_that.tags);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Map<String, List<String>> names,  Map<String, List<String>> phones,  Map<String, List<String>> emails,  Map<String, List<String>> addresses,  Map<String, List<String>> organizations,  Map<String, List<String>> websites,  Map<String, List<String>> socialMedias,  Map<String, List<String>> events,  Map<String, List<String>> misc,  Map<String, List<String>> tags)?  $default,) {final _that = this;
switch (_that) {
case _ProfileSharingSettings() when $default != null:
return $default(_that.names,_that.phones,_that.emails,_that.addresses,_that.organizations,_that.websites,_that.socialMedias,_that.events,_that.misc,_that.tags);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ProfileSharingSettings implements ProfileSharingSettings {
  const _ProfileSharingSettings({final  Map<String, List<String>> names = const {}, final  Map<String, List<String>> phones = const {}, final  Map<String, List<String>> emails = const {}, final  Map<String, List<String>> addresses = const {}, final  Map<String, List<String>> organizations = const {}, final  Map<String, List<String>> websites = const {}, final  Map<String, List<String>> socialMedias = const {}, final  Map<String, List<String>> events = const {}, final  Map<String, List<String>> misc = const {}, final  Map<String, List<String>> tags = const {}}): _names = names,_phones = phones,_emails = emails,_addresses = addresses,_organizations = organizations,_websites = websites,_socialMedias = socialMedias,_events = events,_misc = misc,_tags = tags;
  factory _ProfileSharingSettings.fromJson(Map<String, dynamic> json) => _$ProfileSharingSettingsFromJson(json);

/// Map of name ID to circle IDs that have access to names
 final  Map<String, List<String>> _names;
/// Map of name ID to circle IDs that have access to names
@override@JsonKey() Map<String, List<String>> get names {
  if (_names is EqualUnmodifiableMapView) return _names;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_names);
}

/// Map of phone label to circle IDs that have access to phones
 final  Map<String, List<String>> _phones;
/// Map of phone label to circle IDs that have access to phones
@override@JsonKey() Map<String, List<String>> get phones {
  if (_phones is EqualUnmodifiableMapView) return _phones;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_phones);
}

/// Map of email label to circle IDs that have access to emails
 final  Map<String, List<String>> _emails;
/// Map of email label to circle IDs that have access to emails
@override@JsonKey() Map<String, List<String>> get emails {
  if (_emails is EqualUnmodifiableMapView) return _emails;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_emails);
}

/// Map of address label to circle IDs that have access to addresses
 final  Map<String, List<String>> _addresses;
/// Map of address label to circle IDs that have access to addresses
@override@JsonKey() Map<String, List<String>> get addresses {
  if (_addresses is EqualUnmodifiableMapView) return _addresses;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_addresses);
}

/// Map of ??? to circle IDs that have access to organizations
// TODO: Do organizations even have labels?
 final  Map<String, List<String>> _organizations;
/// Map of ??? to circle IDs that have access to organizations
// TODO: Do organizations even have labels?
@override@JsonKey() Map<String, List<String>> get organizations {
  if (_organizations is EqualUnmodifiableMapView) return _organizations;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_organizations);
}

/// Map of website label to circle IDs that have access to websites
 final  Map<String, List<String>> _websites;
/// Map of website label to circle IDs that have access to websites
@override@JsonKey() Map<String, List<String>> get websites {
  if (_websites is EqualUnmodifiableMapView) return _websites;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_websites);
}

/// Map of social media label to circle IDs that have access to socialMedias
 final  Map<String, List<String>> _socialMedias;
/// Map of social media label to circle IDs that have access to socialMedias
@override@JsonKey() Map<String, List<String>> get socialMedias {
  if (_socialMedias is EqualUnmodifiableMapView) return _socialMedias;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_socialMedias);
}

/// Map of event label to circle IDs that have access to events
 final  Map<String, List<String>> _events;
/// Map of event label to circle IDs that have access to events
@override@JsonKey() Map<String, List<String>> get events {
  if (_events is EqualUnmodifiableMapView) return _events;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_events);
}

/// Map of misc ID to circle IDs that have access to misc field
 final  Map<String, List<String>> _misc;
/// Map of misc ID to circle IDs that have access to misc field
@override@JsonKey() Map<String, List<String>> get misc {
  if (_misc is EqualUnmodifiableMapView) return _misc;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_misc);
}

/// Map of tag ID to circle IDs that have access to tag
 final  Map<String, List<String>> _tags;
/// Map of tag ID to circle IDs that have access to tag
@override@JsonKey() Map<String, List<String>> get tags {
  if (_tags is EqualUnmodifiableMapView) return _tags;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_tags);
}


/// Create a copy of ProfileSharingSettings
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProfileSharingSettingsCopyWith<_ProfileSharingSettings> get copyWith => __$ProfileSharingSettingsCopyWithImpl<_ProfileSharingSettings>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ProfileSharingSettingsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProfileSharingSettings&&const DeepCollectionEquality().equals(other._names, _names)&&const DeepCollectionEquality().equals(other._phones, _phones)&&const DeepCollectionEquality().equals(other._emails, _emails)&&const DeepCollectionEquality().equals(other._addresses, _addresses)&&const DeepCollectionEquality().equals(other._organizations, _organizations)&&const DeepCollectionEquality().equals(other._websites, _websites)&&const DeepCollectionEquality().equals(other._socialMedias, _socialMedias)&&const DeepCollectionEquality().equals(other._events, _events)&&const DeepCollectionEquality().equals(other._misc, _misc)&&const DeepCollectionEquality().equals(other._tags, _tags));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_names),const DeepCollectionEquality().hash(_phones),const DeepCollectionEquality().hash(_emails),const DeepCollectionEquality().hash(_addresses),const DeepCollectionEquality().hash(_organizations),const DeepCollectionEquality().hash(_websites),const DeepCollectionEquality().hash(_socialMedias),const DeepCollectionEquality().hash(_events),const DeepCollectionEquality().hash(_misc),const DeepCollectionEquality().hash(_tags));

@override
String toString() {
  return 'ProfileSharingSettings(names: $names, phones: $phones, emails: $emails, addresses: $addresses, organizations: $organizations, websites: $websites, socialMedias: $socialMedias, events: $events, misc: $misc, tags: $tags)';
}


}

/// @nodoc
abstract mixin class _$ProfileSharingSettingsCopyWith<$Res> implements $ProfileSharingSettingsCopyWith<$Res> {
  factory _$ProfileSharingSettingsCopyWith(_ProfileSharingSettings value, $Res Function(_ProfileSharingSettings) _then) = __$ProfileSharingSettingsCopyWithImpl;
@override @useResult
$Res call({
 Map<String, List<String>> names, Map<String, List<String>> phones, Map<String, List<String>> emails, Map<String, List<String>> addresses, Map<String, List<String>> organizations, Map<String, List<String>> websites, Map<String, List<String>> socialMedias, Map<String, List<String>> events, Map<String, List<String>> misc, Map<String, List<String>> tags
});




}
/// @nodoc
class __$ProfileSharingSettingsCopyWithImpl<$Res>
    implements _$ProfileSharingSettingsCopyWith<$Res> {
  __$ProfileSharingSettingsCopyWithImpl(this._self, this._then);

  final _ProfileSharingSettings _self;
  final $Res Function(_ProfileSharingSettings) _then;

/// Create a copy of ProfileSharingSettings
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? names = null,Object? phones = null,Object? emails = null,Object? addresses = null,Object? organizations = null,Object? websites = null,Object? socialMedias = null,Object? events = null,Object? misc = null,Object? tags = null,}) {
  return _then(_ProfileSharingSettings(
names: null == names ? _self._names : names // ignore: cast_nullable_to_non_nullable
as Map<String, List<String>>,phones: null == phones ? _self._phones : phones // ignore: cast_nullable_to_non_nullable
as Map<String, List<String>>,emails: null == emails ? _self._emails : emails // ignore: cast_nullable_to_non_nullable
as Map<String, List<String>>,addresses: null == addresses ? _self._addresses : addresses // ignore: cast_nullable_to_non_nullable
as Map<String, List<String>>,organizations: null == organizations ? _self._organizations : organizations // ignore: cast_nullable_to_non_nullable
as Map<String, List<String>>,websites: null == websites ? _self._websites : websites // ignore: cast_nullable_to_non_nullable
as Map<String, List<String>>,socialMedias: null == socialMedias ? _self._socialMedias : socialMedias // ignore: cast_nullable_to_non_nullable
as Map<String, List<String>>,events: null == events ? _self._events : events // ignore: cast_nullable_to_non_nullable
as Map<String, List<String>>,misc: null == misc ? _self._misc : misc // ignore: cast_nullable_to_non_nullable
as Map<String, List<String>>,tags: null == tags ? _self._tags : tags // ignore: cast_nullable_to_non_nullable
as Map<String, List<String>>,
  ));
}


}

// dart format on
