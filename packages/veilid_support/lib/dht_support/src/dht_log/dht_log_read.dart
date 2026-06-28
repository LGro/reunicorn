part of 'dht_log.dart';

////////////////////////////////////////////////////////////////////////////
// Reader-only operations interface

abstract class DHTLogReadOperations implements DHTRandomRead {}

////////////////////////////////////////////////////////////////////////////
// Composed reader — cache-only; throws DHTExceptionNotAvailable on miss.

class _DHTLogComposedRead implements DHTLogReadOperations {
  final _DHTLogSpine _spine;

  // In-place retry for transient element failures inside an open tx.
  // Null disables retries for the operation.
  final DHTRetryStrategy? _elementRetry;

  _DHTLogComposedRead._(this._spine, this._elementRetry);

  // Inside our operateWrite scope, see in-flight working state when
  // beginWork has run. Outside the scope, see committed state only so
  // concurrent reads can't observe another task's working state.
  _DHTLogSpineState get _state => _spine.composableSharedState.inWriteScope
      ? (_spine._workingState ?? _spine._state)
      : _spine._state;

  @override
  int get length => _state.length;

  /// Returns the absolute position one-past-end of the segment containing
  /// the logical position [pos], translated back into a logical position.
  int _segmentBoundaryAfter(int pos) {
    final absPos = (_state.head + pos) % _spine._layout.positionLimit;
    final nextSegStart =
        ((absPos ~/ DHTShortArray.maxElements) + 1) * DHTShortArray.maxElements;
    final delta = nextSegStart - absPos;
    return pos + delta;
  }

  @override
  int getRangeLimit(int start) {
    final remaining = _state.length - start;
    if (remaining <= 0) {
      return 0;
    }
    // If [start] sits in an unavailable segment the caller can't read any
    // positions here; signal zero so they skip via getOfflinePositions.
    final absStart = (_state.head + start) % _spine._layout.positionLimit;
    final startSeg = absStart ~/ DHTShortArray.maxElements;
    if (_spine._unavailableSegments.contains(startSeg)) {
      return 0;
    }
    // Clamp the run at the next unavailable segment boundary so a single
    // getRange call only spans contiguous available segments.
    var limit = remaining;
    var probePos = start;
    while (probePos < start + limit) {
      final boundary = _segmentBoundaryAfter(probePos);
      if (boundary >= start + limit) {
        break;
      }
      final boundaryAbs =
          (_state.head + boundary) % _spine._layout.positionLimit;
      final boundarySeg = boundaryAbs ~/ DHTShortArray.maxElements;
      if (_spine._unavailableSegments.contains(boundarySeg)) {
        limit = boundary - start;
        break;
      }
      probePos = boundary;
    }
    return limit;
  }

  /// Internal element fetch. Not virtual so [getRange]'s loop stays in
  /// the composed reader and isn't re-wrapped by the standalone subclass.
  Future<Uint8List> _getImpl(int pos) async {
    if (pos < 0 || pos >= length) {
      throw IndexError.withLength(pos, length);
    }
    return _state.withPosition(
      pos,
      closure: (lookup) => lookup.composable.read(
        (read) => read.get(lookup.pos),
        elementRetry: _elementRetry,
      ),
    );
  }

  @override
  Future<Uint8List> get(int pos) => _getImpl(pos);

  (int, int) _clampStartLen(int start, int? len) {
    var effectiveLen = len ?? _state.length;
    if (start < 0) {
      throw IndexError.withLength(start, _state.length);
    }
    if (start > _state.length) {
      throw IndexError.withLength(start, _state.length);
    }
    if ((effectiveLen + start) > _state.length) {
      effectiveLen = _state.length - start;
    }
    return (start, effectiveLen);
  }

  @override
  Future<List<Uint8List>> getRange(int start, {int? length}) async {
    (start, length) = _clampStartLen(start, length);
    return Future.wait([for (var i = 0; i < length; i++) _getImpl(start + i)]);
  }

  @override
  Future<Set<int>> getOfflinePositions() async {
    if (_spine._unavailableSegments.isEmpty) {
      return {};
    }
    final logicalLen = _state.length;
    final out = <int>{};
    for (final seg in _spine._unavailableSegments) {
      final segStart = seg * DHTShortArray.maxElements;
      final segEnd = segStart + DHTShortArray.maxElements;
      for (var absPos = segStart; absPos < segEnd; absPos++) {
        // Translate absolute -> logical using the ring head.
        final logical = _DHTLogSpine._ringDistance(
          absPos,
          _state.head,
          _spine._layout.positionLimit,
        );
        if (logical >= 0 && logical < logicalLen) {
          out.add(logical);
        }
      }
    }
    return out;
  }
}

////////////////////////////////////////////////////////////////////////////
// Standalone reader — retries cache miss inside an operateWrite tx.

class _DHTLogRead extends _DHTLogComposedRead {
  _DHTLogRead._(super.spine, super.elementRetry) : super._();

  @override
  Future<Uint8List> get(int pos) => _spine.operateRead(() => super.get(pos));

  @override
  Future<List<Uint8List>> getRange(int start, {int? length}) =>
      _spine.operateRead(() => super.getRange(start, length: length));
}
