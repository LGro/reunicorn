// Copyright 2026 The Reunicorn Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

import 'dart:convert';
import 'dart:math';

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

/// A writes many times in a row (each overwriting the previous in DHT) before
/// B reads. Then B writes many times before A reads. Tests whether the 4-combo
/// decrypt in establishedAsymmetric can still find the right key after many
/// unread overwrites.
Future<void> manyConsecutiveOverwritesThenRead() async {
  final comm = await EncryptedCommunication.create();
  await comm.evolveToEstablishedAsymmetric();

  // A writes 5 times — each overwrites the previous in DHT
  for (var i = 1; i <= 5; i++) {
    await comm.aliceWrites('A-overwrite-$i');
  }

  // B reads only the last one
  await comm.bobExpects('A-overwrite-5');
  expect(comm.cryptoB, isA<CryptoEstablishedAsymmetric>());

  // B writes 5 times
  for (var i = 1; i <= 5; i++) {
    await comm.bobWrites('B-overwrite-$i');
  }

  // A reads only the last one
  await comm.aliceExpects('B-overwrite-5');
  expect(comm.cryptoA, isA<CryptoEstablishedAsymmetric>());

  // Verify further communication works
  await comm.aliceWrites('after-overwrite-A');
  await comm.bobExpects('after-overwrite-A');
  await comm.bobWrites('after-overwrite-B');
  await comm.aliceExpects('after-overwrite-B');
}

/// One side reads + writes many rounds while the other side's writes are lost.
/// This drives key rotations on the reading side far ahead. When propagation
/// resumes, the side that fell behind must still decrypt.
///
/// This is the most aggressive test for key divergence: Alice rotates her keys
/// on each read of Bob's messages, but Bob never sees Alice's intermediate
/// writes. When Alice finally gets a write through, Bob must be able to decrypt
/// even though Alice's key material has rotated multiple times.
Future<void> oneWayRotationStormThenCatchUp() async {
  final comm = await EncryptedCommunication.create();
  await comm.evolveToEstablishedAsymmetric();

  // One normal round to establish a baseline
  await comm.aliceWrites('baseline-A');
  await comm.bobExpects('baseline-A');
  await comm.bobWrites('baseline-B');
  await comm.aliceExpects('baseline-B');

  // Block A's propagation
  comm.dhtA.propagationPaused = true;

  // B writes, A reads → A rotates keys. A writes back but B never sees it.
  // Repeat several times to push A's key material far ahead of B's view.
  for (var i = 0; i < 4; i++) {
    await comm.bobWrites('storm-B-$i');
    await comm.aliceExpects('storm-B-$i');
    await comm.aliceWrites('lost-A-$i'); // lost — propagation paused
  }

  // Restore propagation: A writes with heavily rotated keys
  comm.dhtA.propagationPaused = false;
  await comm.aliceWrites('catch-up-A');

  expect(
    await comm.bobReads(),
    'catch-up-A',
    reason:
        'B must decrypt after A rotated keys 4 extra times '
        'without B seeing any of A\'s intermediate writes',
  );
  expect(comm.cryptoB, isA<CryptoEstablishedAsymmetric>());

  // Verify the reverse direction also still works
  await comm.bobWrites('after-storm-B');
  await comm.aliceExpects('after-storm-B');
  expect(comm.cryptoA, isA<CryptoEstablishedAsymmetric>());

  // And another full round-trip
  await comm.aliceWrites('final-A');
  await comm.bobExpects('final-A');
  await comm.bobWrites('final-B');
  await comm.aliceExpects('final-B');
}

/// Both sides write before reading, creating concurrent key evolution.
/// Repeat this pattern multiple rounds to maximize divergence.
Future<void> repeatedConcurrentWritesThenReads() async {
  final comm = await EncryptedCommunication.create();
  await comm.evolveToEstablishedAsymmetric();

  for (var round = 0; round < 5; round++) {
    // Both write before either reads (concurrent evolution)
    await comm.aliceWrites('concurrent-A-$round');
    await comm.bobWrites('concurrent-B-$round');

    // Both read
    await comm.bobExpects('concurrent-A-$round');
    await comm.aliceExpects('concurrent-B-$round');

    expect(comm.cryptoA, isA<CryptoEstablishedAsymmetric>(),
        reason: 'round $round');
    expect(comm.cryptoB, isA<CryptoEstablishedAsymmetric>(),
        reason: 'round $round');
  }

  // Final round-trip to confirm state is consistent
  await comm.aliceWrites('end-A');
  await comm.bobExpects('end-A');
  await comm.bobWrites('end-B');
  await comm.aliceExpects('end-B');
}

