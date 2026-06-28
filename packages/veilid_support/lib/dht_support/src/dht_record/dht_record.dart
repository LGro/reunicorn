part of 'dht_record_pool.dart';

/// Type of a listen onUpdate callback for watch listen subscriptions
typedef DHTRecordWatchOnUpdate =
    Future<void> Function(DHTRecord record, DHTRecordWatchChange change);

/// A change reported by a DHTRecord watch's listen subscription
@immutable
class DHTRecordWatchChange extends Equatable {
  /// The data for a single subkey that changed remotely
  /// Will be the fist subkey in the `remoteSubkeys` range if not null
  final Uint8List? remoteData;

  /// The subkeys that changed remotely
  final List<ValueSubkeyRange> remoteSubkeys;

  /// The subkeys that changed locally
  final List<ValueSubkeyRange> localSubkeys;

  const DHTRecordWatchChange._({
    required this.remoteData,
    required this.remoteSubkeys,
    required this.localSubkeys,
  });

  @override
  List<Object?> get props => [remoteData, remoteSubkeys, localSubkeys];
}

/// Refresh mode for DHT record 'get'
enum DHTRecordRefreshMode {
  /// Return existing subkey values if they exist locally already
  /// If not, check the network for a value
  /// This is the default refresh mode
  cached,

  /// Return existing subkey values only if they exist locally already
  local,

  /// Always check the network for a newer subkey value
  network,

  /// Always check the network for a newer subkey value but only
  /// return that value if its sequence number is newer than the local value
  update;

  bool get _forceRefresh => this == network || this == update;
  bool get _inspectLocal => this == local || this == update;
}

/////////////////////////////////////////////////

