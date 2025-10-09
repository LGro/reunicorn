// Copyright 2024 - 2025 The Reunicorn Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:reunicorn/data/models/batch_invites.dart';
import 'package:reunicorn/data/models/coag_contact.dart';
import 'package:reunicorn/data/models/contact_update.dart';
import 'package:reunicorn/data/models/profile_sharing_settings.dart';
import 'package:reunicorn/data/providers/distributed_storage/dht.dart';
import 'package:reunicorn/data/providers/persistent_storage/base.dart';
import 'package:reunicorn/data/providers/system_contacts/base.dart';
import 'package:reunicorn/data/providers/system_contacts/system_contacts.dart';
import 'package:reunicorn/data/repositories/contacts.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:veilid_support/veilid_support.dart';

const dummyAppUserName = 'App User Name';

Uint8List randomUint8List(int length) {
  final random = Random.secure();
  return Uint8List.fromList(List.generate(length, (_) => random.nextInt(256)));
}

RecordKey dummyDhtRecordKey([int? i]) => RecordKey(
      kind: cryptoKindVLD0,
      value: (i == null)
          ? FixedEncodedString43.fromBytes(randomUint8List(32))
          : FixedEncodedString43.fromBytes(
              Uint8List.fromList(List.filled(32, i)),
            ),
    );

FixedEncodedString43 dummyPsk(int i) =>
    FixedEncodedString43.fromBytes(Uint8List.fromList(List.filled(32, i)));

KeyPair dummyKeyPair([int pub = 0, int sec = 1]) => KeyPair.fromKeyPair(
      cryptoKindVLD0,
      KeyPair(
        key: FixedEncodedString43.fromBytes(
          Uint8List.fromList(List.filled(32, pub)),
        ),
        secret: FixedEncodedString43.fromBytes(
          Uint8List.fromList(List.filled(32, sec)),
        ),
      ),
    );

Future<ContactsRepository> contactsRepositoryFromContacts({
  required List<CoagContact> contacts,
  required Map<Typed<FixedEncodedString43>, CoagContactDHTSchema?> initialDht,
  String appUserName = dummyAppUserName,
}) async =>
    ContactsRepository(
      DummyPersistentStorage(
        Map.fromEntries(contacts.map((c) => MapEntry(c.coagContactId, c))),
      ),
      DummyDistributedStorage(initialDht: initialDht),
      DummySystemContacts([]),
      appUserName,
    );

class DummyPersistentStorage extends PersistentStorage {
  DummyPersistentStorage(this.contacts, {this.profileContactId});

  Map<String, CoagContact> contacts;
  String? profileContactId;
  List<String> log = [];
  Map<String, String> circles = {};
  ProfileSharingSettings profileSharingSettings =
      const ProfileSharingSettings();
  Map<String, List<String>> circleMemberships = {};
  List<ContactUpdate> updates = [];
  ProfileInfo? profileInfo;
  List<BatchInvite> batches = [];

  @override
  Future<void> addUpdate(ContactUpdate update) async {
    log.add('addUpdate');
    updates.add(update);
  }

  @override
  Future<Map<String, CoagContact>> getAllContacts() async {
    log.add('getAllContacts');
    return contacts;
  }

  @override
  Future<CoagContact> getContact(String coagContactId) async {
    log.add('getContact:$coagContactId');
    final c = contacts[coagContactId];
    if (c == null) {
      // TODO: handle error case more specifically
      throw Exception('Contact ID $coagContactId could not be found');
    }
    return c;
  }

  @override
  Future<List<ContactUpdate>> getUpdates() async {
    log.add('getUpdates');
    return [];
  }

  @override
  Future<void> removeContact(String coagContactId) async {
    log.add('removeContact:$coagContactId');
    contacts.remove(coagContactId);
  }

  @override
  Future<void> updateContact(CoagContact contact) async {
    log.add('updateContact:${contact.coagContactId}');
    contacts[contact.coagContactId] = contact;
  }

  @override
  Future<Map<String, List<String>>> getCircleMemberships() async =>
      circleMemberships;

  @override
  Future<Map<String, String>> getCircles() async => circles;

  @override
  Future<void> updateCircleMemberships(
    Map<String, List<String>> circleMemberships,
  ) async {
    log.add('updateCircleMemberships');
    this.circleMemberships = circleMemberships;
  }

  @override
  Future<void> updateCircles(Map<String, String> circles) async {
    log.add('updateCircles');
    this.circles = circles;
  }

  @override
  Future<void> addBatch(BatchInvite batch) async {
    batches.add(batch);
  }

  @override
  Future<List<BatchInvite>> getBatches() async => batches;

