// Copyright 2025 - 2026 The Reunicorn Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:veilid_support/veilid_support.dart';

import '../models/backup.dart';
import '../models/circle.dart';
import '../models/coag_contact.dart';
import '../models/profile_info.dart';
import '../models/setting.dart';
import '../services/dht.dart';
import '../services/storage/base.dart';
import '../utils.dart';
import 'base_dht.dart';
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
    debugName: 'rncrn::backup',
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
            debugName: 'rncrn::backup::read',
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
// TODO: Add settings backup but exclude backup settings to avoid accidentally overriding them
// TODO: on storage update, backup
// TODO: Share backup record key with contacts so that they can cache it
class BackupRepository extends BaseDhtRepository {
  final Storage<ProfileInfo> _profileStorage;
  final Storage<CoagContact> _contactStorage;
  final Storage<Circle> _circleStorage;
  final Storage<Setting> _settingStorage;

  DateTime? _mostRecentBackupTime;
  // TODO(LGro): change into event stream
  var _isBackingUp = false;

  BackupRepository(
    this._profileStorage,
    this._contactStorage,
    this._circleStorage,
    this._settingStorage,
  );

  DateTime? get mostRecentBackupTime => _mostRecentBackupTime;

  @override
  Future<void> dhtBecameAvailableCallback() async =>
      (!_isBackingUp &&
          (_mostRecentBackupTime
                  ?.add(const Duration(minutes: 10))
                  .isBefore(DateTime.now()) ??
              true))
      ? backup()
      : null;

  /// Backup everything that is needed to restore an app "account"
  Future<(RecordKey, SharedSecret)?> backup({
    bool waitForRecordSync = false,
  }) async {
    _isBackingUp = true;
    final profile = await getProfileInfo(_profileStorage);
    if (profile == null) {
      _isBackingUp = false;
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
              systemContactId: c.systemContactId,
              introductionsForThem: c.introductionsForThem,
              details: null,
              theirIdentity: null,
              connectionAttestations: const [],
              addressLocations: const {},
              temporaryLocations: const {},
              sharedProfile: null,
              theirIntroductionKey: null,
              introductionsByThem: const [],
            ),
          )
          .toList(),
      circles.map((id, circle) => MapEntry(id, circle.name)),
      circlesByContactIds(circles.values),
    );

    // Try picking up existing backup settings or create new ones
    final backupSetting = await _settingStorage.get('backup');
    late final SharedSecret backupSecretKey;
    late final RecordKey backupDhtKey;
    late final KeyPair dhtWriter;
    try {
      backupDhtKey = RecordKey.fromString(
        backupSetting!.value['record'] as String,
      );
      dhtWriter = KeyPair.fromString(backupSetting.value['writer'] as String);
      backupSecretKey = SharedSecret.fromString(
        backupSetting.value['secret'] as String,
      );
    } catch (e) {
      // Create new backup record and secret
      (backupDhtKey, dhtWriter) = await createRecord();
      backupSecretKey = await generateRandomSharedSecretBest();

      // Save for future updates
      await _settingStorage.set(
        'backup',
        Setting({
          'record': backupDhtKey.toString(),
          'writer': dhtWriter.toString(),
          'secret': backupSecretKey.toString(),
        }),
      );
    }

    // Try updating backup
    try {
      await updateBackupRecord(
        accountBackup,
        backupDhtKey,
        dhtWriter,
        backupSecretKey,
      );

      // If instructed to, wait while subkeys marked offline
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

      _mostRecentBackupTime = DateTime.now();
      _isBackingUp = false;

      return (backupDhtKey, backupSecretKey);
    } on VeilidAPIException {
      _isBackingUp = false;
      return null;
    }
  }

  /// Restore a previously backed up Reunicorn setup
  Future<bool> restore(RecordKey recordKey, SharedSecret secret) async {
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
