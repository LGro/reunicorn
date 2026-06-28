import 'dart:async';
import 'dart:math';
import 'dart:typed_data';

import 'package:async_tools/async_tools.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:meta/meta.dart';

import '../../../veilid_support.dart';

@immutable
class DHTLogStateData<T> extends Equatable {
  // The total number of elements in the whole log
  final int length;

  // The view window of the elements in the dhtlog
  // Span is from [tail - window.length, tail)
  final IList<OnlineElementState<T>> window;

  // The position of the view window, one past the last element
  final int windowTail;

  // The total number of elements to try to keep in the window
  final int windowSize;

  // If we have the window following the log
  final bool follow;

  const DHTLogStateData({
    required this.length,
    required this.window,
    required this.windowTail,
    required this.windowSize,
    required this.follow,
  });

  @override
  List<Object?> get props => [length, window, windowTail, windowSize, follow];

  @override
  String toString() =>
      'DHTLogStateData('
      'length: $length, '
      'windowTail: $windowTail, '
      'windowSize: $windowSize, '
      'follow: $follow, '
      'window: ${DynamicDebug.toDebug(window)})';
}

typedef DHTLogState<T> = AsyncValue<DHTLogStateData<T>>;
typedef DHTLogBusyState<T> = DHTLogState<T>;

class DHTLogCubit<T> extends Cubit<DHTLogBusyState<T>> with RefreshableCubit {
  final WaitSet<void, bool> _initWait = WaitSet();

  late final DHTLog _log;

  final T Function(Uint8List data) _decodeElement;

  // Optional per-element in-tx retry override; null uses the collection default.
  final DHTRetryStrategy? _elementRetry;

  StreamSubscription<void>? _subscription;

  var _wantsCloseRecord = false;

  final _sspUpdate = SingleStatelessProcessor();

  // Accumulated deltas since last update
  var _headDelta = 0;

  var _tailDelta = 0;

  // Cubit window into the DHTLog
  var _windowTail = 0;

  var _windowSize = DHTShortArray.maxElements;

  var _follow = true;

  DHTLogCubit({
    required Future<DHTLog> Function() open,
    required T Function(Uint8List data) decodeElement,
    DHTRetryStrategy? elementRetry,
  }) : _decodeElement = decodeElement,
       _elementRetry = elementRetry,
       super(const AsyncValue.loading()) {
    _initWait.add((cancel) async {
      try {
        // Do record open/create
        while (!cancel.isCompleted) {
          try {
            // Open DHT record
            _log = await open();
            _wantsCloseRecord = true;
            break;
          } on DHTExceptionNotAvailable {
            // Wait for a bit
            await asyncSleep();
          }
        }

        // Emit local-cache data first so we have a usable (offline-first) state.
        _initialUpdate();

        // Subscribe to changes. listen() establishes the watch and does a
        // best-effort initial network refresh — it no longer throws on a
        // transient offline condition, so this does not block or loop.
        _subscription = await _log.listen(_update);

        // Drive catch-up refreshes when the log is behind.
        startRefreshDriver();
      } on Exception catch (e, st) {
        addError(e, st);
        emit(AsyncValue.error(e, st));
        return;
      }
    });
  }

  // Set the tail position of the log for pagination.
  // If tail is 0, the end of the log is used.
  // If tail is negative, the position is subtracted from the current log
  // length.
  // If tail is positive, the position is absolute from the head of the log
  // If follow is enabled, the tail offset will update when the log changes
  Future<void> setWindow({
    int? windowTail,
    int? windowSize,
    bool? follow,
  }) async {
    await _initWait();
    if (windowTail != null) {
      _windowTail = windowTail;
    }
    if (windowSize != null) {
      _windowSize = windowSize;
    }
    if (follow != null) {
      _follow = follow;
    }
    await _refreshInner();
  }

  @override
  bool get collectionNeedsRefresh => _log.needsRefresh;

  @override
  Future<void> refresh() async {
    await _initWait();
    // Network sync (gated on needsRefresh); then re-read the window from cache.
    try {
      await _log.refresh();
    } on DHTExceptionNotAvailable {
      return; // needsRefresh stays true; driver retries
    } on DHTExceptionOutdated {
      return;
    }
    await _refreshInner();
  }

