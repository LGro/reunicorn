// Copyright 2024 - 2025 The Reunicorn Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

import 'dart:async';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'bloc_observer.dart';
import 'data/models/circle.dart';
import 'data/models/coag_contact.dart';
import 'data/models/community.dart';
import 'data/models/contact_update.dart';
import 'data/models/profile_info.dart';
import 'data/providers/legacy/sqlite.dart' as legacy;
import 'data/repositories/contact_dht.dart';
import 'data/repositories/contact_system.dart';
import 'data/services/storage/sqlite.dart';
import 'notification_service.dart';
import 'tools/loggy.dart';
import 'ui/app.dart';

Future<void> _migratePre023(
  legacy.SqliteStorage legacyStorage,
  SqliteStorage<CoagContact> contactStorage,
  SqliteStorage<ProfileInfo> profileStorage,
  SqliteStorage<Circle> circleStorage,
) async {
  final legacyContacts = await legacyStorage.getAllContacts();
  final legacyProfile = await legacyStorage.getProfileInfo();
  final legacyCircles = await legacyStorage.getCircles();
  final legacyCircleMemberships = await legacyStorage.getCircleMemberships();

  if (legacyContacts.isEmpty) {
    return;
  }
  for (final contact in legacyContacts.values) {
    await contactStorage.set(contact.coagContactId, contact);
    await legacyStorage.removeContact(contact.coagContactId);
  }

  for (final circle in legacyCircles.entries) {
    await circleStorage.set(
      circle.key,
      Circle(
        id: circle.key,
        name: circle.value,
        memberIds: legacyCircleMemberships.entries
            .where((e) => e.value.contains(circle.key))
            .map((e) => e.key)
            .toList(),
      ),
    );
  }

  if (legacyProfile != null) {
    final existingProfile = await profileStorage.getAll();
    if (existingProfile.isNotEmpty) {
      await profileStorage.delete(existingProfile.keys.first);
    }
    await profileStorage.set(legacyProfile.id, legacyProfile);
  }

  final file = File(join(await getDatabasesPath(), 'contacts.db'));
  if (file.existsSync()) {
    await file.delete();
    print('Database deleted');
  }
}

void main() async {
  Future<void> mainFunc() async {
    // Initialize Veilid logging
    initLoggy();

    // Helps ensure that getting the app docs directory works
    WidgetsFlutterBinding.ensureInitialized();

    // Observer for logging Bloc related things
    Bloc.observer = const AppBlocObserver();

    await NotificationService().init();

    final profileStorage = SqliteStorage<ProfileInfo>(
      'profile',
      profileMigrateFromJson,
    );
    final contactStorage = SqliteStorage<CoagContact>(
      'contact',
      contactMigrateFromJson,
    );
    final circleStorage = SqliteStorage<Circle>(
      'circle',
      circleMigrateFromJson,
    );
    final updateStorage = SqliteStorage<ContactUpdate>(
      'update',
      contactUpdateMigrateFromJson,
    );
    final communityStorage = SqliteStorage<Community>(
      'community',
      communityMigrateFromJson,
    );

    unawaited(
      contactStorage.getAll().then(
        (_) => _migratePre023(
          legacy.SqliteStorage(),
          contactStorage,
          profileStorage,
          circleStorage,
        ),
      ),
    );
    final contactDhtRepository = ContactDhtRepository(
      contactStorage,
      circleStorage,
      profileStorage,
    );
    final systemContactRepository = SystemContactRepository(contactStorage);

    runApp(
      App(
        profileStorage,
        contactStorage,
        circleStorage,
        updateStorage,
        communityStorage,
        contactDhtRepository,
        systemContactRepository,
      ),
    );
  }

  if (kDebugMode) {
    // In debug mode, run the app without catching exceptions for debugging
    await mainFunc();
  } else {
    // Catch errors in production without killing the app
    await runZonedGuarded(mainFunc, (error, stackTrace) {
      log.error('Dart Runtime: {$error}\n{$stackTrace}');
    });
  }
}
