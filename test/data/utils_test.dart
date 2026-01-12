// Copyright 2024 - 2026 The Reunicorn Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

import 'package:flutter_test/flutter_test.dart';
import 'package:reunicorn/data/utils.dart';

import '../mocked_providers.dart';

void main() {
  test('test known contacts', () {
    final known = knownContacts('1', {
      '1': minimalBaseContact.copyWith(
        coagContactId: '1',
        name: 'c1',
        connectionAttestations: ['ac2'],
      ),
      '2': minimalBaseContact.copyWith(
        coagContactId: '2',
        name: 'c2',
        connectionAttestations: ['ac1'],
      ),
      '3': minimalBaseContact.copyWith(
        coagContactId: '3',
        name: 'c3',
        connectionAttestations: ['ac2'],
      ),
    });
    expect(known, {'3': 'c3'});
  });

  test('replace picture in json', () {
    expect(
      replacePictureWithEmptyInJson(
        '{"shared_profile":{"details":{"picture":[255,216,255,224,0,16]}}}',
      ),
      '{"shared_profile":{"details":{"picture":[]}}}',
    );

    const noPic = '{"no":"picture here"}';
    expect(replacePictureWithEmptyInJson(noPic), noPic);
  });
}
