// Copyright 2025 - 2026 The Reunicorn Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

import 'dart:math' show min;
import 'package:flutter/foundation.dart';
import 'package:veilid_support/veilid_support.dart';

import '../../../tools/loggy.dart';

Iterable<Uint8List> chopPayloadChunks(
  Uint8List payload, {
  required int numChunks,
  int chunkMaxBytes = 32000,
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
  DHTRecordRefreshMode refreshMode, {
  required int numChunks,
  int chunkOffset = 0,
  CryptoCodec? crypto,
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

abstract class BaseDht {
  Future<(RecordKey, KeyPair)> create();
  Future<void> write(RecordKey recordKey, KeyPair writer, Uint8List value);
  Future<Uint8List?> read(RecordKey recordKey, {bool local = false});
  Future<bool> watch(RecordKey recordKey, VoidCallback callback);
}

class VeilidDht implements BaseDht {
  // TODO(LGro): on which level do we handle watched bookkeeping? could be dht contact repo and then we could make these all functions
  final _watchedRecords = <RecordKey>{};

  // Whether to watch local changes; this is useful for integration tests
  final bool _watchLocalChanges;

  VeilidDht({bool watchLocalChanges = false})
    : _watchLocalChanges = watchLocalChanges;

  @override
  Future<(RecordKey, KeyPair)> create() async {
    final record = await DHTRecordPool.instance.createRecord(
      debugName: 'rcrn::create',
      // Create subkeys allowing max size of 32KiB per subkey given max record
      // limit of 1MiB
      schema: const DHTSchema.dflt(oCnt: 32),
      crypto: const VeilidCryptoPublic(),
    );
    // Write to it once, so push it into the network. (Is this really needed?)
    await record.tryWriteBytes(
      Uint8List(0),
      crypto: const VeilidCryptoPublic(),
    );
    await record.close();
    debugPrint(
      'created and wrote once to ${record.key.toString().substring(5, 10)}',
    );
    // TODO(LGro): When can the writer be null?
    return (record.key, record.writer!);
  }

  @override
  Future<Uint8List?> read(RecordKey recordKey, {bool local = false}) {
    log.debug('RCRN-D READ $recordKey');

    return DHTRecordPool.instance
        .openRecordRead(
          recordKey,
          crypto: const VeilidCryptoPublic(),
          debugName: 'rcrn::read',
        )
        .then((record) async {
          final encryptedPayload = await getChunkedPayload(
            record,
            local ? DHTRecordRefreshMode.cached : DHTRecordRefreshMode.network,
            numChunks: 32,
          );
          await record.close();
          return encryptedPayload;
        });

    // TODO(LGro): handle retry
    // } on VeilidAPIExceptionTryAgain {
    //   // TODO: Handle VeilidAPIExceptionKeyNotFound
    //   // TODO: Make sure that Veilid offline is detected at a higher level and not triggering errors here
    //   retries++;
    //   if (retries <= maxRetries) {
    //     await Future<void>.delayed(const Duration(milliseconds: 500));
    //   } else {
    //     rethrow;
    //   }
    // }
  }

  @override
  Future<void> write(
    RecordKey recordKey,
    KeyPair writer,
    Uint8List value,
  ) async {
    log.debug('RCRN-D UPDT $recordKey');

    final record = await DHTRecordPool.instance.openRecordWrite(
      recordKey,
      writer,
      crypto: const VeilidCryptoPublic(),
      debugName: 'rcrn::update',
    );
    // TODO: handle VeilidAPIExceptionTryAgain
    // final tx = await Veilid.instance.transactDHTRecords([record.key]);
    // await Future.wait(
    //   chopPayloadChunks(
    //     value,
    //     numChunks: 32,
    //   ).toList().asMap().entries.map((e) => tx.set(record.key, e.key, e.value)),
    // );
    // await tx.commit();
    await Future.wait(
      chopPayloadChunks(value, numChunks: 32).toList().asMap().entries.map(
        (e) => record.eventualWriteBytes(e.value, subkey: e.key),
      ),
    );
    await record.close();

    debugPrint('wrote ${recordKey.toString().substring(5, 10)}');
  }

  @override
  Future<bool> watch(RecordKey recordKey, VoidCallback callback) async {
    log.debug('RCRN-D WTCH $recordKey | ATTEMPT');
    if (_watchedRecords.contains(recordKey)) {
      log.debug('RCRN-D WTCH $recordKey | ALREADY WATCHING');
      return true;
    }
    _watchedRecords.add(recordKey);

    try {
      final record = await DHTRecordPool.instance.openRecordRead(
        recordKey,
        crypto: const VeilidCryptoPublic(),
        debugName: 'rcrn::read-to-watch',
      );

      await record.watch(subkeys: [const ValueSubkeyRange(low: 0, high: 32)]);

      await record.listen((record, data, subkeys) async {
        log.debug('RCRN-D WTCH ${record.key} | CALLBACK');
        callback();
      }, localChanges: _watchLocalChanges);
      log.debug('RCRN-D WTCH $recordKey | WATCHING');
      return true;
    } catch (e) {
      log.debug('RCRN-D WTCH $recordKey | ERROR $e');
    }
    _watchedRecords.remove(recordKey);
    return false;
  }
}
