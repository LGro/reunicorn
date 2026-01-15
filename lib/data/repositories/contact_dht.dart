// Copyright 2024 - 2026 The Reunicorn Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

import 'dart:async';
import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter/foundation.dart';
import 'package:loggy/loggy.dart';
import 'package:pointycastle/pointycastle.dart' show Digest;
import 'package:uuid/uuid.dart';
import 'package:veilid_support/veilid_support.dart';

import '../../veilid_processor/models/processor_connection_state.dart';
import '../../veilid_processor/repository/processor_repository.dart';
import '../models/circle.dart';
import '../models/contact_introduction.dart';
import '../models/models.dart';
import '../models/profile_info.dart';
import '../services/dht/encrypted_communication.dart' as dht_comm;
import '../services/dht/veilid_dht.dart';
import '../services/storage/base.dart';
import '../shared_contact_discovery.dart';
import '../utils.dart';

Map<String, T> filterContactDetailsList<T>(
  Map<String, T> values,
  Map<String, List<String>> settings,
  Iterable<String> activeCircles, {
  String Function(String)? labelObfuscation,
}) {
  if (activeCircles.isEmpty) {
    return {};
  }
  return Map.fromEntries(
    values.entries
        .where(
          (e) =>
              settings[e.key]?.asSet().intersectsWith(activeCircles.asSet()) ??
              false,
        )
        .map(
          (e) => MapEntry(
            (labelObfuscation == null) ? e.key : labelObfuscation(e.key),
            e.value,
          ),
        ),
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

/// Hash the contactId together with the label to create a unique label to avoid
/// leaking a global, intra-contact identifier that could be used by malicious
/// contacts to reconstruct the social net
String personalizedLabelHash(String contactId, String label) =>
    Digest('SHA-512').process(utf8.encode('$label$contactId')).toString();

ContactDetails filterDetails(
  String contactId,
  Map<String, List<int>> pictures,
  ContactDetails details,
  ProfileSharingSettings settings,
  Map<String, int> activeCirclesWithMemberCount,
) => ContactDetails(
  picture: selectPicture(pictures, activeCirclesWithMemberCount),
  publicKey: details.publicKey,
  names: filterContactDetailsList(
    details.names,
    settings.names,
    activeCirclesWithMemberCount.keys,
    labelObfuscation: (l) => personalizedLabelHash(contactId, l),
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
    labelObfuscation: (l) => personalizedLabelHash(contactId, l),
  ),
  misc: filterContactDetailsList(
    details.misc,
    settings.misc,
    activeCirclesWithMemberCount.keys,
  ),
  tags: filterContactDetailsList(
    details.tags,
    settings.tags,
    activeCirclesWithMemberCount.keys,
    labelObfuscation: (l) => personalizedLabelHash(contactId, l),
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
ContactSharingSchema filterAccordingToSharingProfile({
  required String contactId,
  required ProfileInfo profile,
  required Map<String, int> activeCirclesWithMemberCount,
  required CryptoState connectionCrypto,
  required List<ContactIntroduction> introductions,
  required PublicKey? identityKey,
  required PublicKey? introductionKey,
  List<String> connectionAttestations = const [],
  List<String> knownPersonalContactIds = const [],
}) => ContactSharingSchema(
  details: filterDetails(
    contactId,
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
  identityKey: identityKey,
  connectionAttestations: connectionAttestations,
  introductionKey: introductionKey,
  introductions: introductions,
);

/// Ensure the most recent profile contact details are shared with the contact
/// identified by the given ID based on the current sharing settings and
/// circle memberships
Future<ContactSharingSchema> updateSharedProfile(
  CoagContact contact,
  Map<String, CoagContact> contacts,
  ProfileInfo profileInfo,
  Map<String, List<String>> circleMemberships,
) async => filterAccordingToSharingProfile(
  contactId: contact.coagContactId,
  profile: profileInfo,
  // TODO: Also expose this view of the data from contacts repo?
  //       Seems to be used in different places.
  activeCirclesWithMemberCount: Map.fromEntries(
    (circleMemberships[contact.coagContactId] ?? []).map(
      (circleId) => MapEntry(
        circleId,
        circleMemberships.values.where((ids) => ids.contains(circleId)).length,
      ),
    ),
  ),
  connectionCrypto: contact.connectionCrypto,
  introductions: contact.introductionsForThem,
  identityKey: contact.myIdentity.key,
  introductionKey: contact.myIntroductionKeyPair.key,
  // TODO: move to function arg
  connectionAttestations: await connectionAttestations(
    contact,
    contacts.values,
  ),
);

class ContactDhtRepository {
  final Storage<CoagContact> _contactStorage;
  final Storage<Circle> _circleStorage;
  final Storage<ProfileInfo> _profileStorage;
  final BaseDht _dhtStorage;
  var veilidNetworkAvailable = false;

  // TODO: Add information about which contact is currently being synced / was synced last

  ContactDhtRepository(
    this._contactStorage,
    this._circleStorage,
    this._profileStorage,
    this._dhtStorage,
  ) {
    unawaited(_initVeilidNetworkAvailable());
    ProcessorRepository.instance.streamProcessorConnectionState().listen(
      _veilidConnectionStateChangeCallback,
    );
    _contactStorage.changeEvents.listen(
      (e) => e.when(
        set: (oldContact, newContact) => (oldContact != newContact)
            ? updateContact(newContact.coagContactId)
            : null,
        delete: _onDeleteContact,
      ),
    );
    _contactStorage.getEvents.listen(
      (c) => (c.dhtConnection == null)
          ? null
          : _watchContact(c.coagContactId, c.dhtConnection!),
    );
    _circleStorage.changeEvents.listen(
      (e) => e.when(
        set: (oldCircle, newCircle) async => Future.wait(
          (newCircle.memberIds.toSet()..addAll(oldCircle?.memberIds ?? [])).map(
            updateContact,
          ),
        ),
        delete: (circle) async =>
            Future.wait(circle.memberIds.map(updateContact)),
      ),
    );
    _profileStorage.changeEvents.listen(
      (_) => _contactStorage.getAll().then(
        (contacts) => Future.wait(contacts.keys.map(updateContact)),
      ),
    );
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
    logDebug('rcrn-veilid-connection-state-changed: $event');
    if (event.isPublicInternetReady &&
        event.isAttached &&
        !veilidNetworkAvailable) {
      veilidNetworkAvailable = true;
      unawaited(
        _contactStorage.getAll().then(
          (contacts) =>
              contacts.values.map((c) => updateContact(c.coagContactId)),
        ),
      );
    }

    if (!event.isPublicInternetReady || !event.isAttached) {
      veilidNetworkAvailable = false;
    }
  }

  /// Update shared profile for contact to DHT, fetch update from them and watch
  Future<void> updateContact(String contactId) async {
    debugPrint(
      'rcrn-dht-on-update | ${contactId.substring(0, 5)} | '
      'called',
    );
    await _contactStorage.lock.synchronized(contactId, () async {
      debugPrint(
        'rcrn-dht-on-update | ${contactId.substring(0, 5)} | '
        'started-sync',
      );
      final contact = await _contactStorage.get(contactId);
      if (contact == null) {
        return;
      }

      if (contact.dhtConnection == null) {
        return _contactStorage.set(
          contactId,
          contact.copyWith(
            dhtConnection: await dht_comm.initializeEncryptedDhtConnection(
              _dhtStorage,
              contact.connectionCrypto,
            ),
          ),
        );
      }

      final (dhtContact, dhtConnection, connectionCrypto) = await dht_comm
          .readEncrypted(
            _dhtStorage,
            contact.dhtConnection!,
            contact.connectionCrypto,
            ContactSharingSchema.fromBytes,
          );
      await _watchContact(contact.coagContactId, dhtConnection);
      if (dhtContact != null) {
        final updatedContact = contact.copyWith(
          name: (contact.name == '???')
              ? dhtContact.details.names.values.firstOrNull ?? contact.name
              : contact.name,
          theirIdentity: dhtContact.identityKey,
          connectionAttestations: dhtContact.connectionAttestations,
          details: dhtContact.details,
          addressLocations: dhtContact.addressLocations,
          temporaryLocations: dhtContact.temporaryLocations,
          theirIntroductionKey: dhtContact.introductionKey,
          introductionsByThem: dhtContact.introductions,
          dhtConnection: dhtConnection,
          connectionCrypto: connectionCrypto,
        );
        if (updatedContact.hashCode != contact.hashCode) {
          debugPrint(
            'rcrn-dht-on-update | ${contact.coagContactId.substring(0, 5)} | '
            'share-changed',
          );
          await _contactStorage.set(contact.coagContactId, updatedContact);
          // If we've had changes here, save and return; Set will trigger this
          // updateContact callback again
          // TODO(LGRo): Doing another read attempt until we don't receive
          //             updates seems slow to get a write in
          return;
        }
      }

      final profileInfo = await getProfileInfo(_profileStorage);
      if (profileInfo == null) {
        return;
      }
      final contacts = await _contactStorage.getAll();
      final circleMemberships = await _circleStorage.getAll().then(
        (circles) => circlesByContactIds(circles.values),
      );
      final updatedSharedProfile = await updateSharedProfile(
        contact,
        contacts,
        profileInfo,
        circleMemberships,
      );
      // If we already have shared the most recent profile version, stop here
      if (updatedSharedProfile == contact.profileSharingStatus.sharedProfile) {
        debugPrint(
          'rcrn-dht-on-update | ${contact.coagContactId.substring(0, 5)} | '
          'skip-no-change',
        );
        return;
      }

      // Update information shared with them second
      debugPrint(
        'rcrn-dht-on-update | ${contact.coagContactId.substring(0, 5)} | '
        'profile-write',
      );
      try {
        // TODO: do we ever use the shared profile = null to empty the record?
        final isWriteSuccess = await dht_comm.writeEncrypted(
          _dhtStorage,
          updatedSharedProfile,
          contact.dhtConnection!,
          contact.connectionCrypto,
        );
        final now = DateTime.now();
        return _contactStorage.set(
          contact.coagContactId,
          contact.copyWith(
            profileSharingStatus: contact.profileSharingStatus.copyWith(
              mostRecentAttempt: now,
              sharedProfile: isWriteSuccess
                  ? updatedSharedProfile
                  : contact.profileSharingStatus.sharedProfile,
              mostRecentSuccess: isWriteSuccess
                  ? now
                  : contact.profileSharingStatus.mostRecentSuccess,
            ),
          ),
        );
      } on DHTExceptionNotAvailable {
        // TODO: When do we try next time? Can this cause outdated shared info?
        debugPrint(
          'rcrn-dht-on-update | ${contact.coagContactId.substring(0, 5)} | '
          'dht-unavailable',
        );
      } on DHTExceptionNoRecord {
        // This can happen when e.g. the share back record is unavailable
        debugPrint(
          'rcrn-dht-on-update | ${contact.coagContactId.substring(0, 5)} | '
          'record-unavailable',
        );
      }
      await _contactStorage.set(
        contact.coagContactId,
        contact.copyWith(
          profileSharingStatus: contact.profileSharingStatus.copyWith(
            mostRecentAttempt: DateTime.now(),
          ),
        ),
      );
    });
  }

  // Future<CoagContact?> _watchContactCallback(String contactId) async {
  //   final contact = await _contactStorage.get(contactId);
  //   if (contact == null) {
  //     return null;
  //   }
  //   final updatedContact = await getContact(contact, useLocalCache: true);

  //   //     // When it's the first time they acknowledge a completed handshake
  //   //     // from symmetric to asymmetric encryption, trigger an update of the
  //   //     // sharing DHT record to switch from the initial secret to a public
  //   //     // key derived one
  //   //     if (!contact.dhtSettings.theyAckHandshakeComplete &&
  //   //         updatedContact.dhtSettings.theyAckHandshakeComplete) {
  //   //       // TODO: This could be directly "distributedStorage.updateRecord"
  //   //       //       with error handling.
  //   //       await tryShareWithContactDHT(updatedContact.coagContactId);
  //   //     }
  //   //   }
  //   // }

  //   if (updatedContact != null) {
  //     await _contactStorage.set(updatedContact.coagContactId, updatedContact);
  //   }
  //   return updatedContact;
  // }

  Future<void> _watchContact(
    String contactId,
    DhtConnectionState dhtConnection,
  ) async {
    try {
      await _dhtStorage.watch(
        dhtConnection.recordKeyThemSharing,
        () => updateContact(contactId),
      );
    } catch (e) {}
  }

  Future<void> _onDeleteContact(CoagContact contact) async {
    if (contact.dhtConnection == null) {
      return;
    }
    try {
      await contact.dhtConnection!.map(
        invited: (s) => null,
        initialized: (s) => _dhtStorage.write(
          s.recordKeyMeSharing,
          s.writerMeSharing,
          Uint8List.fromList([]),
        ),
        established: (s) => _dhtStorage.write(
          s.recordKeyMeSharing,
          s.writerMeSharing,
          Uint8List.fromList([]),
        ),
      );
    } on (VeilidAPIException, DHTExceptionNotAvailable) catch (e) {
      // TODO(LGro): Can we somehow keep track of this and retry to delete it later?
      debugPrint(
        'rcrn-dht-on-delete | ${contact.coagContactId.substring(0, 5)} | '
        'dht-unavailable | $e',
      );
    }
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

    // Check for incoming updates
    await Future.wait(
      contacts
          .where(
            (c) =>
                c.dhtConnection is DhtConnectionInitialized ||
                c.dhtConnection is DhtConnectionEstablished,
          )
          .map((c) => updateContact(c.coagContactId)),
    );

    return true;
  }

  /// Creating contact from just a name or from a profile link, i.e. with name
  /// and public key
  Future<CoagContact> createContactForInvite(
    String name, {
    PublicKey? pubKey,
  }) async {
    final connectionCrypto =
        CryptoState.initializedSymmetric(
              myNextKeyPair: await generateKeyPairBest(),
              initialSharedSecret: await generateRandomSharedSecretBest(),
            )
            as CryptoInitializedSymmetric;
    final contact = CoagContact(
      coagContactId: Uuid().v4(),
      name: name,
      myIdentity: await generateKeyPairBest(),
      myIntroductionKeyPair: await generateKeyPairBest(),
      connectionCrypto: (pubKey == null)
          ? connectionCrypto
          : CryptoState.establishedSymmetric(
              initialSharedSecret: connectionCrypto.initialSharedSecretOrNull!,
              myNextKeyPair: connectionCrypto.myNextKeyPair,
              theirNextPublicKey: pubKey,
            ),
    );
    await _contactStorage.set(contact.coagContactId, contact);
    return contact;
  }
}
