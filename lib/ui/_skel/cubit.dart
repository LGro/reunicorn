// Copyright 2024 - 2025 The Reunicorn Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

import '../../data/models/coag_contact.dart';
import '../../data/services/storage/base.dart';

part 'state.dart';
part 'cubit.g.dart';

class SkelCubit extends Cubit<SkelState> {
  SkelCubit(this._contactStorage) : super(const SkelState(SkelStatus.initial)) {
    _contactSubscription = _contactStorage.changeEvents.listen(
      (_) => fetchData(),
    );

    unawaited(fetchData());
  }

  Future<void> fetchData() async {
    final contacts = await _contactStorage.getAll();
    if (!isClosed) {
      emit(SkelState(SkelStatus.success, contacts: contacts));
    }
  }

  final Storage<CoagContact> _contactStorage;
  late final StreamSubscription<StorageEvent<CoagContact>> _contactSubscription;

  @override
  Future<void> close() {
    unawaited(_contactSubscription.cancel());
    return super.close();
  }
}
