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
    // Create the directory first: on a fresh checkout it does not exist yet for
    // models that have no committed fixtures, and writeAsString does not create
    // parents, so the test died with PathNotFoundException.
    await directory.create(recursive: true);
    final file = File('${directory.path}/$newFileName');
    await file.writeAsString(newJson);
    print('Save created $newFileName');
  }
}

Map<String, String> loadAllPreviousSchemaVersionJsonFiles<T>() {
  final directory = _getTestAssetsModelsPath(camelCaseToSnakeCase(T.toString()));
  // A model with no committed fixtures yet has no directory; listSync would
  // throw rather than report "no previous versions to check".
  if (!directory.existsSync()) {
    return const {};
  }
  return Map.fromEntries(
      directory
          .listSync()
          .whereType<File>()
          .where((file) => file.path.split('/').last.startsWith('v'))
          .map(
            (file) =>
                MapEntry(file.path.split('/').last, file.readAsStringSync()),
          ),
  );
}

String camelCaseToSnakeCase(String value) => value
    .replaceAllMapped(RegExp('(?<=[a-z])[A-Z]'), (m) => '_${m.group(0)}')
    .toLowerCase();
