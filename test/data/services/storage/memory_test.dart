// Copyright 2025 The Reunicorn Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

import 'package:flutter_test/flutter_test.dart';
import 'package:reunicorn/data/models/utils.dart';
import 'package:reunicorn/data/services/storage/base.dart';
import 'package:reunicorn/data/services/storage/memory.dart';

class Dummy implements JsonEncodable {
  final String value;

  const Dummy(this.value);

  @override
  Map<String, dynamic> toJson() => {'key': value};
}

void main() {
  test(
    'test memory change event stream is broadcast allows multiple listeners',
    () async {
      final memory = MemoryStorage<Dummy>();
      final callLog = <String>[];
      memory.changeEvents.listen(
        (e) => e.when(
          set: (oldVal, newVal) => callLog.add(newVal.value),
          delete: (val) {
            return;
          },
        ),
      );
      memory.changeEvents.listen(
        (e) => e.when(
          set: (oldVal, newVal) => callLog.add(newVal.value),
          delete: (val) {
            return;
          },
        ),
      );
      await memory.set('1', const Dummy('dummy'));
      expect(callLog, hasLength(2));
    },
  );
}
