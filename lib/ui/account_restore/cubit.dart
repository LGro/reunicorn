// Copyright 2024 - 2026 The Reunicorn Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:veilid/veilid.dart';
import '../../data/repositories/backup_dht.dart';
import '../../veilid_processor/veilid_processor.dart';

part 'cubit.freezed.dart';
part 'cubit.g.dart';
part 'state.dart';

class RestoreCubit extends Cubit<RestoreState> {
  final BackupRepository _backupRepository;

  RestoreCubit(this._backupRepository)
    : super(const RestoreState(status: RestoreStatus.attaching)) {
    ProcessorRepository.instance.streamProcessorConnectionState().listen(
      _veilidConnectionStateChangeCallback,
    );
  }

  void _veilidConnectionStateChangeCallback(ProcessorConnectionState event) {
    if (state.status.isAttaching &&
        event.isPublicInternetReady &&
        event.isAttached) {
      if (!isClosed) {
        emit(state.copyWith(status: RestoreStatus.ready));
      }
    }
    if (!state.status.isAttaching &&
        !event.isPublicInternetReady &&
        !event.isAttached) {
      if (!isClosed) {
        emit(state.copyWith(status: RestoreStatus.attaching));
      }
    }
  }

  Future<void> restore(RecordKey recordKey, SharedSecret secret) async {
    emit(const RestoreState(status: RestoreStatus.restoring));

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
