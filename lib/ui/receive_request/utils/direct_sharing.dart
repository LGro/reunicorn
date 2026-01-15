// Copyright 2025 - 2026 The Reunicorn Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

import 'package:uuid/uuid.dart';

import '../../../data/models/models.dart';
import '../../../data/services/storage/base.dart';
import '../../../data/utils.dart';
import '../../utils.dart';

Future<CoagContact?> createContactFromDirectSharing(
  String fragment,
  Storage<CoagContact> contactStorage,
) async {
  final DirectSharingInvite invite;
  try {
    invite = DirectSharingInvite.parse(fragment);
  } on Exception {
    return null;
  }

  final existingContacts = await contactStorage.getAll();

  // If we're already receiving from that record, redirect to existing contact/
  // TODO: Should we check for ID or pubkey change / mismatch?
  final existingContactsThemSharing = existingContacts.values.where(
    (c) => c.dhtConnection?.recordKeyThemSharing == invite.recordKey,
  );
  if (existingContactsThemSharing.isNotEmpty) {
    return existingContactsThemSharing.first;
  }

  // If I accidentally scanned my own QR code, don't add a contact
  final existingContactsMeSharing = existingContacts.values.where(
    (c) => c.dhtConnection?.recordKeyMeSharingOrNull == invite.recordKey,
  );
  if (existingContactsMeSharing.isNotEmpty) {
    return null;
  }

  // Otherwise, add new contact with the information we already have
  final contact = CoagContact(
    coagContactId: Uuid().v4(),
    // TODO: localize default to language
    name: invite.name,
    myIdentity: await generateKeyPairBest(),
    myIntroductionKeyPair: await generateKeyPairBest(),
    dhtConnection: DhtConnectionState.invited(
      recordKeyThemSharing: invite.recordKey,
    ),
    connectionCrypto: CryptoState.initializedSymmetric(
      initialSharedSecret: invite.psk,
      myNextKeyPair: await generateKeyPairBest(),
    ),
  );

  // Save contact and trigger optional DHT update if connected, this allows
  // to scan a QR code offline and fetch data later if not available now
  await contactStorage.set(contact.coagContactId, contact);

  return contact;
}
