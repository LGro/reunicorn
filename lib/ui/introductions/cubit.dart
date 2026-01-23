// Copyright 2024 - 2026 The Reunicorn Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:uuid/uuid.dart';
import 'package:veilid/veilid.dart';

import '../../data/models/community.dart';
import '../../data/models/contact_introduction.dart';
import '../../data/models/models.dart';
import '../../data/repositories/community_dht.dart';
import '../../data/services/storage/base.dart';
import '../../data/utils.dart';

part 'state.dart';
part 'cubit.freezed.dart';
part 'cubit.g.dart';

class IntroductionsCubit extends Cubit<IntroductionsState> {
  IntroductionsCubit(this._contactStorage, this._communityStorage)
    : super(const IntroductionsState()) {
    _contactSubscription = _contactStorage.changeEvents.listen(
      (_) => fetchData(),
    );
    unawaited(fetchData());
  }

  final Storage<CoagContact> _contactStorage;
  final Storage<Community> _communityStorage;
  late final StreamSubscription<StorageEvent<CoagContact>> _contactSubscription;

  Future<void> fetchData() async {
    final contacts = await _contactStorage.getAll();
    final communities = await _communityStorage.getAll();

    if (!isClosed) {
      emit(IntroductionsState(contacts: contacts, communities: communities));
    }
  }

  Future<String?> accept(
    CoagContact introducer,
    ContactIntroduction introduction, {
    bool awaitUpdateFromDht = false,
  }) async {
    // Find the key pair to use for encrypting communication with the introduced
    final myKeyPair = [
      introducer.myIntroductionKeyPair,
      ...introducer.myPreviousIntroductionKeyPairs,
    ].where((kp) => kp.key == introduction.publicKey).firstOrNull;
    if (myKeyPair == null) {
      return null;
    }

    // Create new contact for the introduced
    final contact = CoagContact(
      coagContactId: Uuid().v4(),
      name: introduction.otherName,
      myIdentity: await generateKeyPairBest(),
      myIntroductionKeyPair: await generateKeyPairBest(),
      profileSharingStatus: const ProfileSharingStatus(),
      dhtConnection: DhtConnectionState.established(
        recordKeyMeSharing: introduction.dhtRecordKeySharing,
        writerMeSharing: introduction.dhtWriterSharing,
        recordKeyThemSharing: introduction.dhtRecordKeyReceiving,
      ),
      connectionCrypto: CryptoState.establishedAsymmetric(
        myKeyPair: myKeyPair,
        myNextKeyPair: await generateKeyPairBest(),
        theirNextPublicKey: introduction.otherPublicKey,
        theirPublicKey: introduction.otherPublicKey,
      ),
    );

    await _contactStorage.set(contact.coagContactId, contact);

    // Rotate introduction key pair for introducer
    // TODO: Can this cause issues when someone introduces multiple contacts at once?
    await _contactStorage.set(
      introducer.coagContactId,
      introducer.copyWith(
        myIntroductionKeyPair: await generateKeyPairBest(),
        myPreviousIntroductionKeyPairs: [
          introducer.myIntroductionKeyPair,
          ...introducer.myPreviousIntroductionKeyPairs,
        ],
      ),
    );

    return contact.coagContactId;
  }

  Future<String?> acceptCommunityMember(Member member) async {
    final contact = CoagContact(
      coagContactId: Uuid().v4(),
      name: member.name,
      origin: CommunityOrigin.fromMember(member).toString(),
      myIdentity: await generateKeyPairBest(),
      myIntroductionKeyPair: await generateKeyPairBest(),
      // TODO(LGro): or do we need to initialize sharing settings?
      dhtConnection: (member.recordKeyThemSharing == null)
          ? null
          : DhtConnectionState.invited(
              recordKeyThemSharing: member.recordKeyThemSharing!,
            ),
      connectionCrypto: await generateKeyPairBest().then(
        (kp) => (member.theirPublicKey == null)
            ? CryptoState.pendingAsymmetric(myNextKeyPair: kp)
            : CryptoState.establishedAsymmetric(
                myKeyPair: kp,
                myNextKeyPair: kp,
                theirPublicKey: member.theirPublicKey!,
                theirNextPublicKey: member.theirPublicKey!,
              ),
      ),
    );

    await _contactStorage.set(contact.coagContactId, contact);

    return contact.coagContactId;
  }

  @override
  Future<void> close() {
    unawaited(_contactSubscription.cancel());
    return super.close();
  }
}

List<(String?, Member)> pendingCommunityIntroductions(
  Iterable<Community> communities,
  Iterable<CoagContact> contacts,
) {
  // Or should we be checking contact origins instead?
  final establishedReceivingRecordKeys = contacts
      .map((c) => c.dhtConnection?.recordKeyThemSharing)
      .whereType<RecordKey>()
      .toSet();
  final introductions = <(String?, Member)>[];
  for (final community in communities) {
    for (final member in community.members) {
      if (establishedReceivingRecordKeys.contains(
        member.recordKeyThemSharing,
      )) {
        // Skip member if we already added them as a contact
        continue;
      }
      introductions.add((community.info?.name, member));
    }
  }
  return introductions;
}
