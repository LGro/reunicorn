part of 'dht_log.dart';

class _DHTLogLayout {
  final int recordKeyLength;
  final int spineSubkeys;
  final int segmentsPerSubkey;
  final int positionLimit;
  final int stride;

  // Example layout for VLD0:
  // 55 subkeys * 512 segments * 36 bytes per typedkey =
  //   1013760 bytes per record
  // Leaves 34816 bytes for 0th subkey as head, 56 subkeys total
  // 512*36 = 18432 bytes per subkey
  // 28160 shortarrays * 256 elements = 7208960 elements
  // Defaults for VLD0:
  // XXX: Eliminate this in favor of actual calculation from cryptokind
  static const _defaultRecordKeyLength = 36;
  static const _defaultSpineSubkeys = 55;
  static const _defaultSegmentsPerSubkey = 512;

  _DHTLogLayout({required this.stride})
    : recordKeyLength = _defaultRecordKeyLength,
      spineSubkeys = _defaultSpineSubkeys,
      segmentsPerSubkey = _defaultSegmentsPerSubkey,
      positionLimit =
          _defaultSegmentsPerSubkey *
          _defaultSpineSubkeys *
          DHTShortArray.maxElements;
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

typedef _DefaultDHTLogComposable =
    DefaultDHTComposable<
      DHTLogReadOperations,
      DHTLogWriteOperations,
      DHTLogUpdate
    >;

class _DHTLogSpine with _DefaultDHTLogComposable {
  // Read-write lock for local state (head, tail, opened segments).
  // READs acquire read lock (concurrent), SYNC/WRITE commit acquires write lock.
  final _stateLock = ReadWriteMutex(debugLockTimeout: kIsDebugMode ? 60 : null);

  // Subscription to head record internal changes
  DHTRecordWatchSubscription? _subscription;

  // Single state processor for spine update serialization
  final _spineChangeProcessor = SingleStatelessProcessor();

  // Spine DHT record
  final DHTRecord _spineRecord;

  // Layout of dhtlog (includes stride)
  final _DHTLogLayout _layout;

  // An empty segment key to check for null with
  final Uint8List _emptySegmentKey;

  // The committed spine state (head, tail).
  // Protected by _stateLock. READs see this.
  // Initialized in constructor body because _DHTLogSpineState
  // needs a reference to this _DHTLogSpine.
  late _DHTLogSpineState _state;

  // In-flight working state, set by beginWork and cleared by endWork.
  _DHTLogSpineState? _workingState;

  // Segments touched during the active operate. Iterated for flush/endWork.
  final Set<DHTShortArrayComposable> _activeSegments = {};

  // LRU cache of DHT spine elements accessed recently
  // Pair of position and associated shortarray segment
  final _openedSegmentsMutex = Mutex(
    debugLockTimeout: kIsDebugMode ? 60 : null,
  );
  final Map<int, DHTShortArray> _openedSegments = {};
  final List<int> _openCache = [];

  // Segments whose lazy open failed (DHTExceptionNotAvailable). Surfaced
  // through getOfflinePositions so readers can skip them rather than getting
  // stuck on a single bad segment. Cleared by refresh() so a recovered
  // network can re-attempt.
  final Set<int> _unavailableSegments = {};

  static const _openedSegmentsLimit = 3;

  static final _migrationCodec = DHTLogMigrationCodec();

  _DHTLogSpine._({
    required DHTRecord spineRecord,
    required int head,
    required int tail,
    required _DHTLogLayout layout,
    bool needsRefresh = true,
  }) : _spineRecord = spineRecord,
       _layout = layout,
       _emptySegmentKey = Uint8List.fromList(
         List.filled(spineRecord.key.opaque.toBytes().lengthInBytes, 0),
       ) {
    _state = _DHTLogSpineState(
      this,
      head: head,
      tail: tail,
      needsRefresh: needsRefresh,
    );
  }

