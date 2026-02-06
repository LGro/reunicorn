// Copyright 2024 - 2026 The Reunicorn Authors. All rights reserved.
// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:async';
import 'dart:typed_data';

import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:uuid/uuid.dart';
import 'package:veilid/veilid.dart';
import 'package:vodozemac/vodozemac.dart' as vod;

import '../../data/models/community.dart';
import '../../data/models/contact_introduction.dart';
import '../../data/models/models.dart';
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

  Future<CoagContact> accept(
    CoagContact introducer,
    ContactIntroduction introduction, {
    bool awaitUpdateFromDht = false,
  }) async {
    final contact = CoagContact(
      coagContactId: Uuid().v4(),
      name: introduction.otherName,
      myIdentity: await generateKeyPairBest(),
      profileSharingStatus: const ProfileSharingStatus(),
      dhtConnection: DhtConnectionState.established(
        recordKeyMeSharing: introduction.dhtRecordKeySharing,
        writerMeSharing: introduction.dhtWriterSharing,
        recordKeyThemSharing: introduction.dhtRecordKeyReceiving,
      ),
      connectionCrypto: CryptoState.symmetric(
        sharedSecret: introduction.sharedSecret,
        accountVod: (vod.Account()..generateOneTimeKeys(1)).toPickleEncrypted(
          Uint8List(32),
        ),
      ),
    );

    await _contactStorage.set(contact.coagContactId, contact);

    return contact;
  }

  Future<CoagContact> acceptCommunityMember(Member member) async {
    throw UnimplementedError();

    // final contact = CoagContact(
    //   coagContactId: Uuid().v4(),
    //   name: member.name,
    //   origin: CommunityOrigin.fromMember(member).toString(),
    //   myIdentity: await generateKeyPairBest(),
    //   // TODO(LGro): or do we need to initialize sharing settings?
    //   dhtConnection: (member.recordKeyThemSharing == null)
    //       ? null
    //       : DhtConnectionState.invited(
    //           recordKeyThemSharing: member.recordKeyThemSharing!,
    //         ),
    //   connectionCrypto: await generateKeyPairBest().then(
    //     (kp) => (member.theirPublicKey == null)
    //         ? CryptoState.pendingAsymmetric(myNextKeyPair: kp)
    //         : CryptoState.establishedAsymmetric(
    //             myKeyPair: kp,
    //             myNextKeyPair: kp,
    //             theirPublicKey: member.theirPublicKey!,
    //             theirNextPublicKey: member.theirPublicKey!,
    //           ),
    //   ),
    // );

    // await _contactStorage.set(contact.coagContactId, contact);

    // return contact;
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
