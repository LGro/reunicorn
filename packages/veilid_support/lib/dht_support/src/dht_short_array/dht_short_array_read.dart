part of 'dht_short_array.dart';

////////////////////////////////////////////////////////////////////////////
// Reader-only operations interface

abstract class DHTShortArrayReadOperations implements DHTRandomRead {}

////////////////////////////////////////////////////////////////////////////
// Composed reader — cache-only; throws DHTExceptionNotAvailable on miss.

class _DHTShortArrayComposedRead implements DHTShortArrayReadOperations {
  final _DHTShortArrayHead _head;

  // In-place retry for transient element failures inside an open tx.
  // Null disables retries for the operation.
  final DHTRetryStrategy? _elementRetry;

  _DHTShortArrayComposedRead._(this._head, this._elementRetry);

  // Inside our operateWrite scope, see in-flight working state when
  // beginWork has run. Outside the scope, see committed state only so
  // concurrent reads can't observe another task's working state.
  _DHTShortArrayHeadState get _state => _head.composableSharedState.inWriteScope
      ? (_head._workingState ?? _head._state)
      : _head._state;

  @override
  int get length => _state.length;

  @override
  int getRangeLimit(int start) => _state.getRangeLimit(start);

  /// Internal element fetch. Not virtual so [getRange]'s loop stays in
  /// the composed reader and isn't re-wrapped by the standalone subclass.
  Future<Uint8List> _getImpl(int pos) async {
    if (pos < 0 || pos >= length) {
      throw IndexError.withLength(pos, length);
    }
    final lookup = await _state.lookupPosition(pos);

    Uint8List? out;
    if (_head.composableSharedState.inTransaction) {
      // Retry transient element failures in place within the open tx.
      Future<Uint8List> getElement() async {
        final v = await _head.composableSharedState.withTransactionKey(
          lookup.record.key,
          closure: (ops) => ops.getBytes(
            subkey: lookup.recordSubkey,
            refreshMode: DHTRecordRefreshMode.network,
          ),
        );
        if (v == null) {
          // Every index 0..length-1 must have a value; a null network seq is a
          // representational error, not a transient miss — fail fast, no retry.
          throw const DHTExceptionInvalidData(
            cause: 'element value missing network seq',
          );
        }
        return v;
      }

      out = await (_elementRetry?.retry(getElement) ?? getElement());
    } else {
      if (!lookup.isLocallyAvailable) {
        throw const DHTExceptionNotAvailable(
          cause: 'element not available in local cache',
        );
      }
      out = await lookup.record.getBytes(
        subkey: lookup.recordSubkey,
        refreshMode: DHTRecordRefreshMode.local,
      );
    }
    if (out == null) {
      throw const DHTExceptionNotAvailable(cause: 'element not returned');
    }
    return out;
  }

  /// Read an element. Inside a transaction, route through the tx so the
  /// element gets lazy-loaded with the transaction's authoritative network
  /// seq. Outside a transaction, serve from the local cache and surface a
  /// miss as `DHTExceptionNotAvailable` for the operateRead retry path.
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
  Future<Set<int>> getOfflinePositions() async => {};
}

////////////////////////////////////////////////////////////////////////////
// Standalone reader — retries cache miss inside an operateWrite tx.

class _DHTShortArrayRead extends _DHTShortArrayComposedRead {
  _DHTShortArrayRead._(super.head, super.elementRetry) : super._();

  @override
  Future<Uint8List> get(int pos) => _head.operateRead(() => super.get(pos));

  @override
  Future<List<Uint8List>> getRange(int start, {int? length}) =>
      _head.operateRead(() => super.getRange(start, length: length));
}
