// Copyright 2025 The Reunicorn Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

import 'package:flutter/foundation.dart';
import 'package:integration_test/integration_test.dart';
import 'package:test/test.dart';
import 'package:veilid_support/veilid_support.dart';
import 'package:veilid_test/veilid_test.dart';

import 'fixtures/dht_record_pool_fixture.dart';
import 'test_direct_sharing.dart';
import 'test_profile_offer_sharing.dart';

void main() {
  final startTime = DateTime.now();

  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  final veilidFixture = DefaultVeilidFixture(
    programName: 'veilid_support integration test',
  );
  final updateProcessorFixture = UpdateProcessorFixture(
    veilidFixture: veilidFixture,
  );
  final tickerFixture = TickerFixture(
    updateProcessorFixture: updateProcessorFixture,
  );
  final dhtRecordPoolFixture = DHTRecordPoolFixture(
    tickerFixture: tickerFixture,
    updateProcessorFixture: updateProcessorFixture,
  );

  group('Started Tests', () {
    setUpAll(veilidFixture.setUp);
    tearDownAll(veilidFixture.tearDown);
    tearDownAll(() {
      final endTime = DateTime.now();
      debugPrintSynchronously('Duration: ${endTime.difference(startTime)}');
    });

    group('attached', () {
      setUpAll(veilidFixture.attach);
      tearDownAll(veilidFixture.detach);

      group('dht_support', () {
        setUpAll(updateProcessorFixture.setUp);
        setUpAll(tickerFixture.setUp);
        tearDownAll(tickerFixture.tearDown);
        tearDownAll(updateProcessorFixture.tearDown);

        group('dht_record_pool', () {
          setUpAll(
            // Allow this to return a future
            // ignore: discarded_futures
            () => dhtRecordPoolFixture.setUp(defaultKind: cryptoKindVLD0),
          );
          tearDownAll(dhtRecordPoolFixture.tearDown);

          test('direct_sharing', testDirectSharing);
          test('profile_offer_sharing', testProfileOfferBasedSharing);
        });
      });
    });
  }, timeout: const Timeout(Duration(seconds: 240)));
}