  // Create a new spine record and push it to the network
  static Future<_DHTLogSpine> create({
    required String debugName,
    required int stride,
    CryptoKind? kind,
    VeilidRoutingContext? routingContext,
    RecordKey? parent,
    CryptoCodec? crypto,
    KeyPair? writer,
    EncryptionKeyOverride? encryptionKeyOverride,
    DHTComposableSharedState? composableSharedState,
  }) async {
    final pool = DHTRecordPool.instance;
    final layout = _DHTLogLayout(stride: stride);

    late final DHTRecord spineRecord;
    if (writer != null) {
      final schema = DHTSchema.smpl(
        oCnt: 0,
        members: [
          DHTSchemaMember(
            mKey: (await pool.veilid.generateMemberId(writer.key)).value,
            mCnt: layout.spineSubkeys + 1,
          ),
        ],
      );
      spineRecord = await pool.createRecord(
        debugName: debugName,
        kind: kind,
        parent: parent,
        routingContext: routingContext,
        schema: schema,
        crypto: crypto,
        writer: writer,
        encryptionKeyOverride: encryptionKeyOverride,
      );
    } else {
      final schema = DHTSchema.dflt(oCnt: layout.spineSubkeys + 1);
      spineRecord = await pool.createRecord(
        debugName: debugName,
        kind: kind,
        parent: parent,
        routingContext: routingContext,
        schema: schema,
        crypto: crypto,
        encryptionKeyOverride: encryptionKeyOverride,
      );
    }

    // Empty spine is valid at creation time
    final spine = _DHTLogSpine._(
      spineRecord: spineRecord,
      head: 0,
      tail: 0,
      layout: layout,
      needsRefresh: false,
    );

    if (composableSharedState != null) {
      // Composed: spine joins the caller's tx (mirrors DHTShortArray.create);
      // committing here would race rehydration against the open parent tx. The
      // empty spine subkey is initialized lazily on first segment write.
      spine.enterComposedMode(composableSharedState);
    } else {
      // Standalone: initialize and push the spine to the network in its own tx.
      await spine.standaloneSharedState.withWriteScope(
        () => spine.operateWrite(() async {
          final subkeyData = spine._makeEmptySubkey();
          final existingSubkeyData = await spine.standaloneSharedState
              .withTransactionKey(
                spineRecord.key,
                closure: (ops) => ops.tryWriteBytes(subkeyData, subkey: 1),
              );
          if (existingSubkeyData != null) {
            throw StateError('Should never conflict on create');
          }
        }),
      );
    }

    return spine;
  }

  /// Open and load spine state from local cache — no network access.
  /// If no data in local cache (first open before SYNC), returns
  /// a spine with empty state (head=0, tail=0).
  static Future<_DHTLogSpine> openRead(
    RecordKey logRecordKey, {
    required String debugName,
    VeilidRoutingContext? routingContext,
    RecordKey? parent,
    CryptoCodec? crypto,
    DHTComposableSharedState? composableSharedState,
  }) async {
    final spineRecord = await DHTRecordPool.instance.openRecordRead(
      logRecordKey,
      debugName: debugName,
      parent: parent,
      routingContext: routingContext,
      crypto: crypto,
    );
    return _loadFromRecord(spineRecord, composableSharedState);
  }

  /// Open and load spine state with write access.
  static Future<_DHTLogSpine> openWrite(
    RecordKey logRecordKey,
    KeyPair writer, {
    required String debugName,
    VeilidRoutingContext? routingContext,
    RecordKey? parent,
    CryptoCodec? crypto,
    DHTComposableSharedState? composableSharedState,
  }) async {
    final spineRecord = await DHTRecordPool.instance.openRecordWrite(
      logRecordKey,
      writer,
      debugName: debugName,
      parent: parent,
      routingContext: routingContext,
      crypto: crypto,
    );
    return _loadFromRecord(spineRecord, composableSharedState);
  }

  static Future<_DHTLogSpine> _loadFromRecord(
    DHTRecord spineRecord,
    DHTComposableSharedState? composableSharedState,
  ) async {
    // Try local cache first for the spine head
    var spineHead = await spineRecord.getMigrated(
      _migrationCodec,
      subkey: 0,
      refreshMode: DHTRecordRefreshMode.local,
    );

    // If not in local cache, peek at the network via transaction. Commit so
    // the fetched spine head is persisted to the local cache.
    if (spineHead == null) {
      final tx = await DHTRecordPool.instance.transact([
        spineRecord,
      ], debugName: 'DHTLog._loadFromRecord(${spineRecord.debugName})');
      try {
        spineHead = await tx.withKey(
          spineRecord.key,
          closure: (ops) => ops.getMigrated(
            _migrationCodec,
            subkey: 0,
            refreshMode: DHTRecordRefreshMode.network,
          ),
        );
        await tx.commit();
      } on Exception {
        await tx.rollback();
        rethrow;
      }

      if (spineHead == null) {
        throw const DHTExceptionNotAvailable(
          cause: 'spine head not available — record may not exist on network',
        );
      }
    }

    final layout = _DHTLogLayout(stride: spineHead.stride);
    final spine = _DHTLogSpine._(
      spineRecord: spineRecord,
      head: spineHead.head,
      tail: spineHead.tail,
      layout: layout,
    );

    // See if we can open the tail segment locally
    final length = _ringDistance(
      spineHead.tail,
      spineHead.head,
      layout.positionLimit,
    );
    if (length != 0) {
      try {
        await spine._withPositionBySegment(
          (spineHead.tail - 1) ~/ DHTShortArray.maxElements,
          (spineHead.tail - 1) % DHTShortArray.maxElements,
          allowCreate: false,
          allowNetwork: false,
          closure: (tailSegment) async {
            // If the opened tail segment needs a refresh then the whole
            // spine/log needs a refresh
            if (!tailSegment.composable.needsRefresh) {
              // If we have the tail segment available locally
              // we don't need to refresh the spine
              spine._state._needsRefresh = false;
            }
          },
        );
      } on DHTExceptionNotAvailable {
        // If we need the tail segment, then we need to refresh the spine
        // The default is _needsRefresh = true, so do nothing here
      }
    }

    // If a shared state is provided, enter composed mode as the last step
    if (composableSharedState != null) {
      spine.enterComposedMode(composableSharedState);
    }

    return spine;
  }

