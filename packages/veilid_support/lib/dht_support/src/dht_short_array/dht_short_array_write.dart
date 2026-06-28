part of 'dht_short_array.dart';

////////////////////////////////////////////////////////////////////////////
// Writer operations interface

abstract class DHTShortArrayWriteOperations
    implements
        DHTShortArrayReadOperations,
        DHTRandomSwap,
        DHTRandomWrite,
        DHTInsertRemove,
        DHTAdd,
        DHTTruncate,
        DHTClear {}

////////////////////////////////////////////////////////////////////////////
// Composed writer — the core write implementation.
// Expects _workingState and a transaction to already be set.
// Does NOT call standaloneWrite — it just does the work directly.

class _DHTShortArrayComposedWrite extends _DHTShortArrayComposedRead
    implements DHTShortArrayWriteOperations {
  _DHTShortArrayComposedWrite._(super.head, super.elementRetry) : super._();

  // Lazy — only valid during standaloneWrite action phase
  _DHTShortArrayHeadState get _workingState {
    final ws = _head._workingState;
    if (ws == null) {
      throw StateError('_workingState must exist during write operations');
    }
    return ws;
  }

  // Retry transient write failures in place within the open tx.
  // A null result is success (no conflict), so it is not a retry trigger.
  Future<Uint8List?> _tryWriteElementBytes(
    DHTRecord record,
    Uint8List value, {
    required int subkey,
    Output<int>? outSeqNum,
  }) {
    Future<Uint8List?> writeElement() =>
        _head.composableSharedState.withTransactionKey(
          record.key,
          closure: (ops) =>
              ops.tryWriteBytes(value, subkey: subkey, outSeqNum: outSeqNum),
        );
    return _elementRetry?.retry(writeElement) ?? writeElement();
  }

  @override
  int insertAllLimit(int pos) => _workingState.insertAllLimit();

  @override
  int addAllLimit() => _workingState.insertAllLimit();

  @override
  Future<void> add(Uint8List value) => insert(_workingState.length, value);

  @override
  Future<void> addAll(List<Uint8List> values) =>
      insertAll(_workingState.length, values);

  @override
  Future<void> insert(int pos, Uint8List value) async {
    _workingState.allocateIndex(pos);
    try {
      await _writeItemImpl(pos, value);
    } on Exception {
      _workingState.freeIndex(pos);
      rethrow;
    }
  }

  @override
  Future<void> insertAll(int pos, List<Uint8List> values) async {
    // Allocate empty indices
    for (var i = 0; i < values.length; i++) {
      _workingState.allocateIndex(pos + i);
    }

    var success = true;
    final outSeqNums = List.generate(values.length, (_) => Output<int>());
    final lookups = <DHTShortArrayHeadLookup>[];
    try {
      // Do all lookups
      for (var i = 0; i < values.length; i++) {
        final lookup = await _workingState.lookupPosition(pos + i);
        lookups.add(lookup);
      }

      // Write items in parallel; veilid-core's per-tx semaphore caps
      // concurrency.
      Future<void> writeOne(int i) async {
        try {
          final outValue = await _tryWriteElementBytes(
            lookups[i].record,
            values[i],
            subkey: lookups[i].recordSubkey,
            outSeqNum: outSeqNums[i],
          );
          if (outValue != null) {
            success = false;
          }
          // ignore: avoid_catches_without_on_clauses
        } catch (e, st) {
          veilidLoggy.error('$e\n$st\n');
        }
      }

      await Future.wait([
        for (var i = 0; i < values.length; i++) writeOne(i),
      ]);
    } finally {
      // Update sequence numbers
      for (var i = 0; i < values.length; i++) {
        if (outSeqNums[i].value != null) {
          _workingState.updatePositionSeq(pos + i, true, outSeqNums[i].value!);
        }
      }

      // Free indices if this was a failure
      if (!success) {
        for (var i = 0; i < values.length; i++) {
          _workingState.freeIndex(pos);
        }
      }
    }
    if (!success) {
      throw const DHTExceptionOutdated();
    }
  }

  @override
  Future<void> swap(int aPos, int bPos) async {
    _workingState.swapIndex(aPos, bPos);
  }

  @override
  Future<void> remove(int pos, {Output<Uint8List>? output}) async {
    final lookup = await _workingState.lookupPosition(pos);

    final outSeqNum = Output<int>();
    // Read uses non-transactional cache (local refreshMode)
    final result = lookup.seq == null
        ? null
        : await lookup.record.getBytes(
            subkey: lookup.recordSubkey,
            refreshMode: DHTRecordRefreshMode.local,
          );

    if (outSeqNum.value != null) {
      _workingState.updatePositionSeq(pos, false, outSeqNum.value!);
    }

    if (result == null) {
      throw const DHTExceptionNotAvailable(cause: 'element does not exist');
    }
    _workingState.freeIndex(pos);
    output?.save(result);
  }

  @override
  Future<void> clear() async {
    _workingState.clearIndex();
  }

  @override
  Future<void> truncate(int newLength) async {
    _workingState.truncateIndex(newLength);
  }

  /// Non-virtual writeItem body. Called by [insert] so virtual dispatch
  /// doesn't re-enter the standalone wrapper's override (which would double
  /// the operateWrite and bounds-check against committed state).
  Future<Uint8List?> _writeItemImpl(int pos, Uint8List newValue) async {
    final lookup = await _workingState.lookupPosition(pos);

    // Read old value from cache (non-transactional, local only)
    final outSeqNumRead = Output<int>();
    final oldValue = lookup.seq == null
        ? null
        : await lookup.record.getBytes(
            subkey: lookup.recordSubkey,
            refreshMode: DHTRecordRefreshMode.local,
            outSeqNum: outSeqNumRead,
          );
    if (outSeqNumRead.value != null) {
      _workingState.updatePositionSeq(pos, false, outSeqNumRead.value!);
    }

    // Write through transaction
    final outSeqNumWrite = Output<int>();
    final result = await _tryWriteElementBytes(
      lookup.record,
      newValue,
      subkey: lookup.recordSubkey,
      outSeqNum: outSeqNumWrite,
    );
    if (outSeqNumWrite.value != null) {
      _workingState.updatePositionSeq(pos, true, outSeqNumWrite.value!);
    }

    if (result != null) {
      // A newer value exists on the network
      throw const DHTExceptionOutdated();
    }
    return oldValue;
  }

  @override
  Future<Uint8List?> writeItem(int pos, Uint8List newValue) =>
      _writeItemImpl(pos, newValue);
}

