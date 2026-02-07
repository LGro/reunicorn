// Copyright 2026 The Reunicorn Authors. All rights reserved.
// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:integration_test/integration_test.dart';
import 'package:reunicorn/data/models/models.dart';
import 'package:reunicorn/data/models/utils.dart';
import 'package:reunicorn/data/services/dht/encrypted_communication.dart'
    as dht_comm;
import 'package:reunicorn/data/services/dht/encrypted_communication.dart';
import 'package:reunicorn/data/services/dht/veilid_dht.dart';
import 'package:reunicorn/data/utils.dart';
import 'package:reunicorn/ui/utils.dart';
import 'package:reunicorn/veilid_init.dart';
import 'package:test/test.dart';
import 'package:vodozemac/vodozemac.dart' as vod;
import 'package:flutter_vodozemac/flutter_vodozemac.dart' as vod_flutter;

import '../test/mocked_providers.dart';
import 'utils.dart';

part 'encrypted_communication_test.freezed.dart';
part 'encrypted_communication_test.g.dart';

@freezed
sealed class ExamplePayload
    with _$ExamplePayload
    implements BinarySerializable, JsonEncodable {
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

Future<void> directSharingTestGoldenPathTakingTurns(BaseDht dht) async {
  // Set up communication channel from A
  var cryptoA = CryptoState.symmetric(
    sharedSecret: await generateRandomSharedSecretBest(),
    accountVod: (vod.Account()..generateOneTimeKeys(1)).toPickleEncrypted(
      Uint8List(32),
    ),
  );
  final connectionA;
  (connectionA, cryptoA) = await dht_comm.initializeEncryptedDhtConnection(
    dht,
    cryptoA,
  );

  final inviteForB = DirectSharingInvite(
    'B',
    connectionA.recordKeyMeSharing,
    cryptoA.sharedSecretOrNull!,
  );

  // Set up communication channel from B
  var connectionB = DhtConnectionState.invited(
    recordKeyThemSharing: inviteForB.recordKey,
  );
  var cryptoB = CryptoState.symmetric(
    sharedSecret: inviteForB.psk,
    accountVod: (vod.Account()..generateOneTimeKeys(1)).toPickleEncrypted(
      Uint8List(32),
    ),
  );
  (_, connectionB, cryptoB) = await dht_comm.readEncrypted(
    dht,
    connectionB,
    cryptoB,
    ExamplePayload.fromJson,
  );
  expect(connectionB.recordKeyThemSharing, connectionA.recordKeyMeSharing);

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
    ExamplePayload.fromJson,
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
      .readEncrypted(dht, connectionA, cryptoA, ExamplePayload.fromJson);
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
    ExamplePayload.fromJson,
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
        ExamplePayload.fromJson,
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
    ExamplePayload.fromJson,
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
        ExamplePayload.fromJson,
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
    ExamplePayload.fromJson,
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
        ExamplePayload.fromJson,
      );
  expect(payloadFromB?.message, '8');

  expect(cryptoB, isA<CryptoVodozemac>());
  expect(updatedCryptoA, isA<CryptoVodozemac>());
}

// Future<void> directSharingTestGoldenPathTakingTurns(BaseDht dht) async {
//   // Set up communication channel from A
//   final (connectionA, cryptoA) = await dht_comm
//       .initializeEncryptedDhtConnection(dht);

//   final inviteForB = DirectSharingInvite(
//     'B',
//     connectionA.recordKeyMeSharing,
//     cryptoA.initialSharedSecret,
//   );

//   // Set up communication channel from B
//   var connectionB = DhtConnectionState.invited(
//     recordKeyThemSharing: inviteForB.recordKey,
//   );
//   var cryptoB = CryptoState.initializedSymmetric(
//     initialSharedSecret: inviteForB.psk,
//     myNextKeyPair: await generateKeyPairBest(),
//   );
//   (_, connectionB, cryptoB) = await dht_comm.readEncrypted(
//     dht,
//     connectionB,
//     cryptoB,
//     ExamplePayload.fromBytes,
//   );
//   expect(connectionB.recordKeyThemSharing, connectionA.recordKeyMeSharing);
//   expect(
//     (cryptoB as CryptoInitializedSymmetric).initialSharedSecret,
//     cryptoA.initialSharedSecret,
//   );

