part of 'dht_record_pool.dart';

/// Internal context for a single record of a transaction
class _DHTRecordTxContext {
  /// The record being transacted on
  DHTRecord record;

  /// The report of the record's state at begin time
  DHTRecordReport report;

  /// Subkeys whose plaintext changed as a result of a commit
  List<ValueSubkeyRange> valueChanges = [];

  /// Constructor for a single record transaction context
  _DHTRecordTxContext(this.record, this.report);
}

/// Internal implementation for a transaction on multiple records
class _DHTRecordTransactionInner implements Finalize {
  /// The pool this transaction belongs to
  final DHTRecordPool pool;

  /// The map of record keys to their transaction contexts
  final Map<RecordKey, _DHTRecordTxContext> recordTxContexts;

  /// The low-level Veilid DHT transaction object
  final VeilidDHTTransaction dhttx;

  /// The debug name of the transaction
  final String debugName;

  /// Constructor for a transaction on multiple records
  _DHTRecordTransactionInner(
    this.pool,
    this.recordTxContexts,
    this.dhttx,
    this.debugName,
  );

  /// Access record inside transaction
  Future<T> withKey<T>(
    RecordKey key, {
    required Future<T> Function(DHTRecordTransactionOperations) closure,
  }) => closure(DHTRecordTransactionOperations._(this, key));

  /// Called by finalizer if commit or rollback was forgotten before drop
  @override
  Future<void> finalize() async {
    try {
      if (!dhttx.isDone) {
        pool.log(
          'DHTTransaction($debugName) had to be finalized. '
          'Rollback or Commit should be explicit.',
        );
      } else if (recordTxContexts.isNotEmpty) {
        pool.log(
          'DHTTransaction($debugName) had to be finalized '
          'even though it was done. '
          'This should not be a reachable condition.',
        );
      }
    } finally {
      await close();
    }
  }

  /// Called by commit, rollback, or finalizer to close out the object
  Future<void> close() async {
    try {
      if (!dhttx.isDone) {
        try {
          await dhttx.rollback();
        } on VeilidAPIExceptionTransactionNotFound {
          // Transaction already completed — expected during cleanup.
        } on VeilidAPIExceptionTryAgain {
          // DHT not online — expected during cleanup.
        } on VeilidAPIExceptionGeneric catch (e) {
          pool.log(
            'DHTTransaction($debugName) rollback cleanup: '
            'Generic: ${e.message}',
          );
        } on VeilidAPIExceptionInternal catch (e) {
          pool.log(
            'DHTTransaction($debugName) rollback cleanup '
            'ERROR: Internal: ${e.message}',
          );
        }
      }
    } finally {
      await Future.wait(recordTxContexts.values.map((x) => x.record.close()));
      recordTxContexts.clear();
    }
  }
}

