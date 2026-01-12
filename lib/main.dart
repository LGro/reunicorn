// Copyright 2024 - 2026 The Reunicorn Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

import 'dart:async';
import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'bloc_observer.dart';
import 'data/models/circle.dart';
import 'data/models/coag_contact.dart';
import 'data/models/community.dart';
import 'data/models/contact_update.dart';
import 'data/models/profile_info.dart';
import 'data/models/setting.dart';
import 'data/providers/legacy/sqlite.dart' as legacy;
import 'data/repositories/backup_dht.dart';
import 'data/repositories/contact_dht.dart';
import 'data/repositories/contact_system.dart';
import 'data/repositories/notifications.dart';
import 'data/services/dht/veilid_dht.dart';
import 'data/services/storage/sqlite.dart';
import 'data/utils.dart';
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
      (v) => jsonEncode(v.toJson()),
      profileMigrateFromJson,
    );
    final contactStorage = SqliteStorage<CoagContact>(
      'contact',
      (v) => jsonEncode(v.toJson()),
      contactMigrateFromJson,
    );
    final circleStorage = SqliteStorage<Circle>(
      'circle',
      (v) => jsonEncode(v.toJson()),
      circleMigrateFromJson,
    );
    final updateStorage = SqliteStorage<ContactUpdate>(
      'update',
      (v) => jsonEncode(v.toJson()),
      contactUpdateMigrateFromJson,
    );
    final communityStorage = SqliteStorage<Community>(
      'community',
      (v) => jsonEncode(v.toJson()),
      communityMigrateFromJson,
    );
    final settingStorage = SqliteStorage<Setting>(
      'setting',
      (v) => jsonEncode(v.toJson()),
      (v) async => Setting(jsonDecode(v) as Map<String, dynamic>),
    );
    final notificationStorage = SqliteStorage<String>(
      'setting',
      (v) => v,
      (v) async => v,
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
      VeilidDht(),
    );
    final systemContactRepository = SystemContactRepository(contactStorage);
    // ignore: unused_local_variable we just need it to listen
    final pushNotificationRepository = PushNotificationRepository(
      contactStorage,
      notificationStorage,
      settingStorage,
    );
    final backupRepository = BackupRepository(
      profileStorage,
      contactStorage,
      circleStorage,
      settingStorage,
    );

    final profile = await getProfileInfo(profileStorage);

    runApp(
      App(
        profileStorage,
        contactStorage,
        circleStorage,
        updateStorage,
        communityStorage,
        settingStorage,
        contactDhtRepository,
        systemContactRepository,
        backupRepository,
        isFirstRun: profile == null,
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
