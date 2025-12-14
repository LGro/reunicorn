// Copyright 2024 - 2025 The Reunicorn Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

import 'dart:async';
import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter/foundation.dart';
import 'package:loggy/loggy.dart';
import 'package:veilid_support/veilid_support.dart';

import '../../veilid_processor/models/processor_connection_state.dart';
import '../../veilid_processor/repository/processor_repository.dart';
import '../models/circle.dart';
import '../models/coag_contact.dart';
import '../models/contact_introduction.dart';
import '../models/contact_location.dart';
import '../models/profile_info.dart';
import '../models/profile_sharing_settings.dart';
import '../services/dht.dart';
import '../services/storage/base.dart';
import '../shared_contact_discovery.dart';
import '../utils.dart';

/// From an opened record, get app specific content and picture data from
/// corresponding subkeys
Future<(String?, Uint8List?)> _getJsonProfileAndPictureFromRecord(
  DHTRecord record,
  CryptoCodec crypto,
  DHTRecordRefreshMode refreshMode,
) async {
  // Get main profile content from first subkey
  final mainContent = await record.get(
    crypto: crypto,
    refreshMode: refreshMode,
    subkey: 0,
  );
  final jsonString = tryUtf8Decode(mainContent);

  final picture = await getChunkedPayload(
    record,
    crypto,
    refreshMode,
    numChunks: 31,
    chunkOffset: 1,
  );

  return (jsonString, (picture.isEmpty) ? null : picture);
}

DhtSettings rotateKeysInDhtSettings(
  DhtSettings settings,
  PublicKey? usedPublicKey,
  KeyPair? usedKeyPair,
  bool ackHandshakeJustCompleted,
) {
  // If we have received handshake complete signal for the first time, or our
  // next key pair's public key was used
  final rotateKeyPair =
      ackHandshakeJustCompleted ||
      (usedKeyPair != null && settings.myNextKeyPair == usedKeyPair);

  // If their next public key was used
  final rotatePublicKey =
      usedPublicKey != null && settings.theirNextPublicKey == usedPublicKey;

  if (rotateKeyPair) debugPrint('Rotating my key pair');
  if (rotatePublicKey) debugPrint('Rotating their public key');

  return DhtSettings.explicit(
    // If the next key pair was used or acknowledged, rotate it
    myKeyPair: rotateKeyPair ? settings.myNextKeyPair : settings.myKeyPair,
    // The next key pair will be populated only when the shared profile changes,
    // to avoid needlessly rotating keys
    myNextKeyPair: rotateKeyPair ? null : settings.myNextKeyPair,
    // If the next public key was used, rotate it
    theirPublicKey: rotatePublicKey ? usedPublicKey : settings.theirPublicKey,
    // Their next public key will be populated from the update they share(d)
    theirNextPublicKey: rotatePublicKey ? null : settings.theirNextPublicKey,
    // If anything asymmetric crypto related was rotated, discard symmetric key
    initialSecret: (rotateKeyPair || rotatePublicKey)
        ? null
        : settings.initialSecret,
    // Leave all other attributes as is
    recordKeyMeSharing: settings.recordKeyMeSharing,
    writerMeSharing: settings.writerMeSharing,
    recordKeyThemSharing: settings.recordKeyThemSharing,
    writerThemSharing: settings.writerThemSharing,
    theyAckHandshakeComplete: settings.theyAckHandshakeComplete,
  );
}

