// Copyright 2026 The Reunicorn Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:integration_test/integration_test.dart';
import 'package:reunicorn/data/models/models.dart';
import 'package:reunicorn/data/services/dht/encrypted_communication.dart'
    as dht_comm;
import 'package:reunicorn/data/utils.dart';
import 'package:reunicorn/ui/utils.dart';
import 'package:reunicorn/veilid_init.dart';
import 'package:test/test.dart';

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

/// Test harness wrapping two connected mock DHTs (Alice and Bob) with
/// convenient read/write helpers. All internal state (crypto, connection, DHTs)
/// is exposed so tests can assert on it as needed.
class EncryptedCommunication {
  final MockDht dhtA;
  final MockDht dhtB;

  CryptoState cryptoA;
  CryptoState cryptoB;

  DhtConnectionState connectionA;
  DhtConnectionState connectionB;

  EncryptedCommunication._({
    required this.dhtA,
    required this.dhtB,
    required this.cryptoA,
    required this.cryptoB,
    required this.connectionA,
    required this.connectionB,
  });

  /// Sets up two connected mock DHTs and performs the initial invite exchange
  /// so that both sides are ready to communicate (B has read A's invite).
  static Future<EncryptedCommunication> create() async {
    final dhtA = MockDht();
    final dhtB = MockDht();
    dhtA.connect(dhtB);
    dhtB.connect(dhtA);

    final cryptoA =
        CryptoState.initializedSymmetric(
              initialSharedSecret: await generateRandomSharedSecretBest(),
              myNextKeyPair: await generateKeyPairBest(),
            )
            as CryptoInitializedSymmetric;
    final connectionA = await dht_comm.initializeEncryptedDhtConnection(
      dhtA,
      cryptoA,
    );

    final inviteForB = DirectSharingInvite(
      'B',
      connectionA.recordKeyMeSharing,
      cryptoA.initialSharedSecret,
    );

    DhtConnectionState connectionB = DhtConnectionState.invited(
      recordKeyThemSharing: inviteForB.recordKey,
    );
    CryptoState cryptoB = CryptoState.initializedSymmetric(
      initialSharedSecret: inviteForB.psk,
      myNextKeyPair: await generateKeyPairBest(),
    );
    (_, connectionB, cryptoB) = await dht_comm.readEncrypted(
      dhtB,
      connectionB,
      cryptoB,
      ExamplePayload.fromBytes,
    );

    return EncryptedCommunication._(
      dhtA: dhtA,
      dhtB: dhtB,
      cryptoA: cryptoA,
      cryptoB: cryptoB,
      connectionA: connectionA,
      connectionB: connectionB,
    );
  }

  Future<void> aliceWrites(String message) async {
    await dht_comm.writeEncrypted(
      dhtA,
      ExamplePayload(message: message),
      connectionA,
      cryptoA,
    );
  }

  Future<void> bobWrites(String message) async {
    await dht_comm.writeEncrypted(
      dhtB,
      ExamplePayload(message: message),
      connectionB,
      cryptoB,
    );
  }

  Future<String?> aliceReads() async {
    final (payload, newConn, newCrypto) = await dht_comm.readEncrypted(
      dhtA,
      connectionA,
      cryptoA,
      ExamplePayload.fromBytes,
    );
    connectionA = newConn;
    cryptoA = newCrypto;
    return payload?.message;
  }

  Future<String?> bobReads() async {
    final (payload, newConn, newCrypto) = await dht_comm.readEncrypted(
      dhtB,
      connectionB,
      cryptoB,
      ExamplePayload.fromBytes,
    );
    connectionB = newConn;
    cryptoB = newCrypto;
    return payload?.message;
  }

  Future<void> aliceExpects(String expected) async =>
      expect(await aliceReads(), expected);

  Future<void> bobExpects(String expected) async =>
      expect(await bobReads(), expected);

  /// Alternates writes and reads until both sides reach
  /// [CryptoEstablishedAsymmetric].
  Future<void> evolveToEstablishedAsymmetric() async {
    var counter = 0;

    await aliceWrites('${++counter}');
    await bobExpects('$counter');

    while (cryptoA is! CryptoEstablishedAsymmetric ||
        cryptoB is! CryptoEstablishedAsymmetric) {
      await bobWrites('${++counter}');
      await aliceExpects('$counter');

      if (cryptoA is CryptoEstablishedAsymmetric &&
          cryptoB is CryptoEstablishedAsymmetric) {
        break;
      }

      await aliceWrites('${++counter}');
      await bobExpects('$counter');
    }

    expect(cryptoA, isA<CryptoEstablishedAsymmetric>());
    expect(cryptoB, isA<CryptoEstablishedAsymmetric>());
  }
}

