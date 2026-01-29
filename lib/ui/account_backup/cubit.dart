// Copyright 2024 - 2025 The Reunicorn Authors. All rights reserved.
// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:veilid/veilid.dart';
import '../../data/repositories/backup_dht.dart';

part 'cubit.g.dart';
part 'state.dart';

class BackupCubit extends Cubit<BackupState> {
  BackupCubit(this._backupRepository) : super(const BackupState());

  final BackupRepository _backupRepository;

  Future<void> backup() async {
    emit(const BackupState(status: BackupStatus.create));

    final result = await _backupRepository.backup();

    if (!isClosed) {
      if (result == null) {
        emit(const BackupState(status: BackupStatus.failure));
      } else {
        emit(
          BackupState(
            status: BackupStatus.success,
            dhtRecordKey: result.$1,
            secret: result.$2,
          ),
        );
      }
    }
  }
}
