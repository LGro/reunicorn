import 'dart:async';

import 'package:async_tools/async_tools.dart';

import '../../../veilid_support.dart';

/// Default in-place retry window for a single in-transaction element get/set (matches the safety-routed tx timeout).
const kDefaultElementRetryTimeout = Duration(seconds: 10);

/// Minimal interface for a DHT collection
///
/// Type parameters:
/// R: Read operations type
/// W: Write operations type
/// C: Change/Update notification type
abstract interface class DHTCollection<R, W extends R, C>
    implements DHTDeleteable, DHTRefCounted, DebugName {
  /// Check if the collection needs a network refresh before it can be
  /// used. If there is a locally valid cached state this always
  /// returns false.
  bool get needsRefresh;

  /// Transactionally sync the collection from the network
  /// Useful if you aren't 'watching' the collection and want to
  /// poll for an update
  Future<void> refresh();

  /// Runs a closure allowing read-only access to the log
  Future<T> operateRead<T>(
    Future<T> Function(R) closure, {
    DHTRetryStrategy? elementRetry,
  });

  /// Runs a closure allowing append/truncate access to the log.
  /// Each write method inside the closure runs its own plan→tx→commit
  /// lifecycle via standaloneWrite, including sync-before-write.
  Future<T> operateWrite<T>(
    Future<T> Function(W) closure, {
    DHTRetryStrategy? elementRetry,
  });

  /// Runs a closure allowing append/truncate access to the log.
  /// Repeats the closure until a consistent write is achieved.
  /// Timeout if specified will be thrown as a TimeoutException.
  Future<T> operateWriteEventual<T>(
    Future<T> Function(W) closure, {
    Duration? timeout,
    DHTRetryStrategy? elementRetry,
  });

  /// Listen to and any all changes to the structure of this collection
  /// regardless of where the changes are coming from
  Future<StreamSubscription<void>> listen(void Function(C) onChanged);
}

/// Base class providing the default implementation of the minimal
/// interface for a DHT collection.
abstract class DefaultDHTCollection<
  I extends DefaultDHTComposable<R, W, C>,
  R,
  W extends R,
  C