Future<void> directSharingTestGoldenPathTakingTurns() async {
  final comm = await EncryptedCommunication.create();

  expect(
    comm.connectionB.recordKeyThemSharing,
    comm.connectionA.recordKeyMeSharingOrNull,
  );
  expect(comm.cryptoB.initialSharedSecretOrNull, isNotNull);
  expect(
    comm.cryptoB.initialSharedSecretOrNull,
    comm.cryptoA.initialSharedSecretOrNull,
  );

  await comm.aliceWrites('1');
  await comm.bobExpects('1');
  expect(
    comm.connectionB.recordKeyMeSharingOrNull,
    comm.connectionA.recordKeyThemSharing,
    reason: 'should have adopted share back record provided by A',
  );
  expect(
    comm.connectionB.writerMeSharingOrNull,
    comm.connectionA.writerThemSharingOrNull,
    reason: 'should have adopted share back writer provided by A',
  );

  await comm.bobWrites('2');
  await comm.aliceExpects('2');

  await comm.aliceWrites('3');
  await comm.bobExpects('3');

  await comm.bobWrites('4');
  await comm.aliceExpects('4');

  await comm.aliceWrites('5');
  await comm.bobExpects('5');

  await comm.bobWrites('6');
  await comm.aliceExpects('6');

  await comm.aliceWrites('7');
  await comm.bobExpects('7');

  await comm.bobWrites('8');
  await comm.aliceExpects('8');

  expect(comm.cryptoB, isA<CryptoEstablishedAsymmetric>());
  expect(comm.cryptoA, isA<CryptoEstablishedAsymmetric>());
}

Future<void> directSharingMultipleReads() async {
  final comm = await EncryptedCommunication.create();

  expect(
    comm.connectionB.recordKeyThemSharing,
    comm.connectionA.recordKeyMeSharingOrNull,
  );
  expect(comm.cryptoB.initialSharedSecretOrNull, isNotNull);
  expect(
    comm.cryptoB.initialSharedSecretOrNull,
    comm.cryptoA.initialSharedSecretOrNull,
  );

  await comm.aliceWrites('1');
  await comm.bobExpects('1');
  expect(
    comm.connectionB.recordKeyMeSharingOrNull,
    comm.connectionA.recordKeyThemSharing,
    reason: 'should have adopted share back record provided by A',
  );
  expect(
    comm.connectionB.writerMeSharingOrNull,
    comm.connectionA.writerThemSharingOrNull,
    reason: 'should have adopted share back writer provided by A',
  );

  // B reads stale data twice
  await comm.bobReads();
  await comm.bobReads();

  await comm.bobWrites('2');
  await comm.aliceExpects('2');
}

/// A writes twice but B only receives the second write (first is lost due to
/// propagation failure). Verifies B can still decrypt and the subsequent
/// round-trip works.
Future<void> consecutiveWritesMissedIntermediate() async {
  final comm = await EncryptedCommunication.create();
  await comm.evolveToEstablishedAsymmetric();

  // A writes but propagation is blocked → B never sees it
  comm.dhtA.propagationPaused = true;
  await comm.aliceWrites('lost');
  comm.dhtA.propagationPaused = false;

  // A writes again, propagation restored → B receives this one
  await comm.aliceWrites('received');

  await comm.bobExpects('received');
  expect(comm.cryptoB, isA<CryptoEstablishedAsymmetric>());

  // Verify round-trip still works
  await comm.bobWrites('reply');
  await comm.aliceExpects('reply');
  expect(comm.cryptoA, isA<CryptoEstablishedAsymmetric>());
}

/// Both A and B write before either reads the other's update.
/// Verifies both can still decrypt and continue communicating.
Future<void> bothSidesWriteBeforeReading() async {
  final comm = await EncryptedCommunication.create();
  await comm.evolveToEstablishedAsymmetric();

  // Both write without reading from each other first
  await comm.aliceWrites('fromA');
  await comm.bobWrites('fromB');

  // Now both read
  await comm.aliceExpects('fromB');
  await comm.bobExpects('fromA');
  expect(comm.cryptoA, isA<CryptoEstablishedAsymmetric>());
  expect(comm.cryptoB, isA<CryptoEstablishedAsymmetric>());

  // Verify further round-trips work after simultaneous writes
  await comm.aliceWrites('followup-A');
  await comm.bobExpects('followup-A');

  await comm.bobWrites('followup-B');
  await comm.aliceExpects('followup-B');
}

