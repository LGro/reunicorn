// Copyright 2024 - 2026 The Reunicorn Authors. All rights reserved.
// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:reunicorn/data/services/dht/veilid_dht.dart';

import 'bloc_observer.dart';
import 'data/models/community.dart';
import 'data/models/models.dart';
import 'data/repositories/community_dht.dart';
import 'data/services/storage/base.dart';
import 'data/services/storage/sqlite.dart';
import 'tools/loggy.dart';
import 'ui/community_management/page.dart';
import 'veilid_init.dart';

void main() async {
  Future<void> mainFunc() async {
    // Initialize Veilid logging
    initLoggy();

    // Helps ensure that getting the app docs directory works
    WidgetsFlutterBinding.ensureInitialized();

    // Observer for logging Bloc related things
    Bloc.observer = const AppBlocObserver();

    final contactStorage = SqliteStorage<CoagContact>(
      'contact',
      (v) => jsonEncode(v.toJson()),
      contactMigrateFromJson,
    );
    final communityStorage = SqliteStorage<Community>(
      'community',
      (v) => jsonEncode(v.toJson()),
      communityMigrateFromJson,
    );

    runApp(CommunityManagementApp(communityStorage, contactStorage));
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

class CommunityManagementApp extends StatelessWidget {
  const CommunityManagementApp(
    this._communityStorage,
    this._contactStorage, {
    super.key,
  });

  final Storage<Community> _communityStorage;
  final Storage<CoagContact> _contactStorage;

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Reunicorn Community Management',
    home: FutureProvider<AppGlobalInit?>(
      initialData: null,
      create: (context) => AppGlobalInit.initialize('bootstrap-v1.veilid.net'),
      // AppGlobalInit.initialize can throw Already attached VeilidAPIException
      // which is fine
      catchError: (context, error) => null,
      builder: (context, child) => (context.watch<AppGlobalInit?>() == null)
          ? const Center(child: CircularProgressIndicator())
          : RepositoryProvider.value(
              value: CommunityDhtRepository(
                _communityStorage,
                _contactStorage,
                VeilidDht(),
              ),
              child: const CommunityManagementPage(),
            ),
    ),
  );
}
