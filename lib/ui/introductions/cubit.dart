// Copyright 2024 - 2026 The Reunicorn Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:uuid/uuid.dart';

import '../../data/models/contact_introduction.dart';
import '../../data/models/models.dart';
import '../../data/services/storage/base.dart';
import '../../data/utils.dart';

part 'state.dart';
part 'cubit.g.dart';

class IntroductionsCubit extends Cubit<IntroductionsState> {
  IntroductionsCubit(this._contactStorage) : super(const IntroductionsState()) {
    _contactSubscription = _contactStorage.changeEvents.listen(
      (_) => fetchData(),
    );
    unawaited(fetchData());
  }

  final Storage<CoagContact> _contactStorage;
  late final StreamSubscription<StorageEvent<CoagContact>> _contactSubscription;

  Future<void> fetchData() async {
    final contacts = await _contactStorage.getAll();
    if (!isClosed) {
      emit(IntroductionsState(contacts: contacts));
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

  @override
  Future<void> close() {
    unawaited(_contactSubscription.cancel());
    return super.close();
  }
}