/// Simulates A's updates being lost for several rounds while B keeps writing.
/// A reads B's messages (causing key rotations on A's side), then A finally
/// gets a write through. B must still be able to decrypt despite having missed
/// multiple rotations on A's side.
Future<void> multipleMissedUpdatesThenCatchUp() async {
  final comm = await EncryptedCommunication.create();
  await comm.evolveToEstablishedAsymmetric();

  // Round 1: normal rotation
  await comm.aliceWrites('r1-A');
  await comm.bobExpects('r1-A');
  await comm.bobWrites('r1-B');
  await comm.aliceExpects('r1-B');

  // Block A's propagation: A writes multiple times, B never sees them
  comm.dhtA.propagationPaused = true;
  await comm.aliceWrites('lost-1');
  await comm.aliceWrites('lost-2');

  // Meanwhile B writes (propagation from B to A still works)
  await comm.bobWrites('r2-B');
  await comm.aliceExpects('r2-B');
  expect(comm.cryptoA, isA<CryptoEstablishedAsymmetric>());

  // B writes again, A reads → more rotation
  await comm.bobWrites('r3-B');
  await comm.aliceExpects('r3-B');

  // Restore propagation: A writes with its rotated keys
  comm.dhtA.propagationPaused = false;
  await comm.aliceWrites('catch-up-A');

  // B reads → B has NOT rotated (hasn't seen A's updates in a while) so its
  // key set might be stale. This is the critical check.
  expect(
    await comm.bobReads(),
    'catch-up-A',
    reason:
        'B must decrypt A message after A rotated keys multiple times '
        'without B seeing intermediate updates',
  );
  expect(comm.cryptoB, isA<CryptoEstablishedAsymmetric>());

  // Final round-trip to confirm state is consistent
  await comm.bobWrites('final-B');
  await comm.aliceExpects('final-B');
}

/// After reaching established asymmetric, B re-reads stale data (no new write
/// from A) and then continues communicating. Verifies that re-reading the same
/// ciphertext does not corrupt B's crypto state.
Future<void> reReadStaleDataInAsymmetricState() async {
  final comm = await EncryptedCommunication.create();
  await comm.evolveToEstablishedAsymmetric();

  await comm.aliceWrites('msg1');
  await comm.bobExpects('msg1');

  // B re-reads same stale data (A did not write again)
  final cryptoBBeforeReRead = comm.cryptoB;
  await comm.bobReads();
  await comm.bobReads();
  expect(comm.cryptoB, isA<CryptoEstablishedAsymmetric>());

  // Verify crypto state key material hasn't been corrupted by re-reads
  expect(
    comm.cryptoB.myKeyPairOrNull,
    cryptoBBeforeReRead.myKeyPairOrNull,
    reason: 'myKeyPair should not rotate from re-reading stale data',
  );

  // Verify communication still works after re-reads
  await comm.bobWrites('after-reread');
  await comm.aliceExpects('after-reread');

  await comm.aliceWrites('final');
  await comm.bobExpects('final');
}

// TODO(LGro): What does it take for this to be a unit instead of an
//             integration test? We just need the Veilid cryptoSystem, no DHT.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    await AppGlobalInit.initialize(veilidBootstrapUrl);
  });

  test(
    'sharing, initial symmetric until rotating asymmetric crypto (mock DHT)',
    directSharingTestGoldenPathTakingTurns,
  );

  test(
    'sharing, multiple reads after receiving (mock DHT)',
    directSharingMultipleReads,
  );

  test(
    'asymmetric: consecutive writes, B misses intermediate (mock DHT)',
    consecutiveWritesMissedIntermediate,
  );

  test(
    'asymmetric: both sides write before either reads (mock DHT)',
    bothSidesWriteBeforeReading,
  );

  test(
    'asymmetric: multiple missed updates then catch-up (mock DHT)',
    multipleMissedUpdatesThenCatchUp,
  );

  test(
    'asymmetric: re-reading stale data does not corrupt state (mock DHT)',
    reReadStaleDataInAsymmetricState,
  );
}
