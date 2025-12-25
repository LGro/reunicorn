import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:reunicorn/data/models/utils.dart';
import 'package:yaml/yaml.dart';

Directory _getTestAssetsModelsPath(String modelName) {
  final repositoryRootPath = File(Platform.script.toFilePath()).parent.path;
  return Directory('$repositoryRootPath/test/assets/models/$modelName');
}

Future<void> saveJsonModelAsset(
  JsonEncodable jsonEncodable, {
  String? versionSuffix,
}) async {
  final name = camelCaseToSnakeCase(jsonEncodable.runtimeType.toString());
  final pubspec = loadYaml(File('pubspec.yaml').readAsStringSync());
  final version = pubspec['version'].toString().split('+').first;

  final directory = _getTestAssetsModelsPath(name);
  final newJson = jsonEncode(jsonEncodable.toJson());
  final newFileName = (versionSuffix == null)
      ? 'v${version}_$name.json'
      : 'v${version}_${versionSuffix}_$name.json';

  var contentAlreadyExists = false;
  if (directory.existsSync()) {
    final entities = directory.listSync();

    for (final entity in entities) {
      if (entity is! File) {
        continue;
      }
      final fileName = entity.path.split(Platform.pathSeparator).last;
      if (fileName.startsWith('v') && fileName.endsWith('_$name.json')) {
        final existingContent = await entity.readAsString();
        if (existingContent == newJson) {
          contentAlreadyExists = true;
          print('Skip creating $fileName');
          break;
        }
      }
    }
  }

  // 4. Save only if content is unique
  if (!contentAlreadyExists) {
    final file = File('${directory.path}/$newFileName');
    await file.writeAsString(newJson);
    print('Save created $newFileName');
  }
}

Map<String, String> loadAllPreviousSchemaVersionJsonFiles<T>() =>
    Map.fromEntries(
      _getTestAssetsModelsPath(camelCaseToSnakeCase(T.toString()))
          .listSync()
          .whereType<File>()
          .where((file) => file.path.split('/').last.startsWith('v'))
          .map(
            (file) =>
                MapEntry(file.path.split('/').last, file.readAsStringSync()),
          ),
    );

String camelCaseToSnakeCase(String value) => value
    .replaceAllMapped(RegExp('(?<=[a-z])[A-Z]'), (m) => '_${m.group(0)}')
    .toLowerCase();
