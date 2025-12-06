// Copyright 2025 The Reunicorn Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:permission_handler/permission_handler.dart';

import '../models/coag_contact.dart';
import '../services/storage/base.dart';

Set<String> getAllLinkedSystemContactIds(Iterable<CoagContact> contacts) =>
    contacts.map((c) => c.systemContactId).whereType<String>().toSet();

Future<CoagContact> updateSystemContact(CoagContact contact) async {
  if (contact.systemContactId == null) {
    return contact;
  }

  final permission = await Permission.contacts.status;
  if (!permission.isGranted) {
    return contact;
  }

  final systemContact = await FlutterContacts.getContact(
    contact.systemContactId!,
    withAccounts: true,
    withGroups: true,
  );
  if (systemContact == null) {
    // TODO: Is there a better way to remove it?
    final contactJson = contact.toJson()..remove('system_contact_id');
    return CoagContact.fromJson(contactJson);
  }

  if (contact.details == null) {
    return contact;
  }

  // We combine into a display name but the system display name is kept
  // TODO: Claim existing values
  final updatedSystemContact = mergeSystemContacts(
    systemContact,
    contact.details!.toSystemContact(
      contact.details!.names.values.join(' | '),
      contact.addressLocations,
    ),
  );
  await FlutterContacts.updateContact(updatedSystemContact);

  return contact;
}

Future<CoagContact> unlinkSystemContact(CoagContact contact) async {
  if (contact.systemContactId == null) {
    return contact;
  }

  final permission = await Permission.contacts.status;
  if (!permission.isGranted) {
    return contact;
  }

  final systemContact = await FlutterContacts.getContact(
    contact.systemContactId!,
    withAccounts: true,
    withGroups: true,
  );
  if (systemContact != null) {
    await FlutterContacts.updateContact(
      removeCoagManagedSuffixes(systemContact),
    );
  }
  // TODO: Is there a better way to remove it?
  final contactJson = contact.toJson()..remove('system_contact_id');
  return CoagContact.fromJson(contactJson);
}

// TODO: store coag contact and system contact links separate

class SystemContactRepository {
  final Storage<CoagContact> _contactStorage;

  SystemContactRepository(this._contactStorage) {
    _contactStorage.changeEvents.listen(
      (e) => e.when(
        set: (oldContact, newContact) => updateSystemContact(newContact),
        delete: unlinkSystemContact,
      ),
    );
  }
}
