import 'dart:convert';
import 'dart:io';

import 'package:reunicorn/data/models/circle.dart';
import 'package:reunicorn/data/models/coag_contact.dart';
import 'package:reunicorn/data/models/profile_info.dart';
import 'package:reunicorn/data/models/utils.dart';
import 'package:reunicorn/data/utils.dart';
import 'package:yaml/yaml.dart';

import 'mocked_providers.dart';

Future<void> saveJson(String name, JsonEncodable jsonEncodable) async {
  final pubspec =
      loadYaml(File('pubspec.yaml').readAsStringSync()) as Map<String, dynamic>;
  final version = pubspec['version'].toString().split('+').first;

  final directoryPath = File(Platform.script.toFilePath()).parent.path;
  final directory = Directory('$directoryPath/assets');
  final newJson = jsonEncode(jsonEncodable.toJson());
  final newFileName = '${name}_v$version.json';

  var contentAlreadyExists = false;
  if (directory.existsSync()) {
    final entities = directory.listSync();

    for (final entity in entities) {
      if (entity is! File) {
        continue;
      }
      final fileName = entity.path.split(Platform.pathSeparator).last;
      if (fileName.startsWith('${name}_v') && fileName.endsWith('.json')) {
        final existingContent = await entity.readAsString();
        if (existingContent == newJson) {
          contentAlreadyExists = true;
          print('Skip $fileName');
          break;
        }
      }
    }
  }

  // 4. Save only if content is unique
  if (!contentAlreadyExists) {
    final file = File('$directoryPath/$newFileName');
    await file.writeAsString(newJson);
    print('Save $newFileName');
  }
}

void main() async {
  // ProfileInfo
  await saveJson(
    'profile_info',
    const ProfileInfo('p1', details: ContactDetails()),
  );

  // Circle
  await saveJson(
    'circle',
    Circle(id: 'c1', name: 'Circle 1', memberIds: ['cid1', 'cid2']),
  );

  // Contact
  await saveJson(
    'contact',
    CoagContact(
      coagContactId: 'ID1',
      name: 'Awesome Name',
      details: const ContactDetails(
        names: {'n1': 'Awesome Name'},
        emails: {'em1': 'mail@mailmail'},
      ),
      dhtSettings: DhtSettings(
        myNextKeyPair: await generateKeyPairBest(),
        myKeyPair: await generateKeyPairBest(),
        theirNextPublicKey: await generateKeyPairBest().then((kp) => kp.key),
        theirPublicKey: await generateKeyPairBest().then((kp) => kp.key),
        recordKeyMeSharing: dummyDhtRecordKey(0),
        writerMeSharing: await generateKeyPairBest(),
        recordKeyThemSharing: dummyDhtRecordKey(1),
        writerThemSharing: await generateKeyPairBest(),
        initialSecret: dummyPsk(0),
        theyAckHandshakeComplete: true,
      ),
      myIdentity: await generateKeyPairBest(),
      myIntroductionKeyPair: await generateKeyPairBest(),
    ),
  );
}
