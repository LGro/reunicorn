// Copyright 2024 - 2026 The Reunicorn Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

import 'dart:async';
import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_ce_flutter/hive_ce_flutter.dart';
import 'package:reunicorn/config.dart';
import 'package:reunicorn/data/services/storage/hive.dart';

import 'bloc_observer.dart';
import 'data/models/circle.dart';
import 'data/models/coag_contact.dart';
import 'data/models/community.dart';
import 'data/models/contact_update.dart';
import 'data/models/profile_info.dart';
import 'data/models/setting.dart';
import 'data/repositories/backup_dht.dart';
import 'data/repositories/contact_dht.dart';
import 'data/repositories/contact_system.dart';
import 'data/repositories/notifications.dart';
import 'data/services/dht/veilid_dht.dart';
import 'data/utils.dart';
import 'notification_service.dart';
import 'tools/tools.dart';
import 'ui/app.dart';

void main() async {
  Future<void> mainFunc() async {
    // Initialize Veilid logging
    initLoggy();

    // Helps ensure that getting the app docs directory works
    WidgetsFlutterBinding.ensureInitialized();

    // Observer for logging Bloc related things
    Bloc.observer = const AppBlocObserver();

    // Init Hive incl. cryptographic key
    const secureStorage = FlutterSecureStorage();
    final encryptionKeyString = await secureStorage.read(
      key: hiveSecretKeyName,
    );
    if (encryptionKeyString == null) {
      final key = Hive.generateSecureKey();
      await secureStorage.write(
        key: hiveSecretKeyName,
        value: base64UrlEncode(key),
      );
    }
    await Hive.initFlutter();

    if (!isWeb) {
      // TODO(LGro): Check what it takes to enable notifications for web
      await NotificationService().init();
    }

    final profileStorage = HiveStorage<ProfileInfo>(
      'profile',
      (v) => jsonEncode(v.toJson()),
      profileMigrateFromJson,
    );
    final contactStorage = HiveStorage<CoagContact>(
      'contact',
      (v) => jsonEncode(v.toJson()),
      contactMigrateFromJson,
    );
    final circleStorage = HiveStorage<Circle>(
      'circle',
      (v) => jsonEncode(v.toJson()),
      circleMigrateFromJson,
    );
    final updateStorage = HiveStorage<ContactUpdate>(
      'update',
      (v) => jsonEncode(v.toJson()),
      contactUpdateMigrateFromJson,
    );
    final communityStorage = HiveStorage<Community>(
      'community',
      (v) => jsonEncode(v.toJson()),
      communityMigrateFromJson,
    );
    final settingStorage = HiveStorage<Setting>(
      'setting',
      (v) => jsonEncode(v.toJson()),
      (v) async => Setting(jsonDecode(v) as Map<String, dynamic>),
    );
    final notificationStorage = HiveStorage<String>(
      'setting',
      (v) => v,
      (v) async => v,
    );

    final contactDhtRepository = ContactDhtRepository(
      contactStorage,
      circleStorage,
      profileStorage,
      settingStorage,
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
