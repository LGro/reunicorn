// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'dht_connection_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
DhtConnectionState _$DhtConnectionStateFromJson(
  Map<String, dynamic> json
) {
        switch (json['runtimeType']) {
                  case 'initialized':
          return DhtConnectionInitialized.fromJson(
            json
          );
                case 'invited':
          return DhtConnectionInvited.fromJson(
            json
          );
                case 'established':
          return DhtConnectionEstablished.fromJson(
            json
          );
        
          default:
            throw CheckedFromJsonException(
  json,
  'runtimeType',
  'DhtConnectionState',
  'Invalid union type "${json['runtimeType']}"!'
);
        }
      
}

/// @nodoc
mixin _$DhtConnectionState {

/// Record key of their sharing DHT record
 RecordKey get recordKeyThemSharing;
/// Create a copy of DhtConnectionState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DhtConnectionStateCopyWith<DhtConnectionState> get copyWith => _$DhtConnectionStateCopyWithImpl<DhtConnectionState>(this as DhtConnectionState, _$identity);

  /// Serializes this DhtConnectionState to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DhtConnectionState&&(identical(other.recordKeyThemSharing, recordKeyThemSharing) || other.recordKeyThemSharing == recordKeyThemSharing));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,recordKeyThemSharing);

@override
String toString() {
  return 'DhtConnectionState(recordKeyThemSharing: $recordKeyThemSharing)';
}


}

/// @nodoc
abstract mixin class $DhtConnectionStateCopyWith<$Res>  {
  factory $DhtConnectionStateCopyWith(DhtConnectionState value, $Res Function(DhtConnectionState) _then) = _$DhtConnectionStateCopyWithImpl;
@useResult
$Res call({
 RecordKey recordKeyThemSharing
});




}
/// @nodoc
class _$DhtConnectionStateCopyWithImpl<$Res>
    implements $DhtConnectionStateCopyWith<$Res> {
  _$DhtConnectionStateCopyWithImpl(this._self, this._then);

  final DhtConnectionState _self;
  final $Res Function(DhtConnectionState) _then;

/// Create a copy of DhtConnectionState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? recordKeyThemSharing = null,}) {
  return _then(_self.copyWith(
recordKeyThemSharing: null == recordKeyThemSharing ? _self.recordKeyThemSharing : recordKeyThemSharing // ignore: cast_nullable_to_non_nullable
as RecordKey,
  ));
}

}