/// Simulates the contact_dht.dart pattern: read evolves crypto, but the
/// subsequent write doesn't happen immediately. Instead, another read occurs
/// first (from a re-triggered updateContact). Tests that the double-read
/// before write doesn't corrupt key material.
Future<void> readReadWritePatternFromContactDht() async {
  final comm = await EncryptedCommunication.create();
  await comm.evolveToEstablishedAsymmetric();

  // Normal round
  await comm.aliceWrites('r1-A');
  await comm.bobExpects('r1-A');

  // Bob's crypto evolved from the read. Now simulate the contact_dht pattern:
  // Bob reads again (stale data) BEFORE writing, as happens when updateContact
  // is re-triggered by the storage change event.
  final cryptoBAfterFirstRead = comm.cryptoB;
  await comm.bobReads(); // stale re-read
  expect(
    comm.cryptoB.myKeyPairOrNull,
    cryptoBAfterFirstRead.myKeyPairOrNull,
    reason: 'stale re-read before write must not rotate keys',
  );

  // Now Bob writes (as the second updateContact call would)
  await comm.bobWrites('delayed-write-B');
  await comm.aliceExpects('delayed-write-B');

  // Alice writes back
  await comm.aliceWrites('reply-A');
  await comm.bobExpects('reply-A');

  // Repeat the pattern: Alice writes, Bob reads, Bob re-reads stale, Bob writes
  await comm.aliceWrites('r2-A');
  await comm.bobExpects('r2-A');
  await comm.bobReads(); // stale
  await comm.bobReads(); // stale again
  await comm.bobWrites('delayed-write-B-2');
  await comm.aliceExpects('delayed-write-B-2');

  expect(comm.cryptoA, isA<CryptoEstablishedAsymmetric>());
  expect(comm.cryptoB, isA<CryptoEstablishedAsymmetric>());
}

/// During the symmetric→asymmetric handshake, one side's writes are lost for
/// multiple rounds. The offline side keeps reading stale data while the other
/// side advances. When propagation resumes, the handshake must still complete.
Future<void> handshakeWithProlongedOneWayOutage() async {
  final comm = await EncryptedCommunication.create();

  // A writes first message (initializedSymmetric)
  await comm.aliceWrites('hello');
  await comm.bobExpects('hello');

  // Block B's propagation: B writes but A never sees it
  comm.dhtB.propagationPaused = true;
  await comm.bobWrites('lost-1');
  await comm.bobWrites('lost-2');

  // A reads stale data (A's own initial write reflected back? or null?)
  // Since B's write didn't propagate, A sees no new data
  final staleRead = await comm.aliceReads();
  // We don't assert the value — it could be null or stale

  // Restore B's propagation
  comm.dhtB.propagationPaused = false;
  await comm.bobWrites('visible-B');

  // Now A should be able to read B's message
  await comm.aliceExpects('visible-B');

  // Continue the handshake until established
  var rounds = 0;
  while (comm.cryptoA is! CryptoEstablishedAsymmetric ||
      comm.cryptoB is! CryptoEstablishedAsymmetric) {
    if (++rounds > 20) {
      fail(
        'Did not reach CryptoEstablishedAsymmetric after $rounds extra rounds.\n'
        'cryptoA: ${comm.cryptoA}\ncryptoB: ${comm.cryptoB}',
      );
    }
    await comm.aliceWrites('handshake-A-$rounds');
    await comm.bobExpects('handshake-A-$rounds');

    if (comm.cryptoA is CryptoEstablishedAsymmetric &&
        comm.cryptoB is CryptoEstablishedAsymmetric) {
      break;
    }

    await comm.bobWrites('handshake-B-$rounds');
    await comm.aliceExpects('handshake-B-$rounds');
  }

  expect(comm.cryptoA, isA<CryptoEstablishedAsymmetric>());
  expect(comm.cryptoB, isA<CryptoEstablishedAsymmetric>());

  // Verify post-handshake communication
  await comm.aliceWrites('post-A');
  await comm.bobExpects('post-A');
  await comm.bobWrites('post-B');
  await comm.aliceExpects('post-B');
}

/// Both sides write before reading during the handshake (not just in
/// established asymmetric). This can cause both sides to evolve their
/// symmetric→asymmetric transition concurrently.
Future<void> concurrentWritesDuringHandshake() async {
  final comm = await EncryptedCommunication.create();

  // A's first write — kicks off the handshake
  await comm.aliceWrites('init-A');
  await comm.bobExpects('init-A');

  // Now both write before either reads (concurrent during handshake)
  await comm.bobWrites('concurrent-B-1');
  await comm.aliceWrites('concurrent-A-1');

  // Both read
  await comm.aliceExpects('concurrent-B-1');
  await comm.bobExpects('concurrent-A-1');

  // Continue handshake to completion
  var rounds = 0;
  while (comm.cryptoA is! CryptoEstablishedAsymmetric ||
      comm.cryptoB is! CryptoEstablishedAsymmetric) {
    if (++rounds > 20) {
      fail(
        'Did not reach CryptoEstablishedAsymmetric.\n'
        'cryptoA: ${comm.cryptoA}\ncryptoB: ${comm.cryptoB}',
      );
    }
    await comm.bobWrites('hs-B-$rounds');
    await comm.aliceExpects('hs-B-$rounds');

    if (comm.cryptoA is CryptoEstablishedAsymmetric &&
        comm.cryptoB is CryptoEstablishedAsymmetric) {
      break;
    }

    await comm.aliceWrites('hs-A-$rounds');
    await comm.bobExpects('hs-A-$rounds');
  }

  expect(comm.cryptoA, isA<CryptoEstablishedAsymmetric>());
  expect(comm.cryptoB, isA<CryptoEstablishedAsymmetric>());

  // Post-handshake round-trip
  await comm.aliceWrites('post-A');
  await comm.bobExpects('post-A');
  await comm.bobWrites('post-B');
  await comm.aliceExpects('post-B');
}

