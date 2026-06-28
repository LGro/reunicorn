part of 'dht_short_array.dart';

typedef _DefaultDHTShortArrayComposable =
    DefaultDHTComposable<
      DHTShortArrayReadOperations,
      DHTShortArrayWriteOperations,
      void
    >;

class _DHTShortArrayHead with _DefaultDHTShortArrayComposable {
  ////////////////////////////////////////////////////////////////////////////

  // Read-write lock for local state (index, seqs, linked records).
  // READs acquire read lock (concurrent), SYNC/WRITE commit acquires write lock.
  final _stateLock = ReadWriteMutex(debugLockTimeout: kIsDebugMode ? 60 : null);

  // Serializes getOrCreateLinkedRecord. Concurrent _getImpl fans out via
  // Future.wait; without this they can race on the create-and-extend path
  // and leave a lookup record absent from the tx's recordTxContexts.
  final _linkedRecordsLock = Mutex(debugLockTimeout: kIsDebugMode ? 60 : null);

  // Subscription to head record internal changes
  DHTRecordWatchSubscription? _subscription;

  // Stateless processor for head change serialization — ensures
  // the sync loop runs until no more updates are pending
  final _headChangeProcessor = SingleStatelessProcessor();

  // Head DHT record
  final DHTRecord _headRecord;

  // How many elements per linked record
  late final int _stride;

  // The committed head state.
  // Protected by _stateLock. READs see this.
  // Initialized in constructor body because _DHTShortArrayHeadState
  // needs a reference to this _DHTShortArrayHead.
  late _DHTShortArrayHeadState _state;

  // In-flight working state, set by beginWork and cleared by endWork.
  _DHTShortArrayHeadState? _workingState;

  // Migration codec
  static final _migrationCodec = DHTShortArrayMigrationCodec();

  _DHTShortArrayHead._({
    required DHTRecord headRecord,
    bool needsRefresh = true,
  }) : _headRecord = headRecord {
    _calculateStride();
    _state = _DHTShortArrayHeadState(
      this,
      linkedRecords: [],
      index: [],
      free: [],
      seqs: [],
      localSeqs: [],
      needsRefresh: needsRefresh,
    );
  }

