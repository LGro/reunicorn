part of 'dht_log.dart';

class _DHTLogPosition extends DHTCloseable<DHTShortArray> {
  final int pos;

  final _DHTLogSpine _dhtLogSpine;

  final DHTShortArray shortArray;

  final int _segmentNumber;

  _DHTLogPosition._({
    required _DHTLogSpine dhtLogSpine,
    required this.shortArray,
    required this.pos,
    required int segmentNumber,
  }) : _dhtLogSpine = dhtLogSpine,
       _segmentNumber = segmentNumber;

  /// Check if the DHTLogPosition is open
  @override
  bool get isOpen => shortArray.isOpen;

  /// The type of the openable scope
  @override
  FutureOr<DHTShortArray> scoped() => shortArray;

  /// Add a reference to this log
  @override
  void ref() => shortArray.ref();

  /// Free all resources for the DHTLogPosition
  @override
  Future<bool> close() => _dhtLogSpine._segmentClosed(_segmentNumber);
}

class _DHTLogSegmentLookup extends Equatable {
  final int subkey;

  final int segment;

  const _DHTLogSegmentLookup({required this.subkey, required this.segment});

  @override
  List<Object?> get props => [subkey, segment];
}

class _SubkeyData {
  int subkey;

  Uint8List data;

  // lint conflict
  // ignore: omit_obvious_property_types
  bool changed = false;

  _SubkeyData({required this.subkey, required this.data});
}

class _DHTLogSpine {
  // Spine head mutex to ensure we keep the representation valid
  final _spineMutex = Mutex(debugLockTimeout: kIsDebugMode ? 60 : null);

  // Subscription to head record internal changes
  StreamSubscription<DHTRecordWatchChange>? _subscription;

  // Notify closure for external spine head changes
  void Function(DHTLogUpdate)? onUpdatedSpine;

  // Single state processor for spine updates
  final _spineChangeProcessor = SingleStateProcessor<proto.DHTLog>();

  // Spine DHT record
  final DHTRecord _spineRecord;

  // Segment stride to use for spine elements
  final int _segmentStride;

  // Layout of dhtlog
  final _DHTLogLayout _layout;

  // An empty segment key to check for null with
  final Uint8List _emptySegmentKey;

  // Position of the start of the log (oldest items)
  int _head;

  // Position of the end of the log (newest items) (exclusive)
  int _tail;

  // LRU cache of DHT spine elements accessed recently
  // Pair of position and associated shortarray segment
  final _spineCacheMutex = Mutex(debugLockTimeout: kIsDebugMode ? 60 : null);

  final List<int> _openCache;

  final Map<int, DHTShortArray> _openedSegments;

  static final _migrationCodec = DHTLogMigrationCodec();

  static const _openCacheSize = 3;

  _DHTLogSpine._({
    required DHTRecord spineRecord,
    required int head,
    required int tail,
    required int stride,
    required _DHTLogLayout layout,
  }) : _spineRecord = spineRecord,
       _head = head,
       _tail = tail,
       _segmentStride = stride,
       _openedSegments = {},
       _openCache = [],
       _layout = layout,
       _emptySegmentKey = Uint8List.fromList(
         List.filled(spineRecord.key.opaque.toBytes().lengthInBytes, 0),
       );

  // Create a new spine record and push it to the network
  static Future<_DHTLogSpine> create({
    required DHTRecord spineRecord,
    required int segmentStride,
    required _DHTLogLayout layout,
  }) async {
    // Construct new spinehead
    final spine = _DHTLogSpine._(
      spineRecord: spineRecord,
      head: 0,
      tail: 0,
      stride: segmentStride,
      layout: layout,
    );

    // Write new spine head record to the network
    await spine.operate((spine) async {
      // Write first empty subkey
      final subkeyData = spine._makeEmptySubkey();
      final existingSubkeyData = await spineRecord.tryWriteBytes(
        subkeyData,
        subkey: 1,
        options: const SetDHTValueOptions(allowOffline: false),
      );
      assert(existingSubkeyData == null, 'Should never conflict on create');

      final success = await spine.writeSpineHead();
      assert(success, 'false return should never happen on create');
    });

    return spine;
  }

