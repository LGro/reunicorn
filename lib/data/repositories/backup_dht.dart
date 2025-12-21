// Copyright 2025 The Reunicorn Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:veilid_support/veilid_support.dart';

import '../models/backup.dart';
import '../models/circle.dart';
import '../models/coag_contact.dart';
import '../models/profile_info.dart';
import '../services/dht.dart';
import '../services/storage/base.dart';
import '../utils.dart';
import 'contact_dht.dart';

@override
Future<void> updateBackupRecord(
  AccountBackup backup,
  RecordKey recordKey,
  KeyPair writer,
  SharedSecret secret,
) async {
  final crypto = await VeilidCryptoPrivate.fromSharedSecret(
    recordKey.kind,
    secret,
  );
  final record = await DHTRecordPool.instance.openRecordWrite(
    recordKey,
    writer,
    crypto: crypto,
    debugName: 'coag::backup',
  );
  await Future.wait(
    chopPayloadChunks(
      utf8.encode(jsonEncode(backup.toJson())),
      numChunks: 32,
    ).toList().asMap().entries.map(
      (e) => record.eventualWriteBytes(crypto: crypto, e.value, subkey: e.key),
    ),
  );
  await record.close();
}

/// Read backup DHT record, return decrypted content
@override
Future<String?> readBackupRecord(
  RecordKey recordKey,
  SharedSecret secret, {
  int maxRetries = 3,
  DHTRecordRefreshMode refreshMode = DHTRecordRefreshMode.network,
}) async {
  // TODO: Handle VeilidAPIExceptionKeyNotFound, VeilidAPIExceptionTryAgain
  var retries = 0;
  while (true) {
    try {
      final pskCrypto = await VeilidCryptoPrivate.fromSharedSecret(
        recordKey.kind,
        secret,
      );
      final content = await DHTRecordPool.instance
          .openRecordRead(
            recordKey,
            debugName: 'coag::backup::read',
            crypto: pskCrypto,
          )
          .then((record) async {
            try {
              final payload = await getChunkedPayload(
                record,
                pskCrypto,
                refreshMode,
                numChunks: 32,
              );
              debugPrint('read psk ${recordKey.toString().substring(5, 10)}');
              return tryUtf8Decode(payload);
            } on FormatException catch (e) {
              // This can happen due to "not enough data to decrypt" when a record
              // was written empty without encryption during initialization
              // TODO: Only accept "not enough data to decrypt" here, make sure "Unexpected exentsion byte" is passed down as an error
              debugPrint('psk ${recordKey.toString().substring(5, 10)} $e');
            } finally {
              await record.close();
            }
          });

      return content;
    } on VeilidAPIExceptionTryAgain {
      // TODO: Make sure that Veilid offline is detected at a higher level and not triggering errors here
      retries++;
      if (retries <= maxRetries) {
        await Future<void>.delayed(const Duration(milliseconds: 500));
      } else {
        rethrow;
      }
    }
  }
}

// TODO: Add community backup
class BackupRepository {
  final Storage<ProfileInfo> _profileStorage;
  final Storage<CoagContact> _contactStorage;
  final Storage<Circle> _circleStorage;

  BackupRepository(
    this._profileStorage,
    this._contactStorage,
    this._circleStorage,
  );

  /// Backup everything that is needed to restore an app "account"
  Future<(RecordKey, SharedSecret)?> backup({
    bool waitForRecordSync = false,
  }) async {
    final profile = await getProfileInfo(_profileStorage);
    if (profile == null) {
      return null;
    }
    final contacts = await _contactStorage.getAll();
    final circles = await _circleStorage.getAll();
    final accountBackup = AccountBackup(
      // Drop pictures from profile
      ProfileInfo(
        profile.id,
        details: profile.details.copyWith(),
        addressLocations: {...profile.addressLocations},
        temporaryLocations: {...profile.temporaryLocations},
        sharingSettings: profile.sharingSettings.copyWith(),
        mainKeyPair: profile.mainKeyPair,
      ),
      // Reduce contacts to absolute minimum that is required to recreate them
      contacts.values
          .map(
            (c) => CoagContact.explicit(
              coagContactId: c.coagContactId,
              myIdentity: c.myIdentity,
              myIntroductionKeyPair: c.myIntroductionKeyPair,
              myPreviousIntroductionKeyPairs: c.myPreviousIntroductionKeyPairs,
              name: c.name,
              dhtSettings: c.dhtSettings,
              origin: c.origin,
              comment: c.comment,
              verified: c.verified,
              details: null,
              theirIdentity: null,
              connectionAttestations: const [],
              systemContactId: null,
              addressLocations: const {},
              temporaryLocations: const {},
              sharedProfile: null,
              theirIntroductionKey: null,
              introductionsForThem: const [],
              introductionsByThem: const [],
            ),
          )
          .toList(),
      circles.map((id, circle) => MapEntry(id, circle.name)),
      circlesByContactIds(circles.values),
    );
    final backupSecretKey = await generateRandomSharedSecretBest();
    final (backupDhtKey, dhtWriter) = await createRecord();
    try {
      // await distributedStorage.updateRecord(
      //     CoagContactDHTSchema(
      //         details: const ContactDetails(),
      //         shareBackDHTKey: null,
      //         shareBackPubKey: null),
      //     DhtSettings(
      //         myKeyPair: await generateKeyPair(),
      //         recordKeyMeSharing: backupDhtKey,
      //         writerMeSharing:dhtWriter ,
      //         initialSecret: backupSecretKey));
      await updateBackupRecord(
        accountBackup,
        backupDhtKey,
        dhtWriter,
        backupSecretKey,
      );

      // While subkeys marked offline, wait
      while (waitForRecordSync) {
        final report = await DHTRecordPool.instance
            .openRecordRead(
              backupDhtKey,
              debugName: 'coag::backup::read::stats',
            )
            .then((record) async {
              final report = await record.routingContext.inspectDHTRecord(
                backupDhtKey,
              );
              await record.close();
              return report;
            });

        if (report.offlineSubkeys.isEmpty) {
          break;
        }
        await Future<void>.delayed(const Duration(seconds: 1));
      }

      return (backupDhtKey, backupSecretKey);
    } on VeilidAPIException {
      return null;
    }
  }

  /// Restore a previously backed up Reunicorn setup
  Future<bool> restore(
    RecordKey recordKey,
    SharedSecret secret, {
    bool awaitDhtOperations = false,
  }) async {
    // TODO: read record
    try {
      final jsonString = await readBackupRecord(recordKey, secret);
      if (jsonString == null) {
        return false;
      }
      final backup = AccountBackup.fromJson(
        jsonDecode(jsonString) as Map<String, dynamic>,
      );

      final initialProfileInfo = await getProfileInfo(_profileStorage);
      await _profileStorage.set(backup.profileInfo.id, backup.profileInfo);
      if (initialProfileInfo != null) {
        await _profileStorage.delete(initialProfileInfo.id);
      }

      for (final contact in backup.contacts) {
        await _contactStorage.set(contact.coagContactId, contact);
      }

      for (final circle in backup.circles.entries) {
        await _circleStorage.set(
          circle.key,
          Circle(
            id: circle.key,
            name: circle.value,
            memberIds: backup.circleMemberships.entries
                .where((e) => e.value.contains(circle.key))
                .map((e) => e.key)
                .toList(),
          ),
        );
      }

      return true;
    } on VeilidAPIException catch (_) {
      // TODO: Log
      return false;
    } on Exception catch (_) {
      // TODO: Log
      return false;
    }
  }
}
