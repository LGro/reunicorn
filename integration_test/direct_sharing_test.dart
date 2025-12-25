// Copyright 2024 - 2025 The Reunicorn Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

@Timeout(Duration(seconds: 120))
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:reunicorn/data/models/circle.dart';
import 'package:reunicorn/data/models/coag_contact.dart';
import 'package:reunicorn/data/models/contact_location.dart';
import 'package:reunicorn/data/models/profile_info.dart';
import 'package:reunicorn/data/models/profile_sharing_settings.dart';
import 'package:reunicorn/data/repositories/contact_dht.dart';
import 'package:reunicorn/data/services/storage/memory.dart';
import 'package:reunicorn/ui/receive_request/cubit.dart';
import 'package:reunicorn/ui/receive_request/utils/direct_sharing.dart';
import 'package:reunicorn/ui/utils.dart';
import 'package:reunicorn/veilid_init.dart';
import 'package:veilid/veilid.dart';

import 'utils.dart';

const _defaultCircleId = 'c1';

Future<bool> runUntilTimeoutOrSuccess(
  int timeoutSeconds,
  Future<bool> Function() condition,
) async {
  final end = DateTime.now().add(Duration(seconds: timeoutSeconds));
  while (DateTime.now().isBefore(end)) {
    final fulfilled = await condition();
    if (fulfilled) {
      return true;
    }
    await Future<void>.delayed(const Duration(milliseconds: 100));
  }
  return false;
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  final _contactStorageA = MemoryStorage<CoagContact>();
  final _circleStorageA = MemoryStorage<Circle>();
  final _contactStorageB = MemoryStorage<CoagContact>();
  final _circleStorageB = MemoryStorage<Circle>();

  late ContactDhtRepository _cRepoA;
  late ContactDhtRepository _cRepoB;

  setUp(() async {
    // Initialize app and DHT connection
    await AppGlobalInit.initialize(veilidBootstrapUrl);
    final dhtReady = await runUntilTimeoutOrSuccess(60, () async {
      try {
        final state = await Veilid.instance.getVeilidState();
        return state.attachment.publicInternetReady &&
            state.attachment.state == AttachmentState.fullyAttached;
      } on VeilidAPIExceptionNotInitialized {
        return false;
      }
    });
    if (!dhtReady) {
      throw Exception('Integration test requires DHT availability.');
    }

    // Initialize Alice's repository
    _cRepoA = ContactDhtRepository(
      _contactStorageA,
      _circleStorageA,
      MemoryStorage<ProfileInfo>()..addToMemory(
        'pA1',
        const ProfileInfo(
          'pA1',
          details: ContactDetails(names: {'n1': 'UserA'}),
          sharingSettings: ProfileSharingSettings(
            names: {
              'n1': [_defaultCircleId],
            },
          ),
        ),
      ),
    );

    // Initialize Bob's repository
    _cRepoB = ContactDhtRepository(
      _contactStorageB,
      _circleStorageB,
      MemoryStorage<ProfileInfo>()..addToMemory(
        'pB1',
        const ProfileInfo(
          'pB1',
          details: ContactDetails(names: {'n1': 'UserB'}),
          sharingSettings: ProfileSharingSettings(
            names: {
              'n1': [_defaultCircleId],
            },
          ),
        ),
      ),
    );
  });

  test('Alice directly shares with Bob who shares back', () async {
    // Alice prepares invite for Bob and shares via default circle
    debugPrint('ALICE ACTING');
    var contactBobInvitedByA = await createContactForInvite(
      'Bob Invite',
      pubKey: null,
    );
    await _contactStorageA.set(
      contactBobInvitedByA.coagContactId,
      contactBobInvitedByA,
    );
    await _circleStorageA.set(
      _defaultCircleId,
      Circle(
        id: _defaultCircleId,
        name: 'circle1',
        memberIds: [contactBobInvitedByA.coagContactId],
      ),
    );

    // TODO: This doesn't seem ideal
    await runUntilTimeoutOrSuccess(
      60,
      () => _contactStorageA
          .get(contactBobInvitedByA.coagContactId)
          .then(
            (c) =>
                c?.dhtSettings.recordKeyMeSharing != null &&
                c?.sharedProfile?.details.names.values.firstOrNull == 'UserA',
          ),
    );
    contactBobInvitedByA =
        await _contactStorageA.get(contactBobInvitedByA.coagContactId) ??
        contactBobInvitedByA;
    expect(
      contactBobInvitedByA.dhtSettings.recordKeyMeSharing,
      isNotNull,
      reason: 'Sharing record prepared',
    );
    expect(
      contactBobInvitedByA.dhtSettings.recordKeyThemSharing,
      isNotNull,
      reason: 'Receiving record prepared',
    );
    expect(
      contactBobInvitedByA.dhtSettings.initialSecret,
      isNotNull,
      reason: 'Initial secret for symmetric encryption ready',
    );
    expect(
      contactBobInvitedByA.dhtSettings.theirPublicKey,
      isNull,
      reason: 'We have not seen any public keys from them yet',
    );
    expect(
      contactBobInvitedByA.dhtSettings.theirNextPublicKey,
      isNull,
      reason: 'We have not seen any public keys from them yet',
    );
    // TODO: Can those be used as matchers?
    expect(showSharingInitializing(contactBobInvitedByA), false);
    expect(showSharingOffer(contactBobInvitedByA), false);
    expect(showDirectSharing(contactBobInvitedByA), true);
    final directSharingLinkFromAliceForBob = DirectSharingInvite(
      'Alice Sharing',
      contactBobInvitedByA.dhtSettings.recordKeyMeSharing!,
      contactBobInvitedByA.dhtSettings.initialSecret!,
    ).uri;

    // Bob accepts invite from Alice and shares via default circle
    debugPrint('---');
    debugPrint('BOB ACTING');
    await createContactFromDirectSharing(
      directSharingLinkFromAliceForBob.fragment,
      _contactStorageB,
    );
    var contactAliceFromBobsRepo = await _contactStorageB.getAll().then(
      (contacts) => contacts.values.first,
    );
    await _circleStorageB.set(
      _defaultCircleId,
      Circle(
        id: _defaultCircleId,
        name: 'circle1',
        memberIds: [contactAliceFromBobsRepo.coagContactId],
      ),
    );
    // TODO: This doesn't seem ideal
    await runUntilTimeoutOrSuccess(
      60,
      () => _contactStorageB
          .get(contactAliceFromBobsRepo.coagContactId)
          .then((c) => c?.details?.names.values.firstOrNull != null),
    );
    contactAliceFromBobsRepo =
        await _contactStorageB.get(contactAliceFromBobsRepo.coagContactId) ??
        contactAliceFromBobsRepo;
    expect(
      contactAliceFromBobsRepo.name,
      'Alice Sharing',
      reason: 'Name from invite URL',
    );
    // null
    expect(
      contactAliceFromBobsRepo.details?.names.values.firstOrNull,
      'UserA',
      reason: 'Name from sharing profile',
    );
    expect(
      contactAliceFromBobsRepo.dhtSettings.initialSecret,
      isNotNull,
      reason: 'Initial secret still in place because no full pub key cycle yet',
    );
    expect(
      contactAliceFromBobsRepo.dhtSettings.theirNextPublicKey,
      isNotNull,
      reason: 'Public key is expected to be available after first read',
    );
    expect(showSharingInitializing(contactAliceFromBobsRepo), false);
    expect(showSharingOffer(contactAliceFromBobsRepo), false);
    expect(showDirectSharing(contactAliceFromBobsRepo), false);

    // // Alice checks for Bob sharing back
    // debugPrint('---');
    // debugPrint('ALICE ACTING');
    // await _cRepoA.updateContactFromDHT(contactBobInvitedByA);
    // contactBobInvitedByA = _cRepoA.getContact(
    //   contactBobInvitedByA.coagContactId,
    // )!;
    // expect(
    //   contactBobInvitedByA.details?.names.values.firstOrNull,
    //   'UserB',
    //   reason: 'Name from sharing profile',
    // );
    // expect(
    //   contactBobInvitedByA.dhtSettings.theyAckHandshakeComplete,
    //   true,
    //   reason: 'Bob indicated handshake complete',
    // );
    // expect(
    //   contactBobInvitedByA.dhtSettings.initialSecret,
    //   isNull,
    //   reason: 'Initial secret discarded due to switch to public key crypto',
    // );
    // await _cRepoA.tryShareWithContactDHT(contactBobInvitedByA.coagContactId);

    // // Bob checks for completed handshake after updating receive and share
    // debugPrint('---');
    // debugPrint('BOB ACTING');
    // await _cRepoB.updateContactFromDHT(contactAliceFromBobsRepo);
    // contactAliceFromBobsRepo = _cRepoB.getContacts().values.first;
    // expect(
    //   contactAliceFromBobsRepo.dhtSettings.theyAckHandshakeComplete,
    //   true,
    //   reason: 'Handshake accepted as complete by Alice',
    // );
    // expect(
    //   contactAliceFromBobsRepo.dhtSettings.initialSecret,
    //   isNull,
    //   reason: 'Initial secret removed after pub keys exchanged and handshake',
    // );

    // //// TRANSITION FROM SYMMETRIC TO ASYMMETRIC CRYPTO COMPLETED ////
    // ////           TESTING ASYMMETRIC KEY ROTATION NOW            ////

    // // Bob shares update, testing key rotation
    // debugPrint('---');
    // debugPrint('BOB ACTING');
    // final profileB = _cRepoB.getProfileInfo()!;
    // await _cRepoB.setProfileInfo(
    //   profileB.copyWith(
    //     addressLocations: {
    //       'a0': const ContactAddressLocation(latitude: 0, longitude: 0),
    //     },
    //     sharingSettings: profileB.sharingSettings.copyWith(
    //       addresses: {
    //         'a0': [defaultInitialCircleId],
    //       },
    //     ),
    //   ),
    //   triggerDhtUpdate: false,
    // );
    // await _cRepoB.tryShareWithContactDHT(
    //   contactAliceFromBobsRepo.coagContactId,
    // );

    // // Alice receives new location
    // debugPrint('---');
    // debugPrint('ALICE ACTING');
    // await _cRepoA.updateContactFromDHT(
    //   _cRepoA.getContact(contactBobInvitedByA.coagContactId)!,
    // );
    // final contactBobFromAlicesRepo = _cRepoA.getContacts().values.first;
    // expect(
    //   contactBobFromAlicesRepo.dhtSettings.theirPublicKey,
    //   isNotNull,
    //   reason: 'Public key is marked as working',
    // );
    // expect(
    //   contactBobFromAlicesRepo.dhtSettings.theirNextPublicKey,
    //   isNotNull,
    //   reason: 'Follow up public key has been transmitted',
    // );
    // expect(
    //   contactBobFromAlicesRepo.dhtSettings.theirPublicKey,
    //   isNot(equals(contactBobFromAlicesRepo.dhtSettings.theirNextPublicKey)),
    //   reason: 'Follow up key differs',
    // );
    // expect(
    //   contactBobFromAlicesRepo.dhtSettings.theirNextPublicKey,
    //   contactAliceFromBobsRepo.dhtSettings.myNextKeyPair?.key,
    //   reason: 'Next key matches source next key pair public key',
    // );
  });
}