  // Pull the latest or updated copy of the spine head record from the network
  static Future<_DHTLogSpine> load({
    required DHTRecord spineRecord,
    required _DHTLogLayout layout,
  }) async {
    // Get an updated spine head record copy if one exists
    final spineHead = await spineRecord.getMigrated(
      _migrationCodec,
      subkey: 0,
      refreshMode: DHTRecordRefreshMode.network,
    );
    if (spineHead == null) {
      throw StateError('spine head missing during refresh');
    }
    return _DHTLogSpine._(
      spineRecord: spineRecord,
      head: spineHead.head,
      tail: spineHead.tail,
      stride: spineHead.stride,
      layout: layout,
    );
  }

  proto.DHTLog _toProto() {
    assert(_spineMutex.isLocked, 'should be in mutex here');

    final logHead = proto.DHTLog()
      ..head = _head
      ..tail = _tail
      ..stride = _segmentStride;
    return logHead;
  }

  Future<void> close() async {
    await _spineMutex.protect(() async {
      if (!isOpen) {
        return;
      }
      final futures = <Future<void>>[_spineRecord.close()];
      for (final seg in _openCache.toList()) {
        futures.add(_segmentClosed(seg));
      }
      await Future.wait(futures);

      assert(_openedSegments.isEmpty, 'should have closed all segments by now');
    });
  }

  // Will deep delete all segment records as they are children
  Future<bool> delete() => _spineMutex.protect(_spineRecord.delete);

  Future<T> operate<T>(Future<T> Function(_DHTLogSpine) closure) =>
      _spineMutex.protect(() => closure(this));

  Future<T> operateAppend<T>(Future<T> Function(_DHTLogSpine) closure) =>
      _spineMutex.protect(() async {
        final oldHead = _head;
        final oldTail = _tail;
        try {
          final out = await closure(this);
          // Write head assuming it has been changed
          if (!await writeSpineHead(old: (oldHead, oldTail))) {
            // Failed to write head means head got overwritten so write should
            // be considered failed
            throw const DHTExceptionOutdated();
          }
          return out;
        } on Exception {
          // Exception means state needs to be reverted
          _head = oldHead;
          _tail = oldTail;
          rethrow;
        }
      });

  Future<T> operateAppendEventual<T>(
    Future<T> Function(_DHTLogSpine) closure, {
    Duration? timeout,
  }) {
    final timeoutTs = timeout == null
        ? null
        : Veilid.instance.now().offset(TimestampDuration.fromDuration(timeout));

    return _spineMutex.protect(() async {
      late int oldHead;
      late int oldTail;
      late T out;
      try {
        // Iterate until we have a successful element and head write
        do {
          // Save off old values each pass of writeSpineHead because the head
          // will have changed
          oldHead = _head;
          oldTail = _tail;

          // Try to do the element write
          while (true) {
            if (timeoutTs != null) {
              final now = Veilid.instance.now();
              if (now >= timeoutTs) {
                throw TimeoutException('timeout reached');
              }
            }
            try {
              out = await closure(this);
              break;
            } on DHTExceptionOutdated {
              // Failed to write in closure resets state
              _head = oldHead;
              _tail = oldTail;
            } on Exception {
              // Failed to write in closure resets state
              _head = oldHead;
              _tail = oldTail;
              rethrow;
            }
          }
          // Try to do the head write
        } while (!await writeSpineHead(old: (oldHead, oldTail)));
      } on Exception {
        // Exception means state needs to be reverted
        _head = oldHead;
        _tail = oldTail;
        rethrow;
      }

      return out;
    });
  }

  /// Serialize and write out the current spine head subkey, possibly updating
  /// it if a newer copy is available online. Returns true if the write was
  /// successful
  Future<bool> writeSpineHead({(int, int)? old}) async {
    assert(_spineMutex.isLocked, 'should be in mutex here');

    final existingHead = await _spineRecord.tryWriteMigrated(
      _migrationCodec,
      _toProto(),
      options: const SetDHTValueOptions(allowOffline: false),
    );
    if (existingHead != null) {
      // Head write failed, incorporate update if possible
      _updateHead(existingHead.value.head, existingHead.value.tail, old: old);
      if (old != null) {
        sendUpdate(old.$1, old.$2);
      }
      return false;
    }
    if (old != null) {
      sendUpdate(old.$1, old.$2);
    }
    return true;
  }

