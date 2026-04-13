// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'app_link.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AppLink {

 String get appId; String get label; bool get autoAddContacts; List<String> get circles; RecordKey get sharingRecord; KeyPair get sharingWriter; RecordKey get receivingRecord; KeyPair? get receivingWriter;
/// Create a copy of AppLink
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AppLinkCopyWith<AppLink> get copyWith => _$AppLinkCopyWithImpl<AppLink>(this as AppLink, _$identity);

  /// Serializes this AppLink to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AppLink&&(identical(other.appId, appId) || other.appId == appId)&&(identical(other.label, label) || other.label == label)&&(identical(other.autoAddContacts, autoAddContacts) || other.autoAddContacts == autoAddContacts)&&const DeepCollectionEquality().equals(other.circles, circles)&&(identical(other.sharingRecord, sharingRecord) || other.sharingRecord == sharingRecord)&&(identical(other.sharingWriter, sharingWriter) || other.sharingWriter == sharingWriter)&&(identical(other.receivingRecord, receivingRecord) || other.receivingRecord == receivingRecord)&&(identical(other.receivingWriter, receivingWriter) || other.receivingWriter == receivingWriter));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,appId,label,autoAddContacts,const DeepCollectionEquality().hash(circles),sharingRecord,sharingWriter,receivingRecord,receivingWriter);

@override
String toString() {
  return 'AppLink(appId: $appId, label: $label, autoAddContacts: $autoAddContacts, circles: $circles, sharingRecord: $sharingRecord, sharingWriter: $sharingWriter, receivingRecord: $receivingRecord, receivingWriter: $receivingWriter)';
}


}

/// @nodoc
abstract mixin class $AppLinkCopyWith<$Res>  {
  factory $AppLinkCopyWith(AppLink value, $Res Function(AppLink) _then) = _$AppLinkCopyWithImpl;
@useResult
$Res call({
 String appId, String label, bool autoAddContacts, List<String> circles, RecordKey sharingRecord, KeyPair sharingWriter, RecordKey receivingRecord, KeyPair? receivingWriter
});




}
/// @nodoc
class _$AppLinkCopyWithImpl<$Res>
    implements $AppLinkCopyWith<$Res> {
  _$AppLinkCopyWithImpl(this._self, this._then);

  final AppLink _self;
  final $Res Function(AppLink) _then;

/// Create a copy of AppLink
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? appId = null,Object? label = null,Object? autoAddContacts = null,Object? circles = null,Object? sharingRecord = null,Object? sharingWriter = null,Object? receivingRecord = null,Object? receivingWriter = freezed,}) {
  return _then(_self.copyWith(
appId: null == appId ? _self.appId : appId // ignore: cast_nullable_to_non_nullable
as String,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,autoAddContacts: null == autoAddContacts ? _self.autoAddContacts : autoAddContacts // ignore: cast_nullable_to_non_nullable
as bool,circles: null == circles ? _self.circles : circles // ignore: cast_nullable_to_non_nullable
as List<String>,sharingRecord: null == sharingRecord ? _self.sharingRecord : sharingRecord // ignore: cast_nullable_to_non_nullable
as RecordKey,sharingWriter: null == sharingWriter ? _self.sharingWriter : sharingWriter // ignore: cast_nullable_to_non_nullable
as KeyPair,receivingRecord: null == receivingRecord ? _self.receivingRecord : receivingRecord // ignore: cast_nullable_to_non_nullable
as RecordKey,receivingWriter: freezed == receivingWriter ? _self.receivingWriter : receivingWriter // ignore: cast_nullable_to_non_nullable
as KeyPair?,
  ));
}

}


