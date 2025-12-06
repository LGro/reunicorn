// Copyright 2025 The Reunicorn Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:veilid_support/veilid_support.dart';

String? tryUtf8Decode(Uint8List? content) {
  if (content == null) {
    return null;
  }
  try {
    return utf8.decode(content);
  } on FormatException catch (e) {
    // debugPrint('UTF-8 decode attempt lead to $e');
    return null;
  }
}

Iterable<Uint8List> chopPayloadChunks(
  Uint8List payload, {
  int chunkMaxBytes = 32000,
  int numChunks = 31,
}) => List.generate(
  numChunks,
  (i) => (payload.length > i * chunkMaxBytes)
      ? payload.sublist(
          i * chunkMaxBytes,
          min(payload.length, (i + 1) * chunkMaxBytes),
        )
      : Uint8List(0),
);

Future<Uint8List> getChunkedPayload(
  DHTRecord record,
  CryptoCodec crypto,
  DHTRecordRefreshMode refreshMode, {
  required int numChunks,
  int chunkOffset = 0,
}) async {
  // Combine the remaining subkeys into the picture
  final chunks = await Future.wait(
    List.generate(numChunks, (i) => i + chunkOffset).map(
      (i) => record.get(crypto: crypto, refreshMode: refreshMode, subkey: i),
    ),
  );
  final payload = Uint8List.fromList(
    chunks.map((e) => e ?? Uint8List(0)).expand((x) => x).toList(),
  );
  return payload;
}