  /// Send a spine update callback
  void sendUpdate(int oldHead, int oldTail) {
    final oldLength = _ringDistance(oldTail, oldHead);
    if (oldHead != _head || oldTail != _tail || oldLength != length) {
      onUpdatedSpine?.call(
        DHTLogUpdate(
          headDelta: _ringDistance(_head, oldHead),
          tailDelta: _ringDistance(_tail, oldTail),
          length: length,
        ),
      );
    }
  }

  /// Validate a new spine head subkey that has come in from the network
  void _updateHead(int newHead, int newTail, {(int, int)? old}) {
    assert(_spineMutex.isLocked, 'should be in mutex here');

    if (old != null) {
      final oldHead = old.$1;
      final oldTail = old.$2;

      final headDelta = _ringDistance(newHead, oldHead);
      final tailDelta = _ringDistance(newTail, oldTail);
      if (headDelta > _layout.positionLimit ~/ 2 ||
          tailDelta > _layout.positionLimit ~/ 2) {
        throw DHTExceptionInvalidData(
          cause:
              '_DHTLogSpine::_updateHead '
              '_head=$_head _tail=$_tail '
              'oldHead=$oldHead oldTail=$oldTail '
              'newHead=$newHead newTail=$newTail '
              'headDelta=$headDelta tailDelta=$tailDelta '
              '_positionLimit=${_layout.positionLimit}',
        );
      }
    }

    _head = newHead;
    _tail = newTail;
  }

  /////////////////////////////////////////////////////////////////////////////
  // Spine element management

  Uint8List _makeEmptySubkey() => Uint8List.fromList(
    List.filled(_layout.segmentsPerSubkey * _layout.recordKeyLength, 0),
  );

  RecordKey? _getSegmentKey(Uint8List subkeyData, int segment) {
    final segmentKeyBytes = subkeyData.sublist(
      _layout.recordKeyLength * segment,
      _layout.recordKeyLength * (segment + 1),
    );
    if (segmentKeyBytes.equals(_emptySegmentKey)) {
      return null;
    }
    return RecordKey(
      opaque: OpaqueRecordKey.fromBytes(segmentKeyBytes),
      encryptionKey: recordKey.encryptionKey,
    );
  }

  void _setSegmentKey(
    Uint8List subkeyData,
    int segment,
    RecordKey? segmentKey,
  ) {
    late final Uint8List segmentKeyBytes;
    if (segmentKey == null) {
      segmentKeyBytes = _emptySegmentKey;
    } else {
      segmentKeyBytes = segmentKey.opaque.toBytes();
    }
    subkeyData.setRange(
      _layout.recordKeyLength * segment,
      _layout.recordKeyLength * (segment + 1),
      segmentKeyBytes,
    );
  }

  Future<DHTShortArray?> _openOrCreateSegment(int segmentNumber) async {
    assert(_spineMutex.isLocked, 'should be in mutex here');
    assert(_spineRecord.writer != null, 'should be writable');

    // Lookup what subkey and segment subrange has this position's segment
    // shortarray
    final l = _lookupSegment(segmentNumber);
    final subkey = l.subkey;
    final segment = l.segment;

    try {
      var subkeyData = await _spineRecord.get(subkey: subkey);
      subkeyData ??= _makeEmptySubkey();

      while (true) {
        final segmentKey = _getSegmentKey(subkeyData!, segment);
        if (segmentKey == null) {
          // Create a shortarray segment
          final segmentRec = await DHTShortArray.create(
            debugName: '${_spineRecord.debugName}_spine_${subkey}_$segment',
            stride: _segmentStride,
            crypto: _spineRecord.crypto,
            parent: _spineRecord.key,
            routingContext: _spineRecord.routingContext,
            writer: _spineRecord.writer,
            encryptionKeyOverride: EncryptionKeyOverride.fromRecordKey(
              _spineRecord.key,
            ),
          );
          var success = false;
          try {
            // Write it back to the spine record
            _setSegmentKey(subkeyData, segment, segmentRec.recordKey);
            subkeyData = await _spineRecord.tryWriteBytes(
              subkeyData,
              subkey: subkey,
            );
            // If the write was successful then we're done
            if (subkeyData == null) {
              // Return it
              success = true;
              return segmentRec;
            }
          } finally {
            if (!success) {
              await segmentRec.close();
              await segmentRec.delete();
            }
          }
        } else {
          // Open a shortarray segment
          final segmentRec = await DHTShortArray.openWrite(
            segmentKey,
            _spineRecord.writer!,
            debugName: '${_spineRecord.debugName}_spine_${subkey}_$segment',
            crypto: _spineRecord.crypto,
            parent: _spineRecord.key,
            routingContext: _spineRecord.routingContext,
          );
          return segmentRec;
        }
        // Loop if we need to try again with the new data from the network
      }
    } on DHTExceptionNotAvailable {
      return null;
    }
  }

