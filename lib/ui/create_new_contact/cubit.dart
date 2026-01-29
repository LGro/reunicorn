// Copyright 2025 - 2026 The Reunicorn Authors. All rights reserved.
// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:async';
import 'dart:typed_data';

import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:uuid/uuid.dart';
import 'package:vodozemac/vodozemac.dart' as vod;

import '../../data/models/models.dart';
import '../../data/utils.dart';

part 'cubit.freezed.dart';
part 'cubit.g.dart';
part 'state.dart';

class CreateNewContactCubit extends Cubit<CreateNewContactState> {
  CreateNewContactCubit() : super(const CreateNewContactState()) {
    unawaited(initializeContact());
  }

  Future<void> initializeContact() async {
    final contact = CoagContact(
      coagContactId: Uuid().v4(),
      name: '',
      myIdentity: await generateKeyPairBest(),
      myIntroductionKeyPair: await generateKeyPairBest(),
      connectionCrypto: CryptoState.symmetric(
        sharedSecret: await generateRandomSharedSecretBest(),
        accountVod: (vod.Account()..generateOneTimeKeys(1)).toPickleEncrypted(
          Uint8List(32),
        ),
      ),
    );
    if (!isClosed) {
      emit(state.copyWith(contact: contact));
    }
  }
}
