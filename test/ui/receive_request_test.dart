// Copyright 2024 - 2025 The Reunicorn Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

import 'dart:typed_data';

import 'package:bloc_test/bloc_test.dart';
import 'package:reunicorn/data/models/coag_contact.dart';
import 'package:reunicorn/data/repositories/contacts.dart';
import 'package:reunicorn/ui/receive_request/cubit.dart';
import 'package:reunicorn/ui/utils.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_scanner/mobile_scanner.dart' as mobile_scanner;
import 'package:veilid_support/veilid_support.dart';

import '../mocked_providers.dart';

const appUserName = 'App User Name';

FixedEncodedString43 _dummyPsk(int i) =>
    FixedEncodedString43.fromBytes(Uint8List.fromList(List.filled(32, i)));

ContactsRepository _contactsRepositoryFromContacts(
  List<CoagContact> contacts,
) =>
    ContactsRepository(
      DummyPersistentStorage(
        Map.fromEntries(contacts.map((c) => MapEntry(c.coagContactId, c))),
      ),
      DummyDistributedStorage(
        initialDht: {
          dummyDhtRecordKey(0): CoagContactDHTSchema(
            details: const ContactDetails(names: {'0': 'DHT 0'}),
            shareBackDHTKey: dummyDhtRecordKey(9).toString(),
            shareBackPubKey: dummyKeyPair(9, 9).key.toString(),
          ),
          dummyDhtRecordKey(1): CoagContactDHTSchema(
            details: const ContactDetails(names: {'1': 'DHT 1'}),
            shareBackDHTKey: dummyDhtRecordKey(8).toString(),
            shareBackPubKey: dummyKeyPair(8, 8).key.toString(),
          ),
          dummyDhtRecordKey(2): CoagContactDHTSchema(
            details: const ContactDetails(names: {'2': 'DHT 2'}),
            shareBackDHTKey: dummyDhtRecordKey(8).toString(),
            shareBackPubKey: dummyKeyPair(8, 8).key.toString(),
          ),
        },
      ),
      DummySystemContacts([]),
      appUserName,
      initialize: false,
      generateKeyPair: () async => dummyKeyPair(),
      generateSharedSecret: () async => dummyPsk(42),
    );