class DHTRecordTransactionOperations
    with DefaultDHTRecordOperations<DHTTransactionSetValueOptions>
    implements DHTRecordOperations<DHTTransactionSetValueOptions> {
  final _DHTRecordTransactionInner _inner;
  final RecordKey _key;

  DHTRecordTransactionOperations._(this._inner, this._key);

  /// Get a record's subkey value from this transaction
  /// Returns the most recent value data for this subkey or null if this subkey
  /// has not yet been written to.
  /// * 'refreshMode' determines whether or not to return a locally existing
  ///   value or always check the network
  /// * 'outSeqNum' optionally returns the sequence number of the value being
  ///   returned if one was returned.
  @override
  Future<Uint8List?> getBytes({
    int subkey = -1,
    CryptoCodec? crypto,
    DHTRecordRefreshMode refreshMode = DHTRecordRefreshMode.cached,
    Output<int>? outSeqNum,
  }) {
    final recordInfo = _inner.recordTxContexts[_key]!;
    final record = recordInfo.record;
    subkey = record.subkeyOrDefault(subkey);
    final lastSeq = _localSubkeySeq(recordInfo, subkey);
    final networkSeq = _networkSubkeySeq(recordInfo, subkey);

    final cs = crypto ?? record._crypto;

    return _wrapStats(record, 'DHTTransaction::getBytes', () async {
      Uint8List data;
      int seq;
      var fetchedFromNetwork = false;

      switch (refreshMode) {
        case DHTRecordRefreshMode.cached:
          if (lastSeq != null) {
            // Available locally, return it
            final localValueData = await record.routingContext.getDHTValue(
              _key,
              subkey,
            );
            data = localValueData!.data;
            seq = lastSeq;
          } else {
            // Get it from the transaction
            if (networkSeq == null) {
              return null;
            }
            final valueData = (await _inner.dhttx.get(_key, subkey))!;
            data = valueData.data;
            seq = valueData.seq;
            fetchedFromNetwork = true;
          }
        case DHTRecordRefreshMode.local:
          if (lastSeq == null) {
            // If it's not available locally already just return null now
            return null;
          }
          // Available locally, return it
          final localValueData = await record.routingContext.getDHTValue(
            _key,
            subkey,
          );
          data = localValueData!.data;
          seq = lastSeq;
        case DHTRecordRefreshMode.network:
          if (networkSeq == null) {
            return null;
          }
          // If the local copy is already current with the network seq from
          // tx begin-inspect, use it instead of paying a network round-trip.
          if (lastSeq != null && lastSeq == networkSeq) {
            final localValueData = await record.routingContext.getDHTValue(
              _key,
              subkey,
            );
            data = localValueData!.data;
            seq = lastSeq;
          } else {
            final valueData = (await _inner.dhttx.get(_key, subkey))!;
            data = valueData.data;
            seq = valueData.seq;
            fetchedFromNetwork = true;
          }
        case DHTRecordRefreshMode.update:
          if (networkSeq == null ||
              (lastSeq != null && networkSeq <= lastSeq)) {
            // If we're only returning updates then punt now
            return null;
          }
          // Get it from the transaction
          final valueData = (await _inner.dhttx.get(_key, subkey))!;
          data = valueData.data;
          seq = valueData.seq;
          fetchedFromNetwork = true;
      }

      // If we're returning a value, decrypt it
      final out = await cs.decrypt(data);

      // Flag a remote value change if the network fetch produced a different
      // plaintext than the local cache; encrypted-only / seq-only diffs don't.
      if (fetchedFromNetwork) {
        Uint8List? localPlaintext;
        if (lastSeq != null) {
          final lv = await record.routingContext.getDHTValue(_key, subkey);
          if (lv != null) {
            localPlaintext = await cs.decrypt(lv.data);
          }
        }
        if (localPlaintext == null || !out.equals(localPlaintext)) {
          _addValueChange(recordInfo, subkey);
        }
      }

      if (outSeqNum != null) {
        outSeqNum.save(seq);
      }
      return out;
    });
  }

  /// Attempt to write a byte buffer to a DHTTransaction record subkey
  /// If a newer value was found on the network, it is returned
  /// If the value was succesfully written, null is returned
  @override
  Future<Uint8List?> tryWriteBytes(
    Uint8List newValue, {
    int subkey = -1,
    CryptoCodec? crypto,
    DHTTransactionSetValueOptions? options,
    Output<int>? outSeqNum,
  }) {
    final recordInfo = _inner.recordTxContexts[_key]!;
    final record = recordInfo.record;
    subkey = record.subkeyOrDefault(subkey);
    final lastSeq = _localSubkeySeq(recordInfo, subkey);
    final cs = crypto ?? record._crypto;

    return _wrapStats(record, 'DHTTransaction::tryWriteBytes', () async {
      // Compare unencrypted bytes against the local cache. AEAD encryption
      // uses random nonces so encrypted bytes can't be compared directly.
      if (lastSeq != null) {
        final localValueData = await record.routingContext.getDHTValue(
          _key,
          subkey,
        );
        if (localValueData != null) {
          final localPlaintext = await cs.decrypt(localValueData.data);
          if (newValue.equals(localPlaintext)) {
            if (outSeqNum != null) {
              outSeqNum.save(lastSeq);
            }
            return null;
          }
        }
      }

      final encryptedNewValue = await cs.encrypt(newValue);

      final newValueData = await DHTRecordPool.instance._veilidApiRetry(
        () => _inner.dhttx.set(
          _key,
          subkey,
          encryptedNewValue,
          options: DHTTransactionSetValueOptions(
            writer: options?.writer ?? record._writer,
          ),
        ),
      );

      // Record new sequence number
      int newSeqNum;
      if (newValueData == null) {
        newSeqNum = (lastSeq != null ? lastSeq + 1 : 0);
      } else {
        newSeqNum = newValueData.seq;
      }
      final isUpdated = newSeqNum != lastSeq;
      if (outSeqNum != null) {
        outSeqNum.save(newSeqNum);
      }

      // See if the encrypted data returned is exactly the same
      // if so, shortcut and don't bother decrypting it
      if (newValueData == null || newValueData.data.equals(encryptedNewValue)) {
        if (isUpdated) {
          _addValueChange(recordInfo, subkey);
        }
        return null;
      }

      // Decrypt value to return it
      final decryptedNewValue = await cs.decrypt(newValueData.data);
      if (isUpdated) {
        _addValueChange(recordInfo, subkey);
      }
      return decryptedNewValue;
    });
  }

  /// Return the inspection state of a set of subkeys of a record in
  /// the DHTTransaction.
  /// See Veilid's 'inspectDHTRecord' call for details on how this works
  @override
  Future<DHTRecordReport> inspect({
    List<ValueSubkeyRange>? subkeys,
    DHTReportScope scope = DHTReportScope.local,
  }) {
    final recordInfo = _inner.recordTxContexts[_key]!;
    final record = recordInfo.record;

    return _wrapStats(record, 'DHTTransaction::inspect', () async {
      // Shortcut if we already have the report, because it never changes
      // until the commit
      if ((subkeys == null || subkeys.equals(recordInfo.report.subkeys)) &&
          scope == DHTReportScope.syncGet) {
        return recordInfo.report;
      }

      // Get a new report
      return _inner.dhttx.inspect(_key, subkeys: subkeys, scope: scope);
    });
  }

  ////////////////////////////////////////////////////////////////////////////
  // Private Implementation

  @override
  DHTTransactionSetValueOptions eventualOptions(KeyPair? writer) =>
      DHTTransactionSetValueOptions(
        writer: writer ?? _inner.recordTxContexts[_key]!.record._writer,
      );

  /// Check if a subkey needs sync by comparing local and network seq numbers
  /// from the transaction begin inspect. No network access required.
  /// Returns true if the network has a newer version than local cache.
  bool subkeyNeedsSync({int subkey = -1}) {
    final recordInfo = _inner.recordTxContexts[_key]!;
    final record = recordInfo.record;
    subkey = record.subkeyOrDefault(subkey);
    final localSeq = _localSubkeySeq(recordInfo, subkey);
    final networkSeq = _networkSubkeySeq(recordInfo, subkey);
    if (networkSeq == null) {
      return false; // no network data
    }
    if (localSeq == null) {
      return true; // network has data, local doesn't
    }
    return networkSeq > localSeq;
  }

  /// Get the set of all subkeys that need sync (network seq > local seq).
  /// Uses only the inspect data from the transaction begin — no network access.
  Set<int> subkeysNeedSync() {
    final recordInfo = _inner.recordTxContexts[_key]!;
    final result = <int>{};
    final localSeqs = recordInfo.report.localSeqs;
    final networkSeqs = recordInfo.report.networkSeqs;
    for (var i = 0; i < networkSeqs.length; i++) {
      final networkSeq = networkSeqs[i];
      if (networkSeq == null) {
        continue;
      }
      final localSeq = i < localSeqs.length ? localSeqs[i] : null;
      if (localSeq == null || networkSeq > localSeq) {
        result.add(i);
      }
    }
    return result;
  }

  int? _localSubkeySeq(_DHTRecordTxContext recordInfo, int subkey) =>
      recordInfo.report.localSeqs[subkey];

  int? _networkSubkeySeq(_DHTRecordTxContext recordInfo, int subkey) =>
      recordInfo.report.networkSeqs[subkey];

  void _addValueChange(_DHTRecordTxContext recordInfo, int subkey) {
    recordInfo.valueChanges = recordInfo.valueChanges.insertSubkey(subkey);
  }

  Future<T> _wrapStats<T>(
    DHTRecord record,
    String func,
    Future<T> Function() closure,
  ) => DHTRecordPool.instance._stats.measure(
    record.key,
    record.debugName,
    func,
    () => DHTException.wrap(closure),
  );
}

