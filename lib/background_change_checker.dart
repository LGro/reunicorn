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

    // Only check when Veilid network is ready
    if (!ProcessorRepository
        .instance
        .processorConnectionState
        .isPublicInternetReady) {
      debugPrint('rncrn-bg: skip because veilid offline');
      return;
    }

    _checking = true;
    try {
      await checkForPendingChanges();
    } catch (e) {
      debugPrint('rncrn-bg: error during check - $e');
    } finally {
      _checking = false;
    }
  }

  Future<void> checkForPendingChanges() async {
    debugPrint('rncrn-bg: start checking for pending changes in background');
    // Only bring up veilid here and shut down afterwards to reduce background load?
    // TODO: Add timeout?
    final updates = await _contactDhtRepository?.updateAndWatchReceivingDHT(
      shuffle: true,
    );
    debugPrint(
      'rncrn-bg: finished checking for pending changes in background (${updates?.length ?? 'null'})',
    );
    // Notifications are handled downstream by UpdateRepository, which
    // listens to contact storage change events triggered by the DHT sync.
  }
}
