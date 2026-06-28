part of 'dht_log.dart';

class _DHTLogPosition implements DebugName {
  final int pos;

  final _DHTLogSpine _dhtLogSpine;

  final DHTShortArrayComposable composable;

  final int _segmentNumber;

  @override
  String get debugName => 'DHTLogPosition(segment $_segmentNumber:$pos)';

  _DHTLogPosition._({
    required _DHTLogSpine dhtLogSpine,
    required this.composable,
    required this.pos,
    required int segmentNumber,
  }) : _dhtLogSpine = dhtLogSpine,
       _segmentNumber = segmentNumber;

  Future<bool> close() => _dhtLogSpine._segmentClosed(_segmentNumber);
}

/// Copyable spine head state containing only the mutable fields.
/// Write operations work on a copy and only apply to the real
/// state after successful commit, so READs see consistent state.
class _DHTLogSpineState {
  // Parent spine
  final _DHTLogSpine _spine;
  // Ring buffer head position
  int _head;
  // Ring buffer tail position
  int _tail;
  // Whether the spine head needs to be refreshed from the network
  bool _needsRefresh;
  // Bumped on each markNeedsRefresh; lets refresh detect a mid-sync change
  int _refreshGen = 0;

  // Keys to delete after successful commit (set by truncate)
  final List<RecordKey> postCommitDeleteKeys = [];

  _DHTLogSpineState(
    this._spine, {
    required int head,
    required int tail,
    required bool needsRefresh,
  }) : _head = head,
       _tail = tail,
       _needsRefresh = needsRefresh;

  int get head => _head;
  int get tail => _tail;
  bool get needsRefresh => _needsRefresh;
  int get refreshGen => _refreshGen;

  void markNeedsRefresh() {
    _needsRefresh = true;
    _refreshGen++;
  }

  _DHTLogSpineState copy() => _DHTLogSpineState(
    _spine,
    head: _head,
    tail: _tail,
    needsRefresh: _needsRefresh,
  );

  int get length =>
      _DHTLogSpine._ringDistance(_tail, _head, _spine._layout.positionLimit);

  proto.DHTLog toProto() => proto.DHTLog()
    ..head = _head
    ..tail = _tail
    ..stride = _spine._layout.stride;

  void allocateTail(int count) {
    if (count <= 0) {
      throw StateError('count should be > 0');
    }
    if (length + count >= _spine._layout.positionLimit) {
      throw StateError('ring buffer overflow');
    }
    _tail = (_tail + count) % _spine._layout.positionLimit;
  }

  void releaseHead(int count) {
    if (count <= 0) {
      throw StateError('count should be > 0');
    }
    if (count > length) {
      throw StateError('can not release more than length');
    }
    _head = (_head + count) % _spine._layout.positionLimit;
  }

  /// Look up a position in the log, returning the segment position.
  /// Caller MUST close the returned position. Prefer [withPosition] which
  /// handles close in a try/finally; the bare lookup is private to
  /// discourage forget-to-close bugs.
  Future<_DHTLogPosition> _lookupPosition(
    int pos, {
    bool allowCreate = false,
    bool allowNetwork = true,
  }) {
    final endPos = length;
    if (pos < 0 || pos >= endPos) {
      throw IndexError.withLength(pos, endPos);
    }
    final absolutePosition = (_head + pos) % _spine._layout.positionLimit;
    final segmentNumber = absolutePosition ~/ DHTShortArray.maxElements;
    final segmentPos = absolutePosition % DHTShortArray.maxElements;
    return _spine._lookupPositionBySegment(
      segmentNumber,
      segmentPos,
      allowCreate: allowCreate,
      allowNetwork: allowNetwork,
    );
  }

  /// Run [closure] with a looked-up [_DHTLogPosition], guaranteeing the
  /// position is closed even if the closure throws.
  Future<T> withPosition<T>(
    int pos, {
    bool allowCreate = false,
    bool allowNetwork = true,
    required Future<T> Function(_DHTLogPosition) closure,
  }) async {
    final lookup = await _lookupPosition(
      pos,
      allowCreate: allowCreate,
      allowNetwork: allowNetwork,
    );
    try {
      return await closure(lookup);
    } finally {
      await lookup.close();
    }
  }

  /// Validate and update from a network spine head proto.
  /// Validates against committed _state to ensure deltas are sane.
  void updateFromProto(proto.DHTLog newSpineHead) {
    final newHead = newSpineHead.head;
    final newTail = newSpineHead.tail;

    final pl = _spine._layout.positionLimit;
    final headDelta = _DHTLogSpine._ringDistance(
      newHead,
      _spine._state.head,
      pl,
    );
    final tailDelta = _DHTLogSpine._ringDistance(
      newTail,
      _spine._state.tail,
      pl,
    );
    if (headDelta > pl ~/ 2 || tailDelta > pl ~/ 2) {
      throw DHTExceptionInvalidData(
        cause:
            '_DHTLogSpineState::updateFromProto '
            'committed=(${_spine._state.head},${_spine._state.tail}) '
            'working=($_head,$_tail) '
            'new=($newHead,$newTail) '
            'delta=($headDelta,$tailDelta) '
            'positionLimit=$pl',
      );
    }

    _head = newHead;
    _tail = newTail;
    _needsRefresh = false;
  }
}
