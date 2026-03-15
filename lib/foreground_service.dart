// Copyright 2024 - 2026 The Reunicorn Authors. All rights reserved.
// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class ForegroundService {
  factory ForegroundService() => _instance;
  ForegroundService._internal();
  static final ForegroundService _instance = ForegroundService._internal();

  static const _channel =
      MethodChannel('social.coagulate.app/foreground_service');

  bool get isSupported => !kIsWeb && Platform.isAndroid;

  Future<void> start() async {
    if (!isSupported) return;
    try {
      await _channel.invokeMethod('startService');
      debugPrint('ForegroundService: started');
    } on PlatformException catch (e) {
      debugPrint('ForegroundService: failed to start – ${e.message}');
    }
  }

  Future<void> stop() async {
    if (!isSupported) return;
    try {
      await _channel.invokeMethod('stopService');
      debugPrint('ForegroundService: stopped');
    } on PlatformException catch (e) {
      debugPrint('ForegroundService: failed to stop – ${e.message}');
    }
  }

  Future<bool> isEnabled() async {
    if (!isSupported) return false;
    try {
      final result = await _channel.invokeMethod<bool>('isServiceEnabled');
      return result ?? true;
    } on PlatformException {
      return false;
    }
  }
}
