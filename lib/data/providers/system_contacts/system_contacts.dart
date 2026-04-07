// Copyright 2024 The Reunicorn Authors. All rights reserved.
// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter_contacts/flutter_contacts.dart';

import 'base.dart';

class MissingSystemContactsPermissionError implements Exception {}

// TODO: Use or remove
class SystemContacts extends SystemContactsBase {
  @override
  Future<List<Contact>> getContacts() async {
    if (!await FlutterContacts.permissions.has(PermissionType.readWrite)) {
      throw MissingSystemContactsPermissionError();
    }

    // TODO: Offer loading them with just id and display name to speed things up in some cases?
    return FlutterContacts.getAll(
      properties: ContactProperties.all,
    );
  }

  @override
  Future<void> updateContact(Contact contact) async {
    if (!await FlutterContacts.permissions.has(PermissionType.readWrite)) {
      throw MissingSystemContactsPermissionError();
    }

    await FlutterContacts.update(contact);
  }

  @override
  Future<Contact?> getContact(String id) async {
    if (!await FlutterContacts.permissions.has(PermissionType.readWrite)) {
      throw MissingSystemContactsPermissionError();
    }

    // TODO: Error handling
    return FlutterContacts.get(id, properties: ContactProperties.all);
  }

  @override
  Future<String> insertContact(Contact contact) async {
    if (!await FlutterContacts.permissions.has(PermissionType.readWrite)) {
      throw MissingSystemContactsPermissionError();
    }

    return FlutterContacts.create(contact);
  }

  @override
  Future<bool> requestPermission() async {
    final status = await FlutterContacts.permissions.request(PermissionType.readWrite);
    return status == PermissionStatus.granted;
  }
}
