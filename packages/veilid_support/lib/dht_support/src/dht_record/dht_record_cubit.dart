import 'dart:async';

import 'package:async_tools/async_tools.dart';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

import '../../../veilid_support.dart';

typedef InitialStateFunction<T> = Future<T?> Function(DHTRecord);
typedef StateFunction<T> = Future<T?> Function(DHTRecord, DHTRecordWatchChange);
typedef WatchFunction = Future<void> Function(DHTRecord);

abstract class DHTRecordCubit<T> extends Cubit<AsyncValue<T>> {
  DHTRecordCubit({
    required Future<DHTRecord> Function() open,
    required InitialStateFunction<T> initialStateFunction,
    required StateFunction<T> stateFunction,
    required WatchFunction watchFunction,
  }) : _wantsCloseRecord = false,
       super(const AsyncValue.loading()) {
    initWait.add((cancel) async {
      try {
        // Do record open/create
        while (!cancel.isCompleted) {
          try {
            record = await open();
            _wantsCloseRecord = true;
            break;
          } on DHTExceptionNotAvailable {
            // Wait for a bit
            await asyncSleep();
          }
        }
      } on Exception catch (e, st) {
        addError(e, st);
        emit(AsyncValue.error(e, st));
        return;
      }
      await _init(cancel, initialStateFunction, stateFunction, watchFunction);
    });
  }

  Future<void> _init(
    Completer<bool> cancel,
    InitialStateFunction<T> initialStateFunction,
    StateFunction<T> stateFunction,
    WatchFunction watchFunction,
  ) async {
    // Make initial state update
    try {
      while (!cancel.isCompleted) {
        try {
          final initialState = await initialStateFunction(record!);
          if (initialState != null) {
            emit(AsyncValue.data(initialState));
          }
          break;
        } on DHTExceptionNotAvailable {
          // Wait for a bit
          await asyncSleep();
        }
      }
    } on Exception catch (e, st) {
      addError(e, st);
      emit(AsyncValue.error(e, st));
      return;
    }

    _subscription = await record!.listen((record, change) async {
      try {
        final newState = await stateFunction(record, change);
        if (newState != null) {
          emit(AsyncValue.data(newState));
        }
      } on Exception catch (e, st) {
        addError(e, st);
        emit(AsyncValue.error(e, st));
      }
    });

    await watchFunction(record!);
  }

  @override
  Future<void> close() async {
    await initWait(cancelValue: true);
    await record?.cancelWatch();
    await _subscription?.close();
    _subscription = null;
    if (_wantsCloseRecord) {
      await record?.close();
      _wantsCloseRecord = false;
    }
    await super.close();
  }

  Future<void> ready() async {
    await initWait();
  }

  // Fields
  ////////////////////////////////////////////////////////////////////////////

  @protected
  final WaitSet<void, bool> initWait = WaitSet();

  DHTRecordWatchSubscription? _subscription;

  DHTRecord? record;

  bool _wantsCloseRecord;
}
