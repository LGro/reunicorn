// ignore_for_file: file_names because we want to ensure this is run first

import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:reunicorn/data/models/circle.dart';
import 'package:reunicorn/data/models/coag_contact.dart';
import 'package:reunicorn/data/models/profile_info.dart';
import 'package:reunicorn/data/models/utils.dart';
import 'package:yaml/yaml.dart';

import 'mocked_providers.dart';

Future<void> saveJson(String name, JsonEncodable jsonEncodable) async {
  final pubspec = loadYaml(File('pubspec.yaml').readAsStringSync());
  final version = pubspec['version'].toString().split('+').first;

  final directoryPath = File(Platform.script.toFilePath()).parent.path;
  final directory = Directory('$directoryPath/test/assets');
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
    final file = File('${directory.path}/$newFileName');
    await file.writeAsString(newJson);
    print('Save $newFileName');
  }
}

void main() {
  // TODO: Is the 00 file name prefix enough to ensure this runs before the test
  //       that uses the potentially generated assets?
  test('generate updated json test assets where needed', () async {
    // ProfileInfos
    await saveJson(
      'profile_info',
      const ProfileInfo('p1', details: ContactDetails()),
    );

    // Circles
    await saveJson(
      'circle',
      Circle(id: 'c1', name: 'Circle 1', memberIds: ['cid1', 'cid2']),
    );

    // Contacts
    final minimalContact = CoagContact(
      coagContactId: 'ID1',
      name: 'Awesome Name',
      dhtSettings: DhtSettings(
        myNextKeyPair: fakeKeyPair(),
        myKeyPair: fakeKeyPair(),
        theirNextPublicKey: fakeKeyPair().key,
        theirPublicKey: fakeKeyPair().key,
        recordKeyMeSharing: fakeDhtRecordKey(0),
        writerMeSharing: fakeKeyPair(),
        recordKeyThemSharing: fakeDhtRecordKey(1),
        writerThemSharing: fakeKeyPair(),
        initialSecret: fakePsk(0),
        theyAckHandshakeComplete: true,
      ),
      myIdentity: fakeKeyPair(),
      myIntroductionKeyPair: fakeKeyPair(),
    );
    await saveJson('contact_minimal', minimalContact);
    // TODO: Add more things to full contact
    await saveJson(
      'contact_full',
      minimalContact.copyWith(
        details: const ContactDetails(
          names: {'n1': 'Awesome Name'},
          emails: {'em1': 'mail@mailmail'},
        ),
      ),
    );
  });
}