////////////////////////////////////////////////////////////////////////////
// Standalone writer — wraps composed writer methods in operateWrite.

class _DHTShortArrayWrite extends _DHTShortArrayComposedWrite {
  _DHTShortArrayWrite._(super.head, super.elementRetry) : super._();

  // Standalone bounds checks need the live committed state, not the
  // snapshot captured at reader construct.
  @override
  _DHTShortArrayHeadState get _state => _head._state;

  @override
  int insertAllLimit(int pos) => _state.insertAllLimit();

  @override
  int addAllLimit() => _state.insertAllLimit();

  @override
  Future<void> add(Uint8List value) => insert(_state.length, value);

  @override
  Future<void> addAll(List<Uint8List> values) =>
      insertAll(_state.length, values);

  @override
  Future<void> insert(int pos, Uint8List value) async {
    if (pos < 0 || pos > _state.length) {
      throw IndexError.withLength(pos, _state.length);
    }
    await _head.operateWrite(() => super.insert(pos, value));
  }

  @override
  Future<void> insertAll(int pos, List<Uint8List> values) async {
    if (pos < 0 || pos > _state.length) {
      throw IndexError.withLength(pos, _state.length);
    }
    final limit = _state.insertAllLimit();
    if (values.length > limit) {
      throw DHTExceptionLimit(
        requested: values.length,
        limit: limit,
        cause: 'insertAll length exceeds insertAllLimit',
      );
    }
    await _head.operateWrite(() => super.insertAll(pos, values));
  }

  @override
  Future<void> swap(int aPos, int bPos) async {
    if (aPos < 0 || aPos >= _state.length) {
      throw IndexError.withLength(aPos, _state.length);
    }
    if (bPos < 0 || bPos >= _state.length) {
      throw IndexError.withLength(bPos, _state.length);
    }
    await _head.operateWrite(() => super.swap(aPos, bPos));
  }

  @override
  Future<void> remove(int pos, {Output<Uint8List>? output}) async {
    if (pos < 0 || pos >= _state.length) {
      throw IndexError.withLength(pos, _state.length);
    }
    await _head.operateWrite(() => super.remove(pos, output: output));
  }

  @override
  Future<void> clear() async {
    await _head.operateWrite(super.clear);
  }

  @override
  Future<void> truncate(int newLength) async {
    await _head.operateWrite(() => super.truncate(newLength));
  }

  @override
  Future<Uint8List?> writeItem(int pos, Uint8List newValue) async {
    if (pos < 0 || pos >= _state.length) {
      throw IndexError.withLength(pos, _state.length);
    }
    return _head.operateWrite(() => super.writeItem(pos, newValue));
  }
}
