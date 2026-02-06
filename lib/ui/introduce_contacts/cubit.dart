// Copyright 2024 - 2026 The Reunicorn Authors. All rights reserved.
// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:reunicorn/data/utils.dart';

import '../../data/models/coag_contact.dart';
import '../../data/models/contact_introduction.dart';
import '../../data/services/dht/veilid_dht.dart';
import '../../data/services/storage/base.dart';
import '../../data/shared_contact_discovery.dart';

part 'cubit.g.dart';
part 'state.dart';

class IntroduceContactsCubit extends Cubit<IntroduceContactsState> {
  IntroduceContactsCubit(this._contactStorage)
    : super(const IntroduceContactsState(IntroduceContactsStatus.initial)) {
    _contactSubscription = _contactStorage.changeEvents.listen(
      (_) => fetchData(),
    );
  }

  final Storage<CoagContact> _contactStorage;
  late final StreamSubscription<StorageEvent<CoagContact>> _contactSubscription;

  Future<void> fetchData() async {
    final contacts = await _contactStorage.getAll();
    if (!isClosed) {
      emit(
        IntroduceContactsState(
          IntroduceContactsStatus.success,
          contacts: contacts.values.asList(),
        ),
      );
    }
  }

  Future<bool> introduce({
    required String contactIdA,
    required String nameA,
    required String contactIdB,
    required String nameB,
    String? message,
  }) async {
    try {
      // TODO(LGro): Combine locks instead of two locks? Can this be more elegant?
      return await _contactStorage.lock.synchronized(contactIdA, () async {
        return await _contactStorage.lock.synchronized(contactIdB, () async {
          final contactA = await _contactStorage.get(contactIdA);
          final contactB = await _contactStorage.get(contactIdB);

          // This should already have been prevented on the UI side, just checking
          if (!introducible(contactA, contactB) ||
              contactA == null ||
              contactB == null) {
            return false;
          }

          final (recordKeyA, writerA) = await VeilidDht().create();
          final (recordKeyB, writerB) = await VeilidDht().create();

          final sharedSecret = await generateRandomSharedSecretBest();

          await _contactStorage.set(
            contactA.coagContactId,
            contactA.copyWith(
              introductionsForThem: [
                ...contactA.introductionsForThem,
                ContactIntroduction(
                  otherName: nameB,
                  sharedSecret: sharedSecret,
                  dhtRecordKeyReceiving: recordKeyB,
                  dhtRecordKeySharing: recordKeyA,
                  dhtWriterSharing: writerA,
                  message: message,
                ),
              ],
            ),
          );
          await _contactStorage.set(
            contactB.coagContactId,
            contactB.copyWith(
              introductionsForThem: [
                ...contactB.introductionsForThem,
                ContactIntroduction(
                  otherName: nameA,
                  sharedSecret: sharedSecret,
                  dhtRecordKeyReceiving: recordKeyA,
                  dhtRecordKeySharing: recordKeyB,
                  dhtWriterSharing: writerB,
                  message: message,
                ),
              ],
            ),
          );

          return true;
        });
      });
    } catch (e) {
      // TODO: Can this fail? Do we need to try except this?
      debugPrint('Error preparing introduction: $e');
      return false;
    }
  }

  @override
  Future<void> close() {
    unawaited(_contactSubscription.cancel());
    return super.close();
  }
}
