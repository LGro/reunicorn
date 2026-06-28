import 'dart:async';
import 'dart:typed_data';

import 'package:async_tools/async_tools.dart';
import 'package:buffer/buffer.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';

import 'config.dart';
import 'table_db.dart';
import 'veilid_log.dart';

const _ksfSyncAdd = 'ksfSyncAdd';
// Backoff before re-arming a no-progress pass, so a closure that persistently
// returns 0 (e.g. after cancellation) can't spin the processor and starve the
// event loop.
const _kZeroProgressBackoff = Duration(milliseconds: 250);

class PersistentQueue<T> with TableDBBackedFromBuffer<IList<T>> {
  final String _table;
  final String _key;
  final T Function(Uint8List) _fromBuffer;
  final Uint8List Function(T) _toBuffer;
  bool deleteOnClose;
  final WaitSet<void, void> _initWait = WaitSet();
  final _queueMutex = Mutex(debugLockTimeout: kIsDebugMode ? 60 : null);
  var _queue = IList<T>.empty();
  final Future<int> Function(IList<T>) _closure;
  final void Function(Object, StackTrace)? _onError;
  Completer<void>? _queueDoneCompleter;
  // Set the moment close() is called: rejects further adds (use-after-close is
  // invalid) and stops _process self-re-arming so the close() drain loop drives
  // processing to completion instead.
  var _closed = false;
  // Trigger stream: a 'true' event re-arms _process. The processor tolerates
  // re-arms fired from within _process, so a plain async controller is fine.
  final StreamController<bool> _queueReady = StreamController<bool>();
  final _sspQueueReady = SingleStateProcessor<bool>();
  // Broadcast notifier for any change to _queue (load, add, partial-commit
  // shrink). Lets owning cubits re-render when the queue changes shape so
  // the user sees pending items as soon as they're loaded from disk.
  final StreamController<void> _changes = StreamController<void>.broadcast();

  /// [closure] processes the supplied items in order from the front of the
  /// queue. It must return the number of items that were committed (i.e.
  /// successfully written downstream); only that prefix is removed from the
  /// queue. Returning less than the input length leaves the remainder for
  /// the next process tick. Throwing leaves the entire batch in place.
  PersistentQueue({
    required String table,
    required String key,
    required T Function(Uint8List) fromBuffer,
    required Uint8List Function(T) toBuffer,
    required Future<int> Function(IList<T>) closure,
    this.deleteOnClose = false,
    void Function(Object, StackTrace)? onError,
  }) : _table = table,
       _key = key,
       _fromBuffer = fromBuffer,
       _toBuffer = toBuffer,
       _closure = closure,
       _onError = onError {
    _initWait.add(_init);
  }

  Future<void> close() async {
    // Reject any further adds immediately — using the queue after close() is invalid.
    _closed = true;

    // Ensure the init finished
    await _initWait();

    // Finish all sync adds already queued before close()
    await serialFutureClose((this, _ksfSyncAdd));

    // Flush processing: drain the queue (run the closure on all remaining
    // items) before tearing down. Quiesce the async processor first so we
    // don't run _process concurrently with it, then drain until empty or a
    // pass makes no progress — so a closure that can't make headway (e.g.
    // offline) doesn't block close(); the remainder stays persisted.
    await _sspQueueReady.pause();
    while (_queue.isNotEmpty) {
      final before = _queue.length;
      await _process();
      if (_queue.length >= before) {
        break;
      }
    }

    // Stop the processing trigger
    await _sspQueueReady.close();
    await _queueReady.close();
    await _changes.close();

    // No more queue actions
    await _queueMutex.acquire();

    // Clean up table if desired
    if (deleteOnClose) {
      await delete();
    }
  }

  /// Fires whenever [_queue] changes (load, add, partial-commit shrink).
  Stream<void> get changes => _changes.stream;

  Future<void> get waitEmpty async {
    // Ensure the init finished
    await _initWait();

    if (_queue.isEmpty) {
      return;
    }
    final completer = Completer<void>();
    _queueDoneCompleter = completer;
    await completer.future;
  }

  Future<void> _init(Completer<void> _) async {
    // Start the processor
    _sspQueueReady.follow(_queueReady.stream, true, (more) async {
      await _initWait();
      if (more) {
        await _process();
      }
    });

    // Load the queue if we have one
    try {
      await _queueMutex.protect(() async {
        _queue = await load() ?? await store(IList<T>.empty());
        _sendUpdateEventsInner();
      });
    } on Exception catch (e, st) {
      if (_onError != null) {
        _onError(e, st);
      } else {
        rethrow;
      }
    }
  }