class DHTRecord
    with
        DefaultDHTRefCounted,
        DefaultDHTDeleteable,
        DefaultDHTRecordOperations<SetDHTValueOptions>
    implements
        DHTRecordOperations<SetDHTValueOptions>,
        DHTDeleteScoped<DHTRecord> {
  //////////////////////////////////////////////////////////////

  final DHTRecordPool _pool;

  final _SharedDHTRecordData _sharedDHTRecordData;

  final VeilidRoutingContext _routingContext;

  final int _defaultSubkey;

  final KeyPair? _writer;

  final CryptoCodec _crypto;

  @override
  final String debugName;

  StreamController<DHTRecordWatchChange>? _watchController;

  _WatchState? _watchState;

  DHTRecord._({
    required DHTRecordPool pool,
    required VeilidRoutingContext routingContext,
    required _SharedDHTRecordData sharedDHTRecordData,
    required int defaultSubkey,
    required KeyPair? writer,
    required CryptoCodec crypto,
    required this.debugName,
  }) : _pool = pool,
       _crypto = crypto,
       _routingContext = routingContext,
       _defaultSubkey = defaultSubkey,
       _writer = writer,
       _sharedDHTRecordData = sharedDHTRecordData;

  ////////////////////////////////////////////////////////////////////////////
  // DHTCloseable

  /// The type of the openable scope
  @override
  FutureOr<DHTRecord> scoped() => this;

  /// Free all resources for the DHTRecord
  @override
  Future<bool> close() => DHTException.wrap(() async {
    if (!await super.close()) {
      return false;
    }

    await _watchController?.close();
    _watchController = null;
    await serialFutureClose((this, _sfListen));

    // The pool may already be torn down when this runs from a late
    // GC finalizer; in that case there's nothing more to do.
    await DHTRecordPool._singleton?._recordClosed(this);

    return true;
  });

  ////////////////////////////////////////////////////////////////////////////
  // DHTDeleteable

  /// Free all resources for the DHTRecord and delete it from the DHT
  ///
  /// delete() should not be called if the record is already deleted.
  ///
  /// Returns true if the deletion was processed immediately
  /// Returns false if the deletion was marked for later
  @override
  Future<bool> delete() => DHTException.wrap(() async {
    await super.delete();
    final res = await DHTRecordPool.instance.deleteRecord(key);
    return res;
  });

  ////////////////////////////////////////////////////////////////////////////
  // DHTRecordOperations<SetDHTValueOptions>

  /// Get a subkey value from this record.
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
  }) => _wrapStats('getBytes', () async {
    subkey = subkeyOrDefault(subkey);

    // Get the last sequence number if we need it
    final lastSeq = refreshMode._inspectLocal
        ? await _localSubkeySeq(subkey)
        : null;

    // See if we only ever want the locally stored value
    if (refreshMode == DHTRecordRefreshMode.local && lastSeq == null) {
      // If it's not available locally already just return null now
      return null;
    }

    final valueData = await DHTRecordPool.instance._veilidApiRetry(
      () => _routingContext.getDHTValue(
        key,
        subkey,
        forceRefresh: refreshMode._forceRefresh,
      ),
    );
    if (valueData == null) {
      return null;
    }

    // See if this get resulted in a newer sequence number
    if (refreshMode == DHTRecordRefreshMode.update &&
        lastSeq != null &&
        valueData.seq <= lastSeq) {
      // If we're only returning updates then punt now
      return null;
    }
    // If we're returning a value, decrypt it
    final out = (crypto ?? _crypto).decrypt(valueData.data);
    if (outSeqNum != null) {
      outSeqNum.save(valueData.seq);
    }
    return out;
  });

  /// Attempt to write a byte buffer to a DHTRecord subkey
  /// If a newer value was found on the network, it is returned
  /// If the value was succesfully written, null is returned
  @override
  Future<Uint8List?> tryWriteBytes(
    Uint8List newValue, {
    int subkey = -1,
    CryptoCodec? crypto,
    SetDHTValueOptions? options,
    Output<int>? outSeqNum,
  }) => _wrapStats('tryWriteBytes', () async {
    subkey = subkeyOrDefault(subkey);
    final lastSeq = await _localSubkeySeq(subkey);
    final encryptedNewValue = await (crypto ?? _crypto).encrypt(newValue);

    // Set the new data if possible
    var newValueData = await DHTRecordPool.instance._veilidApiRetry(
      () => _routingContext.setDHTValue(
        key,
        subkey,
        encryptedNewValue,
        options: SetDHTValueOptions(
          writer: options?.writer ?? _writer,
          allowOffline: options?.allowOffline,
        ),
      ),
    );
    // A clean write (no conflicting newer value) returns null. This is the
    // common case, and still commits our value, so notify on a seq change.
    if (newValueData == null) {
      final newSeqNum = await _localSubkeySeq(subkey);
      if (newSeqNum == null) {
        throw StateError(
          "can't get sequence number for value that was just set",
        );
      }
      if (newSeqNum != lastSeq) {
        if (outSeqNum != null) {
          outSeqNum.save(newSeqNum);
        }
        DHTRecordPool.instance._addLocalValueChange(key, [
          ValueSubkeyRange.single(subkey),
        ]);
      }
      return null;
    }

    // A newer conflicting value came back; commit it locally and notify
    final isUpdated = newValueData.seq != lastSeq;
    if (isUpdated && outSeqNum != null) {
      outSeqNum.save(newValueData.seq);
    }
    if (isUpdated) {
      DHTRecordPool.instance._addLocalValueChange(key, [
        ValueSubkeyRange.single(subkey),
      ]);
    }

    // See if the encrypted data returned is exactly the same
    // if so, shortcut and don't bother decrypting it
    if (newValueData.data.equals(encryptedNewValue)) {
      return null;
    }

    // Decrypt value to return it
    return (crypto ?? _crypto).decrypt(newValueData.data);
  });

  /// Builds options for eventual operations
  @override
  SetDHTValueOptions eventualOptions(KeyPair? writer) =>
      SetDHTValueOptions(writer: writer ?? _writer, allowOffline: false);

  ////////////////////////////////////////////////////////////////////////////
  // Public API

  DHTRecordPool get pool => _pool;

  VeilidRoutingContext get routingContext => _routingContext;

  RecordKey get key => _sharedDHTRecordData.recordDescriptor.key;

  PublicKey get owner => _sharedDHTRecordData.recordDescriptor.owner;

  KeyPair? get ownerKeyPair =>
      _sharedDHTRecordData.recordDescriptor.ownerKeyPair;

  DHTSchema get schema => _sharedDHTRecordData.recordDescriptor.schema;

  int get subkeyCount =>
      _sharedDHTRecordData.recordDescriptor.schema.subkeyCount;

  KeyPair? get writer => _writer;

  CryptoCodec get crypto => _crypto;

  OwnedDHTRecordPointer? get ownedDHTRecordPointer => ownerKeyPair == null
      ? null
      : OwnedDHTRecordPointer(recordKey: key, owner: ownerKeyPair!.value);

  int subkeyOrDefault(int subkey) => (subkey == -1) ? _defaultSubkey : subkey;

  /// Watch a subkey range of this DHT record for changes
  /// Takes effect on the next DHTRecordPool tick.
  Future<void> watch({
    List<ValueSubkeyRange>? subkeys,
    Timestamp? expiration,
    int? count,
  }) => DHTException.wrap(() async {
    // Set up watch requirements which will get picked up by the next tick
    final oldWatchState = _watchState;
    _watchState = _WatchState(
      subkeys: subkeys,
      expiration: expiration,
      count: count,
    );
    if (oldWatchState != _watchState) {
      _sharedDHTRecordData.needsWatchStateUpdate = true;
    }
  });

  /// Register a callback for changes made on this this DHT record.
  /// You must 'watch' the record as well as listen to it in order for this
  /// call back to be called.
  /// * 'localChanges' also enables calling the callback if changed are made
  ///   locally, otherwise only changes seen from the network itself are
  ///   reported
  ///
  @useResult
  Future<DHTRecordWatchSubscription> listen(
    DHTRecordWatchOnUpdate onUpdate, {
    CryptoCodec? crypto,
  }) => DHTException.wrap(() async {
    // Set up watch requirements
    _watchController ??= StreamController<DHTRecordWatchChange>.broadcast(
      onCancel: () {
        // If there are no more listeners then we can get rid of the controller
        _watchController = null;
      },
    );

    final subscription = _watchController!.stream.listen(
      (rawChange) {
        serialFuture((this, _sfListen), () async {
          // Notification-only remote changes carry no data
          //  * Transactions will not have data for changes
          //  * Local changes will not have data for changes
          // The subscriber must perform their own read in this case
          final rawRemoteData = rawChange.remoteData;
          final remoteData = rawRemoteData == null
              ? null
              : await (crypto ?? _crypto).decrypt(rawRemoteData);
          final change = DHTRecordWatchChange._(
            remoteData: remoteData,
            remoteSubkeys: rawChange.remoteSubkeys,
            localSubkeys: rawChange.localSubkeys,
          );
          await onUpdate(this, change);
        });
      },
      cancelOnError: true,
      onError: (e) async {
        await _watchController!.close();
        _watchController = null;
      },
    );

    return DHTRecordWatchSubscription._(
      record: this,
      subscription: subscription,
      debugName: 'WatchSubscription($debugName)',
    );
  });

  /// Stop watching this record for changes
  /// Takes effect on the next DHTRecordPool tick
  Future<void> cancelWatch() => DHTException.wrap(() async {
    // Tear down watch requirements
    if (_watchState != null) {
      _watchState = null;
      _sharedDHTRecordData.needsWatchStateUpdate = true;
    }
  });

  /// Return the inspection state of a set of subkeys of the DHTRecord
  /// See Veilid's 'inspectDHTRecord' call for details on how this works
  @override
  Future<DHTRecordReport> inspect({
    List<ValueSubkeyRange>? subkeys,
    DHTReportScope scope = DHTReportScope.local,
  }) => DHTException.wrap(
    () => _routingContext.inspectDHTRecord(key, subkeys: subkeys, scope: scope),
  );

  //////////////////////////////////////////////////////////////////////////

  Future<int?> _localSubkeySeq(int subkey) async {
    final rr = await _routingContext.inspectDHTRecord(
      key,
      subkeys: [ValueSubkeyRange.single(subkey)],
    );
    return rr.localSeqs.firstOrNull;
  }

  void _addValueChange({
    required Uint8List? remoteData,
    required List<ValueSubkeyRange> remoteSubkeys,
    required List<ValueSubkeyRange> localSubkeys,
  }) {
    final ws = _watchState;
    if (ws != null) {
      final watchedSubkeys = ws.subkeys;
      if (watchedSubkeys == null) {
        // Report all subkeys
        _watchController?.add(
          DHTRecordWatchChange._(
            remoteData: remoteData,
            remoteSubkeys: remoteSubkeys,
            localSubkeys: localSubkeys,
          ),
        );
      } else {
        // Only some subkeys are being watched, see if the reported update
        // overlaps the subkeys being watched
        final overlappedRemoteSubkeys = watchedSubkeys.intersectSubkeys(
          remoteSubkeys,
        );
        final overlappedLocalSubkeys = watchedSubkeys.intersectSubkeys(
          localSubkeys,
        );

        // If the reported data isn't within the range we care about,
        // then don't pass it through
        final overlappedRemoteFirstSubkey = overlappedRemoteSubkeys.firstSubkey;
        final originalRemoteFirstSubkey = remoteSubkeys.firstSubkey;
        final updatedRemoteData =
            (overlappedRemoteFirstSubkey != null &&
                originalRemoteFirstSubkey != null &&
                overlappedRemoteFirstSubkey == originalRemoteFirstSubkey)
            ? remoteData
            : null;

        // Report only watched subkeys
        if (overlappedRemoteSubkeys.isNotEmpty ||
            overlappedLocalSubkeys.isNotEmpty) {
          // Report the change
          _watchController?.add(
            DHTRecordWatchChange._(
              remoteData: updatedRemoteData,
              remoteSubkeys: overlappedRemoteSubkeys,
              localSubkeys: overlappedLocalSubkeys,
            ),
          );
        }
      }
    }
  }

  void _addRemoteValueChange(VeilidUpdateValueChange update) {
    _addValueChange(
      remoteData: update.value?.data,
      remoteSubkeys: update.subkeys,
      localSubkeys: List.empty(),
    );
  }

  Future<T> _wrapStats<T>(String func, Future<T> Function() closure) =>
      DHTRecordPool.instance._stats.measure(
        key,
        debugName,
        func,
        () => DHTException.wrap(closure),
      );
}