  Future<DHTShortArray?> _openSegment(int segmentNumber) async {
    assert(_spineMutex.isLocked, 'should be in mutex here');

    // Lookup what subkey and segment subrange has this position's segment
    // shortarray
    final l = _lookupSegment(segmentNumber);
    final subkey = l.subkey;
    final segment = l.segment;

    // See if we have the segment key locally
    try {
      RecordKey? segmentKey;
      var subkeyData = await _spineRecord.get(
        subkey: subkey,
        refreshMode: DHTRecordRefreshMode.local,
      );
      if (subkeyData != null) {
        segmentKey = _getSegmentKey(subkeyData, segment);
      }
      if (segmentKey == null) {
        // If not, try from the network
        subkeyData = await _spineRecord.get(
          subkey: subkey,
          refreshMode: DHTRecordRefreshMode.network,
        );
        if (subkeyData == null) {
          return null;
        }
        segmentKey = _getSegmentKey(subkeyData, segment);
        if (segmentKey == null) {
          return null;
        }
      }

      // Open a shortarray segment
      final segmentRec = await DHTShortArray.openRead(
        segmentKey,
        debugName: '${_spineRecord.debugName}_spine_${subkey}_$segment',
        crypto: _spineRecord.crypto,
        parent: _spineRecord.key,
        routingContext: _spineRecord.routingContext,
      );
      return segmentRec;
    } on DHTExceptionNotAvailable {
      return null;
    }
  }

  _DHTLogSegmentLookup _lookupSegment(int segmentNumber) {
    assert(_spineMutex.isLocked, 'should be in mutex here');

    if (segmentNumber < 0) {
      throw IndexError.withLength(
        segmentNumber,
        _layout.spineSubkeys * _layout.segmentsPerSubkey,
      );
    }
    final subkey = segmentNumber ~/ _layout.segmentsPerSubkey;
    if (subkey >= _layout.spineSubkeys) {
      throw IndexError.withLength(
        segmentNumber,
        _layout.spineSubkeys * _layout.segmentsPerSubkey,
      );
    }
    final segment = segmentNumber % _layout.segmentsPerSubkey;
    return _DHTLogSegmentLookup(subkey: subkey + 1, segment: segment);
  }

  ///////////////////////////////////////////
  // API for public interfaces

  Future<_DHTLogPosition?> lookupPositionBySegmentNumber(
    int segmentNumber,
    int segmentPos, {
    bool onlyOpened = false,
  }) => _spineCacheMutex.protect(() async {
    // See if we have this segment opened already
    final openedSegment = _openedSegments[segmentNumber];
    late DHTShortArray shortArray;
    if (openedSegment != null) {
      // If so, return a ref
      openedSegment.ref();
      shortArray = openedSegment;
    } else {
      // Otherwise open a segment
      if (onlyOpened) {
        return null;
      }

      final newShortArray = (_spineRecord.writer == null)
          ? await _openSegment(segmentNumber)
          : await _openOrCreateSegment(segmentNumber);
      if (newShortArray == null) {
        return null;
      }
      // Keep in the opened segments table
      _openedSegments[segmentNumber] = newShortArray;
      shortArray = newShortArray;
    }

    // LRU cache the segment number
    if (!_openCache.remove(segmentNumber)) {
      // If this is new to the cache ref it when it goes in
      shortArray.ref();
    }
    _openCache.add(segmentNumber);
    if (_openCache.length > _openCacheSize) {
      // Trim the LRU cache
      final lruseg = _openCache.removeAt(0);
      final lrusa = _openedSegments[lruseg]!;
      if (await lrusa.close()) {
        _openedSegments.remove(lruseg);
      }
    }

    return _DHTLogPosition._(
      dhtLogSpine: this,
      shortArray: shortArray,
      pos: segmentPos,
      segmentNumber: segmentNumber,
    );
  });