//////////////////////////////////////////////////////////////////////////////

/// A high-level DHT transaction for DHTRecord operations
/// Provides transactional access to multiple records at once
/// Ensures all operations are atomic and consistent
/// Provides a unified interface for transactional operations
/// on multiple records
///
/// Example:
/// ```dart
/// final transaction = await DHTRecordPool.transact([record1, record2], debugName: 'MyTransaction');
/// // perform operations
/// await transaction.commit();
/// ```
class DHTRecordTransaction implements DebugName {
  ////////////////////////////////////////////////////////////////////////////
  // Fields

  // Lifecycle ops (commit/rollback/extend) take the write lock; per-key
  // get/set ops via [withKey] take the read lock so they can run
  // concurrently. veilid-core serializes per-subkey internally, so two
  // get/set operations on different subkeys are safe to overlap.
  final ReadWriteMutex _mutex = ReadWriteMutex(
    debugLockTimeout: kIsDebugMode ? 60 : null,
  );
  final _DHTRecordTransactionInner _inner;

  /// Asynchronous finalizer registration for the inner object
  static final Finalizer<_DHTRecordTransactionInner> _finalizer = Finalizer(
    (inner) => inner.pool.lateFinalizer(inner),
  );

  /// Private constructor, use DHTRecordPool.transact() to create
  DHTRecordTransaction._({
    required DHTRecordPool pool,
    required List<_DHTRecordTxContext> recordTxContexts,
    required VeilidDHTTransaction dhttx,
    required String debugName,
  }) : _inner = _DHTRecordTransactionInner(
         pool,
         {for (final r in recordTxContexts) r.record.key: r},
         dhttx,
         debugName,
       ) {
    // Ref all the records. Unref'd in close()
    for (final recordInfo in recordTxContexts) {
      recordInfo.record.ref();
    }
    // Attach finalizer to ensure things clean up even if the
    // user forgets to close()
    _finalizer.attach(this, _inner, detach: this);
  }