  @override
  Future<bool> close() async {
    if (!await super.close()) {
      return false;
    }

    await _stateLock.protectWrite(() async {
      // Two-phase drain: each open segment carries up to two spine-held
      // refs (create + LRU). Release LRU refs first, then any remaining
      // create refs for segments evicted from the cache during the
      // spine's lifetime.
      final lruFutures = <Future<void>>[];
      for (final seg in _openCache.toList()) {
        lruFutures.add(_segmentClosed(seg));
      }
      _openCache.clear();
      await Future.wait(lruFutures);

      final remainingFutures = <Future<void>>[];
      for (final seg in _openedSegments.keys.toList()) {
        remainingFutures.add(_segmentClosed(seg));
      }
      await Future.wait(remainingFutures);

      await _spineRecord.close();

      if (_openedSegments.isNotEmpty) {
        throw StateError(
          'should have closed all segments by now '
          '(${_openedSegments.length} remaining)',
        );
      }
    });

    return true;
  }

  // Will deep delete all segment records as they are children
  @override
  Future<bool> delete() {
    // Deleting mid-transaction would race the in-flight SYNC/WRITE state
    if (composableSharedState.inTransaction) {
      throw StateError('cannot delete a DHTLog during a transaction');
    }
    return _stateLock.protectWrite(_spineRecord.delete);
  }

  @override
  bool get isDeleted => _spineRecord.isDeleted;

  ////////////////////////////////////////////////////////////////////////////
  // DHTComposable lifecycle

  @override
  bool get needsRefresh => _state.needsRefresh;

  @override
  void markNeedsRefresh() => _state.markNeedsRefresh();

  @override
  int get refreshGen => _state.refreshGen;

  @override
  Set<DHTRecord> operateInitialRecords() => {_spineRecord};

  @override
  void beginWork() {
    if (_workingState != null) {
      throw StateError('already in work phase');
    }
    _workingState = _state.copy();
    _activeSegments.clear();
  }

  @override
  Future<void> flushWork() async {
    final ws = _workingState;
    if (ws == null) {
      return;
    }
    await Future.wait(
      _activeSegments.map((segment) => segment.flushWork()),
      eagerError: true,
    );
    if (_spineRecord.writer != null) {
      await writeSpineHead();
    }
  }

  @override
  Future<void> endWork(bool success) async {
    final ws = _workingState;
    if (ws == null) {
      return;
    }
    _workingState = null;

    final activeSegments = _activeSegments.toList(growable: false);
    _activeSegments.clear();
    await Future.wait(
      activeSegments.map((segment) => segment.endWork(success)),
    );

    if (success) {
      if (ws.postCommitDeleteKeys.isNotEmpty) {
        await _deleteSegmentRecords(ws.postCommitDeleteKeys);
      }

      await _stateLock.protectWrite(() async {
        final oldState = _state;
        _state = ws;
        final pl = _layout.positionLimit;
        final oldLength = _DHTLogSpine._ringDistance(
          oldState.tail,
          oldState.head,
          pl,
        );
        if (oldState.head != _state.head ||
            oldState.tail != _state.tail ||
            oldLength != _state.length) {
          sendUpdate(
            DHTLogUpdate(
              headDelta: _DHTLogSpine._ringDistance(
                _state.head,
                oldState.head,
                pl,
              ),
              tailDelta: _DHTLogSpine._ringDistance(
                _state.tail,
                oldState.tail,
                pl,
              ),
              length: _state.length,
            ),
          );
        }
      });
    }
  }

