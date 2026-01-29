// Copyright 2024 - 2025 The Reunicorn Authors. All rights reserved.
// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

import '../../data/models/contact_update.dart';
import '../../data/repositories/contact_dht.dart';
import '../../data/services/storage/base.dart';
import '../utils.dart';

part 'state.dart';
part 'cubit.g.dart';

class UpdatesCubit extends Cubit<UpdatesState> {
  UpdatesCubit(this._updateStorage, this._contactDhtRepository)
    : super(const UpdatesState(UpdatesStatus.initial)) {
    _updateSubscription = _updateStorage.changeEvents.listen(
      (_) => fetchData(),
    );
    unawaited(fetchData());
  }

  final Storage<ContactUpdate> _updateStorage;
  final ContactDhtRepository _contactDhtRepository;
  late final StreamSubscription<StorageEvent<ContactUpdate>>
  _updateSubscription;

  Future<void> fetchData() async {
    final updates = await _updateStorage.getAll();
    if (!isClosed) {
      emit(
        UpdatesState(
          UpdatesStatus.success,
          // TODO: explicitly sort by date?
          updates: updates.values.toList().reversed.where(
            (u) => contactUpdateSummary(u.oldContact, u.newContact).isNotEmpty,
          ),
        ),
      );
    }
  }

  Future<bool> refresh() => _contactDhtRepository.updateAndWatchReceivingDHT();

  @override
  Future<void> close() {
    unawaited(_updateSubscription.cancel());
    return super.close();
  }
}