  ////////////////////////////////////////////////////////////////////////////
  // Public Interface

  /// Record pool this transaction belongs to
  DHTRecordPool get pool => _inner.pool;

  /// Check if the transaction is done
  bool get isDone => _inner.dhttx.isDone;

  /// Perform operations on a specific record within this transaction.
  /// The closure receives an operations object with full
  /// DefaultDHTRecordOperations support (tryWriteMigrated, getMigrated, etc.)
  Future<T> withKey<T>(
    RecordKey key, {
    required Future<T> Function(DHTRecordTransactionOperations) closure,
  }) => _mutex.protectRead(() => _inner.withKey(key, closure: closure));

  /// Apply all changes locally and remotely for all transactional
  /// gets and sets. No changes will be made remotely or locally until this is
  /// called. Note that even if you only 'get' values, a commit can still
  /// make local changes if the values retrieved from the network are newer
  /// than the previous local values.
  Future<void> commit() => DHTException.wrap(
    () => _mutex.protectWrite(() async {
      try {
        await _inner.dhttx.commit();

        // Notify value changes made locally to all record handles associated
        // with the keys involved in this transaction.
        for (final recordInfo in _inner.recordTxContexts.values) {
          if (recordInfo.valueChanges.isNotEmpty) {
            // Add value changes as _local changes_ because they have
            // already been applied to the local record store by the commit,
            // and do not require a network fetch to retrieve them.
            pool._addLocalValueChange(
              recordInfo.record.key,
              recordInfo.valueChanges,
            );
          }
        }
      } finally {
        // Detach before close so a throw in _inner.close() doesn't leave a
        // phantom lateFinalizer.
        _finalizer.detach(this);
        await _inner.close();
      }
    }),
  );

  /// Drop all changes locally and remotely for all transactional
  /// gets and sets. No changes will be made remotely or locally if this
  /// is called.
  Future<void> rollback() => DHTException.wrap(
    () => _mutex.protectWrite(() async {
      _finalizer.detach(this);
      await _inner.close();
    }),
  );

  /// Extend the transaction with additional records.
  /// Idempotent: records already in the transaction are skipped.
  Future<void> extend(
    Iterable<DHTRecord> records, {
    TransactDHTRecordsOptions? options,
  }) => DHTException.wrap(
    () => _mutex.protectWrite(() async {
      final newRecords = records
          .where((r) => !_inner.recordTxContexts.containsKey(r.key))
          .toList();
      if (newRecords.isEmpty) {
        return;
      }

      await DHTRecordPool.instance._veilidApiRetry(
        () => _inner.dhttx.extend(
          newRecords.map((r) => r.key).toList(),
          options: options,
        ),
      );

      for (final record in newRecords) {
        final report = await _inner.dhttx.inspect(
          record.key,
          scope: DHTReportScope.syncGet,
        );
        record.ref();
        _inner.recordTxContexts[record.key] = _DHTRecordTxContext(
          record,
          report,
        );
      }
    }),
  );

  ////////////////////////////////////////////////////////////////////////////
  // DebugName

  @override
  String get debugName => _inner.debugName;
}