DhtSettings updateDhtSettingsFromContactUpdate(
  DhtSettings settings,
  CoagContactDHTSchema update,
) {
  // Try deserializing shareBackPublicKey
  late PublicKey? shareBackPublicKey;
  try {
    shareBackPublicKey =
        (update.shareBackPubKey != null && update.shareBackPubKey != 'null')
        ? PublicKey.fromString(update.shareBackPubKey!)
        : null;
  } catch (e) {
    debugPrint('Error decoding share back pub key: $e');
  }

  // Try deserializing shareBackDhtKey
  late RecordKey? shareBackDhtKey;
  try {
    shareBackDhtKey =
        (update.shareBackDHTKey != null && update.shareBackDHTKey != 'null')
        ? RecordKey.fromString(update.shareBackDHTKey!)
        : null;
  } catch (e) {
    debugPrint('Error decoding share back dht key: $e');
  }

  // Try deserializing shareBackDHTKey
  late KeyPair? shareBackDhtWriter;
  try {
    shareBackDhtWriter =
        (update.shareBackDHTWriter != null &&
            update.shareBackDHTWriter != 'null')
        ? KeyPair.fromString(update.shareBackDHTWriter!)
        : null;
  } catch (e) {
    debugPrint('Error decoding share back writer: $e');
  }

  // Update settings
  return settings.copyWith(
    // If the update contains a public key and it is not already the one in
    // use, add it as the next candidate public key
    theirNextPublicKey:
        (shareBackPublicKey != null &&
            shareBackPublicKey != settings.theirPublicKey)
        ? shareBackPublicKey
        : null,
    recordKeyMeSharing: shareBackDhtKey,
    writerMeSharing: shareBackDhtWriter,
    // Prevent going back to unacknowledged when a contact sends false
    theyAckHandshakeComplete:
        settings.theyAckHandshakeComplete || update.ackHandshakeComplete,
  );
}

/// Create an empty DHT record, return key and writer in string representation
Future<(RecordKey, KeyPair)> createRecord({String? writer}) async {
  final record = await DHTRecordPool.instance.createRecord(
    debugName: 'coag::create',
    // Create subkeys allowing max size of 32KiB per subkey given max record
    // limit of 1MiB, so that we can store a picture in subkeys 2:32
    schema: const DHTSchema.dflt(oCnt: 32),
    crypto: const VeilidCryptoPublic(),
    writer: (writer != null) ? KeyPair.fromString(writer) : null,
  );
  // Write to it once, so push it into the network. (Is this really needed?)
  await record.tryWriteBytes(Uint8List(0));
  await record.close();
  debugPrint(
    'created and wrote once to ${record.key.toString().substring(5, 10)}',
  );
  return (record.key, record.writer!);
}