/// Runs a single fuzz iteration with the given [seed]. Both sides alternate
/// writes and reads through the entire handshake until both reach
/// [CryptoEstablishedAsymmetric], then perform one more messaging round.
///
/// At each write step, the writer randomly (seeded by [seed]) either:
///   - writes once (normal), or
///   - writes twice ("double write") with the first write's propagation
///     optionally paused (simulating message loss).
///
/// On failure the assertion message includes the seed and full action log so
/// the exact sequence can be reproduced deterministically.
Future<void> fuzzKeyEvolutionWithSeed(int seed) async {
  final rng = Random(seed);
  final comm = await EncryptedCommunication.create();
  var msgCounter = 0;
  final actions = <String>[];

  String describeState() =>
      'seed=$seed\n'
      'actions:\n${actions.indexed.map((e) => '  ${e.$1}: ${e.$2}').join('\n')}\n'
      'cryptoA: ${comm.cryptoA}\n'
      'cryptoB: ${comm.cryptoB}';

  Future<String> writeWithFuzz(bool isAlice) async {
    final who = isAlice ? 'Alice' : 'Bob';
    final dht = isAlice ? comm.dhtA : comm.dhtB;
    final doDouble = rng.nextBool();
    final firstPaused = doDouble && rng.nextBool();

    if (doDouble) {
      actions.add('$who double-write (firstPaused=$firstPaused)');
      if (firstPaused) dht.propagationPaused = true;
      final ghost = 'ghost-${++msgCounter}';
      if (isAlice) {
        await comm.aliceWrites(ghost);
      } else {
        await comm.bobWrites(ghost);
      }
      dht.propagationPaused = false;
    } else {
      actions.add('$who single-write');
    }

    final msg = '${++msgCounter}';
    if (isAlice) {
      await comm.aliceWrites(msg);
    } else {
      await comm.bobWrites(msg);
    }
    return msg;
  }

  // --- Handshake: evolve to established asymmetric ---
  var rounds = 0;
  var msg = await writeWithFuzz(true);
  actions.add('Bob reads');
  expect(await comm.bobReads(), msg, reason: describeState());

  while (comm.cryptoA is! CryptoEstablishedAsymmetric ||
      comm.cryptoB is! CryptoEstablishedAsymmetric) {
    if (++rounds > 20) {
      fail(
        'Did not reach CryptoEstablishedAsymmetric after $rounds rounds.\n'
        '${describeState()}',
      );
    }

    msg = await writeWithFuzz(false);
    actions.add('Alice reads');
    expect(await comm.aliceReads(), msg, reason: describeState());

    if (comm.cryptoA is CryptoEstablishedAsymmetric &&
        comm.cryptoB is CryptoEstablishedAsymmetric) {
      break;
    }

    msg = await writeWithFuzz(true);
    actions.add('Bob reads');
    expect(await comm.bobReads(), msg, reason: describeState());
  }

  expect(comm.cryptoA, isA<CryptoEstablishedAsymmetric>(),
      reason: describeState());
  expect(comm.cryptoB, isA<CryptoEstablishedAsymmetric>(),
      reason: describeState());

  // --- One more messaging round after established ---
  msg = await writeWithFuzz(true);
  actions.add('Bob reads (post-established)');
  expect(await comm.bobReads(), msg, reason: describeState());

  msg = await writeWithFuzz(false);
  actions.add('Alice reads (post-established)');
  expect(await comm.aliceReads(), msg, reason: describeState());

  expect(comm.cryptoA, isA<CryptoEstablishedAsymmetric>(),
      reason: describeState());
  expect(comm.cryptoB, isA<CryptoEstablishedAsymmetric>(),
      reason: describeState());
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

  test(
    'asymmetric: many consecutive overwrites then read (mock DHT)',
    manyConsecutiveOverwritesThenRead,
  );

  test(
    'asymmetric: one-way rotation storm then catch-up (mock DHT)',
    oneWayRotationStormThenCatchUp,
  );

  test(
    'asymmetric: repeated concurrent writes then reads (mock DHT)',
    repeatedConcurrentWritesThenReads,
  );

  test(
    'asymmetric: read-read-write pattern from contact_dht (mock DHT)',
    readReadWritePatternFromContactDht,
  );

  test(
    'handshake: prolonged one-way outage then recovery (mock DHT)',
    handshakeWithProlongedOneWayOutage,
  );

  test(
    'handshake: concurrent writes during handshake (mock DHT)',
    concurrentWritesDuringHandshake,
  );

  for (var seed = 0; seed < 100; seed++) {
    test(
      'fuzz: key evolution with random double-writes (seed=$seed)',
      () => fuzzKeyEvolutionWithSeed(seed),
    );
  }
}
