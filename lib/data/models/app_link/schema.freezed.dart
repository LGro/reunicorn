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
mixin _$Connection {

 String get theirName; RecordKey get myRecord; KeyPair get myWriter; RecordKey get theirRecord;
/// Create a copy of Connection
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ConnectionCopyWith<Connection> get copyWith => _$ConnectionCopyWithImpl<Connection>(this as Connection, _$identity);

  /// Serializes this Connection to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Connection&&(identical(other.theirName, theirName) || other.theirName == theirName)&&(identical(other.myRecord, myRecord) || other.myRecord == myRecord)&&(identical(other.myWriter, myWriter) || other.myWriter == myWriter)&&(identical(other.theirRecord, theirRecord) || other.theirRecord == theirRecord));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,theirName,myRecord,myWriter,theirRecord);

@override
String toString() {
  return 'Connection(theirName: $theirName, myRecord: $myRecord, myWriter: $myWriter, theirRecord: $theirRecord)';
}


}

/// @nodoc
abstract mixin class $ConnectionCopyWith<$Res>  {
  factory $ConnectionCopyWith(Connection value, $Res Function(Connection) _then) = _$ConnectionCopyWithImpl;
@useResult
$Res call({
 String theirName, RecordKey myRecord, KeyPair myWriter, RecordKey theirRecord
});




}
/// @nodoc
class _$ConnectionCopyWithImpl<$Res>
    implements $ConnectionCopyWith<$Res> {
  _$ConnectionCopyWithImpl(this._self, this._then);

  final Connection _self;
  final $Res Function(Connection) _then;

/// Create a copy of Connection
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? theirName = null,Object? myRecord = null,Object? myWriter = null,Object? theirRecord = null,}) {
  return _then(_self.copyWith(
theirName: null == theirName ? _self.theirName : theirName // ignore: cast_nullable_to_non_nullable
as String,myRecord: null == myRecord ? _self.myRecord : myRecord // ignore: cast_nullable_to_non_nullable
as RecordKey,myWriter: null == myWriter ? _self.myWriter : myWriter // ignore: cast_nullable_to_non_nullable
as KeyPair,theirRecord: null == theirRecord ? _self.theirRecord : theirRecord // ignore: cast_nullable_to_non_nullable
as RecordKey,
  ));
}

}


/// Adds pattern-matching-related methods to [Connection].
extension ConnectionPatterns on Connection {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Connection value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Connection() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Connection value)  $default,){
final _that = this;
switch (_that) {
case _Connection():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Connection value)?  $default,){
final _that = this;
switch (_that) {
case _Connection() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String theirName,  RecordKey myRecord,  KeyPair myWriter,  RecordKey theirRecord)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Connection() when $default != null:
return $default(_that.theirName,_that.myRecord,_that.myWriter,_that.theirRecord);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String theirName,  RecordKey myRecord,  KeyPair myWriter,  RecordKey theirRecord)  $default,) {final _that = this;
switch (_that) {
case _Connection():
return $default(_that.theirName,_that.myRecord,_that.myWriter,_that.theirRecord);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String theirName,  RecordKey myRecord,  KeyPair myWriter,  RecordKey theirRecord)?  $default,) {final _that = this;
switch (_that) {
case _Connection() when $default != null:
return $default(_that.theirName,_that.myRecord,_that.myWriter,_that.theirRecord);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Connection implements Connection {
   _Connection({required this.theirName, required this.myRecord, required this.myWriter, required this.theirRecord});
  factory _Connection.fromJson(Map<String, dynamic> json) => _$ConnectionFromJson(json);

@override final  String theirName;
@override final  RecordKey myRecord;
@override final  KeyPair myWriter;
@override final  RecordKey theirRecord;

/// Create a copy of Connection
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ConnectionCopyWith<_Connection> get copyWith => __$ConnectionCopyWithImpl<_Connection>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ConnectionToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Connection&&(identical(other.theirName, theirName) || other.theirName == theirName)&&(identical(other.myRecord, myRecord) || other.myRecord == myRecord)&&(identical(other.myWriter, myWriter) || other.myWriter == myWriter)&&(identical(other.theirRecord, theirRecord) || other.theirRecord == theirRecord));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,theirName,myRecord,myWriter,theirRecord);

@override
String toString() {
  return 'Connection(theirName: $theirName, myRecord: $myRecord, myWriter: $myWriter, theirRecord: $theirRecord)';
}


}

/// @nodoc
abstract mixin class _$ConnectionCopyWith<$Res> implements $ConnectionCopyWith<$Res> {
  factory _$ConnectionCopyWith(_Connection value, $Res Function(_Connection) _then) = __$ConnectionCopyWithImpl;
@override @useResult
$Res call({
 String theirName, RecordKey myRecord, KeyPair myWriter, RecordKey theirRecord
});




}
/// @nodoc
class __$ConnectionCopyWithImpl<$Res>
    implements _$ConnectionCopyWith<$Res> {
  __$ConnectionCopyWithImpl(this._self, this._then);

  final _Connection _self;
  final $Res Function(_Connection) _then;

/// Create a copy of Connection
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? theirName = null,Object? myRecord = null,Object? myWriter = null,Object? theirRecord = null,}) {
  return _then(_Connection(
theirName: null == theirName ? _self.theirName : theirName // ignore: cast_nullable_to_non_nullable
as String,myRecord: null == myRecord ? _self.myRecord : myRecord // ignore: cast_nullable_to_non_nullable
as RecordKey,myWriter: null == myWriter ? _self.myWriter : myWriter // ignore: cast_nullable_to_non_nullable
as KeyPair,theirRecord: null == theirRecord ? _self.theirRecord : theirRecord // ignore: cast_nullable_to_non_nullable
as RecordKey,
  ));
}


}


