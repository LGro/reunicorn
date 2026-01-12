// Copyright 2026 The Reunicorn Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:integration_test/integration_test.dart';
import 'package:reunicorn/data/models/models.dart';
import 'package:reunicorn/data/services/dht/encrypted_communication.dart'
    as dht_comm;
import 'package:reunicorn/data/services/dht/veilid_dht.dart';
import 'package:reunicorn/data/utils.dart';
import 'package:reunicorn/ui/utils.dart';
import 'package:reunicorn/veilid_init.dart';
import 'package:test/test.dart';
import 'package:veilid_support/veilid_support.dart';

import '../test/mocked_providers.dart';
import 'utils.dart';

part 'encrypted_communication_test.freezed.dart';
part 'encrypted_communication_test.g.dart';

@freezed
sealed class ExamplePayload
    with _$ExamplePayload
    implements BinarySerializable {
  const factory ExamplePayload({required String message}) = _ExamplePayload;
  const ExamplePayload._();

  factory ExamplePayload.fromJson(Map<String, dynamic> json) =>
      _$ExamplePayloadFromJson(json);

  @override
  Uint8List toBytes() => Uint8List.fromList(utf8.encode(jsonEncode(toJson())));

  factory ExamplePayload.fromBytes(Uint8List data) => ExamplePayload.fromJson(
    jsonDecode(utf8.decode(data)) as Map<String, dynamic>,
  );
}

class MockDht implements BaseDht {
  final _storage = <RecordKey, Uint8List>{};
  final _watchCallbacks = <RecordKey, VoidCallback>{};
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
  Future<void> write(RecordKey key, KeyPair writer, Uint8List value) async {
    _storage[key] = value;
    if (_watchCallbacks.containsKey(key)) {
      _watchCallbacks[key]!();
    }
  }

  @override
  Future<Uint8List?> read(RecordKey key, {bool local = false}) async =>
      _storage[key];

  @override
  Future<bool> watch(RecordKey key, VoidCallback callback) async {
    _watchCallbacks[key] = callback;
    return true;
  }
}

Future<void> directSharingTestGoldenPathTakingTurns(BaseDht dht) async {
  // Set up communication channel from A
  final (connectionA, cryptoA) = await dht_comm
      .initializeEncryptedDhtConnection(dht);

  final inviteForB = DirectSharingInvite(
    'B',
    connectionA.recordKeyMeSharing,
    cryptoA.initialSharedSecret,
  );

  // Set up communication channel from B
  var connectionB = DhtConnectionState.invited(
    recordKeyThemSharing: inviteForB.recordKey,
  );
  var cryptoB = CryptoState.initializedSymmetric(
    initialSharedSecret: inviteForB.psk,
    myNextKeyPair: await generateKeyPairBest(),
  );
  (_, connectionB, cryptoB) = await dht_comm.readEncrypted(
    dht,
    connectionB,
    cryptoB,
    ExamplePayload.fromBytes,
  );
  expect(connectionB.recordKeyThemSharing, connectionA.recordKeyMeSharing);
  expect(
    (cryptoB as CryptoInitializedSymmetric).initialSharedSecret,
    cryptoA.initialSharedSecret,
  );

  // Write from A to B
  debugPrint('A writing for B');
  await dht_comm.writeEncrypted(
    dht,
    const ExamplePayload(message: '1'),
    connectionA,
    cryptoA,
  );
  debugPrint('B reading from A');
  final ExamplePayload? initialPayloadFromA;
  (initialPayloadFromA, connectionB, cryptoB) = await dht_comm.readEncrypted(
    dht,
    connectionB,
    cryptoB,
    ExamplePayload.fromBytes,
  );
  expect(initialPayloadFromA?.message, '1');
  expect(
    (connectionB as DhtConnectionEstablished).recordKeyMeSharing,
    connectionA.recordKeyThemSharing,
    reason: 'should have adopted share back record provided by A',
  );
  expect(
    connectionB.writerMeSharing,
    connectionA.writerThemSharing,
    reason: 'should have adopted share back writer provided by A',
  );

  // Write from B to A
  debugPrint('B writing for A');
  await dht_comm.writeEncrypted(
    dht,
    const ExamplePayload(message: '2'),
    connectionB,
    cryptoB,
  );
  debugPrint('A reading from B');
  var (payloadFromB, updatedConnectionA, updatedCryptoA) = await dht_comm
      .readEncrypted(dht, connectionA, cryptoA, ExamplePayload.fromBytes);
  expect(payloadFromB?.message, '2');

  // Write from A to B
  debugPrint('A writing for B');
  await dht_comm.writeEncrypted(
    dht,
    const ExamplePayload(message: '3'),
    updatedConnectionA,
    updatedCryptoA,
  );
  debugPrint('B reading from A');
  ExamplePayload? payloadFromA;
  (payloadFromA, connectionB, cryptoB) = await dht_comm.readEncrypted(
    dht,
    connectionB,
    cryptoB,
    ExamplePayload.fromBytes,
  );
  expect(payloadFromA?.message, '3');

  // Write from B to A
  debugPrint('B writing for A');
  await dht_comm.writeEncrypted(
    dht,
    const ExamplePayload(message: '4'),
    connectionB,
    cryptoB,
  );
  debugPrint('A reading from B');
  (payloadFromB, updatedConnectionA, updatedCryptoA) = await dht_comm
      .readEncrypted(
        dht,
        updatedConnectionA,
        updatedCryptoA,
        ExamplePayload.fromBytes,
      );
  expect(payloadFromB?.message, '4');

  // Write from A to B
  debugPrint('A writing for B');
  await dht_comm.writeEncrypted(
    dht,
    const ExamplePayload(message: '5'),
    updatedConnectionA,
    updatedCryptoA,
  );
  debugPrint('B reading from A');
  (payloadFromA, connectionB, cryptoB) = await dht_comm.readEncrypted(
    dht,
    connectionB,
    cryptoB,
    ExamplePayload.fromBytes,
  );
  expect(payloadFromA?.message, '5');

  // Write from B to A
  debugPrint('B writing for A');
  await dht_comm.writeEncrypted(
    dht,
    const ExamplePayload(message: '6'),
    connectionB,
    cryptoB,
  );
  debugPrint('A reading from B');
  (payloadFromB, updatedConnectionA, updatedCryptoA) = await dht_comm
      .readEncrypted(
        dht,
        updatedConnectionA,
        updatedCryptoA,
        ExamplePayload.fromBytes,
      );
  expect(payloadFromB?.message, '6');

  // Write from A to B
  debugPrint('A writing for B');
  await dht_comm.writeEncrypted(
    dht,
    const ExamplePayload(message: '7'),
    updatedConnectionA,
    updatedCryptoA,
  );
  debugPrint('B reading from A');
  (payloadFromA, connectionB, cryptoB) = await dht_comm.readEncrypted(
    dht,
    connectionB,
    cryptoB,
    ExamplePayload.fromBytes,
  );
  expect(payloadFromA?.message, '7');

  // Write from B to A
  debugPrint('B writing for A');
  await dht_comm.writeEncrypted(
    dht,
    const ExamplePayload(message: '8'),
    connectionB,
    cryptoB,
  );
  debugPrint('A reading from B');
  (payloadFromB, updatedConnectionA, updatedCryptoA) = await dht_comm
      .readEncrypted(
        dht,
        updatedConnectionA,
        updatedCryptoA,
        ExamplePayload.fromBytes,
      );
  expect(payloadFromB?.message, '8');

  expect(cryptoB, isA<CryptoEstablishedAsymmetric>());
  expect(updatedCryptoA, isA<CryptoEstablishedAsymmetric>());
}