//   // Write from A to B
//   debugPrint('A writing for B');
//   await dht_comm.writeEncrypted(
//     dht,
//     const ExamplePayload(message: '1'),
//     connectionA,
//     cryptoA,
//   );
//   debugPrint('B reading from A');
//   final ExamplePayload? initialPayloadFromA;
//   (initialPayloadFromA, connectionB, cryptoB) = await dht_comm.readEncrypted(
//     dht,
//     connectionB,
//     cryptoB,
//     ExamplePayload.fromBytes,
//   );
//   expect(initialPayloadFromA?.message, '1');
//   expect(
//     (connectionB as DhtConnectionEstablished).recordKeyMeSharing,
//     connectionA.recordKeyThemSharing,
//     reason: 'should have adopted share back record provided by A',
//   );
//   expect(
//     connectionB.writerMeSharing,
//     connectionA.writerThemSharing,
//     reason: 'should have adopted share back writer provided by A',
//   );

//   // Write from B to A
//   debugPrint('B writing for A');
//   await dht_comm.writeEncrypted(
//     dht,
//     const ExamplePayload(message: '2'),
//     connectionB,
//     cryptoB,
//   );
//   debugPrint('A reading from B');
//   var (payloadFromB, updatedConnectionA, updatedCryptoA) = await dht_comm
//       .readEncrypted(dht, connectionA, cryptoA, ExamplePayload.fromBytes);
//   expect(payloadFromB?.message, '2');

//   // Write from A to B
//   debugPrint('A writing for B');
//   await dht_comm.writeEncrypted(
//     dht,
//     const ExamplePayload(message: '3'),
//     updatedConnectionA,
//     updatedCryptoA,
//   );
//   debugPrint('B reading from A');
//   ExamplePayload? payloadFromA;
//   (payloadFromA, connectionB, cryptoB) = await dht_comm.readEncrypted(
//     dht,
//     connectionB,
//     cryptoB,
//     ExamplePayload.fromBytes,
//   );
//   expect(payloadFromA?.message, '3');

//   // Write from B to A
//   debugPrint('B writing for A');
//   await dht_comm.writeEncrypted(
//     dht,
//     const ExamplePayload(message: '4'),
//     connectionB,
//     cryptoB,
//   );
//   debugPrint('A reading from B');
//   (payloadFromB, updatedConnectionA, updatedCryptoA) = await dht_comm
//       .readEncrypted(
//         dht,
//         updatedConnectionA,
//         updatedCryptoA,
//         ExamplePayload.fromBytes,
//       );
//   expect(payloadFromB?.message, '4');

//   // Write from A to B
//   debugPrint('A writing for B');
//   await dht_comm.writeEncrypted(
//     dht,
//     const ExamplePayload(message: '5'),
//     updatedConnectionA,
//     updatedCryptoA,
//   );
//   debugPrint('B reading from A');
//   (payloadFromA, connectionB, cryptoB) = await dht_comm.readEncrypted(
//     dht,
//     connectionB,
//     cryptoB,
//     ExamplePayload.fromBytes,
//   );
//   expect(payloadFromA?.message, '5');

//   // Write from B to A
//   debugPrint('B writing for A');
//   await dht_comm.writeEncrypted(
//     dht,
//     const ExamplePayload(message: '6'),
//     connectionB,
//     cryptoB,
//   );
//   debugPrint('A reading from B');
//   (payloadFromB, updatedConnectionA, updatedCryptoA) = await dht_comm
//       .readEncrypted(
//         dht,
//         updatedConnectionA,
//         updatedCryptoA,
//         ExamplePayload.fromBytes,
//       );
//   expect(payloadFromB?.message, '6');

//   // Write from A to B
//   debugPrint('A writing for B');
//   await dht_comm.writeEncrypted(
//     dht,
//     const ExamplePayload(message: '7'),
//     updatedConnectionA,
//     updatedCryptoA,
//   );
//   debugPrint('B reading from A');
//   (payloadFromA, connectionB, cryptoB) = await dht_comm.readEncrypted(
//     dht,
//     connectionB,
//     cryptoB,
//     ExamplePayload.fromBytes,
//   );
//   expect(payloadFromA?.message, '7');

