// Copyright 2024 - 2026 The Reunicorn Authors. All rights reserved.
// SPDX-License-Identifier: AGPL-3.0-or-later

part of 'cubit.dart';

enum LinkToSystemContactStatus { initial, success, denied }

extension LinkToSystemContactStatusX on LinkToSystemContactStatus {
  bool get isInitial => this == LinkToSystemContactStatus.initial;
  bool get isSuccess => this == LinkToSystemContactStatus.success;
  bool get isDenied => this == LinkToSystemContactStatus.denied;
}

class ContactConverter implements JsonConverter<Contact, Map<String, dynamic>> {
  const ContactConverter();

  @override
  Contact fromJson(Map<String, dynamic> json) {
    return Contact.fromJson(json);
  }

  @override
  Map<String, dynamic> toJson(Contact object) {
    return object.toJson();
  }
}

class AccountConverter implements JsonConverter<Account, Map<String, dynamic>> {
  const AccountConverter();

  @override
  Account fromJson(Map<String, dynamic> json) {
    return Account.fromJson(json);
  }

  @override
  Map<String, dynamic> toJson(Account object) {
    return object.toJson();
  }
}

@freezed
sealed class LinkToSystemContactState with _$LinkToSystemContactState {
  const factory LinkToSystemContactState({
    @Default(LinkToSystemContactStatus.initial)
    LinkToSystemContactStatus status,
    @Default(false) bool permissionGranted,
    CoagContact? contact,
    @Default([]) @ContactConverter() List<Contact> contacts,
    @Default({}) @AccountConverter() Set<Account> accounts,
    @AccountConverter() Account? selectedAccount,
    @Default({}) Set<String> linkedSystemContactIds,
  }) = _LinkToSystemContactState;

  factory LinkToSystemContactState.fromJson(Map<String, dynamic> json) =>
      _$LinkToSystemContactStateFromJson(json);
}
