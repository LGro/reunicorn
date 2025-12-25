// Copyright 2024 - 2025 The Reunicorn Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:reunicorn/data/services/dht.dart';

void main() {
  test('chop payload chunks for payload smaller than chunk size', () {
    final chunks = chopPayloadChunks(
      Uint8List(2),
      chunkMaxBytes: 4,
      numChunks: 3,
    ).toList();
    expect(chunks.length, 3);
    expect(chunks[0].length, 2);
    expect(chunks[1].length, 0);
    expect(chunks[2].length, 0);
  });

  test('chop payload chunks for payload max size', () {
    final chunks = chopPayloadChunks(
      Uint8List.fromList([0, 1, 2, 3]),
      chunkMaxBytes: 2,
      numChunks: 2,
    ).toList();
    expect(chunks.length, 2);
    expect(chunks[0], [0, 1]);
    expect(chunks[1], [2, 3]);
  });
}