//   // Write from B to A
//   debugPrint('B writing for A');
//   await dht_comm.writeEncrypted(
//     dht,
//     const ExamplePayload(message: '8'),
//     connectionB,
//     cryptoB,
//   );
//   debugPrint('A reading from B');
//   (payloadFromB, updatedConnectionA, updatedCryptoA) = await dht_comm
//       .readEncrypted(
//         dht,
//         updatedConnectionA,
//         updatedCryptoA,
//         ExamplePayload.fromBytes,
//       );
//   expect(payloadFromB?.message, '8');

//   expect(cryptoB, isA<CryptoEstablishedAsymmetric>());
//   expect(updatedCryptoA, isA<CryptoEstablishedAsymmetric>());
// }

// Future<void> directSharingMultipleReads(BaseDht dht) async {
//   // Set up communication channel from A
//   final (connectionA, cryptoA) = await dht_comm
//       .initializeEncryptedDhtConnection(dht);

//   final inviteForB = DirectSharingInvite(
//     'B',
//     connectionA.recordKeyMeSharing,
//     cryptoA.initialSharedSecret,
//   );

//   // Set up communication channel from B
//   var connectionB = DhtConnectionState.invited(
//     recordKeyThemSharing: inviteForB.recordKey,
//   );
//   var cryptoB = CryptoState.initializedSymmetric(
//     initialSharedSecret: inviteForB.psk,
//     myNextKeyPair: await generateKeyPairBest(),
//   );
//   (_, connectionB, cryptoB) = await dht_comm.readEncrypted(
//     dht,
//     connectionB,
//     cryptoB,
//     ExamplePayload.fromBytes,
//   );
//   expect(connectionB.recordKeyThemSharing, connectionA.recordKeyMeSharing);
//   expect(
//     (cryptoB as CryptoInitializedSymmetric).initialSharedSecret,
//     cryptoA.initialSharedSecret,
//   );

//   // Write from A to B
//   debugPrint('A writing for B');
//   await dht_comm.writeEncrypted(
//     dht,
//     const ExamplePayload(message: '1'),
//     connectionA,
//     cryptoA,
//   );
//   debugPrint('B reading from A');
//   final ExamplePayload? initialPayloadFromA;
//   (initialPayloadFromA, connectionB, cryptoB) = await dht_comm.readEncrypted(
//     dht,
//     connectionB,
//     cryptoB,
//     ExamplePayload.fromBytes,
//   );
//   expect(initialPayloadFromA?.message, '1');
//   expect(
//     (connectionB as DhtConnectionEstablished).recordKeyMeSharing,
//     connectionA.recordKeyThemSharing,
//     reason: 'should have adopted share back record provided by A',
//   );
//   expect(
//     connectionB.writerMeSharing,
//     connectionA.writerThemSharing,
//     reason: 'should have adopted share back writer provided by A',
//   );
//   // B reads again
//   (_, connectionB, cryptoB) = await dht_comm.readEncrypted(
//     dht,
//     connectionB,
//     cryptoB,
//     ExamplePayload.fromBytes,
//   );
//   (_, connectionB, cryptoB) = await dht_comm.readEncrypted(
//     dht,
//     connectionB,
//     cryptoB,
//     ExamplePayload.fromBytes,
//   );