void main() {
  group('Test Cubit State Transitions', () {
    ContactsRepository? contactsRepository;

    setUp(() async {
      TestWidgetsFlutterBinding.ensureInitialized();
      contactsRepository = _contactsRepositoryFromContacts([
        CoagContact(
          coagContactId: '2',
          name: 'Existing Contact A',
          myIdentity: dummyKeyPair(3, 2),
          myIntroductionKeyPair: dummyKeyPair(3, 3),
          dhtSettings: DhtSettings(
            myKeyPair: dummyKeyPair(2, 1),
            myNextKeyPair: dummyKeyPair(2, 2),
          ),
        ),
        CoagContact(
          coagContactId: '5',
          name: 'Existing Contact B',
          myIdentity: dummyKeyPair(2, 3),
          myIntroductionKeyPair: dummyKeyPair(2, 4),
          dhtSettings: DhtSettings(
            myKeyPair: dummyKeyPair(5, 1),
            myNextKeyPair: dummyKeyPair(5, 5),
          ),
        ),
      ]);
      await contactsRepository!.initialize();
    });

    blocTest<ReceiveRequestCubit, ReceiveRequestState>(
      'emits no state changes when nothing is called',
      build: () => ReceiveRequestCubit(contactsRepository!),
      expect: () => const <ReceiveRequestState>[],
    );

    blocTest<ReceiveRequestCubit, ReceiveRequestState>(
      'scan qr code',
      build: () => ReceiveRequestCubit(contactsRepository!),
      act: (c) async => c.scanQrCode(),
      expect: () => const [ReceiveRequestState(ReceiveRequestStatus.qrcode)],
    );

    blocTest<ReceiveRequestCubit, ReceiveRequestState>(
      'emits qrcode state when non-reunicorn code is scanned',
      build: () => ReceiveRequestCubit(contactsRepository!),
      act: (c) async => c.qrCodeCaptured(
        const mobile_scanner.BarcodeCapture(
          barcodes: [mobile_scanner.Barcode(rawValue: 'not.coag.social')],
        ),
      ),
      expect: () => const [
        ReceiveRequestState(ReceiveRequestStatus.processing),
        ReceiveRequestState(ReceiveRequestStatus.qrcode),
      ],
    );

    blocTest<ReceiveRequestCubit, ReceiveRequestState>(
      'emits qrcode state when reunicorn link is scanned but fragment missing',
      build: () => ReceiveRequestCubit(contactsRepository!),
      act: (c) async => c.qrCodeCaptured(
        const mobile_scanner.BarcodeCapture(
          barcodes: [
            mobile_scanner.Barcode(rawValue: 'https://reunicorn.app/c/'),
          ],
        ),
      ),
      expect: () => const [
        ReceiveRequestState(ReceiveRequestStatus.processing),
        ReceiveRequestState(ReceiveRequestStatus.qrcode),
      ],
    );

    blocTest<ReceiveRequestCubit, ReceiveRequestState>(
      'emits scan qr code when handling own invite link',
      build: () => ReceiveRequestCubit(contactsRepository!),
      act: (c) async {
        final contact = await contactsRepository!.createContactForInvite(
          'for invite',
          awaitDhtSharingAttempt: true,
        );
        await c.qrCodeCaptured(
          mobile_scanner.BarcodeCapture(
            barcodes: [
              mobile_scanner.Barcode(
                rawValue: directSharingUrl(
                  'my own',
                  contact.dhtSettings.recordKeyMeSharing!,
                  contact.dhtSettings.initialSecret!,
                ).toString(),
              ),
            ],
          ),
        );
      },
      expect: () => [
        const ReceiveRequestState(ReceiveRequestStatus.processing),
        const ReceiveRequestState(ReceiveRequestStatus.qrcode),
      ],
    );

    blocTest<ReceiveRequestCubit, ReceiveRequestState>(
      'successful direct sharing qt scanning, no dht info available yet',
      build: () => ReceiveRequestCubit(contactsRepository!),
      act: (c) async => c.qrCodeCaptured(
        mobile_scanner.BarcodeCapture(
          barcodes: [
            mobile_scanner.Barcode(
              rawValue: directSharingUrl(
                'Direct Sharer',
                dummyDhtRecordKey(4),
                _dummyPsk(5),
              ).toString(),
            ),
          ],
        ),
      ),
      expect: () => [
        const ReceiveRequestState(ReceiveRequestStatus.processing),
        const TypeMatcher<ReceiveRequestState>().having(
          (s) => s.status.isSuccess,
          'isSuccess',
          isTrue,
        ),
      ],
      verify: (c) {
        // Check state
        expect(c.state.status, ReceiveRequestStatus.success);
        expect(c.state.profile!.name, 'Direct Sharer');
        expect(c.state.profile!.dhtSettings.initialSecret, _dummyPsk(5));
        expect(
          c.state.profile!.dhtSettings.recordKeyThemSharing,
          dummyDhtRecordKey(4),
        );
        expect(c.state.profile!.dhtSettings.recordKeyMeSharing, null);

        // Check repo
        expect(
          c.contactsRepository.getContact(c.state.profile!.coagContactId)?.name,
          'Direct Sharer',
        );
        expect(
          c.contactsRepository.getCirclesForContact(
            c.state.profile!.coagContactId,
          ),
          isEmpty,
        );
      },
    );

    blocTest<ReceiveRequestCubit, ReceiveRequestState>(
      'direct sharing qr code, dht available',
      build: () => ReceiveRequestCubit(contactsRepository!),
      act: (c) async => c.qrCodeCaptured(
        mobile_scanner.BarcodeCapture(
          barcodes: [
            mobile_scanner.Barcode(
              rawValue: directSharingUrl(
                'Direct Sharer',
                dummyDhtRecordKey(0),
                _dummyPsk(0),
              ).toString(),
            ),
          ],
        ),
      ),
      expect: () => [
        const ReceiveRequestState(ReceiveRequestStatus.processing),
        const TypeMatcher<ReceiveRequestState>().having(
          (s) => s.status.isSuccess,
          'isSuccess',
          isTrue,
        ),
      ],
      verify: (c) {
        // Check state
        expect(c.state.status, ReceiveRequestStatus.success);
        expect(c.state.profile!.name, 'Direct Sharer');
        expect(c.state.profile!.dhtSettings.initialSecret, _dummyPsk(0));
        expect(
          c.state.profile!.dhtSettings.recordKeyThemSharing,
          dummyDhtRecordKey(0),
        );
        // Still null, but populated from DHT in the repo below
        expect(c.state.profile!.dhtSettings.recordKeyMeSharing, isNull);

        // Check repo
        expect(
          c.contactsRepository.getContact(c.state.profile!.coagContactId)?.name,
          'Direct Sharer',
        );
        expect(
          c.contactsRepository.getCirclesForContact(
            c.state.profile!.coagContactId,
          ),
          isEmpty,
        );
        expect(
          c.contactsRepository
              .getContact(c.state.profile!.coagContactId)
              ?.dhtSettings
              .recordKeyMeSharing,
          dummyDhtRecordKey(9),
        );
      },
    );

    blocTest<ReceiveRequestCubit, ReceiveRequestState>(
      'successful profile based offer qr scanning',
      build: () => ReceiveRequestCubit(contactsRepository!),
      act: (c) async => c.qrCodeCaptured(
        mobile_scanner.BarcodeCapture(
          barcodes: [
            mobile_scanner.Barcode(
              rawValue: profileBasedOfferUrl(
                'Offering Sharer',
                dummyDhtRecordKey(4),
                dummyKeyPair(4, 4).key,
              ).toString(),
            ),
          ],
        ),
      ),
      expect: () => [
        const ReceiveRequestState(ReceiveRequestStatus.processing),
        const TypeMatcher<ReceiveRequestState>().having(
          (s) => s.status.isSuccess,
          'isSuccess',
          isTrue,
        ),
      ],
      verify: (c) {
        // Check state
        expect(c.state.status, ReceiveRequestStatus.success);
        expect(c.state.profile!.name, 'Offering Sharer');
        expect(
          c.state.profile!.dhtSettings.theirPublicKey,
          dummyKeyPair(4, 4).key,
        );
        expect(c.state.profile!.dhtSettings.initialSecret, isNull);
        expect(
          c.state.profile!.dhtSettings.recordKeyThemSharing,
          dummyDhtRecordKey(4),
        );
        expect(c.state.profile!.dhtSettings.recordKeyMeSharing, isNull);

        // Check repo
        expect(
          c.contactsRepository.getContact(c.state.profile!.coagContactId)?.name,
          'Offering Sharer',
        );
        expect(
          c.contactsRepository.getCirclesForContact(
            c.state.profile!.coagContactId,
          ),
          isEmpty,
        );
      },
    );

    blocTest<ReceiveRequestCubit, ReceiveRequestState>(
      'batch invite qr scanning',
      build: () => ReceiveRequestCubit(contactsRepository!),
      act: (c) async => c.qrCodeCaptured(
        mobile_scanner.BarcodeCapture(
          barcodes: [
            mobile_scanner.Barcode(
              rawValue: batchInviteUrl(
                'Batch Label',
                dummyDhtRecordKey(4),
                _dummyPsk(4),
                4,
                dummyKeyPair(4, 4).toKeyPair(),
              ).toString(),
            ),
          ],
        ),
      ),
      expect: () => [
        const ReceiveRequestState(ReceiveRequestStatus.processing),
        const TypeMatcher<ReceiveRequestState>().having(
          (s) => s.status.isHandleBatchInvite,
          'isHandleBatchInvite',
          isTrue,
        ),
      ],
    );
  });
}
