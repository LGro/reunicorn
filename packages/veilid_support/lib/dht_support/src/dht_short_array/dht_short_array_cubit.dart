import 'dart:async';

import 'package:async_tools/async_tools.dart';
import 'package:bloc/bloc.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';

import '../../../veilid_support.dart';

typedef DHTShortArrayState<T> = AsyncValue<IList<OnlineElementState<T>>>;
typedef DHTShortArrayCubitState<T> = DHTShortArrayState<T>;

class DHTShortArrayCubit<T> extends Cubit<DHTShortArrayCubitState<T>>
    with RefreshableCubit {
  final WaitSet<void, bool> _initWait = WaitSet();

  late final DHTShortArray _shortArray;

  final MigrationCodec<T> migrationCodec;

  // Optional per-element in-tx retry override; null uses the collection default.
  final DHTRetryStrategy? _elementRetry;

  StreamSubscription<void>? _subscription;

  var _wantsCloseRecord = false;

  final _sspUpdate = SingleStatelessProcessor();

  DHTShortArrayCubit({
    required Future<DHTShortArray> Function() open,
    required this.migrationCodec,
    DHTRetryStrategy? elementRetry,
  }) : _elementRetry = elementRetry,
       super(const AsyncValue.loading()) {
    _initWait.add((cancel) async {
      try {
        // Do record open/create
        while (!cancel.isCompleted) {
          try {
            // Open DHT record
            _shortArray = await open();
            _wantsCloseRecord = true;
            break;
          } on DHTExceptionNotAvailable {
            // Wait for a bit
            await asyncSleep();
          }
        }

        // Emit local-cache data first so we have a usable (offline-first) state.
        _update(null);

        // Subscribe to changes. listen() establishes the watch and does a
        // best-effort initial network refresh — it no longer throws on a
        // transient offline condition, so this does not block or loop.
        _subscription = await _shortArray.listen(_update);

        // Drive catch-up refreshes when the array is behind.
        startRefreshDriver();
      } on Exception catch (e, st) {
        addError(e, st);
        emit(AsyncValue.error(e, st));
        return;
      }
    });
  }

  @override
  bool get collectionNeedsRefresh => _shortArray.needsRefresh;

  @override
  Future<void> refresh() async {
    await _initWait();
    // SYNC from network first, then re-read from cache
    try {
      await _shortArray.refresh();
    } on DHTExceptionNotAvailable {
      return; // needsRefresh stays true; driver retries
    } on DHTExceptionOutdated {
      return; // transient: a transaction lost consensus; driver retries
    }
    await _readStateInner();
  }

  /// Read current state from local cache only — no network access.
  /// Called by _update (watch-driven) and after explicit refresh().
  /// Concurrent calls are serialized at the SSP level.
  Future<void> _readStateInner() async {
    try {
      final newState = await _shortArray.operateRead((reader) async {
        // If this is writeable get the offline positions
        Set<int>? offlinePositions;
        if (_shortArray.writer != null) {
          offlinePositions = await reader.getOfflinePositions();
        }

        // Get the items — local cache only
        final allItems = (await reader.getRange(0)).indexed
            .map(
              (x) => OnlineElementState(
                value: migrationCodec.fromBytes(x.$2).value,
                isOffline: offlinePositions?.contains(x.$1) ?? false,
              ),
            )
            .toIList();
        return allItems;
      }, elementRetry: _elementRetry);
      emit(AsyncValue.data(newState));
    } on DHTExceptionNotAvailable {
      return; // collection needsRefresh stays set; driver retries
    } on DHTExceptionOutdated {
      return; // transient: a transaction lost consensus; driver retries
    } on Exception catch (e, st) {
      addError(e, st);
      emit(AsyncValue.error(e, st));
    }
  }

  void _update(void update) {
    // Run at most one background update process
    // Because this is async, we could get an update while we're
    // still processing the last one.
    // Only called after init future has run, or during it
    // so we dont have to wait for that here.
    _sspUpdate.update(_readStateInner);
  }

  @override
  Future<void> close() async {
    await _initWait(cancelValue: true);
    await closeRefreshDriver();
    await _subscription?.cancel();
    _subscription = null;
    if (_wantsCloseRecord) {
      await _shortArray.close();
    }
    await super.close();
  }

  Future<R> operateRead<R>(
    Future<R> Function(DHTShortArrayReadOperations) closure, {
    DHTRetryStrategy? elementRetry,
  }) async {
    await _initWait();
    return _shortArray.operateRead(closure, elementRetry: elementRetry ?? _elementRetry);
  }

  Future<R> operateWrite<R>(
    Future<R> Function(DHTShortArrayWriteOperations) closure, {
    DHTRetryStrategy? elementRetry,
  }) async {
    await _initWait();
    return _shortArray.operateWrite(closure, elementRetry: elementRetry ?? _elementRetry);
  }

  Future<R> operateWriteEventual<R>(
    Future<R> Function(DHTShortArrayWriteOperations) closure, {
    Duration? timeout,
    DHTRetryStrategy? elementRetry,
  }) async {
    await _initWait();
    return _shortArray.operateWriteEventual(
      closure,
      timeout: timeout,
      elementRetry: elementRetry ?? _elementRetry,
    );
  }
}
