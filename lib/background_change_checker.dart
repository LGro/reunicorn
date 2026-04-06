// Copyright 2026 The Reunicorn Authors. All rights reserved.
// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:reunicorn/data/repositories/contact_dht.dart';
import 'veilid_processor/veilid_processor.dart';

class BackgroundChangeChecker {
  factory BackgroundChangeChecker() => _instance;
  BackgroundChangeChecker._internal();
  static final BackgroundChangeChecker _instance =
      BackgroundChangeChecker._internal();

  static const _checkInterval = Duration(seconds: kDebugMode ? 15 : 60 * 5);

  Timer? _timer;
  bool _checking = false;
  ContactDhtRepository? _contactDhtRepository;

  void start(ContactDhtRepository contactDhtRepository) {
    if (_timer != null) return;
    _contactDhtRepository = contactDhtRepository;
    debugPrint('rncrn-bg: started');
    _timer = Timer.periodic(_checkInterval, (_) => _tick());
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
    debugPrint('rncrn-bg: stopped');
  }

  bool get isRunning => _timer != null;

  Future<void> _tick() async {
    if (_checking) {
      debugPrint('rncrn-bg: skip because checking');
      return;
    }

    if (!ProcessorRepository.instance.startedUp) {
      debugPrint('rncrn-bg: skip because veilid not started');
      return;
    }

    _checking = true;
    try {
      debugPrint('rncrn-bg: attaching veilid for background check');
      await ProcessorRepository.instance.attach();

      final ready = await ProcessorRepository.instance.waitForPublicInternet(
        timeout: const Duration(seconds: 30),
      );
      if (!ready) {
        debugPrint('rncrn-bg: timed out waiting for public internet');
        if (_timer != null) {
          await ProcessorRepository.instance.detach();
        }
        return;
      }

      await checkForPendingChanges();
    } catch (e) {
      debugPrint('rncrn-bg: error during check - $e');
    } finally {
      // Only detach if the checker is still running. If stop() was called
      // (i.e. the app resumed) while a check was in flight, the lifecycle
      // handler already re-attached Veilid for foreground use — detaching
      // here would kill that connection.
      if (_timer != null) {
        debugPrint('rncrn-bg: detaching veilid after background check');
        try {
          await ProcessorRepository.instance.detach();
        } catch (e) {
          debugPrint('rncrn-bg: error detaching - $e');
        }
      } else {
        debugPrint('rncrn-bg: checker was stopped during check, skipping detach');
      }
      _checking = false;
    }
  }

  Future<void> checkForPendingChanges() async {
    debugPrint('rncrn-bg: start checking for pending changes');
    final updates = await _contactDhtRepository?.updateAndWatchReceivingDHT(
      shuffle: true,
    );
    debugPrint(
      'rncrn-bg: finished checking (${updates?.length ?? 'null'})',
    );
    // Notifications are handled downstream by UpdateRepository, which
    // listens to contact storage change events triggered by the DHT sync.
  }
}