  @override
  Future<Future<void> Function()?> syncCheck() async {
    if (!composableSharedState.inTransaction) {
      throw StateError('syncCheck requires an active transaction');
    }

    final spineNeedsSync = await composableSharedState.withTransactionKey(
      _spineRecord.key,
      closure: (ops) async => ops.subkeyNeedsSync(subkey: 0),
    );

    // Tail segment lives in a separate record. If the spine head is current
    // but the tail segment has never been opened locally, the segment record
    // hasn't been faulted in yet and the closure needs to load it.
    final tail = _state.tail;
    final tailSegmentNumber = tail > 0
        ? (tail - 1) ~/ DHTShortArray.maxElements
        : null;
    final tailSegmentNeedsLoad =
        tailSegmentNumber != null &&
        !_openedSegments.containsKey(tailSegmentNumber);

    if (!spineNeedsSync && !tailSegmentNeedsLoad) {
      return null;
    }

    return () async {
      final ws = _workingState;
      if (ws == null) {
        throw StateError('working state must exist for sync');
      }

      _unavailableSegments.clear();

      if (spineNeedsSync) {
        final spineHead = await composableSharedState.withTransactionKey(
          _spineRecord.key,
          closure: (ops) => ops.getMigrated(
            _migrationCodec,
            subkey: 0,
            refreshMode: DHTRecordRefreshMode.update,
          ),
        );
        if (spineHead != null) {
          ws.updateFromProto(spineHead);
        }
      }

      final tail = ws.tail;
      final tailSegmentNumber = tail > 0
          ? (tail - 1) ~/ DHTShortArray.maxElements
          : null;
      if (tailSegmentNumber != null) {
        // Track cached-ness BEFORE _withPositionBySegment so we know whether
        // _openSegment's fresh-open syncCheck ran or not.
        final wasCached = _openedSegments.containsKey(tailSegmentNumber);

        await _withPositionBySegment(
          tailSegmentNumber,
          (tail - 1) % DHTShortArray.maxElements,
          closure: (_) async {},
        );

        // _openSegment syncs on fresh opens; for a cached tail segment we
        // must explicitly syncCheck so its length picks up elements appended
        // since the segment was last synced (spine head advanced).
        if (wasCached) {
          final seg = _openedSegments[tailSegmentNumber];
          if (seg != null) {
            await _activateSegment(seg.composable());
            final segSync = await seg.composable().syncCheck();
            if (segSync != null) {
              await segSync();
            }
          }
        }
      }
    };
  }

  Future<void> _activateSegment(DHTShortArrayComposable segment) async {
    if (_activeSegments.add(segment)) {
      await composableSharedState.extendTransaction(
        segment.operateInitialRecords(),
      );
      segment.beginWork();
    }
  }

  @override
  Future<T> read<T>(
    Future<T> Function(DHTLogReadOperations) closure, {
    DHTRetryStrategy? elementRetry,
  }) async {
    final reader = isComposed
        ? _DHTLogComposedRead._(this, elementRetry) as DHTLogReadOperations
        : _DHTLogRead._(this, elementRetry) as DHTLogReadOperations;
    return closure(reader);
  }

  @override
  Future<T> write<T>(
    Future<T> Function(DHTLogWriteOperations) closure, {
    DHTRetryStrategy? elementRetry,
  }) async {
    final writer = isComposed
        ? _DHTLogComposedWrite._(this, elementRetry) as DHTLogWriteOperations
        : _DHTLogWrite._(this, elementRetry) as DHTLogWriteOperations;
    return closure(writer);
  }