/// Adds pattern-matching-related methods to [AppLink].
extension AppLinkPatterns on AppLink {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AppLink value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AppLink() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AppLink value)  $default,){
final _that = this;
switch (_that) {
case _AppLink():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AppLink value)?  $default,){
final _that = this;
switch (_that) {
case _AppLink() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String appId,  String label,  bool autoAddContacts,  List<String> circles,  RecordKey sharingRecord,  KeyPair sharingWriter,  RecordKey receivingRecord,  KeyPair? receivingWriter)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AppLink() when $default != null:
return $default(_that.appId,_that.label,_that.autoAddContacts,_that.circles,_that.sharingRecord,_that.sharingWriter,_that.receivingRecord,_that.receivingWriter);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String appId,  String label,  bool autoAddContacts,  List<String> circles,  RecordKey sharingRecord,  KeyPair sharingWriter,  RecordKey receivingRecord,  KeyPair? receivingWriter)  $default,) {final _that = this;
switch (_that) {
case _AppLink():
return $default(_that.appId,_that.label,_that.autoAddContacts,_that.circles,_that.sharingRecord,_that.sharingWriter,_that.receivingRecord,_that.receivingWriter);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String appId,  String label,  bool autoAddContacts,  List<String> circles,  RecordKey sharingRecord,  KeyPair sharingWriter,  RecordKey receivingRecord,  KeyPair? receivingWriter)?  $default,) {final _that = this;
switch (_that) {
case _AppLink() when $default != null:
return $default(_that.appId,_that.label,_that.autoAddContacts,_that.circles,_that.sharingRecord,_that.sharingWriter,_that.receivingRecord,_that.receivingWriter);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AppLink implements AppLink {
   _AppLink({required this.appId, required this.label, required this.autoAddContacts, required final  List<String> circles, required this.sharingRecord, required this.sharingWriter, required this.receivingRecord, this.receivingWriter}): _circles = circles;
  factory _AppLink.fromJson(Map<String, dynamic> json) => _$AppLinkFromJson(json);

@override final  String appId;
@override final  String label;
@override final  bool autoAddContacts;
 final  List<String> _circles;
@override List<String> get circles {
  if (_circles is EqualUnmodifiableListView) return _circles;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_circles);
}

@override final  RecordKey sharingRecord;
@override final  KeyPair sharingWriter;
@override final  RecordKey receivingRecord;
@override final  KeyPair? receivingWriter;

/// Create a copy of AppLink
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AppLinkCopyWith<_AppLink> get copyWith => __$AppLinkCopyWithImpl<_AppLink>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AppLinkToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AppLink&&(identical(other.appId, appId) || other.appId == appId)&&(identical(other.label, label) || other.label == label)&&(identical(other.autoAddContacts, autoAddContacts) || other.autoAddContacts == autoAddContacts)&&const DeepCollectionEquality().equals(other._circles, _circles)&&(identical(other.sharingRecord, sharingRecord) || other.sharingRecord == sharingRecord)&&(identical(other.sharingWriter, sharingWriter) || other.sharingWriter == sharingWriter)&&(identical(other.receivingRecord, receivingRecord) || other.receivingRecord == receivingRecord)&&(identical(other.receivingWriter, receivingWriter) || other.receivingWriter == receivingWriter));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,appId,label,autoAddContacts,const DeepCollectionEquality().hash(_circles),sharingRecord,sharingWriter,receivingRecord,receivingWriter);

@override
String toString() {
  return 'AppLink(appId: $appId, label: $label, autoAddContacts: $autoAddContacts, circles: $circles, sharingRecord: $sharingRecord, sharingWriter: $sharingWriter, receivingRecord: $receivingRecord, receivingWriter: $receivingWriter)';
}


}

/// @nodoc
abstract mixin class _$AppLinkCopyWith<$Res> implements $AppLinkCopyWith<$Res> {
  factory _$AppLinkCopyWith(_AppLink value, $Res Function(_AppLink) _then) = __$AppLinkCopyWithImpl;
@override @useResult
$Res call({
 String appId, String label, bool autoAddContacts, List<String> circles, RecordKey sharingRecord, KeyPair sharingWriter, RecordKey receivingRecord, KeyPair? receivingWriter
});




}
/// @nodoc
class __$AppLinkCopyWithImpl<$Res>
    implements _$AppLinkCopyWith<$Res> {
  __$AppLinkCopyWithImpl(this._self, this._then);

  final _AppLink _self;
  final $Res Function(_AppLink) _then;

/// Create a copy of AppLink
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? appId = null,Object? label = null,Object? autoAddContacts = null,Object? circles = null,Object? sharingRecord = null,Object? sharingWriter = null,Object? receivingRecord = null,Object? receivingWriter = freezed,}) {
  return _then(_AppLink(
appId: null == appId ? _self.appId : appId // ignore: cast_nullable_to_non_nullable
as String,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,autoAddContacts: null == autoAddContacts ? _self.autoAddContacts : autoAddContacts // ignore: cast_nullable_to_non_nullable
as bool,circles: null == circles ? _self._circles : circles // ignore: cast_nullable_to_non_nullable
as List<String>,sharingRecord: null == sharingRecord ? _self.sharingRecord : sharingRecord // ignore: cast_nullable_to_non_nullable
as RecordKey,sharingWriter: null == sharingWriter ? _self.sharingWriter : sharingWriter // ignore: cast_nullable_to_non_nullable
as KeyPair,receivingRecord: null == receivingRecord ? _self.receivingRecord : receivingRecord // ignore: cast_nullable_to_non_nullable
as RecordKey,receivingWriter: freezed == receivingWriter ? _self.receivingWriter : receivingWriter // ignore: cast_nullable_to_non_nullable
as KeyPair?,
  ));
}


}

// dart format on
