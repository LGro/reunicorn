// Copyright 2024 - 2025 The Reunicorn Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

import 'dart:async';

import 'package:flutter/services.dart' show rootBundle;
import 'package:shared_preferences/shared_preferences.dart';

String maptilerToken() =>
    const String.fromEnvironment('REUNICORN_MAPTILER_TOKEN');

Future<String> loadMapStyle(
    {required bool darkMode,
    required String spriteUrl,
    required String glyphsUrl,
    required String pmTilesUrl}) async {
  final jsonString = await rootBundle.loadString(darkMode
      ? 'assets/map-style-dataviz-black.json'
      : 'assets/map-style-dataviz-white.json');
  return jsonString
      .replaceFirst(
          'pmtiles://https://demo-bucket.protomaps.com/v4.pmtiles', pmTilesUrl)
      .replaceFirst(
          'https://protomaps.github.io/basemaps-assets/sprites/v4/black',
          spriteUrl)
      .replaceFirst(
          'https://protomaps.github.io/basemaps-assets/fonts/{fontstack}/{range}.pbf',
          glyphsUrl);
}

class SettingsRepository {
  SettingsRepository({required bool darkMode}) {
    _darkMode = darkMode;
    unawaited(_init());
  }

  String _bootstrapServer = 'bootstrap-v1.veilid.net';
  bool _darkMode = false;
  String _customMapProviderUrl = '';
  String _mapStyleJson = '{}';

  Future<void> _init() async {
    final sp = await SharedPreferences.getInstance();

    _bootstrapServer = sp.getString('bootstrapServer') ?? _bootstrapServer;
    _darkMode = sp.getBool('darkMode') ?? _darkMode;
    _customMapProviderUrl =
        sp.getString('customMapProviderUrl') ?? _customMapProviderUrl;
    // _mapStyleJson = await loadMapStyle(
    //     darkMode: _darkMode,
    //     spriteUrl: _darkMode
    //         ? 'https://protomaps.github.io/basemaps-assets/sprites/v4/black'
    //         : 'https://protomaps.github.io/basemaps-assets/sprites/v4/white',
    //     glyphsUrl:
    //         'https://protomaps.github.io/basemaps-assets/fonts/{fontstack}/{range}.pbf',
    //     pmTilesUrl: 'pmtiles://https://maps.reunicorn.app/v4.pmtiles');
  }

  Future<void> setBootstrapServer(String value) async {
    _bootstrapServer = value;
    final sp = await SharedPreferences.getInstance();
    await sp.setString('bootstrapServer', value);
  }

  Future<void> setDarkMode(bool value) async {
    _darkMode = value;
    final sp = await SharedPreferences.getInstance();
    await sp.setBool('darkMode', value);
  }

  Future<void> setCustomMapProviderUrl(String value) async {
    _customMapProviderUrl = value;
    final sp = await SharedPreferences.getInstance();
    await sp.setString('customMapProviderUrl', value);
  }

  bool get darkMode => _darkMode;
  String get mapStyleString => (_customMapProviderUrl.isNotEmpty)
      ? _customMapProviderUrl
      // TODO: Replace by self hosted tile server compatible _mapStyleJson
      : [
          'https://api.maptiler.com/maps/dataviz-',
          if (_darkMode) 'dark' else 'light',
          '/style.json?key=${maptilerToken()}'
        ].join();
}
