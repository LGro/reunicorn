// Copyright 2024 - 2026 The Reunicorn Authors. All rights reserved.
// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:loggy/loggy.dart';
import 'package:provider/provider.dart';
import 'package:reunicorn/data/repositories/contact_update.dart';

import '../data/models/circle.dart';
import '../data/models/coag_contact.dart';
import '../data/models/community.dart';
import '../data/models/contact_update.dart';
import '../data/models/profile_info.dart';
import '../data/models/setting.dart';
import '../data/repositories/backup_dht.dart';
import '../data/repositories/contact_dht.dart';
import '../data/repositories/contact_system.dart';
import '../data/repositories/notifications.dart';
import '../data/repositories/settings.dart';
import '../data/services/storage/base.dart';
import '../l10n/app_localizations.dart';
import '../background_change_checker.dart';
import '../tick.dart';
import '../veilid_init.dart';
import '../veilid_processor/veilid_processor.dart';
import '../veilid_processor/views/developer.dart';
import 'router.dart';

class App extends StatefulWidget {
  const App(
    this.profileStorage,
    this.contactStorage,
    this.circleStorage,
    this.updateStorage,
    this.communityStorage,
    this.settingStorage,
    this.contactDhtRepository,
    this.updateRepository,
    this.systemContactRepository,
    this.backupRepository, {
    required this.isFirstRun,
    super.key,
  });

  final Storage<ProfileInfo> profileStorage;
  final Storage<CoagContact> contactStorage;
  final Storage<Circle> circleStorage;
  final Storage<ContactUpdate> updateStorage;
  final Storage<Community> communityStorage;
  final Storage<Setting> settingStorage;
  final ContactDhtRepository contactDhtRepository;
  final UpdateRepository updateRepository;
  final SystemContactRepository systemContactRepository;
  final BackupRepository backupRepository;
  final bool isFirstRun;

  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<App> with WidgetsBindingObserver {
  static const _apnsChannel = MethodChannel('apns_token');
  late final AppRouters _routers;
  late final AppLifecycleListener _lifecycleListener;

  final _seedColor = Colors.indigo;

  // TODO: Move to service or repository
  Future<void> _initAPNs() async {
    if (!Platform.isIOS) {
      return;
    }
    _apnsChannel.setMethodCallHandler((call) async {
      if (call.method == 'onApnsToken') {
        switch (call.method) {
          case 'onApnsToken':
            final raw = call.arguments;

            // Only accept clean String token.
            if (raw is! String || raw.isEmpty) {
              debugPrint('APNs invalid token received: $raw');
              return;
            }

            await widget.settingStorage.set(
              apnsSettingKey,
              Setting({
                'token': raw,
                'timestamp': DateTime.now().toUtc().toIso8601String(),
              }),
            );

            debugPrint('APNs token: $raw');
          case 'onTokenError':
            debugPrint('APNs Error: ${call.arguments}');
        }
      }
    });

    // Request permission and register for notifications
    try {
      await _apnsChannel.invokeMethod('register');
    } on PlatformException catch (e) {
      debugPrint('APNs failed to invoke register: ${e.message}');
    }
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);
    // _lifecycleListener = AppLifecycleListener(onRestart: _handleAppRestart);

    _routers = AppRouters(isFirstRun: widget.isFirstRun);

    unawaited(_initAPNs());
  }

  @override
  void dispose() {
    BackgroundChangeChecker().stop();
    WidgetsBinding.instance.removeObserver(this);
    _lifecycleListener.dispose();
    _routers.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!Platform.isAndroid) return;

    final checker = BackgroundChangeChecker();
    if (state == AppLifecycleState.paused) {
      // Detach Veilid to save battery; the background checker will
      // briefly re-attach for each periodic DHT poll.
      debugPrint(
        'rncrn-lifecycle: paused - detaching veilid, starting checker',
      );
      unawaited(VeilidProcessorRepository.instance.detach());
      checker.start(widget.contactDhtRepository);
    } else if (state == AppLifecycleState.resumed) {
      debugPrint(
        'rncrn-lifecycle: resumed - stopping checker, attaching veilid',
      );
      checker.stop();
      unawaited(VeilidProcessorRepository.instance.attach());
    }
  }

  Future<void> onDidReceiveNotificationResponse(
    NotificationResponse notificationResponse,
  ) async {
    final payload = notificationResponse.payload;
    if (notificationResponse.payload != null) {
      logDebug('notification payload: $payload');
    }
    // await Navigator.push(
    //   context,
    //   MaterialPageRoute<void>(builder: (context) => SecondScreen(payload)),
    // );
  }

  Future<void> _handleAppRestart() async {
    // On iOS sometimes when the app has been in the background for a while,
    // Veilid ends up showing up uninitialized, so let's try to initialize it
    try {
      await AppGlobalInit.initialize('bootstrap-v1.veilid.net');
    } catch (_) {
      // AppGlobalInit.initialize can throw Already attached VeilidAPIException
    }
  }

  @override
  Widget build(BuildContext context) => FutureProvider<AppGlobalInit?>(
    initialData: null,
    create: (context) =>
        // TODO: Pass initially specified boostrap url
        AppGlobalInit.initialize('bootstrap-v1.veilid.net'),
    // AppGlobalInit.initialize can throw Already attached VeilidAPIException which is fine
    catchError: (context, error) => null,
    builder: (context, child) {
      final globalInit = context.watch<AppGlobalInit?>();
      // Splash screen until we're done with init
      if (globalInit == null) {
        return MaterialApp(
          title: 'Reunicorn',
          debugShowCheckedModeBanner: true,
          themeMode: ThemeMode.system,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: _seedColor),
            useMaterial3: true,
          ),
          darkTheme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: _seedColor,
              brightness: Brightness.dark,
            ),
            useMaterial3: true,
          ),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const DeveloperPage(),
        );
        return const Center(child: CircularProgressIndicator());
      }

      // Once init is done, we proceed with the app
      return BackgroundTicker(
        child: MultiRepositoryProvider(
          providers: [
            RepositoryProvider<Storage<ProfileInfo>>(
              create: (_) => widget.profileStorage,
            ),
            RepositoryProvider<Storage<CoagContact>>(
              create: (_) => widget.contactStorage,
            ),
            RepositoryProvider<Storage<Circle>>(
              create: (_) => widget.circleStorage,
            ),
            RepositoryProvider<Storage<ContactUpdate>>(
              create: (_) => widget.updateStorage,
            ),
            RepositoryProvider<Storage<Community>>(
              create: (_) => widget.communityStorage,
            ),
            RepositoryProvider(create: (_) => widget.contactDhtRepository),
            RepositoryProvider(create: (_) => widget.updateRepository),
            RepositoryProvider(create: (_) => widget.systemContactRepository),
            RepositoryProvider(create: (_) => widget.backupRepository),
            RepositoryProvider(
              create: (_) => SettingsRepository(
                darkMode:
                    MediaQuery.of(context).platformBrightness ==
                    Brightness.dark,
              ),
            ),
            // Above the router, so cross-branch navigation helpers can reach
            // the branch routers from any screen.
            Provider<AppRouters>.value(value: _routers),
          ],
          child: MaterialApp.router(
            title: 'Reunicorn',
            debugShowCheckedModeBanner: true,
            themeMode: ThemeMode.system,
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(seedColor: _seedColor),
              useMaterial3: true,
            ),
            darkTheme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: _seedColor,
                brightness: Brightness.dark,
              ),
              useMaterial3: true,
            ),
            routerConfig: _routers.config,
            restorationScopeId: 'reunicorn',
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
          ),
        ),
      );
    },
  );
}
