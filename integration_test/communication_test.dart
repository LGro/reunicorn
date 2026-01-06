// Copyright 2026 The Reunicorn Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:integration_test/integration_test.dart';
import 'package:reunicorn/data/models/coag_contact.dart';
import 'package:reunicorn/data/services/dht_communication.dart';
import 'package:reunicorn/data/utils.dart';
import 'package:reunicorn/ui/utils.dart';
import 'package:reunicorn/veilid_init.dart';
import 'package:test/test.dart';
import 'package:veilid_support/veilid_support.dart';

import '../test/mocked_providers.dart';
import 'utils.dart';

part 'communication_test.freezed.dart';
part 'communication_test.g.dart';

@freezed
sealed class ExamplePayload with _$ExamplePayload {
  const factory ExamplePayload({required String message}) = _ExamplePayload;

  factory ExamplePayload.fromJson(Map<String, dynamic> json) =>
      _$ExamplePayloadFromJson(json);
}

Future<Uint8List> encodePayload(ExamplePayload value) async =>
    Uint8List.fromList(utf8.encode(jsonEncode(value.toJson())));

Future<ExamplePayload> decodePayload(Uint8List data) async =>
    ExamplePayload.fromJson(
      jsonDecode(utf8.decode(data)) as Map<String, dynamic>,
    );

class MockDht implements BaseDht {
  final _storage = <RecordKey, Uint8List>{};
  final _watchCallbacks = <RecordKey, Future<void> Function(Uint8List)>{};
  var _recordCounter = 0;

  @override
  Future<(RecordKey, KeyPair)> create() async {
    _recordCounter = _recordCounter + 1;
    return (
      fakeDhtRecordKey(_recordCounter),
      fakeKeyPair(_recordCounter, _recordCounter + 1000),
    );
  }

  @override
  Future<void> write(RecordKey key, Uint8List value) async {
    _storage[key] = value;
    if (_watchCallbacks.containsKey(key)) {
      await _watchCallbacks[key]!(value);
    }
  }

  @override
  Future<Uint8List?> read(RecordKey key) async => _storage[key];

  @override
  Future<void> watch(
    RecordKey key,
    Future<void> Function(Uint8List) callback,
  ) async {
    _watchCallbacks[key] = callback;
  }
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  // TODO(LGro): What does it take for this to be a unit instead of an
  //             integration test? We just need the Veilid cryptoSystem, no DHT.

  setUp(() async {
    await AppGlobalInit.initialize(veilidBootstrapUrl);
  });

  test('TBD', () async {
    final dht = MockDht();

    // Set up communication channel from A
    DhtSettings? mostRecentSettingsA;
    final watchUpdatesA = <ExamplePayload>[];

    Future<void> watchCallbackA(
      ExamplePayload value,
      DhtSettings settings,
    ) async {
      debugPrint('watch callback A triggered');
      mostRecentSettingsA = settings;
      watchUpdatesA.add(value);
    }

    final commA = BidirectionalDhtCommunication<ExamplePayload>(
      dht,
      encodePayload,
      decodePayload,
      watchCallbackA,
    );
    mostRecentSettingsA = await commA.init(
      DhtSettings(myKeyPair: await generateKeyPairBest()),
    );
    expect(mostRecentSettingsA?.recordKeyMeSharing, isNotNull);
    expect(mostRecentSettingsA?.recordKeyThemSharing, isNotNull);

    final inviteForB = DirectSharingInvite(
      'B',
      mostRecentSettingsA!.recordKeyMeSharing!,
      mostRecentSettingsA!.initialSecret!,
    );

    // Set up communication channel from B
    DhtSettings? mostRecentSettingsB;

    final watchUpdatesB = <ExamplePayload>[];

    Future<void> watchCallbackB(
      ExamplePayload value,
      DhtSettings settings,
    ) async {
      debugPrint('watch callback B triggered');
      mostRecentSettingsB = settings;
      watchUpdatesB.add(value);
    }

    final commB = BidirectionalDhtCommunication<ExamplePayload>(
      dht,
      encodePayload,
      decodePayload,
      watchCallbackB,
    );
    mostRecentSettingsB = await commB.init(
      DhtSettings(
        recordKeyThemSharing: inviteForB.recordKey,
        initialSecret: inviteForB.psk,
        myNextKeyPair: await generateKeyPairBest(),
      ),
    );

    // Write from A to B
    debugPrint('A writing for B');
    mostRecentSettingsA = await commA.write(
      const ExamplePayload(message: 'Hi B!'),
    );

    debugPrint('B reading from A');
    final ExamplePayload? initialPayloadFromA;
    (initialPayloadFromA, mostRecentSettingsB) = await commB.read();
    expect(initialPayloadFromA?.message, 'Hi B!');
    expect(
      mostRecentSettingsB?.recordKeyMeSharing,
      isNotNull,
      reason: 'should have adopted share back record provided by A',
    );

    // Write from B to A
    debugPrint('B writing for A');
    mostRecentSettingsB = await commB.write(
      const ExamplePayload(message: 'Hi A!'),
    );

    debugPrint('A reading from B');
    final ExamplePayload? initialPayloadFromB;
    (initialPayloadFromB, mostRecentSettingsA) = await commA.read();
    expect(initialPayloadFromB?.message, 'Hi A!');
  });
}
