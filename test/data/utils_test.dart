// Copyright 2024 - 2025 The Reunicorn Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

import 'package:reunicorn/data/utils.dart';
import 'package:flutter_test/flutter_test.dart';

import '../utils.dart';

void main() {
  test('test known contacts', () {
    final known = knownContacts('1', {
      '1': dummyBaseContact.copyWith(
        coagContactId: '1',
        name: 'c1',
        connectionAttestations: ['ac2'],
      ),
      '2': dummyBaseContact.copyWith(
        coagContactId: '2',
        name: 'c2',
        connectionAttestations: ['ac1'],
      ),
      '3': dummyBaseContact.copyWith(
        coagContactId: '3',
        name: 'c3',
        connectionAttestations: ['ac2'],
      ),
    });
    expect(known, {'3': 'c3'});
  });
}
