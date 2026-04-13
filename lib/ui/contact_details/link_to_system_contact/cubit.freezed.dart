// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'cubit.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$LinkToSystemContactState {

 LinkToSystemContactStatus get status; bool get permissionGranted; CoagContact? get contact;@ContactConverter() List<Contact> get contacts;@AccountConverter() Set<Account> get accounts;@AccountConverter() Account? get selectedAccount; Set<String> get linkedSystemContactIds;
/// Create a copy of LinkToSystemContactState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LinkToSystemContactStateCopyWith<LinkToSystemContactState> get copyWith => _$LinkToSystemContactStateCopyWithImpl<LinkToSystemContactState>(this as LinkToSystemContactState, _$identity);

  /// Serializes this LinkToSystemContactState to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LinkToSystemContactState&&(identical(other.status, status) || other.status == status)&&(identical(other.permissionGranted, permissionGranted) || other.permissionGranted == permissionGranted)&&(identical(other.contact, contact) || other.contact == contact)&&const DeepCollectionEquality().equals(other.contacts, contacts)&&const DeepCollectionEquality().equals(other.accounts, accounts)&&(identical(other.selectedAccount, selectedAccount) || other.selectedAccount == selectedAccount)&&const DeepCollectionEquality().equals(other.linkedSystemContactIds, linkedSystemContactIds));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,status,permissionGranted,contact,const DeepCollectionEquality().hash(contacts),const DeepCollectionEquality().hash(accounts),selectedAccount,const DeepCollectionEquality().hash(linkedSystemContactIds));

@override
String toString() {
  return 'LinkToSystemContactState(status: $status, permissionGranted: $permissionGranted, contact: $contact, contacts: $contacts, accounts: $accounts, selectedAccount: $selectedAccount, linkedSystemContactIds: $linkedSystemContactIds)';
}


}

/// @nodoc
abstract mixin class $LinkToSystemContactStateCopyWith<$Res>  {
  factory $LinkToSystemContactStateCopyWith(LinkToSystemContactState value, $Res Function(LinkToSystemContactState) _then) = _$LinkToSystemContactStateCopyWithImpl;
@useResult
$Res call({
 LinkToSystemContactStatus status, bool permissionGranted, CoagContact? contact,@ContactConverter() List<Contact> contacts,@AccountConverter() Set<Account> accounts,@AccountConverter() Account? selectedAccount, Set<String> linkedSystemContactIds
});




}
/// @nodoc
class _$LinkToSystemContactStateCopyWithImpl<$Res>
    implements $LinkToSystemContactStateCopyWith<$Res> {
  _$LinkToSystemContactStateCopyWithImpl(this._self, this._then);

  final LinkToSystemContactState _self;
  final $Res Function(LinkToSystemContactState) _then;

/// Create a copy of LinkToSystemContactState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? status = null,Object? permissionGranted = null,Object? contact = freezed,Object? contacts = null,Object? accounts = null,Object? selectedAccount = freezed,Object? linkedSystemContactIds = null,}) {
  return _then(_self.copyWith(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as LinkToSystemContactStatus,permissionGranted: null == permissionGranted ? _self.permissionGranted : permissionGranted // ignore: cast_nullable_to_non_nullable
as bool,contact: freezed == contact ? _self.contact : contact // ignore: cast_nullable_to_non_nullable
as CoagContact?,contacts: null == contacts ? _self.contacts : contacts // ignore: cast_nullable_to_non_nullable
as List<Contact>,accounts: null == accounts ? _self.accounts : accounts // ignore: cast_nullable_to_non_nullable
as Set<Account>,selectedAccount: freezed == selectedAccount ? _self.selectedAccount : selectedAccount // ignore: cast_nullable_to_non_nullable
as Account?,linkedSystemContactIds: null == linkedSystemContactIds ? _self.linkedSystemContactIds : linkedSystemContactIds // ignore: cast_nullable_to_non_nullable
as Set<String>,
  ));
}

}