  /// Create a new DHTShortArray head record and write initial state.
  static Future<_DHTShortArrayHead> create({
    required String debugName,
    CryptoKind? kind,
    int stride = DHTShortArray.maxElements,
    VeilidRoutingContext? routingContext,
    RecordKey? parent,
    CryptoCodec? crypto,
    KeyPair? writer,
    EncryptionKeyOverride? encryptionKeyOverride,
    DHTComposableSharedState? composableSharedState,
  }) async {
    assert(stride <= DHTShortArray.maxElements, 'stride too long');
    final pool = DHTRecordPool.instance;

    late final DHTRecord dhtRecord;
    if (writer != null) {
      final schema = DHTSchema.smpl(
        oCnt: 0,
        members: [
          DHTSchemaMember(
            mKey: (await pool.veilid.generateMemberId(writer.key)).value,
            mCnt: stride + 1,
          ),
        ],
      );
      dhtRecord = await pool.createRecord(
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
      final schema = DHTSchema.dflt(oCnt: stride + 1);
      dhtRecord = await pool.createRecord(
        debugName: debugName,
        kind: kind,
        parent: parent,
        routingContext: routingContext,
        schema: schema,
        crypto: crypto,
        encryptionKeyOverride: encryptionKeyOverride,
      );
    }

    // Empty head is valid at creation time
    final head = _DHTShortArrayHead._(
      headRecord: dhtRecord,
      needsRefresh: false,
    );
    try {
      if (composableSharedState != null) {
        // Composed: head joins the caller's tx (parent activates + flushes it);
        // committing here would make the record independently live mid-append
        // and race rehydration against the still-open parent transaction.
        head.enterComposedMode(composableSharedState);
      } else {
        // Standalone: write the head to the network in its own transaction.
        await head.standaloneSharedState.withWriteScope(
          () => head.operateWrite(() async {}),
        );
      }
      return head;
    } on Exception {
      await dhtRecord.close();
      await pool.deleteRecord(dhtRecord.key);
      rethrow;
    }
  }

  /// Open a DHTShortArray head record for reading.
  static Future<_DHTShortArrayHead> openRead(
    RecordKey headRecordKey, {
    required String debugName,
    VeilidRoutingContext? routingContext,
    RecordKey? parent,
    CryptoCodec? crypto,
    DHTComposableSharedState? composableSharedState,
  }) async {
    final dhtRecord = await DHTRecordPool.instance.openRecordRead(
      headRecordKey,
      debugName: debugName,
      parent: parent,
      routingContext: routingContext,
      crypto: crypto,
    );
    try {
      return await _loadFromRecord(dhtRecord, composableSharedState);
    } on Exception {
      await dhtRecord.close();
      rethrow;
    }
  }

  /// Open a DHTShortArray head record for writing.
  static Future<_DHTShortArrayHead> openWrite(
    RecordKey headRecordKey,
    KeyPair writer, {
    required String debugName,
    VeilidRoutingContext? routingContext,
    RecordKey? parent,
    CryptoCodec? crypto,
    DHTComposableSharedState? composableSharedState,
  }) async {
    final dhtRecord = await DHTRecordPool.instance.openRecordWrite(
      headRecordKey,
      writer,
      debugName: debugName,
      parent: parent,
      routingContext: routingContext,
      crypto: crypto,
    );
    try {
      return await _loadFromRecord(dhtRecord, composableSharedState);
    } on Exception {
      await dhtRecord.close();
      rethrow;
    }
  }

  /// Build a head from a freshly opened DHTRecord. Loads the head proto from
  /// the local cache when present; leaves the state empty (needsRefresh stays
  /// true) when absent so the caller's open-time refresh fetches it from the
  /// network. Mirrors _DHTLogSpine._loadFromRecord.
  static Future<_DHTShortArrayHead> _loadFromRecord(
    DHTRecord headRecord,
    DHTComposableSharedState? composableSharedState,
  ) async {
    final head = _DHTShortArrayHead._(headRecord: headRecord);

    final headProto = await headRecord.getMigrated(
      _migrationCodec,
      subkey: 0,
      refreshMode: DHTRecordRefreshMode.local,
    );
    if (headProto != null) {
      await head._state.updateFromProto(headProto);
    }

    if (composableSharedState != null) {
      head.enterComposedMode(composableSharedState);
    }

    return head;
  }

  void _calculateStride() {
    switch (_headRecord.schema) {
      case DHTSchemaDFLT(oCnt: final oCnt):
        if (oCnt <= 1) {
          throw StateError('Invalid DFLT schema in DHTShortArray');
        }
        _stride = oCnt - 1;
      case DHTSchemaSMPL(oCnt: final oCnt, members: final members):
        if (oCnt != 0 || members.length != 1 || members[0].mCnt <= 1) {
          throw StateError('Invalid SMPL schema in DHTShortArray');
        }
        _stride = members[0].mCnt - 1;
    }
    assert(_stride <= DHTShortArray.maxElements, 'stride too long');
    assert(_stride >= DHTShortArray.minStride, 'stride too short');
  }

  ////////////////////////////////////////////////////////////////////////////
  // Properties

  RecordKey get recordKey => _headRecord.key;

  KeyPair? get writer => _headRecord.writer;

  OwnedDHTRecordPointer? get recordPointer => _headRecord.ownedDHTRecordPointer;

  @override
  @override
  String get debugName => _headRecord.debugName;

  ////////////////////////////////////////////////////////////////////////////
  // DHTCloseable

  @override
  Future<bool> close() async {
    if (!await super.close()) {
      return false;
    }

    // Close the records in use
    await _stateLock.protectWrite(() async {
      await Future.wait([
        _headRecord.close(),
        ..._state.linkedRecords.map((x) => x.close()),
      ]);
    });

    return true;
  }

  ////////////////////////////////////////////////////////////////////////////
  // DHTDeleteable

  @override
  Future<bool> delete() {
    // Deleting mid-transaction would race the in-flight SYNC/WRITE state
    if (composableSharedState.inTransaction) {
      throw StateError('cannot delete a DHTShortArray during a transaction');
    }
    return _stateLock.protectWrite(
      () async => (await Future.wait([
        _headRecord.delete(),
        ..._state.linkedRecords.map((x) => x.delete()),
      ])).reduce((value, element) => value && element),
    );
  }

  @override
  bool get isDeleted => _headRecord.isDeleted;

  ////////////////////////////////////////////////////////////////////////////
  // DHTComposable lifecycle

  @override
  bool get needsRefresh => _state.needsRefresh;

  @override
  void markNeedsRefresh() => _state.markNeedsRefresh();

  @override
  int get refreshGen => _state.refreshGen;

  @override
  Set<DHTRecord> operateInitialRecords() => {_headRecord};

  @override
  void beginWork() {
    if (_workingState != null) {
      throw StateError('already in work phase');
    }
    _workingState = _state.copy();
  }

  @override
  Future<void> flushWork() async {
    if (_workingState == null) {
      return;
    }
    if (_headRecord.writer != null) {
      await writeHead();
    }
  }

  @override
  Future<void> endWork(bool success) async {
    if (success) {
      if (await _commitWorkingState()) {
        sendUpdate(null);
      }
    } else {
      await _cleanupWorkingState();
    }
  }

  @override
  Future<Future<void> Function()?> syncCheck() async {
    if (!composableSharedState.inTransaction) {
      throw StateError('syncCheck requires an active transaction');
    }

    // A freshly opened record (no cached head) always needs sync; skip
    // the inspect since begin may not report network seqs for it.
    if (!needsRefresh) {
      final headNeedsSync = await composableSharedState.withTransactionKey(
        _headRecord.key,
        closure: (ops) async => ops.subkeyNeedsSync(subkey: 0),
      );
      if (!headNeedsSync) {
        return null;
      }
    }

    return () async {
      final ws = _workingState;
      if (ws == null) {
        throw StateError('working state must exist for sync');
      }

      // Sync the head proto only. Elements lazy-load on read via the
      // tx-aware path so a refresh doesn't have to drag every element
      // record into the transaction (which would overflow tx record
      // limits for non-trivial arrays).
      final head = await composableSharedState.withTransactionKey(
        _headRecord.key,
        closure: (ops) => ops.getMigrated(
          _migrationCodec,
          subkey: 0,
          refreshMode: DHTRecordRefreshMode.network,
        ),
      );
      if (head == null) {
        throw const DHTExceptionNotAvailable(
          cause: 'short array head not available on network',
        );
      }
      await ws.updateFromProto(head);
    };
  }

  @override
  Future<T> read<T>(
    Future<T> Function(DHTShortArrayReadOperations) closure, {
    DHTRetryStrategy? elementRetry,
  }) async {
    final reader = isComposed
        ? _DHTShortArrayComposedRead._(this, elementRetry)
              as DHTShortArrayReadOperations
        : _DHTShortArrayRead._(this, elementRetry)
              as DHTShortArrayReadOperations;
    return closure(reader);
  }

  @override
  Future<T> write<T>(
    Future<T> Function(DHTShortArrayWriteOperations) closure, {
    DHTRetryStrategy? elementRetry,
  }) async {
    final writer = isComposed
        ? _DHTShortArrayComposedWrite._(this, elementRetry)
              as DHTShortArrayWriteOperations
        : _DHTShortArrayWrite._(this, elementRetry)
              as DHTShortArrayWriteOperations;
    return closure(writer);
  }

  @override
  Future<void> localReload() async => _stateLock.protectWrite(() async {
    // Update the state locally without network access
    final headProto = await _headRecord.getMigrated(
      _migrationCodec,
      subkey: 0,
      refreshMode: DHTRecordRefreshMode.local,
    );
    if (headProto == null) {
      // No head record locally, so local reload is not possible
      throw DHTExceptionNotAvailable(cause: 'no head record locally');
    }
    await _state.updateFromProto(headProto);
    sendUpdate(null);
  });

  ////////////////////////////////////////////////////////////////////////////
  // Working state management

  Future<bool> _commitWorkingState() async => _stateLock.protectWrite(() async {
    final ws = _workingState;
    _workingState = null;
    if (ws == null) {
      return false;
    }

    final newRecordKeys = ws.linkedRecords.map((r) => r.key).toSet();
    for (final r in _state.linkedRecords) {
      if (!newRecordKeys.contains(r.key)) {
        await r.close();
      }
    }

    _state = ws;
    return true;
  });

  Future<void> _cleanupWorkingState() async =>
      _stateLock.protectWrite(() async {
        final ws = _workingState;
        _workingState = null;
        if (ws == null) {
          return;
        }

        final committedKeys = _state.linkedRecords.map((r) => r.key).toSet();
        final orphanedRecords = ws.linkedRecords
            .where((r) => !committedKeys.contains(r.key))
            .toList();

        for (final record in orphanedRecords) {
          try {
            await record.delete();
            await record.close();
          } on Exception catch (e) {
            veilidLoggy.error(
              'Failed to cleanup orphaned linked record '
              '${record.key}: $e',
            );
          }
        }
      });

  ////////////////////////////////////////////////////////////////////////////
  // Linked record management

  /// Get or create a linked record by record number on the given state.
  Future<DHTRecord> getOrCreateLinkedRecord(
    _DHTShortArrayHeadState st,
    int recordNumber,
  ) => _linkedRecordsLock.protect(() async {
    if (recordNumber == 0) {
      return _headRecord;
    }
    final keyIdx = recordNumber - 1;

    if (keyIdx >= st.linkedRecords.length) {
      final pool = DHTRecordPool.instance;
      for (var rn = st.linkedRecords.length; rn <= keyIdx; rn++) {
        final smplWriter = _headRecord.writer!;
        final parent = _headRecord.key;
        final routingContext = _headRecord.routingContext;
        final crypto = _headRecord.crypto;

        final schema = DHTSchema.smpl(
          oCnt: 0,
          members: [
            DHTSchemaMember(
              mKey: (await pool.veilid.generateMemberId(smplWriter.key)).value,
              mCnt: _stride,
            ),
          ],
        );
        final dhtRecord = await pool.createRecord(
          debugName: '${_headRecord.debugName}_linked_$rn',
          parent: parent,
          routingContext: routingContext,
          schema: schema,
          crypto: crypto,
          writer: smplWriter,
          encryptionKeyOverride: EncryptionKeyOverride.fromRecordKey(parent),
        );
        st.linkedRecords.add(dhtRecord);
      }
    }
    final record = st.linkedRecords[keyIdx];
    if (composableSharedState.inTransaction) {
      await composableSharedState.extendTransaction({record});
    }
    return record;
  });

  /// Open a linked record for reading or writing.
  Future<DHTRecord> openLinkedRecord(
    RecordKey recordKey,
    int recordNumber,
  ) async {
    final writer = _headRecord.writer;
    return (writer != null)
        ? await DHTRecordPool.instance.openRecordWrite(
            recordKey,
            writer,
            debugName: '${_headRecord.debugName}_linked_$recordNumber',
            parent: _headRecord.key,
            routingContext: _headRecord.routingContext,
          )
        : await DHTRecordPool.instance.openRecordRead(
            recordKey,
            debugName: '${_headRecord.debugName}_linked_$recordNumber',
            parent: _headRecord.key,
            routingContext: _headRecord.routingContext,
          );
  }

  ////////////////////////////////////////////////////////////////////////////
  // Head record management

  /// Serialize and write out the current head record through the transaction.
  /// Throws DHTExceptionOutdated if the write conflicts.
  Future<void> writeHead() async {
    if (!composableSharedState.inWriteScope) {
      throw StateError('writeHead must run inside withWriteScope');
    }
    if (!composableSharedState.inTransaction) {
      throw StateError('writeHead requires an active transaction');
    }
    final ws = _workingState;
    if (ws == null) {
      throw StateError('working state must exist for writeHead');
    }

    final existingHead = await composableSharedState.withTransactionKey(
      _headRecord.key,
      closure: (ops) => ops.tryWriteMigrated(_migrationCodec, ws.toProto()),
    );
    if (existingHead != null) {
      await ws.updateFromProto(existingHead.value);
      throw const DHTExceptionOutdated(cause: 'head write conflict');
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
      _subscription ??= await _headRecord.listen(_onHeadValueChanged);

      await _headRecord.watch(subkeys: [ValueSubkeyRange.single(0)]);
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
      throw StateError('cannot watch in composed mode');
    }

    await _headRecord.cancelWatch();
    await _subscription?.close();
    _subscription = null;
  }

  // Called when the shortarray changes online and we find out from a watch
  // but not when we make a change locally
  Future<void> _onHeadValueChanged(
    DHTRecord record,
    DHTRecordWatchChange change,
  ) async {
    if (record.key != _headRecord.key) {
      throw StateError(
        'Unexpected head record change for wrong record key: ${record.key} != ${_headRecord.key}',
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
          'Unexpected local head record change for wrong subkey: ${change.localSubkeys} != ${ValueSubkeyRange.single(0)}',
        );
      }

      // Update the state locally without network access
      try {
        await localReload();
      } on DHTExceptionNotAvailable catch (e) {
        throw StateError(
          'Unexpected local head record change with unavailable local reload for record ${record.key}: $e',
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
      _headChangeProcessor.update(() async {
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
          veilidLoggy.warning('_onHeadValueChanged sync failed: $e\n$st');
        }
      });
    }
  }
}