Future<void> directSharingMultipleReads(BaseDht dht) async {
  // Set up communication channel from A
  final (connectionA, cryptoA) = await dht_comm
      .initializeEncryptedDhtConnection(dht);

  final inviteForB = DirectSharingInvite(
    'B',
    connectionA.recordKeyMeSharing,
    cryptoA.initialSharedSecret,
  );

  // Set up communication channel from B
  var connectionB = DhtConnectionState.invited(
    recordKeyThemSharing: inviteForB.recordKey,
  );
  var cryptoB = CryptoState.initializedSymmetric(
    initialSharedSecret: inviteForB.psk,
    myNextKeyPair: await generateKeyPairBest(),
  );
  (_, connectionB, cryptoB) = await dht_comm.readEncrypted(
    dht,
    connectionB,
    cryptoB,
    ExamplePayload.fromBytes,
  );
  expect(connectionB.recordKeyThemSharing, connectionA.recordKeyMeSharing);
  expect(
    (cryptoB as CryptoInitializedSymmetric).initialSharedSecret,
    cryptoA.initialSharedSecret,
  );

  // Write from A to B
  debugPrint('A writing for B');
  await dht_comm.writeEncrypted(
    dht,
    const ExamplePayload(message: '1'),
    connectionA,
    cryptoA,
  );
  debugPrint('B reading from A');
  final ExamplePayload? initialPayloadFromA;
  (initialPayloadFromA, connectionB, cryptoB) = await dht_comm.readEncrypted(
    dht,
    connectionB,
    cryptoB,
    ExamplePayload.fromBytes,
  );
  expect(initialPayloadFromA?.message, '1');
  expect(
    (connectionB as DhtConnectionEstablished).recordKeyMeSharing,
    connectionA.recordKeyThemSharing,
    reason: 'should have adopted share back record provided by A',
  );
  expect(
    connectionB.writerMeSharing,
    connectionA.writerThemSharing,
    reason: 'should have adopted share back writer provided by A',
  );
  // B reads again
  (_, connectionB, cryptoB) = await dht_comm.readEncrypted(
    dht,
    connectionB,
    cryptoB,
    ExamplePayload.fromBytes,
  );
  (_, connectionB, cryptoB) = await dht_comm.readEncrypted(
    dht,
    connectionB,
    cryptoB,
    ExamplePayload.fromBytes,
  );

  // Write from B to A
  debugPrint('B writing for A');
  await dht_comm.writeEncrypted(
    dht,
    const ExamplePayload(message: '2'),
    connectionB,
    cryptoB,
  );
  debugPrint('A reading from B');
  final (payloadFromB, updatedConnectionA, updatedCryptoA) = await dht_comm
      .readEncrypted(dht, connectionA, cryptoA, ExamplePayload.fromBytes);
  expect(payloadFromB?.message, '2');
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    await AppGlobalInit.initialize(veilidBootstrapUrl);
  });

  // TODO(LGro): What does it take for this to be a unit instead of an
  //             integration test? We just need the Veilid cryptoSystem, no DHT.
  test(
    'sharing, initial symmetric until rotating asymmetric crypto (mock DHT)',
    () => directSharingTestGoldenPathTakingTurns(MockDht()),
  );
  test(
    'sharing, multiple reads after receiving (mock DHT)',
    () => directSharingMultipleReads(MockDht()),
  );

  test(
    'sharing, initial symmetric until rotating asymmetric crypto (Veilid DHT)',
    () => directSharingTestGoldenPathTakingTurns(
      VeilidDht(watchLocalChanges: true),
    ),
  );
}
