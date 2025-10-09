// Copyright 2024 - 2025 The Reunicorn Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

import 'dart:io';

import 'package:yaml/yaml.dart';

Future<String> readCurrentVersionFromPubspec() async {
  final content = await File('pubspec.yaml').readAsString();
  final yamlMap = loadYaml(content) as YamlMap;
  return yamlMap['version'] as String;
}

Map<String, String> loadAllPreviousSchemaVersionJsons(
  String jsonAssetDirectory,
) =>
    Map.fromEntries(Directory(jsonAssetDirectory)
        .listSync()
        .whereType<File>()
        .where((file) => file.path.endsWith('.json'))
        .map((file) => MapEntry(file.path, file.readAsStringSync())));