  void _sendUpdateEventsInner() {
    assert(_queueMutex.isLocked, 'must be locked');
    if (!_changes.isClosed) {
      _changes.sink.add(null);
    }
    if (_queue.isNotEmpty) {
      if (!_queueReady.isClosed) {
        _queueReady.sink.add(true);
      }
    } else {
      _queueDoneCompleter?.complete();
    }
  }

  Future<void> _updateQueueInner(IList<T> newQueue) async {
    _queue = await store(newQueue);
    _sendUpdateEventsInner();
  }

  Future<void> add(T item) async {
    _checkNotClosed();
    await _addInner(item);
  }

  Future<void> addAll(Iterable<T> items) async {
    _checkNotClosed();
    await _addAllInner(items);
  }

  // Internal add paths with no closed-check, so addSync/addAllSync work that
  // was queued before close() still completes when serialFutureClose drains it.
  Future<void> _addInner(T item) async {
    await _initWait();
    await _queueMutex.protect(() async {
      final newQueue = _queue.add(item);
      await _updateQueueInner(newQueue);
    });
  }

  Future<void> _addAllInner(Iterable<T> items) async {
    await _initWait();
    await _queueMutex.protect(() async {
      final newQueue = _queue.addAll(items);
      await _updateQueueInner(newQueue);
    });
  }

  void addSync(T item) {
    _checkNotClosed();
    serialFuture((this, _ksfSyncAdd), () async {
      await _addInner(item);
    });
  }

  void addAllSync(Iterable<T> items) {
    _checkNotClosed();
    serialFuture((this, _ksfSyncAdd), () async {
      await _addAllInner(items);
    });
  }

  void _checkNotClosed() {
    if (_closed) {
      throw StateError('PersistentQueue used after close()');
    }
  }

  Future<void> pause() async {
    await _sspQueueReady.pause();
  }

  Future<void> resume() async {
    await _sspQueueReady.resume();
  }

  Future<void> _process() async {
    var committed = 0;
    try {
      // Take a copy of the current queue
      // (doesn't need queue mutex because this is a sync operation)
      final toProcess = _queue;
      if (toProcess.isEmpty) {
        return;
      }

      // Run the processing closure. The closure returns the number of items
      // it committed; anything past that stays in the queue for next tick.
      final reported = await _closure(toProcess);
      committed = reported.clamp(0, toProcess.length);
    } on Exception catch (e, sp) {
      // Closure threw before reporting committed count: remove nothing.
      if (_onError != null) {
        _onError(e, sp);
      } else {
        rethrow;
      }
    }

    if (committed > 0) {
      await _queueMutex.protect(() async {
        // Re-read the queue: items could have been added during processing.
        final newQueue = _queue.skip(committed).toIList();
        await _updateQueueInner(newQueue);
      });
    }

    // If items remain (closure committed only a prefix or threw mid-batch),
    // re-arm the processor to try again. On a no-progress pass (committed == 0)
    // back off first so a persistently-zero closure can't spin and starve the
    // event loop.
    if (_queue.isNotEmpty && !_queueReady.isClosed && !_closed) {
      if (committed == 0) {
        await Future<void>.delayed(_kZeroProgressBackoff);
        if (_queueReady.isClosed || _closed) {
          return;
        }
      }
      _queueReady.sink.add(true);
    }
  }

  IList<T> get queue => _queue;

  // TableDBBacked
  @override
  String tableKeyName() => _key;

  @override
  String tableName() => _table;

  @override
  IList<T> valueFromBuffer(Uint8List bytes) {
    var out = IList<T>();
    try {
      final reader = ByteDataReader()..add(bytes);
      while (reader.remainingLength != 0) {
        final count = reader.readUint32();
        final bytes = reader.read(count);
        try {
          final item = _fromBuffer(bytes);
          out = out.add(item);
        } on Exception catch (e, st) {
          veilidLoggy.debug(
            'Dropping invalid item from persistent queue: $bytes\n'
            'tableName=${tableName()}:tableKeyName=${tableKeyName()}\n',
            e,
            st,
          );
        }
      }
    } on Exception catch (e, st) {
      veilidLoggy.debug(
        'Dropping remainder of invalid persistent queue\n'
        'tableName=${tableName()}:tableKeyName=${tableKeyName()}\n',
        e,
        st,
      );
    }
    return out;
  }

  @override
  Uint8List valueToBuffer(IList<T> val) {
    final writer = ByteDataWriter();
    for (final elem in val) {
      final bytes = _toBuffer(elem);
      final count = bytes.lengthInBytes;
      writer
        ..writeUint32(count)
        ..write(bytes);
    }
    return writer.toBytes();
  }
}