  Future<_DHTLogPosition?> lookupPosition(int pos) {
    assert(_spineMutex.isLocked, 'should be locked');

    // Check if our position is in bounds
    final endPos = length;
    if (pos < 0 || pos >= endPos) {
      throw IndexError.withLength(pos, endPos);
    }

    // Calculate absolute position, ring-buffer style
    final absolutePosition = (_head + pos) % _layout.positionLimit;

    // Determine the segment number and position within the segment
    final segmentNumber = absolutePosition ~/ DHTShortArray.maxElements;
    final segmentPos = absolutePosition % DHTShortArray.maxElements;

    return lookupPositionBySegmentNumber(segmentNumber, segmentPos);
  }

  Future<bool> _segmentClosed(int segmentNumber) {
    assert(_spineMutex.isLocked, 'should be locked');
    return _spineCacheMutex.protect(() async {
      final sa = _openedSegments[segmentNumber]!;
      if (await sa.close()) {
        _openedSegments.remove(segmentNumber);
        return true;
      }
      return false;
    });
  }

  void allocateTail(int count) {
    assert(_spineMutex.isLocked, 'should be locked');

    final currentLength = length;
    if (count <= 0) {
      throw StateError('count should be > 0');
    }
    if (currentLength + count >= _layout.positionLimit) {
      throw StateError('ring buffer overflow');
    }

    _tail = (_tail + count) % _layout.positionLimit;
  }

  Future<void> releaseHead(int count) async {
    assert(_spineMutex.isLocked, 'should be locked');

    final currentLength = length;
    if (count <= 0) {
      throw StateError('count should be > 0');
    }
    if (count > currentLength) {
      throw StateError('ring buffer underflow');
    }

    final oldHead = _head;
    _head = (_head + count) % _layout.positionLimit;
    final newHead = _head;
    await _purgeSegments(oldHead, newHead);
  }

  Future<void> _deleteSegmentsContiguous(int start, int end) async {
    assert(_spineMutex.isLocked, 'should be in mutex here');
    DHTRecordPool.instance.log(
      '_deleteSegmentsContiguous: start=$start, end=$end',
    );

    final startSegmentNumber = start ~/ DHTShortArray.maxElements;
    final startSegmentPos = start % DHTShortArray.maxElements;

    final endSegmentNumber = end ~/ DHTShortArray.maxElements;
    final endSegmentPos = end % DHTShortArray.maxElements;

    final firstDeleteSegment = (startSegmentPos == 0)
        ? startSegmentNumber
        : startSegmentNumber + 1;
    final lastDeleteSegment = (endSegmentPos == 0)
        ? endSegmentNumber - 1
        : endSegmentNumber - 2;

    _SubkeyData? lastSubkeyData;
    for (
      var segmentNumber = firstDeleteSegment;
      segmentNumber <= lastDeleteSegment;
      segmentNumber++
    ) {
      // Lookup what subkey and segment subrange has this position's segment
      // shortarray
      final l = _lookupSegment(segmentNumber);
      final subkey = l.subkey;
      final segment = l.segment;

      if (subkey != lastSubkeyData?.subkey) {
        // Flush subkey writes
        if (lastSubkeyData != null && lastSubkeyData.changed) {
          final result = await _spineRecord.tryWriteBytes(
            lastSubkeyData.data,
            subkey: lastSubkeyData.subkey,
            options: const SetDHTValueOptions(allowOffline: false),
          );
          if (result != null) {
            throw const DHTExceptionOutdated();
          }
        }

        // Get next subkey if available locally
        final data = await _spineRecord.get(
          subkey: subkey,
          refreshMode: DHTRecordRefreshMode.local,
        );
        if (data != null) {
          lastSubkeyData = _SubkeyData(subkey: subkey, data: data);
        } else {
          lastSubkeyData = null;
          // If the subkey was not available locally we can go to the
          // last segment number at the end of this subkey
          segmentNumber = ((subkey + 1) * _layout.segmentsPerSubkey) - 1;
        }
      }
      if (lastSubkeyData != null) {
        final segmentKey = _getSegmentKey(lastSubkeyData.data, segment);
        if (segmentKey != null) {
          await DHTRecordPool.instance.deleteRecord(segmentKey);
          _setSegmentKey(lastSubkeyData.data, segment, null);
          lastSubkeyData.changed = true;
        }
      }
    }
    // Flush subkey writes
    if (lastSubkeyData != null && lastSubkeyData.changed) {
      final result = await _spineRecord.tryWriteBytes(
        lastSubkeyData.data,
        subkey: lastSubkeyData.subkey,
        options: const SetDHTValueOptions(allowOffline: false),
      );
      if (result != null) {
        throw const DHTExceptionOutdated();
      }
    }
  }