  @override
  Future<void> localReload() => _stateLock.protectWrite(() async {
    // Get spine head locally
    final headProto = await _spineRecord.getMigrated(
      _migrationCodec,
      subkey: 0,
      refreshMode: DHTRecordRefreshMode.local,
    );
    if (headProto == null) {
      // No spine head record locally, so local reload is not possible
      throw DHTExceptionNotAvailable(cause: 'no spine head record locally');
    }

    // See if we can reload the tail segment locally
    final newLength = _ringDistance(
      headProto.tail,
      headProto.head,
      _layout.positionLimit,
    );

    final oldHead = _state.head, oldTail = _state.tail;
    final oldLength = _DHTLogSpine._ringDistance(
      oldTail,
      oldHead,
      _layout.positionLimit,
    );

    var reloaded = false;

    if (newLength != 0) {
      // Reload the tail segment if the tail has changed from the local state
      if (headProto.tail != _state.tail) {
        try {
          await _withPositionBySegment(
            (headProto.tail - 1) ~/ DHTShortArray.maxElements,
            (headProto.tail - 1) % DHTShortArray.maxElements,
            allowCreate: false,
            allowNetwork: false,
            closure: (tailSegment) async {
              // Try to reload the tail segment locally
              await tailSegment.composable.localReload();
            },
          );
        } on DHTExceptionNotAvailable catch (e) {
          // If we need the tail segment, then local reload is not possible
          DHTRecordPool.instance.log('local reload of tail segment failed: $e');
          rethrow;
        }
        reloaded = true;
      }

      // Reload the head segment if the head has changed from the local state
      if (headProto.head != _state.head) {
        try {
          await _withPositionBySegment(
            headProto.head ~/ DHTShortArray.maxElements,
            headProto.head % DHTShortArray.maxElements,
            allowCreate: false,
            allowNetwork: false,
            closure: (headSegment) async {
              // Try to reload the head segment locally
              await headSegment.composable.localReload();
            },
          );
        } on DHTExceptionNotAvailable {
          // If we need the head segment, then local reload IS possible
          // because all segments other than the tail are lazily loaded
          // and we just haven't loaded the head segment yet
        }
        reloaded = true;
      }
    }

    if (reloaded) {
      // Local reload of tail segment worked, so update the state
      // and send an update if the state has changed
      _state.updateFromProto(headProto);

      if (oldHead != _state.head ||
          oldTail != _state.tail ||
          oldLength != _state.length) {
        sendUpdate(
          DHTLogUpdate(
            headDelta: _DHTLogSpine._ringDistance(
              _state.head,
              oldHead,
              _layout.positionLimit,
            ),
            tailDelta: _DHTLogSpine._ringDistance(
              _state.tail,
              oldTail,
              _layout.positionLimit,
            ),
            length: _state.length,
          ),
        );
      }
    }
  });

  ////////////////////////////////////////////////////////////////////////////
  // Standalone write lifecycle (sync-or-execute)

  // standaloneWrite and refresh are provided by
  // DefaultDHTComposableStandaloneWrite mixin.