>
    implements DHTCollection<R, W, C> {
  DefaultDHTCollection({required I inner}) : _inner = inner;

  /// Get the composable interface for this collection.
  /// Used by outer collections to participate in shared transactions
  /// while in composed mode.
  DHTComposable<R, W> composable() => _inner;

  /// Inner composable implementation
  final I _inner;

  /// Watch mutex to ensure we keep the representation valid
  final _listenMutex = Mutex(debugLockTimeout: kIsDebugMode ? 60 : null);

  /// Stream of external changes
  StreamController<C>? _watchController;

  ////////////////////////////////////////////////////////////////////////////
  // DHTCloseable

  // Start in the 'opened' state with one reference
  int _openCount = 1;

  @override
  void ref() {
    _openCount++;
  }

  @override
  bool get isOpen => _openCount > 0;

  /// Inlined from DefaultDHTRefCounted.close()
  Future<bool> _refClose() async {
    if (_openCount == 0) {
      throw StateError('$debugName is already closed');
    }
    _openCount--;
    if (_openCount != 0) {
      return false;
    }

    return true;
  }

  /// Free all resources for the collection
  @override
  Future<bool> close() => DHTException.wrap(() async {
    if (!await _refClose()) {
      return false;
    }

    await _watchController?.close();
    _watchController = null;
    await _inner.close();
    return true;
  });

  ////////////////////////////////////////////////////////////////////////////
  // DHTDeleteable

  bool _isDeleted = false;

  @override
  Future<bool> delete() => DHTException.wrap(() async {
    if (isDeleted) {
      return true;
    }
    if (!isOpen) {
      throw StateError('$debugName must be deleted before close');
    }
    _isDeleted = true;
    return await _inner.delete();
  });

  @override
  bool get isDeleted => _isDeleted;

  /// Transactionally sync the collection from the network
  /// Useful if you aren't 'watching' the collection and want to
  /// poll for an update

  @override
  Future<void> refresh() => DHTException.wrap(() async {
    if (!isOpen || isDeleted) {
      throw StateError('collection is not open');
    }

    try {
      // refresh() self-manages the write lock and the needsRefresh gate.
      await _inner.refresh();
    } on Exception catch (e, st) {
      DHTRecordPool.instance.log('$debugName: refresh failed: $e\n$st');
      rethrow;
    }
  });

  /// Default element retry: bounded in-place re-query for one in-tx element op.
  DHTRetryStrategy get _defaultElementRetry => DHTRetryStrategy.logged(
    '$debugName element',
    timeout: kDefaultElementRetryTimeout,
  );

  /// Runs a closure allowing read-only access to the log
  @override
  Future<T> operateRead<T>(
    Future<T> Function(R) closure, {
    DHTRetryStrategy? elementRetry,
  }) {
    if (!isOpen || isDeleted) {
      throw StateError('collection is not open');
    }

    return _inner.read(
      closure,
      elementRetry: elementRetry ?? _defaultElementRetry,
    );
  }

  /// Runs a closure allowing append/truncate access to the log.
  /// Each write method inside the closure runs its own plan→tx→commit
  /// lifecycle via standaloneWrite, including sync-before-write.
  @override
  Future<T> operateWrite<T>(
    Future<T> Function(W) closure, {
    DHTRetryStrategy? elementRetry,
  }) {
    if (!isOpen || isDeleted) {
      throw StateError('DHTLog is not open');
    }

    return _inner.standaloneSharedState.withWriteScope(() async {
      return _inner.write(
        closure,
        elementRetry: elementRetry ?? _defaultElementRetry,
      );
    });
  }

  /// Runs a closure allowing append/truncate access to the log.
  /// Repeats the closure until a consistent write is achieved.
  /// Timeout if specified will be thrown as a TimeoutException.
  @override
  Future<T> operateWriteEventual<T>(
    Future<T> Function(W) closure, {
    Duration? timeout,
    DHTRetryStrategy? elementRetry,
  }) {
    if (!isOpen || isDeleted) {
      throw StateError('DHTLog is not open');
    }

    // Retry only `outdated` (a write that lost to a newer value: the
    // transaction rolled back, so re-running is safe). Do NOT retry
    // `notAvailable` here: an append is not idempotent, and re-running a
    // possibly-partially-applied write would duplicate/corrupt elements. Let
    // it bubble to the caller's network-gated retry (begin-time contention is
    // handled pre-commit by the VeilidAPI-level retry).
    return _inner.standaloneSharedState.withWriteScope(
      () => DHTRecordPool.instance.retry(
        () => _inner.write(
          closure,
          elementRetry: elementRetry ?? _defaultElementRetry,
        ),
        strategy: DHTRetryStrategy(
          notAvailableRetry: (_) async => false,
          timeout: timeout,
        ),
      ),
    );
  }

  /// Listen to and any all changes to the structure of this log
  /// regardless of where the changes are coming from
  @override
  Future<StreamSubscription<void>> listen(
    void Function(C) onChanged,
  ) => DHTException.wrap(() {
    if (!isOpen || isDeleted) {
      throw StateError('collection is not open');
    }
    if (_inner.isComposed) {
      throw StateError('cannot listen in composed mode');
    }

    return _listenMutex.protect(() async {
      // If don't have a controller yet, set it up
      if (_watchController == null) {
        // Set up watch requirements
        _watchController = StreamController<C>.broadcast(
          onCancel: () {
            // If there are no more listeners then we can get
            // rid of the controller and drop our subscriptions
            unawaited(
              _listenMutex.protect(() async {
                // Cancel watches of head record
                await _inner.cancelWatch();
                _watchController = null;
              }),
            );
          },
        );

        // Register an update callback with the inner collection
        // Note that we don't need to unregister the callback because
        // this is an idempotent operation and clearing _watchController
        // is sufficient to ensure this does nothing
        _inner.setUpdateCallback((update) {
          _watchController?.sink.add(update);
        });

        try {
          // Watch first so updates during refresh aren't missed. The watch is
          // local (flag-based) and offline-safe.
          await _inner.watch();
          // Initial refresh is best-effort: catch up pre-listen remote changes
          // when online, but offline-first launch must still establish the
          // watch and return. A transient leaves the local-cache view in place;
          // the head watch refreshes on the next remote change once online.
          try {
            await refresh();
          } on DHTExceptionNotAvailable {
            // offline — keep the watch, serve local cache
          } on DHTExceptionOutdated {
            // a transaction lost consensus — keep the watch, retry later
          }
        } on Exception {
          await _inner.cancelWatch();
          await _watchController?.close();
          _watchController = null;
          rethrow;
        }
      }
      // Return subscription
      return _watchController!.stream.listen((upd) => onChanged(upd));
    });
  });
}