  Future<void> _purgeSegments(int from, int to) async {
    assert(_spineMutex.isLocked, 'should be in mutex here');
    if (from < to) {
      await _deleteSegmentsContiguous(from, to);
    } else if (from > to) {
      await _deleteSegmentsContiguous(from, _layout.positionLimit);
      await _deleteSegmentsContiguous(0, to);
    }
  }

  /////////////////////////////////////////////////////////////////////////////
  // Watch For Updates

  // Watch head for changes
  Future<void> watch() async {
    // This will update any existing watches if necessary
    try {
      // Update changes to the head record
      _subscription ??= await _spineRecord.listen(_onSpineChanged);
      await _spineRecord.watch(subkeys: [ValueSubkeyRange.single(0)]);
    } on Exception {
      // If anything fails, try to cancel the watches
      await cancelWatch();
      rethrow;
    }
  }

  // Stop watching for changes to head and linked records
  Future<void> cancelWatch() async {
    await _spineRecord.cancelWatch();
    await _subscription?.cancel();
    _subscription = null;
  }

  // Called when the log changes online and we find out from a watch
  // but not when we make a change locally
  Future<void> _onSpineChanged(
    DHTRecord record,
    Uint8List? data,
    List<ValueSubkeyRange> subkeys,
  ) async {
    // If head record subkey zero changes, then the layout
    // of the dhtshortarray has changed
    if (data == null) {
      throw StateError('spine head changed without data');
    }
    if (record.key != _spineRecord.key ||
        subkeys.length != 1 ||
        subkeys[0] != ValueSubkeyRange.single(0)) {
      throw StateError('watch returning wrong subkey range');
    }

    // Decode updated head
    final headData = _migrationCodec.fromBytes(data).value;

    // Then update the head record
    _spineChangeProcessor.updateState(headData, (headData) async {
      await _spineMutex.protect(() async {
        final oldHead = _head;
        final oldTail = _tail;

        _updateHead(headData.head, headData.tail, old: (oldHead, oldTail));

        // Lookup tail position segments that have changed
        // and force their short arrays to refresh their heads if
        // they are opened
        final segmentsToRefresh = <_DHTLogPosition>[];
        var curTail = oldTail;
        final endSegmentNumber = _tail ~/ DHTShortArray.maxElements;
        while (true) {
          final segmentNumber = curTail ~/ DHTShortArray.maxElements;
          final segmentPos = curTail % DHTShortArray.maxElements;
          final dhtLogPosition = await lookupPositionBySegmentNumber(
            segmentNumber,
            segmentPos,
            onlyOpened: true,
          );
          if (dhtLogPosition != null) {
            segmentsToRefresh.add(dhtLogPosition);
          }

          if (segmentNumber == endSegmentNumber) {
            break;
          }

          curTail =
              (curTail +
                  (DHTShortArray.maxElements -
                      (curTail % DHTShortArray.maxElements))) %
              _layout.positionLimit;
        }

        // Refresh the segments that have probably changed
        await segmentsToRefresh.map((p) async {
          await p.shortArray.refresh();
          await p.close();
        }).wait;

        sendUpdate(oldHead, oldTail);
      });
    });
  }

  ////////////////////////////////////////////////////////////////////////////

  RecordKey get recordKey => _spineRecord.key;

  OwnedDHTRecordPointer? get recordPointer =>
      _spineRecord.ownedDHTRecordPointer;

  int get length => _ringDistance(_tail, _head);

  bool get isOpen => _spineRecord.isOpen;

  // Ring buffer distance from old to new
  int _ringDistance(int n, int o) =>
      (n < o) ? (_layout.positionLimit - o) + n : n - o;
}
