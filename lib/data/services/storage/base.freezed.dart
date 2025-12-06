// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'base.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$StorageEvent<T> {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is StorageEvent<T>);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'StorageEvent<$T>()';
}


}

/// @nodoc
class $StorageEventCopyWith<T,$Res>  {
$StorageEventCopyWith(StorageEvent<T> _, $Res Function(StorageEvent<T>) __);
}


/// Adds pattern-matching-related methods to [StorageEvent].
extension StorageEventPatterns<T> on StorageEvent<T> {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( SetEvent<T> value)?  set,TResult Function( DeleteEvent<T> value)?  delete,required TResult orElse(),}){
final _that = this;
switch (_that) {
case SetEvent() when set != null:
return set(_that);case DeleteEvent() when delete != null:
return delete(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( SetEvent<T> value)  set,required TResult Function( DeleteEvent<T> value)  delete,}){
final _that = this;
switch (_that) {
case SetEvent():
return set(_that);case DeleteEvent():
return delete(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( SetEvent<T> value)?  set,TResult? Function( DeleteEvent<T> value)?  delete,}){
final _that = this;
switch (_that) {
case SetEvent() when set != null:
return set(_that);case DeleteEvent() when delete != null:
return delete(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( T? oldValue,  T newValue)?  set,TResult Function( T value)?  delete,required TResult orElse(),}) {final _that = this;
switch (_that) {
case SetEvent() when set != null:
return set(_that.oldValue,_that.newValue);case DeleteEvent() when delete != null:
return delete(_that.value);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( T? oldValue,  T newValue)  set,required TResult Function( T value)  delete,}) {final _that = this;
switch (_that) {
case SetEvent():
return set(_that.oldValue,_that.newValue);case DeleteEvent():
return delete(_that.value);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( T? oldValue,  T newValue)?  set,TResult? Function( T value)?  delete,}) {final _that = this;
switch (_that) {
case SetEvent() when set != null:
return set(_that.oldValue,_that.newValue);case DeleteEvent() when delete != null:
return delete(_that.value);case _:
  return null;

}
}

}

/// @nodoc


class SetEvent<T> implements StorageEvent<T> {
  const SetEvent(this.oldValue, this.newValue);
  

 final  T? oldValue;
 final  T newValue;

/// Create a copy of StorageEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SetEventCopyWith<T, SetEvent<T>> get copyWith => _$SetEventCopyWithImpl<T, SetEvent<T>>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SetEvent<T>&&const DeepCollectionEquality().equals(other.oldValue, oldValue)&&const DeepCollectionEquality().equals(other.newValue, newValue));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(oldValue),const DeepCollectionEquality().hash(newValue));

@override
String toString() {
  return 'StorageEvent<$T>.set(oldValue: $oldValue, newValue: $newValue)';
}


}

/// @nodoc
abstract mixin class $SetEventCopyWith<T,$Res> implements $StorageEventCopyWith<T, $Res> {
  factory $SetEventCopyWith(SetEvent<T> value, $Res Function(SetEvent<T>) _then) = _$SetEventCopyWithImpl;
@useResult
$Res call({
 T? oldValue, T newValue
});




}
/// @nodoc
class _$SetEventCopyWithImpl<T,$Res>
    implements $SetEventCopyWith<T, $Res> {
  _$SetEventCopyWithImpl(this._self, this._then);

  final SetEvent<T> _self;
  final $Res Function(SetEvent<T>) _then;

/// Create a copy of StorageEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? oldValue = freezed,Object? newValue = freezed,}) {
  return _then(SetEvent<T>(
freezed == oldValue ? _self.oldValue : oldValue // ignore: cast_nullable_to_non_nullable
as T?,freezed == newValue ? _self.newValue : newValue // ignore: cast_nullable_to_non_nullable
as T,
  ));
}


}

/// @nodoc


class DeleteEvent<T> implements StorageEvent<T> {
  const DeleteEvent(this.value);
  

 final  T value;

/// Create a copy of StorageEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DeleteEventCopyWith<T, DeleteEvent<T>> get copyWith => _$DeleteEventCopyWithImpl<T, DeleteEvent<T>>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DeleteEvent<T>&&const DeepCollectionEquality().equals(other.value, value));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(value));

@override
String toString() {
  return 'StorageEvent<$T>.delete(value: $value)';
}


}

/// @nodoc
abstract mixin class $DeleteEventCopyWith<T,$Res> implements $StorageEventCopyWith<T, $Res> {
  factory $DeleteEventCopyWith(DeleteEvent<T> value, $Res Function(DeleteEvent<T>) _then) = _$DeleteEventCopyWithImpl;
@useResult
$Res call({
 T value
});




}
/// @nodoc
class _$DeleteEventCopyWithImpl<T,$Res>
    implements $DeleteEventCopyWith<T, $Res> {
  _$DeleteEventCopyWithImpl(this._self, this._then);

  final DeleteEvent<T> _self;
  final $Res Function(DeleteEvent<T>) _then;

/// Create a copy of StorageEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? value = freezed,}) {
  return _then(DeleteEvent<T>(
freezed == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as T,
  ));
}


}

// dart format on