/// @nodoc
mixin _$AppLinkSchema {

 String get appId; Map<String, Connection> get connections;
/// Create a copy of AppLinkSchema
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AppLinkSchemaCopyWith<AppLinkSchema> get copyWith => _$AppLinkSchemaCopyWithImpl<AppLinkSchema>(this as AppLinkSchema, _$identity);

  /// Serializes this AppLinkSchema to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AppLinkSchema&&(identical(other.appId, appId) || other.appId == appId)&&const DeepCollectionEquality().equals(other.connections, connections));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,appId,const DeepCollectionEquality().hash(connections));

@override
String toString() {
  return 'AppLinkSchema(appId: $appId, connections: $connections)';
}


}

/// @nodoc
abstract mixin class $AppLinkSchemaCopyWith<$Res>  {
  factory $AppLinkSchemaCopyWith(AppLinkSchema value, $Res Function(AppLinkSchema) _then) = _$AppLinkSchemaCopyWithImpl;
@useResult
$Res call({
 String appId, Map<String, Connection> connections
});




}
/// @nodoc
class _$AppLinkSchemaCopyWithImpl<$Res>
    implements $AppLinkSchemaCopyWith<$Res> {
  _$AppLinkSchemaCopyWithImpl(this._self, this._then);

  final AppLinkSchema _self;
  final $Res Function(AppLinkSchema) _then;

/// Create a copy of AppLinkSchema
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? appId = null,Object? connections = null,}) {
  return _then(_self.copyWith(
appId: null == appId ? _self.appId : appId // ignore: cast_nullable_to_non_nullable
as String,connections: null == connections ? _self.connections : connections // ignore: cast_nullable_to_non_nullable
as Map<String, Connection>,
  ));
}

}


/// Adds pattern-matching-related methods to [AppLinkSchema].
extension AppLinkSchemaPatterns on AppLinkSchema {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AppLinkSchema value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AppLinkSchema() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AppLinkSchema value)  $default,){
final _that = this;
switch (_that) {
case _AppLinkSchema():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AppLinkSchema value)?  $default,){
final _that = this;
switch (_that) {
case _AppLinkSchema() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String appId,  Map<String, Connection> connections)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AppLinkSchema() when $default != null:
return $default(_that.appId,_that.connections);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String appId,  Map<String, Connection> connections)  $default,) {final _that = this;
switch (_that) {
case _AppLinkSchema():
return $default(_that.appId,_that.connections);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String appId,  Map<String, Connection> connections)?  $default,) {final _that = this;
switch (_that) {
case _AppLinkSchema() when $default != null:
return $default(_that.appId,_that.connections);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AppLinkSchema implements AppLinkSchema {
   _AppLinkSchema({this.appId = "app.reunicorn", final  Map<String, Connection> connections = const {}}): _connections = connections;
  factory _AppLinkSchema.fromJson(Map<String, dynamic> json) => _$AppLinkSchemaFromJson(json);

@override@JsonKey() final  String appId;
 final  Map<String, Connection> _connections;
@override@JsonKey() Map<String, Connection> get connections {
  if (_connections is EqualUnmodifiableMapView) return _connections;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_connections);
}


/// Create a copy of AppLinkSchema
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AppLinkSchemaCopyWith<_AppLinkSchema> get copyWith => __$AppLinkSchemaCopyWithImpl<_AppLinkSchema>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AppLinkSchemaToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AppLinkSchema&&(identical(other.appId, appId) || other.appId == appId)&&const DeepCollectionEquality().equals(other._connections, _connections));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,appId,const DeepCollectionEquality().hash(_connections));

@override
String toString() {
  return 'AppLinkSchema(appId: $appId, connections: $connections)';
}


}

/// @nodoc
abstract mixin class _$AppLinkSchemaCopyWith<$Res> implements $AppLinkSchemaCopyWith<$Res> {
  factory _$AppLinkSchemaCopyWith(_AppLinkSchema value, $Res Function(_AppLinkSchema) _then) = __$AppLinkSchemaCopyWithImpl;
@override @useResult
$Res call({
 String appId, Map<String, Connection> connections
});




}
/// @nodoc
class __$AppLinkSchemaCopyWithImpl<$Res>
    implements _$AppLinkSchemaCopyWith<$Res> {
  __$AppLinkSchemaCopyWithImpl(this._self, this._then);

  final _AppLinkSchema _self;
  final $Res Function(_AppLinkSchema) _then;

/// Create a copy of AppLinkSchema
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? appId = null,Object? connections = null,}) {
  return _then(_AppLinkSchema(
appId: null == appId ? _self.appId : appId // ignore: cast_nullable_to_non_nullable
as String,connections: null == connections ? _self._connections : connections // ignore: cast_nullable_to_non_nullable
as Map<String, Connection>,
  ));
}


}

// dart format on
