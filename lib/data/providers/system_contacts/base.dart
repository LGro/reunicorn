// Copyright 2024 The Reunicorn Authors. All rights reserved.
// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:convert';

import 'package:flutter_contacts/flutter_contacts.dart';

abstract class SystemContactsBase {
  Future<List<Contact>> getContacts();
  Future<void> updateContact(Contact contact);
  Future<Contact?> getContact(String id);
  Future<String> insertContact(Contact contact);
  Future<bool> requestPermission();
}

/// Compare contacts, ignoring differences wrt thumbnail or photo
bool systemContactsEqual(Contact c1, Contact c2) {
  final c1Json = jsonEncode(c1.copyWith(clearPhoto: true).toJson());
  final c2Json = jsonEncode(c2.copyWith(clearPhoto: true).toJson());
  return c1Json == c2Json;
}
