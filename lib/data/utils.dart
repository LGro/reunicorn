// Copyright 2024 - 2025 The Reunicorn Authors. All rights reserved.
// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:veilid_support/veilid_support.dart';

import 'models/coag_contact.dart';
import 'models/profile_info.dart';
import 'services/storage/base.dart';

Future<KeyPair> generateKeyPairBest() => Veilid.instance
    .getCryptoSystem(cryptoKindVLD0)
    .then((cs) => cs.generateKeyPair());

Future<SharedSecret> generateRandomSharedSecretBest() => Veilid.instance
    .getCryptoSystem(cryptoKindVLD0)
    .then((cs) => cs.randomSharedSecret());

Map<String, String> knownContacts(
  String coagContactId,
  Map<String, CoagContact> contacts,
) {
  final contact = contacts[coagContactId];
  if (contact == null) {
    return {};
  }

  final attestations = contact.connectionAttestations.toSet();

  return Map.fromEntries(
    contacts.values
        .where(
          (c) =>
              c.coagContactId != coagContactId &&
              c.connectionAttestations
                      .toSet()
                      .intersection(attestations)
                      .length ==
                  1,
        )
        .map((c) => MapEntry(c.coagContactId, c.name)),
  );
}

Future<ProfileInfo?> getProfileInfo(Storage<ProfileInfo> profileStorage) =>
    profileStorage.getAll().then((profiles) => profiles.values.firstOrNull);

String replacePictureWithEmptyInJson(String json) =>
    json.replaceAll(RegExp(r'"picture":\[[^\]]*\]'), '"picture":[]');