/// Adds pattern-matching-related methods to [LinkToSystemContactState].
extension LinkToSystemContactStatePatterns on LinkToSystemContactState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LinkToSystemContactState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LinkToSystemContactState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LinkToSystemContactState value)  $default,){
final _that = this;
switch (_that) {
case _LinkToSystemContactState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LinkToSystemContactState value)?  $default,){
final _that = this;
switch (_that) {
case _LinkToSystemContactState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( LinkToSystemContactStatus status,  bool permissionGranted,  CoagContact? contact, @ContactConverter()  List<Contact> contacts, @AccountConverter()  Set<Account> accounts, @AccountConverter()  Account? selectedAccount,  Set<String> linkedSystemContactIds)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LinkToSystemContactState() when $default != null:
return $default(_that.status,_that.permissionGranted,_that.contact,_that.contacts,_that.accounts,_that.selectedAccount,_that.linkedSystemContactIds);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( LinkToSystemContactStatus status,  bool permissionGranted,  CoagContact? contact, @ContactConverter()  List<Contact> contacts, @AccountConverter()  Set<Account> accounts, @AccountConverter()  Account? selectedAccount,  Set<String> linkedSystemContactIds)  $default,) {final _that = this;
switch (_that) {
case _LinkToSystemContactState():
return $default(_that.status,_that.permissionGranted,_that.contact,_that.contacts,_that.accounts,_that.selectedAccount,_that.linkedSystemContactIds);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( LinkToSystemContactStatus status,  bool permissionGranted,  CoagContact? contact, @ContactConverter()  List<Contact> contacts, @AccountConverter()  Set<Account> accounts, @AccountConverter()  Account? selectedAccount,  Set<String> linkedSystemContactIds)?  $default,) {final _that = this;
switch (_that) {
case _LinkToSystemContactState() when $default != null:
return $default(_that.status,_that.permissionGranted,_that.contact,_that.contacts,_that.accounts,_that.selectedAccount,_that.linkedSystemContactIds);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _LinkToSystemContactState implements LinkToSystemContactState {
  const _LinkToSystemContactState({this.status = LinkToSystemContactStatus.initial, this.permissionGranted = false, this.contact, @ContactConverter() final  List<Contact> contacts = const [], @AccountConverter() final  Set<Account> accounts = const {}, @AccountConverter() this.selectedAccount, final  Set<String> linkedSystemContactIds = const {}}): _contacts = contacts,_accounts = accounts,_linkedSystemContactIds = linkedSystemContactIds;
  factory _LinkToSystemContactState.fromJson(Map<String, dynamic> json) => _$LinkToSystemContactStateFromJson(json);

@override@JsonKey() final  LinkToSystemContactStatus status;
@override@JsonKey() final  bool permissionGranted;
@override final  CoagContact? contact;
 final  List<Contact> _contacts;
@override@JsonKey()@ContactConverter() List<Contact> get contacts {
  if (_contacts is EqualUnmodifiableListView) return _contacts;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_contacts);
}

 final  Set<Account> _accounts;
@override@JsonKey()@AccountConverter() Set<Account> get accounts {
  if (_accounts is EqualUnmodifiableSetView) return _accounts;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableSetView(_accounts);
}

@override@AccountConverter() final  Account? selectedAccount;
 final  Set<String> _linkedSystemContactIds;
@override@JsonKey() Set<String> get linkedSystemContactIds {
  if (_linkedSystemContactIds is EqualUnmodifiableSetView) return _linkedSystemContactIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableSetView(_linkedSystemContactIds);
}


/// Create a copy of LinkToSystemContactState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LinkToSystemContactStateCopyWith<_LinkToSystemContactState> get copyWith => __$LinkToSystemContactStateCopyWithImpl<_LinkToSystemContactState>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$LinkToSystemContactStateToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LinkToSystemContactState&&(identical(other.status, status) || other.status == status)&&(identical(other.permissionGranted, permissionGranted) || other.permissionGranted == permissionGranted)&&(identical(other.contact, contact) || other.contact == contact)&&const DeepCollectionEquality().equals(other._contacts, _contacts)&&const DeepCollectionEquality().equals(other._accounts, _accounts)&&(identical(other.selectedAccount, selectedAccount) || other.selectedAccount == selectedAccount)&&const DeepCollectionEquality().equals(other._linkedSystemContactIds, _linkedSystemContactIds));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,status,permissionGranted,contact,const DeepCollectionEquality().hash(_contacts),const DeepCollectionEquality().hash(_accounts),selectedAccount,const DeepCollectionEquality().hash(_linkedSystemContactIds));

@override
String toString() {
  return 'LinkToSystemContactState(status: $status, permissionGranted: $permissionGranted, contact: $contact, contacts: $contacts, accounts: $accounts, selectedAccount: $selectedAccount, linkedSystemContactIds: $linkedSystemContactIds)';
}


}

/// @nodoc
abstract mixin class _$LinkToSystemContactStateCopyWith<$Res> implements $LinkToSystemContactStateCopyWith<$Res> {
  factory _$LinkToSystemContactStateCopyWith(_LinkToSystemContactState value, $Res Function(_LinkToSystemContactState) _then) = __$LinkToSystemContactStateCopyWithImpl;
@override @useResult
$Res call({
 LinkToSystemContactStatus status, bool permissionGranted, CoagContact? contact,@ContactConverter() List<Contact> contacts,@AccountConverter() Set<Account> accounts,@AccountConverter() Account? selectedAccount, Set<String> linkedSystemContactIds
});




}
/// @nodoc
class __$LinkToSystemContactStateCopyWithImpl<$Res>
    implements _$LinkToSystemContactStateCopyWith<$Res> {
  __$LinkToSystemContactStateCopyWithImpl(this._self, this._then);

  final _LinkToSystemContactState _self;
  final $Res Function(_LinkToSystemContactState) _then;

/// Create a copy of LinkToSystemContactState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? status = null,Object? permissionGranted = null,Object? contact = freezed,Object? contacts = null,Object? accounts = null,Object? selectedAccount = freezed,Object? linkedSystemContactIds = null,}) {
  return _then(_LinkToSystemContactState(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as LinkToSystemContactStatus,permissionGranted: null == permissionGranted ? _self.permissionGranted : permissionGranted // ignore: cast_nullable_to_non_nullable
as bool,contact: freezed == contact ? _self.contact : contact // ignore: cast_nullable_to_non_nullable
as CoagContact?,contacts: null == contacts ? _self._contacts : contacts // ignore: cast_nullable_to_non_nullable
as List<Contact>,accounts: null == accounts ? _self._accounts : accounts // ignore: cast_nullable_to_non_nullable
as Set<Account>,selectedAccount: freezed == selectedAccount ? _self.selectedAccount : selectedAccount // ignore: cast_nullable_to_non_nullable
as Account?,linkedSystemContactIds: null == linkedSystemContactIds ? _self._linkedSystemContactIds : linkedSystemContactIds // ignore: cast_nullable_to_non_nullable
as Set<String>,
  ));
}


}

// dart format on