/// Adds pattern-matching-related methods to [DhtConnectionState].
extension DhtConnectionStatePatterns on DhtConnectionState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( DhtConnectionInitialized value)?  initialized,TResult Function( DhtConnectionInvited value)?  invited,TResult Function( DhtConnectionEstablished value)?  established,required TResult orElse(),}){
final _that = this;
switch (_that) {
case DhtConnectionInitialized() when initialized != null:
return initialized(_that);case DhtConnectionInvited() when invited != null:
return invited(_that);case DhtConnectionEstablished() when established != null:
return established(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( DhtConnectionInitialized value)  initialized,required TResult Function( DhtConnectionInvited value)  invited,required TResult Function( DhtConnectionEstablished value)  established,}){
final _that = this;
switch (_that) {
case DhtConnectionInitialized():
return initialized(_that);case DhtConnectionInvited():
return invited(_that);case DhtConnectionEstablished():
return established(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( DhtConnectionInitialized value)?  initialized,TResult? Function( DhtConnectionInvited value)?  invited,TResult? Function( DhtConnectionEstablished value)?  established,}){
final _that = this;
switch (_that) {
case DhtConnectionInitialized() when initialized != null:
return initialized(_that);case DhtConnectionInvited() when invited != null:
return invited(_that);case DhtConnectionEstablished() when established != null:
return established(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( RecordKey recordKeyMeSharing,  KeyPair writerMeSharing,  RecordKey recordKeyThemSharing,  KeyPair writerThemSharing)?  initialized,TResult Function( RecordKey recordKeyThemSharing)?  invited,TResult Function( RecordKey recordKeyMeSharing,  KeyPair writerMeSharing,  RecordKey recordKeyThemSharing)?  established,required TResult orElse(),}) {final _that = this;
switch (_that) {
case DhtConnectionInitialized() when initialized != null:
return initialized(_that.recordKeyMeSharing,_that.writerMeSharing,_that.recordKeyThemSharing,_that.writerThemSharing);case DhtConnectionInvited() when invited != null:
return invited(_that.recordKeyThemSharing);case DhtConnectionEstablished() when established != null:
return established(_that.recordKeyMeSharing,_that.writerMeSharing,_that.recordKeyThemSharing);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( RecordKey recordKeyMeSharing,  KeyPair writerMeSharing,  RecordKey recordKeyThemSharing,  KeyPair writerThemSharing)  initialized,required TResult Function( RecordKey recordKeyThemSharing)  invited,required TResult Function( RecordKey recordKeyMeSharing,  KeyPair writerMeSharing,  RecordKey recordKeyThemSharing)  established,}) {final _that = this;
switch (_that) {
case DhtConnectionInitialized():
return initialized(_that.recordKeyMeSharing,_that.writerMeSharing,_that.recordKeyThemSharing,_that.writerThemSharing);case DhtConnectionInvited():
return invited(_that.recordKeyThemSharing);case DhtConnectionEstablished():
return established(_that.recordKeyMeSharing,_that.writerMeSharing,_that.recordKeyThemSharing);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( RecordKey recordKeyMeSharing,  KeyPair writerMeSharing,  RecordKey recordKeyThemSharing,  KeyPair writerThemSharing)?  initialized,TResult? Function( RecordKey recordKeyThemSharing)?  invited,TResult? Function( RecordKey recordKeyMeSharing,  KeyPair writerMeSharing,  RecordKey recordKeyThemSharing)?  established,}) {final _that = this;
switch (_that) {
case DhtConnectionInitialized() when initialized != null:
return initialized(_that.recordKeyMeSharing,_that.writerMeSharing,_that.recordKeyThemSharing,_that.writerThemSharing);case DhtConnectionInvited() when invited != null:
return invited(_that.recordKeyThemSharing);case DhtConnectionEstablished() when established != null:
return established(_that.recordKeyMeSharing,_that.writerMeSharing,_that.recordKeyThemSharing);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class DhtConnectionInitialized implements DhtConnectionState {
  const DhtConnectionInitialized({required this.recordKeyMeSharing, required this.writerMeSharing, required this.recordKeyThemSharing, required this.writerThemSharing, final  String? $type}): $type = $type ?? 'initialized';
  factory DhtConnectionInitialized.fromJson(Map<String, dynamic> json) => _$DhtConnectionInitializedFromJson(json);

/// Record key of my sharing DHT record
 final  RecordKey recordKeyMeSharing;
/// Writer of my sharing DHT record
 final  KeyPair writerMeSharing;
/// Record key of their sharing DHT record
@override final  RecordKey recordKeyThemSharing;
/// Writer of their sharing DHT record
 final  KeyPair writerThemSharing;

@JsonKey(name: 'runtimeType')
final String $type;


/// Create a copy of DhtConnectionState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DhtConnectionInitializedCopyWith<DhtConnectionInitialized> get copyWith => _$DhtConnectionInitializedCopyWithImpl<DhtConnectionInitialized>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DhtConnectionInitializedToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DhtConnectionInitialized&&(identical(other.recordKeyMeSharing, recordKeyMeSharing) || other.recordKeyMeSharing == recordKeyMeSharing)&&(identical(other.writerMeSharing, writerMeSharing) || other.writerMeSharing == writerMeSharing)&&(identical(other.recordKeyThemSharing, recordKeyThemSharing) || other.recordKeyThemSharing == recordKeyThemSharing)&&(identical(other.writerThemSharing, writerThemSharing) || other.writerThemSharing == writerThemSharing));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,recordKeyMeSharing,writerMeSharing,recordKeyThemSharing,writerThemSharing);

@override
String toString() {
  return 'DhtConnectionState.initialized(recordKeyMeSharing: $recordKeyMeSharing, writerMeSharing: $writerMeSharing, recordKeyThemSharing: $recordKeyThemSharing, writerThemSharing: $writerThemSharing)';
}


}

/// @nodoc
abstract mixin class $DhtConnectionInitializedCopyWith<$Res> implements $DhtConnectionStateCopyWith<$Res> {
  factory $DhtConnectionInitializedCopyWith(DhtConnectionInitialized value, $Res Function(DhtConnectionInitialized) _then) = _$DhtConnectionInitializedCopyWithImpl;
@override @useResult
$Res call({
 RecordKey recordKeyMeSharing, KeyPair writerMeSharing, RecordKey recordKeyThemSharing, KeyPair writerThemSharing
});




}
/// @nodoc
class _$DhtConnectionInitializedCopyWithImpl<$Res>
    implements $DhtConnectionInitializedCopyWith<$Res> {
  _$DhtConnectionInitializedCopyWithImpl(this._self, this._then);

  final DhtConnectionInitialized _self;
  final $Res Function(DhtConnectionInitialized) _then;

/// Create a copy of DhtConnectionState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? recordKeyMeSharing = null,Object? writerMeSharing = null,Object? recordKeyThemSharing = null,Object? writerThemSharing = null,}) {
  return _then(DhtConnectionInitialized(
recordKeyMeSharing: null == recordKeyMeSharing ? _self.recordKeyMeSharing : recordKeyMeSharing // ignore: cast_nullable_to_non_nullable
as RecordKey,writerMeSharing: null == writerMeSharing ? _self.writerMeSharing : writerMeSharing // ignore: cast_nullable_to_non_nullable
as KeyPair,recordKeyThemSharing: null == recordKeyThemSharing ? _self.recordKeyThemSharing : recordKeyThemSharing // ignore: cast_nullable_to_non_nullable
as RecordKey,writerThemSharing: null == writerThemSharing ? _self.writerThemSharing : writerThemSharing // ignore: cast_nullable_to_non_nullable
as KeyPair,
  ));
}


}

/// @nodoc
@JsonSerializable()

class DhtConnectionInvited implements DhtConnectionState {
  const DhtConnectionInvited({required this.recordKeyThemSharing, final  String? $type}): $type = $type ?? 'invited';
  factory DhtConnectionInvited.fromJson(Map<String, dynamic> json) => _$DhtConnectionInvitedFromJson(json);

/// Record key of their sharing DHT record
@override final  RecordKey recordKeyThemSharing;

@JsonKey(name: 'runtimeType')
final String $type;


/// Create a copy of DhtConnectionState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DhtConnectionInvitedCopyWith<DhtConnectionInvited> get copyWith => _$DhtConnectionInvitedCopyWithImpl<DhtConnectionInvited>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DhtConnectionInvitedToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DhtConnectionInvited&&(identical(other.recordKeyThemSharing, recordKeyThemSharing) || other.recordKeyThemSharing == recordKeyThemSharing));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,recordKeyThemSharing);

@override
String toString() {
  return 'DhtConnectionState.invited(recordKeyThemSharing: $recordKeyThemSharing)';
}


}

/// @nodoc
abstract mixin class $DhtConnectionInvitedCopyWith<$Res> implements $DhtConnectionStateCopyWith<$Res> {
  factory $DhtConnectionInvitedCopyWith(DhtConnectionInvited value, $Res Function(DhtConnectionInvited) _then) = _$DhtConnectionInvitedCopyWithImpl;
@override @useResult
$Res call({
 RecordKey recordKeyThemSharing
});




}
/// @nodoc
class _$DhtConnectionInvitedCopyWithImpl<$Res>
    implements $DhtConnectionInvitedCopyWith<$Res> {
  _$DhtConnectionInvitedCopyWithImpl(this._self, this._then);

  final DhtConnectionInvited _self;
  final $Res Function(DhtConnectionInvited) _then;

/// Create a copy of DhtConnectionState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? recordKeyThemSharing = null,}) {
  return _then(DhtConnectionInvited(
recordKeyThemSharing: null == recordKeyThemSharing ? _self.recordKeyThemSharing : recordKeyThemSharing // ignore: cast_nullable_to_non_nullable
as RecordKey,
  ));
}


}

/// @nodoc
@JsonSerializable()

class DhtConnectionEstablished implements DhtConnectionState {
  const DhtConnectionEstablished({required this.recordKeyMeSharing, required this.writerMeSharing, required this.recordKeyThemSharing, final  String? $type}): $type = $type ?? 'established';
  factory DhtConnectionEstablished.fromJson(Map<String, dynamic> json) => _$DhtConnectionEstablishedFromJson(json);

/// Record key of my sharing DHT record
 final  RecordKey recordKeyMeSharing;
/// Writer of my sharing DHT record
 final  KeyPair writerMeSharing;
/// Record key of their sharing DHT record
@override final  RecordKey recordKeyThemSharing;

@JsonKey(name: 'runtimeType')
final String $type;


/// Create a copy of DhtConnectionState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DhtConnectionEstablishedCopyWith<DhtConnectionEstablished> get copyWith => _$DhtConnectionEstablishedCopyWithImpl<DhtConnectionEstablished>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DhtConnectionEstablishedToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DhtConnectionEstablished&&(identical(other.recordKeyMeSharing, recordKeyMeSharing) || other.recordKeyMeSharing == recordKeyMeSharing)&&(identical(other.writerMeSharing, writerMeSharing) || other.writerMeSharing == writerMeSharing)&&(identical(other.recordKeyThemSharing, recordKeyThemSharing) || other.recordKeyThemSharing == recordKeyThemSharing));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,recordKeyMeSharing,writerMeSharing,recordKeyThemSharing);

@override
String toString() {
  return 'DhtConnectionState.established(recordKeyMeSharing: $recordKeyMeSharing, writerMeSharing: $writerMeSharing, recordKeyThemSharing: $recordKeyThemSharing)';
}


}

/// @nodoc
abstract mixin class $DhtConnectionEstablishedCopyWith<$Res> implements $DhtConnectionStateCopyWith<$Res> {
  factory $DhtConnectionEstablishedCopyWith(DhtConnectionEstablished value, $Res Function(DhtConnectionEstablished) _then) = _$DhtConnectionEstablishedCopyWithImpl;
@override @useResult
$Res call({
 RecordKey recordKeyMeSharing, KeyPair writerMeSharing, RecordKey recordKeyThemSharing
});




}
/// @nodoc
class _$DhtConnectionEstablishedCopyWithImpl<$Res>
    implements $DhtConnectionEstablishedCopyWith<$Res> {
  _$DhtConnectionEstablishedCopyWithImpl(this._self, this._then);

  final DhtConnectionEstablished _self;
  final $Res Function(DhtConnectionEstablished) _then;

/// Create a copy of DhtConnectionState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? recordKeyMeSharing = null,Object? writerMeSharing = null,Object? recordKeyThemSharing = null,}) {
  return _then(DhtConnectionEstablished(
recordKeyMeSharing: null == recordKeyMeSharing ? _self.recordKeyMeSharing : recordKeyMeSharing // ignore: cast_nullable_to_non_nullable
as RecordKey,writerMeSharing: null == writerMeSharing ? _self.writerMeSharing : writerMeSharing // ignore: cast_nullable_to_non_nullable
as KeyPair,recordKeyThemSharing: null == recordKeyThemSharing ? _self.recordKeyThemSharing : recordKeyThemSharing // ignore: cast_nullable_to_non_nullable
as RecordKey,
  ));
}


}

// dart format on