  Future<void> _refreshInner() async {
    late final int length;
    final (int, IList<OnlineElementState<T>>)? windowElements;
    try {
      windowElements = await _log.operateRead((reader) {
        length = reader.length;
        return _loadElementsFromReader(reader, _windowTail, _windowSize);
      }, elementRetry: _elementRetry);
    } on DHTExceptionNotAvailable {
      // Transient: collection needsRefresh stays set; driver retries
      return;
    } on DHTExceptionOutdated {
      // Transient: a transaction lost consensus; driver retries
      return;
    }
    if (windowElements == null) {
      return;
    }

    emit(
      AsyncValue.data(
        DHTLogStateData(
          length: length,
          window: windowElements.$2,
          windowTail: windowElements.$1 + windowElements.$2.length,
          windowSize: windowElements.$2.length,
          follow: _follow,
        ),
      ),
    );
  }

  // Tail is one past the last element to load
  Future<(int, IList<OnlineElementState<T>>)?> _loadElementsFromReader(
    DHTLogReadOperations reader,
    int tail,
    int count,
  ) async {
    final length = reader.length;
    final end = ((tail - 1) % length) + 1;
    final start = (count < end) ? end - count : 0;
    if (length == 0) {
      return (start, IList<OnlineElementState<T>>.empty());
    }

    // If this is writeable get the offline positions
    Set<int>? offlinePositions;
    if (_log.writer != null) {
      offlinePositions = await reader.getOfflinePositions();
    }

    // Read elements in chunks respecting getRangeLimit
    final totalLen = end - start;
    final allData = <Uint8List>[];
    var pos = start;
    var remaining = totalLen;
    while (remaining > 0) {
      final limit = reader.getRangeLimit(pos);
      final chunkLen = min(remaining, limit);
      if (chunkLen == 0) {
        // Can't read any more — return what we have or null
        break;
      }
      try {
        final chunk = await reader.getRange(
          pos,
          length: chunkLen,
        );
        allData.addAll(chunk);
      } on DHTExceptionNotAvailable {
        // Data not available — return what we have so far or null
        break;
      }
      pos += chunkLen;
      remaining -= chunkLen;
    }

    if (allData.isEmpty && totalLen > 0) {
      return null;
    }

    final allItems = allData.indexed
        .map(
          (x) => OnlineElementState(
            value: _decodeElement(x.$2),
            isOffline: offlinePositions?.contains(x.$1 + start) ?? false,
          ),
        )
        .toIList();

    return (start, allItems);
  }

  void _update(DHTLogUpdate upd) {
    // Run at most one background update process
    // Because this is async, we could get an update while we're
    // still processing the last one. Only called after init future has run
    // or during it, so we dont have to wait for that here.

    // Accumulate head and tail deltas
    _headDelta += upd.headDelta;
    _tailDelta += upd.tailDelta;

    _sspUpdate.update(() async {
      // apply follow
      if (_follow) {
        if (_windowTail <= 0) {
          // Negative tail is already following tail changes
        } else {
          // Positive tail is measured from the head, so apply deltas
          _windowTail = (_windowTail + _tailDelta - _headDelta) % upd.length;
        }
      } else {
        if (_windowTail <= 0) {
          // Negative tail is following tail changes so apply deltas
          var posTail = _windowTail + upd.length;
          posTail = (posTail + _tailDelta - _headDelta) % upd.length;
          _windowTail = posTail - upd.length;
        } else {
          // Positive tail is measured from head so not following tail
        }
      }
      _headDelta = 0;
      _tailDelta = 0;

      await _refreshInner();
    });
  }

  void _initialUpdate() {
    _sspUpdate.update(_refreshInner);
  }

  @override
  Future<void> close() async {
    await _initWait(cancelValue: true);
    await closeRefreshDriver();
    await _subscription?.cancel();
    _subscription = null;
    if (_wantsCloseRecord) {
      await _log.close();
    }
    await super.close();
  }

  Future<R> operateRead<R>(
    Future<R> Function(DHTLogReadOperations) closure, {
    DHTRetryStrategy? elementRetry,
  }) async {
    await _initWait();
    return _log.operateRead(closure, elementRetry: elementRetry ?? _elementRetry);
  }

  Future<R> operateWrite<R>(
    Future<R> Function(DHTLogWriteOperations) closure, {
    DHTRetryStrategy? elementRetry,
  }) async {
    await _initWait();
    return _log.operateWrite(closure, elementRetry: elementRetry ?? _elementRetry);
  }

  Future<R> operateWriteEventual<R>(
    Future<R> Function(DHTLogWriteOperations) closure, {
    Duration? timeout,
    DHTRetryStrategy? elementRetry,
  }) async {
    await _initWait();
    return _log.operateWriteEventual(
      closure,
      timeout: timeout,
      elementRetry: elementRetry ?? _elementRetry,
    );
  }
}
