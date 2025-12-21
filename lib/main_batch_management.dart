// Copyright 2024 - 2025 The Reunicorn Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'bloc_observer.dart';
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

    runApp(const CommunityManagementApp());
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
  const CommunityManagementApp({super.key});

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
          : const CommunityManagementPage(),
    ),
  );
}
