// Copyright 2024 - 2025 The Reunicorn Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:veilid/veilid.dart';
import '../../data/repositories/backup_dht.dart';

part 'cubit.g.dart';
part 'state.dart';

class RestoreCubit extends Cubit<RestoreState> {
  RestoreCubit(this._backupRepository) : super(const RestoreState());

  final BackupRepository _backupRepository;

  Future<void> restore(RecordKey recordKey, SharedSecret secret) async {
    emit(const RestoreState(status: RestoreStatus.create));

    final result = await _backupRepository.restore(recordKey, secret);

    if (!isClosed) {
      emit(
        RestoreState(
          status: result ? RestoreStatus.success : RestoreStatus.failure,
        ),
      );
    }
  }
}
