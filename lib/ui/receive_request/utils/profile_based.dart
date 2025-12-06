// Copyright 2025 The Reunicorn Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

import 'package:uuid/uuid.dart';
import 'package:veilid/veilid.dart';

import '../../../data/models/coag_contact.dart';
import '../../../data/services/storage/base.dart';
import '../../../data/utils.dart';
import '../../utils.dart';

Future<CoagContact?> createContactFromProfileInvite(
  String fragment,
  KeyPair myInitialKeyPair,
  Storage<CoagContact> contactStorage,
) async {
  final ProfileBasedInvite invite;
  try {
    invite = ProfileBasedInvite.parse(fragment);
  } on Exception {
    return null;
  }

  // Otherwise, add new contact with the information we already have
  final contact = CoagContact(
    coagContactId: Uuid().v4(),
    name: invite.name,
    myIdentity: await generateKeyPairBest(),
    myIntroductionKeyPair: await generateKeyPairBest(),
    dhtSettings: DhtSettings(
      recordKeyThemSharing: invite.recordKey,
      theirNextPublicKey: invite.publicKey,
      myNextKeyPair: myInitialKeyPair,
      // We skip the DH key exchange and directly start with all pub keys
      theyAckHandshakeComplete: true,
    ),
  );

  // Save contact and trigger optional DHT update if connected, this allows
  // to scan a QR code offline and fetch data later if not available now
  await contactStorage.set(contact.coagContactId, contact);

  return contact;
}
