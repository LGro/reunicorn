// Copyright 2024 - 2025 The Reunicorn Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:reunicorn/veilid_init.dart';
import 'package:veilid_support/veilid_support.dart';

import 'utils.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    await AppGlobalInit.initialize(veilidBootstrapUrl);
  });

  test('Create, write and read a DHT record', () async {
    final recordW = await DHTRecordPool.instance.createRecord(
      debugName: 'coag::create',
      schema: const DHTSchema.dflt(oCnt: 32),
      crypto: const VeilidCryptoPublic(),
    );
    await recordW.tryWriteBytes(utf8.encode('Hi World!'));
    await recordW.close();

    final recordR = await DHTRecordPool.instance.openRecordRead(recordW.key,
        debugName: 'reunicorn integration test read');
    final raw = await recordR.get();
    expect(utf8.decode(raw!), 'Hi World!');
  });
}