  @override
  Future<ProfileInfo?> getProfileInfo() async => profileInfo;

  @override
  Future<void> updateProfileInfo(ProfileInfo info) async {
    profileInfo = info;
  }

  @override
  String debugInfo() => '';
}

class DummyDistributedStorage extends VeilidDhtStorage {
  DummyDistributedStorage({
    Map<RecordKey, CoagContactDHTSchema?>? initialDht,
    this.transparent = false,
  }) {
    if (initialDht != null) {
      dht = {...initialDht};
    }
  }
  final bool transparent;
  List<String> log = [];
  Map<RecordKey, CoagContactDHTSchema?> dht = {};
  Map<RecordKey, Future<void> Function(String coagContactId, RecordKey key)>
      _watchedRecords = {};

  @override
  Future<(RecordKey, KeyPair)> createRecord({
    String? writer,
  }) async {
    log.add('createDHTRecord');
    if (transparent) {
      final recordAndWriter = await super.createRecord(writer: writer);
      dht[recordAndWriter.$1] = null;
      return recordAndWriter;
    }
    final recordKey = dummyDhtRecordKey();
    dht[recordKey] = null;
    return (recordKey, dummyKeyPair());
  }

  @override
  Future<(PublicKey?, KeyPair?, String?, Uint8List?)> readRecord({
    required RecordKey recordKey,
    KeyPair? keyPair,
    KeyPair? nextKeyPair,
    SecretKey? psk,
    PublicKey? publicKey,
    PublicKey? nextPublicKey,
    Iterable<KeyPair> myMiscKeyPairs = const [],
    int maxRetries = 3,
    DHTRecordRefreshMode refreshMode = DHTRecordRefreshMode.network,
  }) async {
    if (transparent) {
      return super.readRecord(
        recordKey: recordKey,
        keyPair: keyPair,
        nextKeyPair: nextKeyPair,
        psk: psk,
        publicKey: publicKey,
        nextPublicKey: nextPublicKey,
        maxRetries: maxRetries,
        myMiscKeyPairs: myMiscKeyPairs,
        refreshMode: DHTRecordRefreshMode.local,
      );
    }
    return (publicKey, keyPair, jsonEncode(dht[recordKey]?.toJson()), null);
  }

  @override
  Future<void> updateRecord(
    CoagContactDHTSchema? sharedProfile,
    DhtSettings settings,
  ) async {
    if (settings.recordKeyMeSharing == null ||
        settings.writerMeSharing == null) {
      return;
    }
    log.add('updateRecord:${settings.recordKeyMeSharing}');
    dht[settings.recordKeyMeSharing!] = sharedProfile;
    if (transparent) {
      return super.updateRecord(sharedProfile, settings);
    }
  }

  @override
  Future<void> watchRecord(
    String coagContactId,
    Typed<FixedEncodedString43> key,
    Future<void> Function(String coagContactId, Typed<FixedEncodedString43> key)
        onNetworkUpdate,
  ) async {
    log.add('watchRecord:$key');
    if (transparent) {
      return super.watchRecord(coagContactId, key, onNetworkUpdate);
    }
    // TODO: Also call the updates when updates happen
    _watchedRecords[key] = onNetworkUpdate;
  }
}

class DummySystemContacts extends SystemContactsBase {
  DummySystemContacts(this.contacts, {this.permissionGranted = true});

  List<Contact> contacts;
  List<String> log = [];
  bool permissionGranted;

  @override
  Future<Contact> getContact(String id) async {
    if (!permissionGranted) {
      throw MissingSystemContactsPermissionError();
    }
    log.add('getContact:$id');
    return Future.value(contacts.where((c) => c.id == id).first);
  }

  @override
  Future<List<Contact>> getContacts() async {
    if (!permissionGranted) {
      throw MissingSystemContactsPermissionError();
    }
    log.add('getContacts');
    return Future.value(contacts);
  }

  @override
  Future<Contact> updateContact(Contact contact) {
    if (!permissionGranted) {
      throw MissingSystemContactsPermissionError();
    }
    log.add('updateContact:${json.encode(contact.toJson())}');
    if (contacts.where((c) => c.id == contact.id).isNotEmpty) {
      contacts =
          contacts.map((c) => (c.id == contact.id) ? contact : c).asList();
    } else {
      contacts.add(contact);
    }
    return Future.value(contact);
  }

  @override
  Future<Contact> insertContact(Contact contact) {
    if (!permissionGranted) {
      throw MissingSystemContactsPermissionError();
    }
    contacts.add(contact);
    return Future.value(contact);
  }

  @override
  Future<bool> requestPermission() async => permissionGranted;
}
