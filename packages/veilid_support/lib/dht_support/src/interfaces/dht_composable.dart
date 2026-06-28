import 'dart:async';

import 'package:async_tools/async_tools.dart';
import 'package:meta/meta.dart';

import '../../../veilid_support.dart';

class _StandaloneWriteHolder {
  DHTRecordTransaction? tx;
}

/// Per-collection write lock + transaction handle, scoped to the async
/// stack of the current `withWriteScope` call via a Dart Zone. Readers
/// outside the scope cannot observe the in-flight transaction or working
/// state, so concurrent reads see only committed state.
class DHTComposableSharedState {
  final Mutex _mutex = Mutex(debugLockTimeout: kIsDebugMode ? 60 : null);

  // Per-instance: nested scopes for different states don't collide.
  final Object _holderKey = Object();

  _StandaloneWriteHolder? get _holderOrNull =>
      Zone.current[_holderKey] as _StandaloneWriteHolder?;

  bool get inWriteScope => _holderOrNull != null;

  DHTRecordTransaction? get transaction => _holderOrNull?.tx;

  bool get inTransaction => transaction != null;

  Future<R> withWriteScope<R>(Future<R> Function() body) => _mutex.protect(
    () => runZoned(body, zoneValues: {_holderKey: _StandaloneWriteHolder()}),
  );

  void setTransaction(DHTRecordTransaction tx) {
    final h = _holderOrNull;
    if (h == null) {
      throw StateError('not in write scope');
    }
    if (h.tx != null) {
      throw StateError('transaction already in use');
    }
    h.tx = tx;
  }

  void clearTransaction() {
    final h = _holderOrNull;
    if (h == null) {
      throw StateError('not in write scope');
    }
    if (h.tx == null) {
      throw StateError('no transaction in use');
    }
    h.tx = null;
  }

  Future<void> close() async {
    if (!inWriteScope) {
      throw StateError('should be in write scope here');
    }
    final h = _holderOrNull!;
    final transaction = h.tx;
    h.tx = null;
    if (transaction != null) {
      DHTRecordPool.instance.log(
        '${transaction.debugName}): '
        'should not close during transaction',
      );
      await transaction.rollback();
    }
  }

  Future<T> withTransactionKey<T>(
    RecordKey key, {
    required Future<T> Function(DHTRecordTransactionOperations) closure,
  }) {
    final tx = transaction;
    if (tx == null) {
      throw StateError('no transaction in use');
    }
    return tx.withKey(key, closure: closure);
  }

  Future<void> extendTransaction(Iterable<DHTRecord> records) {
    final tx = transaction;
    if (tx == null) {
      throw StateError('no transaction in use');
    }
    return tx.extend(records);
  }
}

abstract interface class DHTComposable<R, W extends R>
    implements DebugName, DHTCloseable, DHTDeleteable {
  // Composed mode setup and refresh logic
  ////////////////////////////////////////////////////////////////////////////

  /// Switch to composed mode, allowing the collection to participate
  /// in shared transactions.
  void enterComposedMode(DHTComposableSharedState sharedState);

  /// Mark the collection as behind. Cleared on the next successful sync.
  void markNeedsRefresh();

  /// True if the collection needs a network refresh before it can be used.
  bool get needsRefresh;

  /// Bumped by [markNeedsRefresh]; lets [refresh] detect a change that landed
  /// mid-sync and re-arm needsRefresh.
  int get refreshGen;

  /// Perform a local-only reload of the collection state without network
  /// access. Called when a watched collection is modified locally.
  /// Should chain through to any child collections to perform their
  /// local reloads as well.
  /// Throws DHTExceptionNotAvailable if the collection could not be
  /// loaded from the local record store.
  Future<void> localReload();

  // Composed mode operations lifecycle
  ////////////////////////////////////////////////////////////////////////////

  /// Get the initial records to include in any transactions.
  Set<DHTRecord> operateInitialRecords();

  /// Begin the work phase of a transaction. Called after a transaction begins
  /// but before any operational closure is executed.
  void beginWork();

  /// Flush the work phase of a transaction.
  /// Writes out any changes to the current transaction in preparation for a
  /// commit.
  Future<void> flushWork();

  /// End the work phase of a transaction. Called post-transaction commit or
  /// rollback with success=true if the transaction committed.
  /// Calls through to any child collections to end their work phase.
  /// If successful, writes any 'working state' to the 'active state' of the
  /// collection to reflect the changes made during the work phase
  /// If not successful, cleans up any 'working state'.
  Future<void> endWork(bool success);

  /// Check if the collection needs a refresh, and return the closure to run
  /// to perform the refresh if not null.
  Future<Future<void> Function()?> syncCheck();

  /// Read from the collection with an optional per-element retry strategy.
  Future<T> read<T>(
    Future<T> Function(R) closure, {
    DHTRetryStrategy? elementRetry,
  });

  /// Write to the collection with an optional per-element retry strategy.
  Future<T> write<T>(
    Future<T> Function(W) closure, {
    DHTRetryStrategy? elementRetry,
  });
}