//   // Write from B to A
//   debugPrint('B writing for A');
//   await dht_comm.writeEncrypted(
//     dht,
//     const ExamplePayload(message: '2'),
//     connectionB,
//     cryptoB,
//   );
//   debugPrint('A reading from B');
//   final (payloadFromB, updatedConnectionA, updatedCryptoA) = await dht_comm
//       .readEncrypted(dht, connectionA, cryptoA, ExamplePayload.fromBytes);
//   expect(payloadFromB?.message, '2');
// }

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    await AppGlobalInit.initialize(veilidBootstrapUrl);
    await vod_flutter.init();
  });

  // test('encrypt decrypt symmetric', () async {
  //   final message = 'Secret Test Message';
  //   final (ciphertextWithVodInfo, crypto) = await encryptAndPrependVodInfo(
  //     utf8.encode(message),
  //     CryptoState.symmetric(
  //       sharedSecret: await generateRandomSharedSecretBest(),
  //       accountVod: vod.Account().toPickleEncrypted(Uint8List(32)),
  //     ),
  //   );
  //   final (decrypted, _, _) = await decrypt(ciphertextWithVodInfo, crypto);
  //   expect(utf8.decode(decrypted!), equals(message));
  // });

  // test('encrypt decrypt with vodozemac', () async {
  //   final message = 'Secret Test Message';

  //   final myAcc = vod.Account();
  //   final theirAcc = vod.Account()..generateOneTimeKeys(1);

  //   final mySession = myAcc.createOutboundSession(
  //     identityKey: theirAcc.identityKeys.curve25519,
  //     oneTimeKey: theirAcc.oneTimeKeys.values.first,
  //   );

  //   final (ciphertextWithVodInfo, myCrypto) = await encryptAndPrependVodInfo(
  //     utf8.encode(message),
  //     CryptoState.vodozemac(
  //       theirIdentityKey: theirAcc.identityKeys.curve25519.toBase64(),
  //       myIdentityKey: myAcc.identityKeys.curve25519.toBase64(),
  //       sessionVod: mySession.toPickleEncrypted(Uint8List(32)),
  //     ),
  //   );

  //   final (decrypted, theirCrypto, _) = await decrypt(
  //     ciphertextWithVodInfo,
  //     CryptoState.symmetric(
  //       sharedSecret: fakePsk(0),
  //       accountVod: theirAcc.toPickleEncrypted(Uint8List(32)),
  //     ),
  //   );
  //   expect(utf8.decode(decrypted!), equals(message));
  //   expect(theirCrypto, isA<CryptoSymToVod>());
  // });

  test('encrypt decrypt with vodozemac incl meta data', () async {
    final message = MessageWithEncryptionMetaData(
      message: {'msg': 'Secret Test Message'},
    ).toJsonString();

    final myAcc = vod.Account();
    final theirAcc = vod.Account()..generateOneTimeKeys(1);

    final mySession = myAcc.createOutboundSession(
      identityKey: theirAcc.identityKeys.curve25519,
      oneTimeKey: theirAcc.oneTimeKeys.values.first,
    );

    final (ciphertextWithVodInfo, myCrypto) = await encryptAndPrependVodInfo(
      message,
      CryptoState.vodozemac(
        theirIdentityKey: theirAcc.identityKeys.curve25519.toBase64(),
        myIdentityKey: myAcc.identityKeys.curve25519.toBase64(),
        sessionVod: mySession.toPickleEncrypted(Uint8List(32)),
      ),
    );

    final (decrypted, theirCrypto, _) = await decrypt(
      ciphertextWithVodInfo,
      CryptoState.symmetric(
        sharedSecret: fakePsk(0),
        accountVod: theirAcc.toPickleEncrypted(Uint8List(32)),
      ),
    );
    expect(decrypted, equals(message));
    final decryptedMessage = MessageWithEncryptionMetaData.fromJsonString(
      decrypted!,
    );
    expect(decryptedMessage!.message!['msg'], 'Secret Test Message');
    expect(theirCrypto, isA<CryptoSymToVod>());
  });

  // TODO(LGro): What does it take for this to be a unit instead of an
  //             integration test? We just need the Veilid cryptoSystem, no DHT.
  test(
    'sharing, initial symmetric until rotating asymmetric crypto (mock DHT)',
    () => directSharingTestGoldenPathTakingTurns(MockDht()),
  );

  // test(
  //   'sharing, multiple reads after receiving (mock DHT)',
  //   () => directSharingMultipleReads(MockDht()),
  // );

  // test(
  //   'sharing, initial symmetric until rotating asymmetric crypto (Veilid DHT)',
  //   () => directSharingTestGoldenPathTakingTurns(
  //     VeilidDht(watchLocalChanges: true),
  //   ),
  // );
}
