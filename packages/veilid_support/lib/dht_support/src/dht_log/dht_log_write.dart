part of 'dht_log.dart';

////////////////////////////////////////////////////////////////////////////
// Writer operations interface

abstract class DHTLogWriteOperations
    implements
        DHTLogReadOperations,
        DHTRandomWrite,
        DHTAdd,
        DHTTruncate,
        DHTClear {}

////////////////////////////////////////////////////////////////////////////
// Composed writer — the core write implementation.
// Expects _workingState and a transaction to already be set on the spine.
// For segment operations, uses the composable interface (no nested lifecycle).

class _DHTLogComposedWrite extends _DHTLogComposedRead
    implements DHTLogWriteOperations {
  _DHTLogComposedWrite._(super.spine, super.elementRetry) : super._();

  _DHTLogSpineState get _workingState {
    final ws = _spine._workingState;
    if (ws == null) {
      throw StateError('_workingState must exist during write operations');
    }
    return ws;
  }

  @override
  int addAllLimit() {
    final tailPosInSegment = _workingState.tail % DHTShortArray.maxElements;
    return DHTShortArray.maxElements - tailPosInSegment;
  }

  @override
  Future<Uint8List?> writeItem(int pos, Uint8List newValue) async {
    if (pos < 0 || pos >= _workingState.length) {
      throw IndexError.withLength(pos, _workingState.length);
    }
    return _workingState.withPosition(
      pos,
      allowCreate: true,
      closure: (lookup) => lookup.composable.write(
        (write) => write.writeItem(lookup.pos, newValue),
        elementRetry: _elementRetry,
      ),
    );
  }

  @override
  Future<void> add(Uint8List value) async {
    final insertPos = _workingState.length;
    _workingState.allocateTail(1);
    await _workingState.withPosition(
      insertPos,
      allowCreate: true,
      closure: (lookup) => lookup.composable.write((write) async {
        // If this a new segment, then clear it in case we have wrapped
        if (lookup.pos == 0) {
          await write.clear();
        } else if (lookup.pos != write.length) {
          // We should always be appending at the length
          await write.truncate(lookup.pos);
        }
        return write.add(value);
      }, elementRetry: _elementRetry),
    );
  }

  @override
  Future<void> addAll(List<Uint8List> values) async {
    final insertPos = _workingState.length;
    _workingState.allocateTail(values.length);

    for (var valueIdxIter = 0; valueIdxIter < values.length;) {
      final valueIdx = valueIdxIter;
      final remaining = values.length - valueIdx;

      valueIdxIter += await _workingState.withPosition(
        insertPos + valueIdx,
        allowCreate: true,
        closure: (lookup) async {
          final sacount = min(
            remaining,
            DHTShortArray.maxElements - lookup.pos,
          );
          final sublistValues = values.sublist(valueIdx, valueIdx + sacount);

          await lookup.composable.write((write) async {
            // If this a new segment, then clear it in case we have wrapped
            if (lookup.pos == 0) {
              await write.clear();
            } else if (lookup.pos != write.length) {
              // We should always be appending at the length
              await write.truncate(lookup.pos);
            }
            await write.addAll(sublistValues);
          }, elementRetry: _elementRetry);

          return sacount;
        },
      );
    }
  }

  Future<void> _truncateImpl(int newLength) async {
    if (newLength < 0) {
      throw StateError('can not truncate to negative length');
    }
    if (newLength >= _workingState.length) {
      return;
    }

    // Use committed state head as the old position for segment cleanup
    final oldHead = _workingState.head;
    _workingState.releaseHead(_workingState.length - newLength);

    // Clear segment keys from spine subkeys using the active transaction.
    // Keys to delete are stored on the working state for post-commit cleanup.
    final keysToDelete = await _workingState._spine.clearReleasedSegments(
      oldHead,
      _workingState.head,
    );
    _workingState.postCommitDeleteKeys.addAll(keysToDelete);
  }

  @override
  Future<void> truncate(int newLength) => _truncateImpl(newLength);

  @override
  Future<void> clear() => _truncateImpl(0);
}

////////////////////////////////////////////////////////////////////////////
// Standalone writer — wraps composed writer methods in operateWrite.

class _DHTLogWrite extends _DHTLogComposedWrite {
  _DHTLogWrite._(super.spine, super.elementRetry) : super._();

  // Standalone needs the live committed state for bounds checks, not the
  // snapshot captured at reader construct.
  @override
  _DHTLogSpineState get _state => _spine._state;

  @override
  int addAllLimit() {
    final tailPosInSegment = _state.tail % DHTShortArray.maxElements;
    return DHTShortArray.maxElements - tailPosInSegment;
  }

  @override
  Future<Uint8List?> writeItem(int pos, Uint8List newValue) =>
      _spine.operateWrite(() => super.writeItem(pos, newValue));

  @override
  Future<void> add(Uint8List value) =>
      _spine.operateWrite(() => super.add(value));

  @override
  Future<void> addAll(List<Uint8List> values) =>
      _spine.operateWrite(() => super.addAll(values));

  @override
  Future<void> truncate(int newLength) =>
      _spine.operateWrite(() => super.truncate(newLength));

  @override
  Future<void> clear() => _spine.operateWrite(() => super.clear());
}