mixin DefaultDHTComposable<R, W extends R, C> implements DHTComposable<R, W> {
  @override
  bool get isOpen => _isOpen;

  bool get isComposed => _isComposed;

  @override
  @mustBeOverridden
  @mustCallSuper
  Future<bool> close() async {
    _isOpen = false;

    if (!isComposed) {
      await standaloneSharedState.withWriteScope(
        () => standaloneSharedState.close(),
      );
    }
    return true;
  }

  DHTComposableSharedState get composableSharedState => _composableSharedState;

  DHTComposableSharedState get standaloneSharedState {
    if (isComposed) {
      throw StateError('cannot get standalone interface in composed mode');
    }
    return _composableSharedState;
  }

  @override
  void enterComposedMode(DHTComposableSharedState sharedState) {
    _composableSharedState = sharedState;
    _isComposed = true;
  }

  /// Caller must already be inside withWriteScope.
  Future<T> operateWrite<T>(Future<T> Function() opClosure) async {
    final sss = standaloneSharedState;
    if (!sss.inWriteScope) {
      throw StateError('operateWrite must run inside withWriteScope');
    }

    final tBeginSw = Stopwatch();
    final tSyncCheckSw = Stopwatch();
    final tSyncRunSw = Stopwatch();
    final tOpSw = Stopwatch();
    final tFlushSw = Stopwatch();
    final tCommitSw = Stopwatch();
    final tEndWorkSw = Stopwatch();
    var attempts = 0;
    var didSync = false;

    while (true) {
      attempts++;
      tBeginSw.start();
      final tx = await DHTRecordPool.instance.transact(
        operateInitialRecords(),
        debugName: 'operateWrite($debugName)',
      );
      sss.setTransaction(tx);
      tBeginSw.stop();

      var success = false;
      try {
        beginWork();

        tSyncCheckSw.start();
        final syncClosure = await syncCheck();
        tSyncCheckSw.stop();

        if (syncClosure != null) {
          if (didSync) {
            throw const DHTExceptionOutdated(
              cause: 'still outdated after sync',
            );
          }
          tSyncRunSw.start();
          await syncClosure();
          tSyncRunSw.stop();
          await flushWork();
          await tx.commit();
          success = true;
          didSync = true;
          continue;
        }

        tOpSw.start();
        final result = await opClosure();
        tOpSw.stop();

        tFlushSw.start();
        await flushWork();
        tFlushSw.stop();

        tCommitSw.start();
        await tx.commit();
        tCommitSw.stop();
        success = true;

        DHTRecordPool.instance.log(
          'operateWrite($debugName) attempts=$attempts '
          'begin=${tBeginSw.elapsedMilliseconds}ms '
          'syncCheck=${tSyncCheckSw.elapsedMilliseconds}ms '
          'syncRun=${tSyncRunSw.elapsedMilliseconds}ms '
          'op=${tOpSw.elapsedMilliseconds}ms '
          'flush=${tFlushSw.elapsedMilliseconds}ms '
          'commit=${tCommitSw.elapsedMilliseconds}ms '
          'endWork=${tEndWorkSw.elapsedMilliseconds}ms',
        );

        return result;
      } on VeilidAPIExceptionTransactionNotFound catch (e) {
        DHTRecordPool.instance.log(
          'operateWrite: TransactionNotFound: ${e.message}',
        );
        throw DHTExceptionOutdated(cause: e.toDisplayError());
      } on Exception {
        await tx.rollback();
        rethrow;
      } finally {
        sss.clearTransaction();
        tEndWorkSw.start();
        await endWork(success);
        tEndWorkSw.stop();
      }
    }
  }

  /// Retry a read inside withWriteScope on DHTExceptionNotAvailable.
  /// Rethrows if already in scope to avoid re-entering our own write lock.
  Future<T> operateRead<T>(Future<T> Function() opClosure) async {
    try {
      return await opClosure();
    } on DHTExceptionNotAvailable {
      final sss = standaloneSharedState;
      if (sss.inWriteScope) {
        rethrow;
      }
      return await sss.withWriteScope(() => operateWrite(opClosure));
    }
  }

  /// Sync from the network only if behind ([needsRefresh]). Serialized by the
  /// write lock (withWriteScope), so callers that arrive after a successful
  /// sync find needsRefresh cleared and no-op. Re-arms needsRefresh if a change
  /// landed mid-sync (refreshGen moved).
  Future<void> refresh() async {
    final sss = standaloneSharedState;
    if (sss.inWriteScope) {
      await _refreshGated();
    } else {
      await sss.withWriteScope(_refreshGated);
    }
  }

  Future<void> _refreshGated() async {
    if (!needsRefresh) {
      return;
    }
    final gen = refreshGen;
    await _refreshSync();
    if (refreshGen != gen) {
      markNeedsRefresh();
    }
  }

  /// One-transaction sync used only by refresh: begin, syncCheck, sync if
  /// behind, commit. Unlike operateWrite there is no op, so it skips the
  /// post-sync confirm iteration — a behind refresh costs one begin, not two.
  Future<void> _refreshSync() async {
    final sss = standaloneSharedState;
    if (!sss.inWriteScope) {
      throw StateError('refresh must run inside withWriteScope');
    }

    final tBeginSw = Stopwatch()..start();
    final tx = await DHTRecordPool.instance.transact(
      operateInitialRecords(),
      debugName: 'refreshSync($debugName)',
    );
    sss.setTransaction(tx);
    tBeginSw.stop();

    final tSyncSw = Stopwatch();
    var synced = false;
    try {
      beginWork();
      tSyncSw.start();
      final syncClosure = await syncCheck();
      if (syncClosure != null) {
        await syncClosure();
        await flushWork();
        await tx.commit();
        synced = true;
      } else {
        // Already current: drop the empty transaction, no commit.
        await tx.rollback();
      }
      tSyncSw.stop();
      DHTRecordPool.instance.log(
        'refreshSync($debugName) synced=$synced '
        'begin=${tBeginSw.elapsedMilliseconds}ms '
        'sync=${tSyncSw.elapsedMilliseconds}ms',
      );
    } on VeilidAPIExceptionTransactionNotFound catch (e) {
      throw DHTExceptionOutdated(cause: e.toDisplayError());
    } on Exception {
      await tx.rollback();
      rethrow;
    } finally {
      sss.clearTransaction();
      await endWork(synced);
    }
  }

  Future<void> watch();

  Future<void> cancelWatch();

  void setUpdateCallback(void Function(C) callback) {
    _onUpdate = callback;
  }

  void sendUpdate(C update) {
    _onUpdate?.call(update);
  }

  // Fields
  ////////////////////////////////////////////////////////////////////////////

  DHTComposableSharedState _composableSharedState = DHTComposableSharedState();
  bool _isComposed = false;
  bool _isOpen = true;
  void Function(C)? _onUpdate;
}