/// Read DHT record, return decrypted content
Future<(PublicKey?, KeyPair?, String?, Uint8List?)> readRecord({
  required RecordKey recordKey,
  KeyPair? keyPair,
  KeyPair? nextKeyPair,
  SharedSecret? psk,
  PublicKey? publicKey,
  PublicKey? nextPublicKey,
  Iterable<KeyPair> myMiscKeyPairs = const [],
  int maxRetries = 3,
  DHTRecordRefreshMode refreshMode = DHTRecordRefreshMode.network,
}) async {
  // Derive all available DH secrets to try in addition to the pre shared key
  final domain = utf8.encode('dht');
  final secrets = <(PublicKey?, KeyPair?, SharedSecret)>[
    if (psk != null) (null, null, psk),
    if (publicKey != null && keyPair != null)
      (
        publicKey,
        keyPair,
        await Veilid.instance
            .getCryptoSystem(keyPair.kind)
            .then(
              (cs) =>
                  cs.generateSharedSecret(publicKey, keyPair.secret, domain),
            ),
      ),
    if (publicKey != null && nextKeyPair != null)
      (
        publicKey,
        nextKeyPair,
        await Veilid.instance
            .getCryptoSystem(nextKeyPair.kind)
            .then(
              (cs) => cs.generateSharedSecret(
                publicKey,
                nextKeyPair.secret,
                domain,
              ),
            ),
      ),
    if (publicKey != null)
      ...await Future.wait(
        myMiscKeyPairs
            .map(
              (kp) async => (
                publicKey,
                kp,
                await Veilid.instance
                    .getCryptoSystem(kp.kind)
                    .then(
                      (cs) =>
                          cs.generateSharedSecret(publicKey, kp.secret, domain),
                    ),
              ),
            )
            .toList(),
      ),
    if (nextPublicKey != null && keyPair != null)
      (
        nextPublicKey,
        keyPair,
        await Veilid.instance
            .getCryptoSystem(keyPair.kind)
            .then(
              (cs) => cs.generateSharedSecret(
                nextPublicKey,
                keyPair.secret,
                domain,
              ),
            ),
      ),
    if (nextPublicKey != null && nextKeyPair != null)
      (
        nextPublicKey,
        nextKeyPair,
        await Veilid.instance
            .getCryptoSystem(nextKeyPair.kind)
            .then(
              (cs) => cs.generateSharedSecret(
                nextPublicKey,
                nextKeyPair.secret,
                domain,
              ),
            ),
      ),
    if (nextPublicKey != null)
      ...await Future.wait(
        myMiscKeyPairs
            .map(
              (kp) async => (
                nextPublicKey,
                kp,
                await Veilid.instance
                    .getCryptoSystem(kp.kind)
                    .then(
                      (cs) => cs.generateSharedSecret(
                        nextPublicKey,
                        kp.secret,
                        domain,
                      ),
                    ),
              ),
            )
            .toList(),
      ),
  ];

  var retries = 0;
  while (true) {
    try {
      debugPrint(
        'trying ${secrets.length} secrets for '
        '${recordKey.toString().substring(5, 10)}',
      );
      for (final secret in secrets.reversed) {
        debugPrint(
          'trying pub ${secret.$1?.toString().substring(0, 10)} '
          'kp ${secret.$2?.toString().substring(0, 10)}',
        );

        final crypto = await VeilidCryptoPrivate.fromSharedSecret(
          recordKey.kind,
          secret.$3,
        );

        final content = await DHTRecordPool.instance
            .openRecordRead(recordKey, debugName: 'coag::read', crypto: crypto)
            .then((record) async {
              try {
                final (
                  jsonString,
                  picture,
                ) = await _getJsonProfileAndPictureFromRecord(
                  record,
                  crypto,
                  refreshMode,
                );
                return (jsonString, picture);
              } on FormatException catch (e) {
                // This can happen due to "not enough data to decrypt" when a
                // record was written empty without encryption during init
                // TODO: Only accept "not enough data to decrypt" here, make sure "Unexpected exentsion byte" is passed down as an error
                debugPrint(
                  'error reading ${recordKey.toString().substring(5, 10)} $e',
                );
              } finally {
                await record.close();
              }
            });

        // TODO: Let's in the future check for schema_version here,
        // when fewer v2 schemas without version included are in circulation
        if (content?.$1?.contains('details') ?? false) {
          debugPrint('got ${recordKey.toString().substring(5, 10)}');
          return (secret.$1, secret.$2, content?.$1, content?.$2);
        }
      }

      debugPrint('nothing for ${recordKey.toString().substring(5, 10)}');
      return (null, null, null, null);
    } on VeilidAPIExceptionTryAgain {
      // TODO: Handle VeilidAPIExceptionKeyNotFound
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

Future<CoagContact?> getContact(
  CoagContact contact, {
  Iterable<KeyPair> myMiscKeyPairs = const [],
  bool useLocalCache = false,
}) async {
  if (contact.dhtSettings.recordKeyThemSharing == null) {
    return null;
  }
  final (
    usedPublicKey,
    usedKeyPair,
    contactJson,
    contactPicture,
  ) = await readRecord(
    recordKey: contact.dhtSettings.recordKeyThemSharing!,
    psk: contact.dhtSettings.initialSecret,
    publicKey: contact.dhtSettings.theirPublicKey,
    nextPublicKey: contact.dhtSettings.theirNextPublicKey,
    keyPair: contact.dhtSettings.myKeyPair,
    nextKeyPair: contact.dhtSettings.myNextKeyPair,
    myMiscKeyPairs: myMiscKeyPairs,
    refreshMode: useLocalCache
        ? DHTRecordRefreshMode.cached
        : DHTRecordRefreshMode.network,
  );
  if ((contactJson?.isEmpty ?? true) || contactJson == 'null') {
    debugPrint(
      'empty or null ${contact.dhtSettings.recordKeyThemSharing.toString().substring(5, 10)}: $contactJson',
    );
    return null;
  }

  late CoagContactDHTSchema? dhtContact;
  try {
    dhtContact = CoagContactDHTSchema.fromJson(
      json.decode(contactJson!) as Map<String, dynamic>,
    );
  } catch (e) {
    // TODO: Report to user?
    debugPrint(
      'error deserializing ${contact.dhtSettings.recordKeyThemSharing.toString().substring(5, 10)} $e',
    );
    return null;
  }

  final dhtSettingsWithRotatedKeys = rotateKeysInDhtSettings(
    contact.dhtSettings,
    usedPublicKey,
    usedKeyPair,
    !contact.dhtSettings.theyAckHandshakeComplete &&
        dhtContact.ackHandshakeComplete,
  );

  final updatedDhtSettings = updateDhtSettingsFromContactUpdate(
    dhtSettingsWithRotatedKeys,
    dhtContact,
  );

  return contact.copyWith(
    name: (contact.name == '???')
        ? dhtContact.details.names.values.firstOrNull ?? contact.name
        : contact.name,
    theirIdentity: dhtContact.identityKey,
    connectionAttestations: dhtContact.connectionAttestations,
    details: dhtContact.details.copyWith(picture: contactPicture),
    addressLocations: dhtContact.addressLocations,
    temporaryLocations: dhtContact.temporaryLocations,
    theirIntroductionKey: dhtContact.introductionKey,
    introductionsByThem: dhtContact.introductions,
    dhtSettings: updatedDhtSettings,
  );
}

// TODO: Check and if not handle that the encoded content does (not):
// exceed e.g. half of the DHT record value limit: 500000 bytes i.e. entries
/// Encrypt the content with the given secret and write it to the DHT at key
/// This is used for sharing only (TODO: consider renaming)
Future<void> updateRecord(
  CoagContactDHTSchema? sharedProfile,
  DhtSettings settings,
) async {
  if (settings.recordKeyMeSharing == null || settings.writerMeSharing == null) {
    // TODO: Log/raise/handle
    return;
  }
  final _recordKey = settings.recordKeyMeSharing!;

  final content = sharedProfile?.toJsonStringWithoutPicture() ?? '';
  final picture = (sharedProfile?.details.picture == null)
      ? Uint8List(0)
      : Uint8List.fromList(sharedProfile!.details.picture!);

  // Prefer their next public key over the established one for sending updates
  final theirPublicKey = settings.theirNextPublicKey ?? settings.theirPublicKey;

  // TODO: Is it safe to assume consistent crypto systems between record key
  //       and psk/public keys or would it make sense to use typed instances?
  final SharedSecret secret;
  if (settings.initialSecret != null && !settings.theyAckHandshakeComplete) {
    // Otherwise, if an initial secret is present, use it for symmetric crypto
    secret = settings.initialSecret!;
    debugPrint(
      'using psk ${secret.toString().substring(0, 6)} '
      'for writing ${_recordKey.toString().substring(5, 10)}',
    );
  } else if (theirPublicKey != null && settings.myKeyPair != null) {
    // If a next public key is queued, use it to confirm
    debugPrint(
      'using their pubkey ${theirPublicKey.toString().substring(0, 6)} '
      'and my kp ${settings.myKeyPair!.key.toString().substring(0, 6)} '
      'for writing ${_recordKey.toString().substring(5, 10)}',
    );
    // Derive DH secret with next public key
    secret = await Veilid.instance
        .getCryptoSystem(settings.myKeyPair!.kind)
        .then(
          (cs) => cs.generateSharedSecret(
            theirPublicKey,
            settings.myKeyPair!.secret,
            utf8.encode('dht'),
          ),
        );
  } else {
    // TODO: Raise Exception / signal to user that something is broken
    debugPrint('no crypto for ${_recordKey.toString().substring(5, 10)}');
    return;
  }

  final crypto = await VeilidCryptoPrivate.fromSharedSecret(
    _recordKey.kind,
    secret,
  );

  // Open, write and close record
  final record = await DHTRecordPool.instance.openRecordWrite(
    _recordKey,
    settings.writerMeSharing!,
    crypto: crypto,
    debugName: 'coag::update',
  );
  // Write main profile info
  await record.eventualWriteBytes(
    crypto: crypto,
    utf8.encode(content),
    subkey: 0,
  );
  // Write picture chunks to remaining subkeys
  await Future.wait(
    chopPayloadChunks(picture).toList().asMap().entries.map(
      (e) =>
          record.eventualWriteBytes(crypto: crypto, e.value, subkey: e.key + 1),
    ),
  );
  await record.close();

  debugPrint('wrote ${_recordKey.toString().substring(5, 10)}');
}

Map<String, String> filterNames(
  Map<String, String> names,
  Map<String, List<String>> settings,
  Iterable<String> activeCircles,
) {
  if (activeCircles.isEmpty) {
    return {};
  }
  final updatedValues = {...names}
    ..removeWhere(
      (i, n) =>
          !(settings[i]?.asSet().intersectsWith(activeCircles.asSet()) ??
              false),
    );
  return updatedValues;
}

Map<String, T> filterContactDetailsList<T>(
  Map<String, T> values,
  Map<String, List<String>> settings,
  Iterable<String> activeCircles,
) {
  if (activeCircles.isEmpty) {
    return {};
  }
  return {...values}..removeWhere(
    (label, value) =>
        !(settings[label]?.asSet().intersectsWith(activeCircles.asSet()) ??
            false),
  );
}

List<int>? selectPicture(
  Map<String, List<int>> avatars,
  Map<String, int> activeCirclesWithMemberCount,
) => avatars.entries
    .where((e) => activeCirclesWithMemberCount.containsKey(e.key))
    .sorted(
      (a, b) =>
          (activeCirclesWithMemberCount[a.key] ?? 0) -
          (activeCirclesWithMemberCount[b.key] ?? 0),
    )
    .firstOrNull
    ?.value;

ContactDetails filterDetails(
  Map<String, List<int>> pictures,
  ContactDetails details,
  ProfileSharingSettings settings,
  Map<String, int> activeCirclesWithMemberCount,
) => ContactDetails(
  picture: selectPicture(pictures, activeCirclesWithMemberCount),
  publicKey: details.publicKey,
  names: filterNames(
    details.names,
    settings.names,
    activeCirclesWithMemberCount.keys,
  ),
  phones: filterContactDetailsList(
    details.phones,
    settings.phones,
    activeCirclesWithMemberCount.keys,
  ),
  emails: filterContactDetailsList(
    details.emails,
    settings.emails,
    activeCirclesWithMemberCount.keys,
  ),
  websites: filterContactDetailsList(
    details.websites,
    settings.websites,
    activeCirclesWithMemberCount.keys,
  ),
  socialMedias: filterContactDetailsList(
    details.socialMedias,
    settings.socialMedias,
    activeCirclesWithMemberCount.keys,
  ),
  events: filterContactDetailsList(
    details.events,
    settings.events,
    activeCirclesWithMemberCount.keys,
  ),
  organizations: filterContactDetailsList(
    details.organizations,
    settings.organizations,
    activeCirclesWithMemberCount.keys,
  ),
);

/// Remove address locations that are not shared with the circles specified for
/// the corresponding address label
Map<String, ContactAddressLocation> filterAddressLocations(
  Map<String, ContactAddressLocation> locations,
  ProfileSharingSettings settings,
  Iterable<String> activeCircles,
) => Map.fromEntries(
  locations.entries.where(
    (l) =>
        settings.addresses[l.key]?.toSet().intersectsWith(
          activeCircles.toSet(),
        ) ??
        false,
  ),
);

/// Remove locations that ended longer than a day ago,
/// or aren't shared with the given circles if provided
Map<String, ContactTemporaryLocation> filterTemporaryLocations(
  Map<String, ContactTemporaryLocation> locations, [
  Iterable<String>? activeCircles,
]) => Map.fromEntries(
  locations.entries.where(
    (l) =>
        l.value.end.isAfter(DateTime.now()) &&
        // TODO: Unify that selected circles are part of profileShareSettings
        //       instead of the location instance?
        (activeCircles == null ||
            l.value.circles.toSet().intersectsWith(activeCircles.toSet())),
  ),
);

// TODO: Empty all the known contacts and misc stuff when no circles active?
CoagContactDHTSchema filterAccordingToSharingProfile({
  required ProfileInfo profile,
  required Map<String, int> activeCirclesWithMemberCount,
  required DhtSettings dhtSettings,
  required List<ContactIntroduction> introductions,
  required PublicKey? identityKey,
  required PublicKey? introductionKey,
  List<String> connectionAttestations = const [],
  List<String> knownPersonalContactIds = const [],
}) => CoagContactDHTSchema(
  details: filterDetails(
    profile.pictures,
    profile.details,
    profile.sharingSettings,
    activeCirclesWithMemberCount,
  ),
  // Only share locations up to 1 day ago
  temporaryLocations: filterTemporaryLocations(
    profile.temporaryLocations,
    activeCirclesWithMemberCount.keys,
  ),
  addressLocations: filterAddressLocations(
    profile.addressLocations,
    profile.sharingSettings,
    activeCirclesWithMemberCount.keys,
  ),
  shareBackDHTKey: dhtSettings.recordKeyThemSharing.toString(),
  shareBackDHTWriter: dhtSettings.writerThemSharing.toString(),
  shareBackPubKey: (dhtSettings.myNextKeyPair != null)
      ? dhtSettings.myNextKeyPair!.key.toString()
      : ((dhtSettings.myKeyPair != null)
            ? dhtSettings.myKeyPair!.key.toString()
            : null),
  identityKey: identityKey,
  connectionAttestations: connectionAttestations,
  ackHandshakeComplete:
      dhtSettings.theirPublicKey != null ||
      dhtSettings.theirNextPublicKey != null,
  introductionKey: introductionKey,
  introductions: introductions,
);

/// Ensure the most recent profile contact details are shared with the contact
/// identified by the given ID based on the current sharing settings and
/// circle memberships
Future<CoagContact> updateSharedProfile(
  CoagContact contact,
  Map<String, CoagContact> contacts,
  ProfileInfo profileInfo,
  Map<String, List<String>> circleMemberships,
) async {
  final updatedSharedProfile = filterAccordingToSharingProfile(
    profile: profileInfo,
    // TODO: Also expose this view of the data from contacts repo?
    //       Seems to be used in different places.
    activeCirclesWithMemberCount: Map.fromEntries(
      (circleMemberships[contact.coagContactId] ?? []).map(
        (circleId) => MapEntry(
          circleId,
          circleMemberships.values
              .where((ids) => ids.contains(circleId))
              .length,
        ),
      ),
    ),
    dhtSettings: contact.dhtSettings,
    introductions: contact.introductionsForThem,
    identityKey: contact.myIdentity.key,
    introductionKey: contact.myIntroductionKeyPair.key,
    // TODO: move to function arg
    connectionAttestations: await connectionAttestations(
      contact,
      contacts.values,
    ),
  );

  return contact.copyWith(
    sharedProfile: updatedSharedProfile,
    dhtSettings: contact.dhtSettings.copyWith(
      // Only if the shared profile infos actually changed, and there isn't
      // already a next key pair queued, queue one for rotation
      // TODO: Check that the comparison detects changes on location list
      //       membership, not list instance
      myNextKeyPair:
          (contact.sharedProfile != updatedSharedProfile &&
              contact.dhtSettings.myNextKeyPair == null)
          ? await generateKeyPairBest()
          : null,
    ),
  );
}

class ContactDhtRepository {
  final _watchedRecords = <RecordKey>{};
  final Storage<CoagContact> _contactStorage;
  final Storage<Circle> _circleStorage;
  final Storage<ProfileInfo> _profileStorage;
  var veilidNetworkAvailable = false;

  // TODO: Add information about which contact is currently being synced / was synced last

  ContactDhtRepository(
    this._contactStorage,
    this._circleStorage,
    this._profileStorage,
  ) {
    unawaited(_initVeilidNetworkAvailable());
    ProcessorRepository.instance.streamProcessorConnectionState().listen(
      _veilidConnectionStateChangeCallback,
    );
    _contactStorage.changeEvents.listen(
      (e) => e.when(
        set: (oldContact, newContact) =>
            (oldContact != newContact) ? _updateContact(newContact) : null,
        delete: _onDeleteContact,
      ),
    );
    _contactStorage.getEvents.listen(_watchContact);
    // TODO: Filter for affected contats to restrict to relevant updates/changes
    _circleStorage.changeEvents.listen((_) => _updatedSharedProfiles());
    _profileStorage.changeEvents.listen((_) => _updatedSharedProfiles());
  }

  Future<void> _initVeilidNetworkAvailable() async {
    try {
      final state = await Veilid.instance.getVeilidState();
      veilidNetworkAvailable =
          state.attachment.publicInternetReady &&
          state.attachment.state == AttachmentState.fullyAttached;
    } on VeilidAPIExceptionNotInitialized {
      veilidNetworkAvailable = false;
    }
  }

  void _veilidConnectionStateChangeCallback(ProcessorConnectionState event) {
    logDebug('rncrn-veilid-connection-state-changed: $event');
    if (event.isPublicInternetReady &&
        event.isAttached &&
        !veilidNetworkAvailable) {
      veilidNetworkAvailable = true;
      unawaited(
        _contactStorage.getAll().then(
          (contacts) => contacts.values.map(_updateContact),
        ),
      );
    }

    if (!event.isPublicInternetReady || !event.isAttached) {
      veilidNetworkAvailable = false;
    }
  }

  /// Update shared profile for contact to DHT, fetch update from them and watch
  Future<void> _updateContact(CoagContact contact) async {
    // First get their updates since this helps with earlier feedback in the app
    if (contact.dhtSettings.recordKeyThemSharing != null) {
      debugPrint(
        'rncrn-dht-on-update | ${contact.coagContactId.substring(0, 5)} | '
        'share',
      );
      try {
        final updatedContact = await getContact(contact);
        await _watchContact(contact);

        // If we've had changes here, save and return; Set will trigger this
        // _updateContact callback again
        if (updatedContact != null &&
            updatedContact.hashCode != contact.hashCode) {
          debugPrint(
            'rncrn-dht-on-update | ${contact.coagContactId.substring(0, 5)} | '
            'share-changed',
          );
          await _contactStorage.set(contact.coagContactId, updatedContact);
          return;
        }
      } on DHTExceptionNotAvailable {
        // We just skip this stage
      }
    }

    if (contact.dhtSettings.recordKeyThemSharing == null &&
        contact.dhtSettings.recordKeyMeSharing == null) {
      debugPrint(
        'rncrn-dht-on-update | ${contact.coagContactId.substring(0, 5)} | '
        'share-init',
      );

      // Init sharing settings
      final (shareKey, shareWriter) = await createRecord();
      final initialSecret =
          (contact.dhtSettings.theirPublicKey == null &&
              contact.dhtSettings.theirNextPublicKey == null)
          ? await generateRandomSharedSecretBest()
          : null;
      contact = contact.copyWith(
        dhtSettings: contact.dhtSettings.copyWith(
          recordKeyMeSharing: shareKey,
          writerMeSharing: shareWriter,
          initialSecret: initialSecret,
        ),
      );

      // Init receiving settings
      final (receiveKey, receiveWriter) = await createRecord();
      contact = contact.copyWith(
        dhtSettings: contact.dhtSettings.copyWith(
          recordKeyThemSharing: receiveKey,
          writerThemSharing: receiveWriter,
        ),
      );

      // Since we've had changes here, save and return; Set will trigger this
      // _updateContact callback again
      await _contactStorage.set(contact.coagContactId, contact);
      return;
    }

    final profileInfo = await getProfileInfo(_profileStorage);
    if (profileInfo == null) {
      return;
    }
    final contacts = await _contactStorage.getAll();
    final circleMemberships = await _circleStorage.getAll().then(
      (circles) => circlesByContactIds(circles.values),
    );
    final updatedContact = await updateSharedProfile(
      contact,
      contacts,
      profileInfo,
      circleMemberships,
    );
    if (updatedContact != contact) {
      debugPrint(
        'rncrn-dht-on-update | ${contact.coagContactId.substring(0, 5)} | '
        'profile-update',
      );
      // If we've had changes here, save and return; Set will trigger this
      // _updateContact callback again
      await _contactStorage.set(contact.coagContactId, updatedContact);
      return;
    }

    // Update information shared with them second
    debugPrint(
      'rncrn-dht-on-update | ${contact.coagContactId.substring(0, 5)} | '
      'profile-write',
    );
    try {
      // TODO: only if relevant settings avail? already the case make args explicit
      await updateRecord(contact.sharedProfile, contact.dhtSettings);
    } on DHTExceptionNotAvailable {
      // TODO: When do we try next time? Can this cause outdated shared info?
      debugPrint(
        'rncrn-dht-on-update | ${contact.coagContactId.substring(0, 5)} | '
        'dht-unavailable',
      );
    }
  }

  /// Watch for updates the contact shares via the DHT
  Future<void> _watchContact(CoagContact contact) async {
    // TODO: What happens with watch if we're offline? does it watch as soon as we go online or fail?
    // TODO: Do we need to build up a watch queue when offline to then start watch when online?
    final theirRecordKey = contact.dhtSettings.recordKeyThemSharing;
    if (theirRecordKey == null) {
      return;
    }
    _watchedRecords.add(theirRecordKey);

    try {
      final record = await DHTRecordPool.instance.openRecordRead(
        theirRecordKey,
        debugName: 'coag::read-to-watch',
      );

      await record.watch(subkeys: [const ValueSubkeyRange(low: 0, high: 32)]);

      await record.listen(
        // TODO: If we want to make use of data here, we also likely need to pass crypto to decrypt it
        (record, data, subkeys) =>
            _watchContactCallback(contact.coagContactId, record.key),
        localChanges: false,
      );
    } catch (e) {
      _watchedRecords.remove(theirRecordKey);
    }
  }

  Future<CoagContact?> _watchContactCallback(
    String contactId,
    RecordKey key,
  ) async {
    final contact = await _contactStorage.get(contactId);
    if (contact == null) {
      return null;
    }
    if (key != contact.dhtSettings.recordKeyThemSharing) {
      return null;
    }
    final updatedContact = await getContact(contact, useLocalCache: true);

    //     // Ensure shared profile contains all the updated share and share back
    //     await updateContactSharedProfile(contact.coagContactId);

    //     unawaited(updateSystemContact(contact.coagContactId));

    //     // When it's the first time they acknowledge a completed handshake
    //     // from symmetric to asymmetric encryption, trigger an update of the
    //     // sharing DHT record to switch from the initial secret to a public
    //     // key derived one
    //     if (!contact.dhtSettings.theyAckHandshakeComplete &&
    //         updatedContact.dhtSettings.theyAckHandshakeComplete) {
    //       // TODO: This could be directly "distributedStorage.updateRecord"
    //       //       with error handling.
    //       await tryShareWithContactDHT(updatedContact.coagContactId);
    //     }
    //   }
    // }

    if (updatedContact != null) {
      await _contactStorage.set(updatedContact.coagContactId, updatedContact);
    }
    return updatedContact;
  }

  Future<void> _onDeleteContact(CoagContact contact) async {
    _watchedRecords.remove(contact.dhtSettings.recordKeyThemSharing);
    await updateRecord(null, contact.dhtSettings);
  }

  // TODO: Can there be race conditions where before all contact updates are
  //       finished a contact is changed in other ways? Can we lock contacts?
  Future<void> _updatedSharedProfiles() async {
    final circles = await _circleStorage.getAll();
    final profileInfo = await _profileStorage.getAll().then(
      (profiles) => profiles.values.firstOrNull,
    );
    if (profileInfo == null || circles.isEmpty) {
      return;
    }
    final contacts = await _contactStorage.getAll();
    await Future.wait(
      contacts.keys.map((contactId) async {
        // Get contact right before updating in the hope to avoid race condition
        final contact = await _contactStorage.get(contactId);
        if (contact == null) {
          return;
        }
        await updateSharedProfile(
          contact,
          contacts,
          profileInfo,
          circlesByContactIds(circles.values),
        ).then(
          (updatedContact) =>
              _contactStorage.set(updatedContact.coagContactId, updatedContact),
        );
      }),
    );
  }

  Future<bool> updateAndWatchReceivingDHT({bool shuffle = false}) async {
    if (!ProcessorRepository
        .instance
        .processorConnectionState
        .attachment
        .publicInternetReady) {
      veilidNetworkAvailable = false;
      logDebug('Veilid attachment not public internet ready');
      return false;
    }
    veilidNetworkAvailable = true;
    final contacts = await _contactStorage.getAll().then(
      (contacts) => contacts.values.toList(),
    );
    if (shuffle) {
      contacts.shuffle();
    }

    // TODO: Can we parallelize this? with Future.wait([])
    for (final contact in contacts) {
      // Check for incoming updates
      if (contact.dhtSettings.recordKeyThemSharing != null) {
        await _updateContact(contact);
      }
    }

    return true;
  }
}