  /// Serialize and write out the current spine head subkey.
  /// Throws DHTExceptionOutdated if the write conflicts.
  /// Routes through _currentTransaction.
  Future<void> writeSpineHead() async {
    if (!composableSharedState.inWriteScope) {
      throw StateError('writeSpineHead must run inside withWriteScope');
    }
    if (!composableSharedState.inTransaction) {
      throw StateError('writeSpineHead requires an active transaction');
    }
    final ws = _workingState;
    if (ws == null) {
      throw StateError('working state must exist for writeSpineHead');
    }

    final existingHead = await composableSharedState.withTransactionKey(
      _spineRecord.key,
      closure: (ops) => ops.tryWriteMigrated(_migrationCodec, ws.toProto()),
    );

    if (existingHead != null) {
      ws.updateFromProto(existingHead.value);
      throw const DHTExceptionOutdated(cause: 'spine head write conflict');
    }
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

  Future<DHTShortArray> _openOrCreateSegment(int segmentNumber) async {
    // In standalone mode, caller holds _networkMutex.
    // In composed mode, the outer collection holds its own mutex.
    if (_spineRecord.writer == null) {
      throw StateError('should be writable');
    }

    final l = _lookupSegment(segmentNumber);
    final subkey = l.subkey;
    final segment = l.segment;

    var subkeyData = await composableSharedState.withTransactionKey(
      _spineRecord.key,
      closure: (ops) async => ops.getBytes(subkey: subkey),
    );
    subkeyData ??= _makeEmptySubkey();

    while (true) {
      final segmentKey = _getSegmentKey(subkeyData!, segment);
      if (segmentKey == null) {
        final segmentRec = await DHTShortArray.create(
          debugName: '${_spineRecord.debugName}_spine_${subkey}_$segment',
          stride: _layout.stride,
          crypto: _spineRecord.crypto,
          parent: _spineRecord.key,
          routingContext: _spineRecord.routingContext,
          writer: _spineRecord.writer,
          encryptionKeyOverride: EncryptionKeyOverride.fromRecordKey(
            _spineRecord.key,
          ),
          composableSharedState: composableSharedState,
        );
        var success = false;
        try {
          _setSegmentKey(subkeyData, segment, segmentRec.recordKey);
          final writeResult = await composableSharedState
              .withTransactionKey<Uint8List?>(
                _spineRecord.key,
                closure: (ops) async =>
                    ops.tryWriteBytes(subkeyData!, subkey: subkey),
              );
          subkeyData = writeResult;
          if (subkeyData == null) {
            success = true;
            return segmentRec;
          }
        } finally {
          if (!success) {
            await segmentRec.delete();
            await segmentRec.close();
          }
        }
      } else {
        // Open a shortarray segment in composed mode
        final segmentRec = await DHTShortArray.openWrite(
          segmentKey,
          _spineRecord.writer!,
          debugName: '${_spineRecord.debugName}_spine_${subkey}_$segment',
          crypto: _spineRecord.crypto,
          parent: _spineRecord.key,
          routingContext: _spineRecord.routingContext,
          composableSharedState: composableSharedState,
        );
        await _syncOpenedSegmentOrThrow(segmentRec);
        return segmentRec;
      }
      // Loop if we need to try again with the new data from the network
    }
  }

  /// Open a segment for reading. Throws DHTExceptionNotAvailable if the
  /// segment is not available locally or from the network.
  /// [requiredMinLength] (if set) flows to _syncOpenedSegmentOrThrow so a
  /// stale-but-present cached segment head triggers fallback to refresh.
  Future<DHTShortArray> _openSegment(
    int segmentNumber, {
    required bool allowNetwork,
    int? requiredMinLength,
  }) async {
    // Lookup what subkey and segment subrange has this position's segment
    // shortarray
    final l = _lookupSegment(segmentNumber);
    final subkey = l.subkey;
    final segment = l.segment;

    // Try local first.
    RecordKey? segmentKey;
    var subkeyData = await _spineRecord.getBytes(
      subkey: subkey,
      refreshMode: DHTRecordRefreshMode.local,
    );
    if (subkeyData != null) {
      segmentKey = _getSegmentKey(subkeyData, segment);
    }
    if (segmentKey == null) {
      // Network reads must go through an active tx (strong-consensus fanout).
      if (!allowNetwork || !composableSharedState.inTransaction) {
        throw const DHTExceptionNotAvailable(
          cause: 'segment subkey data not available locally',
        );
      }
      subkeyData = await composableSharedState.withTransactionKey(
        _spineRecord.key,
        closure: (ops) => ops.getBytes(
          subkey: subkey,
          refreshMode: DHTRecordRefreshMode.network,
        ),
      );
      if (subkeyData == null) {
        throw const DHTExceptionNotAvailable(
          cause: 'segment subkey data not available',
        );
      }
      segmentKey = _getSegmentKey(subkeyData, segment);
      if (segmentKey == null) {
        throw const DHTExceptionNotAvailable(
          cause: 'segment key not found in subkey data',
        );
      }
    }

    // Open the segment with the same access level as the parent spine.
    // Opening read-only on a writable log would make subsequent writes through
    // the cached segment throw "value is not writable".
    final writer = _spineRecord.writer;
    final segmentRec = writer != null
        ? await DHTShortArray.openWrite(
            segmentKey,
            writer,
            debugName: '${_spineRecord.debugName}_spine_${subkey}_$segment',
            crypto: _spineRecord.crypto,
            parent: _spineRecord.key,
            routingContext: _spineRecord.routingContext,
            composableSharedState: composableSharedState,
          )
        : await DHTShortArray.openRead(
            segmentKey,
            debugName: '${_spineRecord.debugName}_spine_${subkey}_$segment',
            crypto: _spineRecord.crypto,
            parent: _spineRecord.key,
            routingContext: _spineRecord.routingContext,
            composableSharedState: composableSharedState,
          );

    await _syncOpenedSegmentOrThrow(
      segmentRec,
      requiredMinLength: requiredMinLength,
    );
    return segmentRec;
  }

  /// After opening a segment in composed mode, ensure its data is available.
  /// In an active transaction: extend the tx with the segment, run its
  /// syncCheck, and execute the returned sync closure. If sync fails the
  /// segment is closed and DHTExceptionNotAvailable is thrown.
  /// Outside a transaction: the segment must have loaded its head from the
  /// local cache (tryLoadCachedHead). If not, throw DHTExceptionNotAvailable.
  /// If [requiredMinLength] is non-null, also throw when the cached segment
  /// length is below it, so operateRead can fall back to operateWrite.
  Future<void> _syncOpenedSegmentOrThrow(
    DHTShortArray segmentRec, {
    int? requiredMinLength,
  }) async {
    try {
      if (composableSharedState.inTransaction) {
        await _activateSegment(segmentRec.composable());
        final segSyncClosure = await segmentRec.composable().syncCheck();
        if (segSyncClosure != null) {
          await segSyncClosure();
        }
      } else {
        if (segmentRec.composable().needsRefresh) {
          throw const DHTExceptionNotAvailable(
            cause: 'segment data not available locally',
          );
        }
        if (requiredMinLength != null) {
          final len = await segmentRec.operateRead((r) async => r.length);
          if (len < requiredMinLength) {
            throw const DHTExceptionNotAvailable(
              cause: 'segment length behind spine; needs sync',
            );
          }
        }
      }
    } on Exception catch (e) {
      await segmentRec.close();
      if (e is DHTExceptionNotAvailable) {
        rethrow;
      }
      throw DHTExceptionNotAvailable(cause: 'segment sync failed: $e');
    }
  }

  _DHTLogSegmentLookup _lookupSegment(int segmentNumber) {
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

  /// Run [closure] with a looked-up [_DHTLogPosition] for a specific
  /// segment, guaranteeing the position is closed on exit. See
  /// [_lookupPositionBySegment] for the bare lookup.
  Future<T> _withPositionBySegment<T>(
    int segmentNumber,
    int segmentPos, {
    bool allowCreate = false,
    bool allowNetwork = true,
    required Future<T> Function(_DHTLogPosition) closure,
  }) async {
    final lookup = await _lookupPositionBySegment(
      segmentNumber,
      segmentPos,
      allowCreate: allowCreate,
      allowNetwork: allowNetwork,
    );
    try {
      return await closure(lookup);
    } finally {
      await lookup.close();
    }
  }

  /// Open or lookup a segment position with LRU caching.
  /// When [allowCreate] is true (write mode), creates the segment if needed.
  /// When false (read mode), only opens existing segments.
  /// Caller MUST close the returned position. Prefer
  /// [_withPositionBySegment].
  Future<_DHTLogPosition> _lookupPositionBySegment(
    int segmentNumber,
    int segmentPos, {
    bool allowCreate = false,
    bool allowNetwork = true,
  }) => _openedSegmentsMutex.protect(() async {
    final openedSegment = _openedSegments[segmentNumber];
    late DHTShortArray segment;
    if (openedSegment != null) {
      openedSegment.ref();
      segment = openedSegment;
    } else {
      // Short-circuit only for non-tx attempts; an in-tx attempt has the
      // means to lazy-load the segment and should always be allowed to try.
      if (!composableSharedState.inTransaction &&
          _unavailableSegments.contains(segmentNumber)) {
        throw DHTExceptionNotAvailable(
          cause:
              'segment $segmentNumber previously unavailable; '
              'call refresh() to retry',
        );
      }
      _unavailableSegments.remove(segmentNumber);
      try {
        final newShortArray = (allowCreate && allowNetwork)
            ? await _openOrCreateSegment(segmentNumber)
            : await _openSegment(
                segmentNumber,
                allowNetwork: allowNetwork,
                requiredMinLength: segmentPos + 1,
              );
        _openedSegments[segmentNumber] = newShortArray;
        segment = newShortArray;
      } on DHTExceptionNotAvailable {
        // Only cache as unavailable when the network was actually consulted.
        if (allowNetwork) {
          _unavailableSegments.add(segmentNumber);
        }
        rethrow;
      }
    }

    // LRU cache the segment number
    if (!_openCache.remove(segmentNumber)) {
      segment.ref();
    }
    _openCache.add(segmentNumber);
    if (_openCache.length > _openedSegmentsLimit) {
      final lruseg = _openCache.removeAt(0);
      final lrusa = _openedSegments[lruseg]!;
      if (await lrusa.close()) {
        _openedSegments.remove(lruseg);
      }
    }

    if (composableSharedState.inTransaction) {
      await _activateSegment(segment.composable());
    }

    return _DHTLogPosition._(
      dhtLogSpine: this,
      composable: segment.composable(),
      pos: segmentPos,
      segmentNumber: segmentNumber,
    );
  });

  Future<bool> _segmentClosed(int segmentNumber) {
    return _openedSegmentsMutex.protect(() async {
      final sa = _openedSegments[segmentNumber]!;
      if (await sa.close()) {
        _openedSegments.remove(segmentNumber);
        return true;
      }
      return false;
    });
  }

  /// Phase 1: Null out segment keys in spine subkeys via the current
  /// transaction and collect the record keys to delete locally after commit.
  Future<List<RecordKey>> _clearSegmentsContiguous(int start, int end) async {
    DHTRecordPool.instance.log(
      '_clearSegmentsContiguous: start=$start, end=$end',
    );

    final keysToDelete = <RecordKey>[];

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
        // Flush subkey writes through transaction
        if (lastSubkeyData != null && lastSubkeyData.changed) {
          final result = await composableSharedState.withTransactionKey(
            _spineRecord.key,
            closure: (ops) => ops.tryWriteBytes(
              lastSubkeyData!.data,
              subkey: lastSubkeyData.subkey,
            ),
          );
          if (result != null) {
            throw const DHTExceptionOutdated();
          }
        }

        // Get next subkey if available locally
        final data = await composableSharedState.withTransactionKey(
          _spineRecord.key,
          closure: (ops) => ops.getBytes(
            subkey: subkey,
            refreshMode: DHTRecordRefreshMode.local,
          ),
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
          keysToDelete.add(segmentKey);
          _setSegmentKey(lastSubkeyData.data, segment, null);
          lastSubkeyData.changed = true;
        }
      }
    }
    // Flush subkey writes through transaction
    if (lastSubkeyData != null && lastSubkeyData.changed) {
      final result = await composableSharedState.withTransactionKey(
        _spineRecord.key,
        closure: (ops) => ops.tryWriteBytes(
          lastSubkeyData!.data,
          subkey: lastSubkeyData.subkey,
        ),
      );
      if (result != null) {
        throw const DHTExceptionOutdated();
      }
    }

    return keysToDelete;
  }

