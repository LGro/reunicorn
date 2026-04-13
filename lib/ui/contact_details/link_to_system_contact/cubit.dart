// Copyright 2024 - 2025 The Reunicorn Authors. All rights reserved.
// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:permission_handler/permission_handler.dart'
    hide PermissionStatus;

import '../../../data/models/coag_contact.dart';
import '../../../data/repositories/contact_system.dart';
import '../../../data/services/storage/base.dart';

part 'cubit.freezed.dart';
part 'cubit.g.dart';
part 'state.dart';

class LinkToSystemContactCubit extends Cubit<LinkToSystemContactState> {
  LinkToSystemContactCubit(this._contactStorage, String coagContactId)
    : super(const LinkToSystemContactState()) {
    _contactSubscription = _contactStorage.changeEvents.listen(
      (e) => e.when(
        delete: (contact) {
          return;
        },
        set: (oldContact, newContact) {
          if (newContact.coagContactId == coagContactId && !isClosed) {
            emit(state.copyWith(contact: newContact));
          }
          return;
        },
      ),
    );
    unawaited(initialize(coagContactId));
  }

  final Storage<CoagContact> _contactStorage;
  late final StreamSubscription<StorageEvent<CoagContact>> _contactSubscription;

  Future<void> initialize(String contactId) async {
    final contacts = await _contactStorage.getAll();
    final permissionStatus = await Permission.contacts.status;
    if (!isClosed) {
      emit(
        state.copyWith(
          contact: contacts[contactId],
          permissionGranted: permissionStatus.isGranted,
          linkedSystemContactIds: getAllLinkedSystemContactIds(contacts.values),
        ),
      );
      if (permissionStatus.isGranted) {
        await loadSystemContacts();
      }
    }
  }

  /// Ask for system contact access (if not already granted)
  Future<void> requestPermission() => FlutterContacts.permissions
      .request(PermissionType.readWrite)
      .then((status) async {
        final granted = status == PermissionStatus.granted;
        if (!isClosed) {
          emit(state.copyWith(permissionGranted: granted));
          if (granted) {
            await loadSystemContacts();
          }
        }
      });

  /// Load contacts from system address book
  Future<void> loadSystemContacts() async {
    final contacts = await FlutterContacts.getAll(
      properties: {
        ...ContactProperties.allProperties,
        ContactProperty.photoThumbnail,
      },
    );
    final allAccounts = await FlutterContacts.accounts.getAll();
    final uniqueAccounts = Map.fromEntries(
      allAccounts.map((a) => MapEntry(a.name, a)),
    ).values.toSet();
    if (!isClosed) {
      emit(
        state.copyWith(
          contacts: contacts,
          accounts: uniqueAccounts,
          selectedAccount: (uniqueAccounts.length > 1)
              ? uniqueAccounts.first
              : null,
        ),
      );
    }
  }

  /// Add new system contact from app contact
  Future<void> createNewSystemContact(
    String displayName, {
    Account? account,
  }) async => (state.contact == null)
      ? null
      : FlutterContacts.create(
          Contact(name: Name(first: displayName)),
          account: account,
        ).then(
          (systemContactId) => _contactStorage.set(
            state.contact!.coagContactId,
            state.contact!.copyWith(systemContactId: systemContactId),
          ),
        );

  /// Link app contact to existing system contact
  Future<void> linkExistingSystemContact(String systemContactId) async =>
      (state.contact == null)
      ? null
      : _contactStorage.set(
          state.contact!.coagContactId,
          state.contact!.copyWith(systemContactId: systemContactId),
        );

  /// Select an account to potentially add a new system contact to
  void setSelectedAccount(Account? account) =>
      isClosed ? null : emit(state.copyWith(selectedAccount: account));

  /// Close subscriptions
  @override
  Future<void> close() {
    unawaited(_contactSubscription.cancel());
    return super.close();
  }
}
