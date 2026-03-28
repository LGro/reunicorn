// Copyright 2024 - 2026 The Reunicorn Authors. All rights reserved.
// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:reunicorn/data/repositories/contact_dht.dart';
import 'package:veilid_support/veilid_support.dart';

import 'notification_service.dart';
import 'veilid_processor/veilid_processor.dart';

class BackgroundChangeChecker {
  factory BackgroundChangeChecker() => _instance;
  BackgroundChangeChecker._internal();
  static final BackgroundChangeChecker _instance =
      BackgroundChangeChecker._internal();

  static const _checkInterval = Duration(seconds: kIsDebugMode ? 15 : 60 * 5);

  Timer? _timer;
  bool _checking = false;
  int _notificationIdCounter = 2000;
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
      final result = await checkForPendingChanges();
      if (result != null) {
        await _showNotification(result);
      }
    } catch (e) {
      debugPrint('rncrn-bg: error during check - $e');
    } finally {
      _checking = false;
    }
  }

  Future<ChangeResult?> checkForPendingChanges() async {
    debugPrint('rncrn-bg: start checking for pending changes in background');
    // Only bring up veilid here and shut down afterwards to reduce background load?
    // TODO: Add timeout?
    final updatedContacts = await _contactDhtRepository
        ?.updateAndWatchReceivingDHT(shuffle: true);
    debugPrint(
      'rncrn-bg: finished checking for pending changes in background (${updatedContacts?.length ?? 'null'})',
    );
    if (updatedContacts == null) {
      return null;
    }
    if (updatedContacts.length == 1) {
      return ChangeResult(
        title: 'Update from ${updatedContacts.first.name}',
        body: 'Check the app for more details...',
      );
    }
    if (updatedContacts.length > 1) {
      return ChangeResult(
        title: 'Update from multiple contacts',
        body: updatedContacts.map((c) => c.name).toString(),
      );
    }
    return null;
  }

  Future<void> _showNotification(ChangeResult result) async {
    final notificationService = NotificationService();
    if (!notificationService.isInitialized) return;

    await notificationService.showNotification(
      _notificationIdCounter++,
      result.title,
      result.body,
      payload: result.payload,
    );
  }
}

class ChangeResult {
  const ChangeResult({required this.title, required this.body, this.payload});

  final String title;
  final String body;
  final String? payload;
}