  /// Phase 1: Clear segment keys from spine subkeys for the range
  /// [from, to) in the ring buffer. Returns keys to delete after commit.
  Future<List<RecordKey>> clearReleasedSegments(int from, int to) async {
    // In standalone mode, caller holds _networkMutex.
    // In composed mode, the outer collection holds its own mutex.
    final keysToDelete = <RecordKey>[];
    if (from < to) {
      keysToDelete.addAll(await _clearSegmentsContiguous(from, to));
    } else if (from > to) {
      keysToDelete.addAll(
        await _clearSegmentsContiguous(from, _layout.positionLimit),
      );
      keysToDelete.addAll(await _clearSegmentsContiguous(0, to));
    }
    return keysToDelete;
  }

  /// Phase 2: Delete collected segment records locally after commit.
  Future<void> _deleteSegmentRecords(List<RecordKey> keys) async {
    for (final key in keys) {
      await DHTRecordPool.instance.deleteRecord(key);
    }
  }

  /////////////////////////////////////////////////////////////////////////////
  // Watch For Updates

  // Watch head for changes
  @override
  Future<void> watch() async {
    if (isComposed) {
      throw StateError('cannot watch in composed mode');
    }

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
  @override
  Future<void> cancelWatch() async {
    if (isComposed) {
      throw StateError('cannot cancel watch in composed mode');
    }

    await _spineRecord.cancelWatch();
    await _subscription?.close();
    _subscription = null;
  }

  // Called when the log changes online and we find out from a watch
  // but not when we make a change locally
  Future<void> _onSpineChanged(
    DHTRecord record,
    DHTRecordWatchChange change,
  ) async {
    if (record.key != _spineRecord.key) {
      throw StateError(
        'Unexpected spine record change for wrong record key: ${record.key} != ${_spineRecord.key}',
      );
    }

    if (isComposed) {
      throw StateError('cannot watch in composed mode');
    }

    // See if local changes are present, if so
    // refresh the state locally without network access
    if (change.localSubkeys.isNotEmpty) {
      // Verify the change is in the expected format
      if (change.localSubkeys.length != 1 ||
          change.localSubkeys[0] != ValueSubkeyRange.single(0)) {
        throw StateError(
          'Unexpected local spine record change for wrong subkey for record ${record.key}: ${change.localSubkeys} != ${ValueSubkeyRange.single(0)}',
        );
      }

      // Update the state locally without network access
      try {
        await localReload();
      } on DHTExceptionNotAvailable catch (e) {
        throw StateError(
          'Unexpected local spine record change with unavailable local reload for record ${record.key}: $e',
        );
      }
    }

    // If remote changes happened, queue up a fetch for them
    // Only process remote changes to the head record subkey 0
    // (matches the watch we set up)
    if (change.remoteSubkeys.isNotEmpty) {
      // Verify the change is in the expected format
      if (change.remoteSubkeys.length != 1 ||
          change.remoteSubkeys[0] != ValueSubkeyRange.single(0)) {
        throw StateError(
          'Unexpected remote head record change for wrong subkey: ${change.remoteSubkeys} != ${ValueSubkeyRange.single(0)}',
        );
      }

      // Queue up a refresh for the remote changes
      _spineChangeProcessor.update(() async {
        if (!isOpen) return;
        markNeedsRefresh();
        try {
          // Retry transient conditions (e.g. 'transaction begin contended') so a
          // live update isn't dropped; needsRefresh stays true on final failure
          // for the refresh driver to retry.
          await DHTRecordPool.instance.retry(() async {
            if (!isOpen) return;
            await refresh();
          });
        } on Exception catch (e, st) {
          veilidLoggy.warning('_onSpineChanged sync failed: $e\n$st');
        }
      });
    }
  }

  ////////////////////////////////////////////////////////////////////////////

  RecordKey get recordKey => _spineRecord.key;

  @override
  String get debugName => 'DHTLog($recordKey)';

  OwnedDHTRecordPointer? get recordPointer =>
      _spineRecord.ownedDHTRecordPointer;

  // Ring buffer distance from old to new
  static int _ringDistance(int n, int o, int positionLimit) =>
      (n < o) ? (positionLimit - o) + n : n - o;
}
