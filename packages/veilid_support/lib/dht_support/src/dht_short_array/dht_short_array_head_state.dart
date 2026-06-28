part of 'dht_short_array.dart';

class DHTShortArrayHeadLookup {
  final DHTRecord record;
  final int recordSubkey;
  final int? seq;
  final int? localSeq;

  DHTShortArrayHeadLookup({
    required this.record,
    required this.recordSubkey,
    required this.seq,
    required this.localSeq,
  });

  /// Whether the subkey is available in the local cache.
  /// For DHTShortArray, after SYNC, localSeq should equal seq.
  /// If localSeq is null, the element hasn't been cached yet.
  /// If localSeq != seq, a SYNC is needed.
  bool get isLocallyAvailable => localSeq != null && localSeq == seq;
}

/// Copyable head state containing only the mutable fields.
/// Write operations work on a copy (_workingState) and only apply to the
/// committed state (_state) after successful commit, so READs see
/// consistent state throughout network I/O.
class _DHTShortArrayHeadState {
  final _DHTShortArrayHead _head;

  // List of additional records after the head record used for element data
  List<DHTRecord> linkedRecords;

  // Ordering of the subkey indices.
  // Elements are subkey numbers. Represents the element order.
  List<int> index;

  // List of free subkeys for elements that have been removed.
  // Used to optimize allocations.
  List<int> free;

  // The sequence numbers of each subkey as they are in the online copy.
  // Index is by subkey number not by element index.
  List<int?> seqs;

  // The local sequence numbers for each subkey.
  // Cache of what the local DHT record store has.
  List<int?> localSeqs;

  // Whether the head needs to be refreshed from the network.
  // Lives on state so rollback reverts a sync-time flag flip.
  bool needsRefresh;
  // Bumped on each markNeedsRefresh; lets refresh detect a mid-sync change
  int _refreshGen = 0;
  int get refreshGen => _refreshGen;

  void markNeedsRefresh() {
    needsRefresh = true;
    _refreshGen++;
  }

  _DHTShortArrayHeadState(
    this._head, {
    required this.linkedRecords,
    required this.index,
    required this.free,
    required this.seqs,
    required this.localSeqs,
    required this.needsRefresh,
  });

  /// Create a shallow copy. Lists are copied; DHTRecord references are shared.
  _DHTShortArrayHeadState copy() => _DHTShortArrayHeadState(
    _head,
    linkedRecords: List.of(linkedRecords),
    index: List.of(index),
    free: List.of(free),
    seqs: List.of(seqs),
    localSeqs: List.of(localSeqs),
    needsRefresh: needsRefresh,
  );

  int get length => index.length;

  int getRangeLimit(int start) => index.length - start;

  int insertAllLimit() => DHTShortArray.maxElements - index.length;

  /////////////////////////////////////////////////////////////////////////////
  // Record lookup

  /// Look up a position in the array, returning the record and subkey.
  Future<DHTShortArrayHeadLookup> lookupPosition(int pos) {
    final idx = index[pos];
    return lookupIndex(idx);
  }

  /// Look up an index in the array, returning the record and subkey.
  Future<DHTShortArrayHeadLookup> lookupIndex(int idx) async {
    final seq = idx < seqs.length ? seqs[idx] : null;
    final localSeq = idx < localSeqs.length ? localSeqs[idx] : null;
    final recordNumber = idx ~/ _head._stride;
    final record = await _head.getOrCreateLinkedRecord(this, recordNumber);
    final recordSubkey =
        (idx % _head._stride) + ((recordNumber == 0) ? 1 : 0);
    return DHTShortArrayHeadLookup(
      record: record,
      recordSubkey: recordSubkey,
      seq: seq,
      localSeq: localSeq,
    );
  }

  /////////////////////////////////////////////////////////////////////////////
  // Index management

  /// Allocate an empty index slot, returning the subkey index.
  int allocateEmptyIndex() {
    if (free.isNotEmpty) {
      return free.removeLast();
    }
    if (index.length == DHTShortArray.maxElements) {
      throw StateError('too many elements');
    }
    return index.length;
  }

  /// Allocate and insert an index at a specific position.
  void allocateIndex(int pos) {
    final idx = allocateEmptyIndex();
    index.insert(pos, idx);
  }

  /// Free an index at a particular position.
  void freeIndex(int pos) {
    final idx = index.removeAt(pos);
    free.add(idx);
  }

  /// Swap two index positions.
  void swapIndex(int aPos, int bPos) {
    if (aPos == bPos) {
      return;
    }
    final aIdx = index[aPos];
    final bIdx = index[bPos];
    index[aPos] = bIdx;
    index[bPos] = aIdx;
  }

  /// Clear all indices and free list.
  void clearIndex() {
    index.clear();
    free.clear();
  }

  /// Truncate index to a particular length.
  void truncateIndex(int newLength) {
    if (newLength >= index.length) {
      return;
    } else if (newLength == 0) {
      clearIndex();
      return;
    } else if (newLength < 0) {
      throw StateError('can not truncate to negative length');
    }
    final freed = index.sublist(newLength);
    index.removeRange(newLength, index.length);
    free.addAll(freed);
  }

  proto.DHTShortArray toProto() {
    final head = proto.DHTShortArray();
    head.keys.addAll(linkedRecords.map((lr) => lr.key.toProto()));
    head.index = List.of(index);
    head.seqs.addAll(seqs.map((x) => x ?? 0xFFFFFFFF));
    return head;
  }

  /// Check if a position's element needs to be synced from the network.
  bool positionNeedsSync(int pos) {
    final idx = index[pos];

    if (seqs.length <= idx || seqs[idx] == null) {
      return false;
    }
    if (localSeqs.length <= idx || localSeqs[idx] == null) {
      return true;
    }
    return localSeqs[idx]! < seqs[idx]!;
  }

  /// Update the sequence number for a particular index.
  void updatePositionSeq(int pos, bool write, int newSeq) {
    final idx = index[pos];

    while (localSeqs.length <= idx) {
      localSeqs.add(null);
    }
    localSeqs[idx] = newSeq;
    if (write) {
      while (seqs.length <= idx) {
        seqs.add(null);
      }
      seqs[idx] = newSeq;
    }
  }

  /// Validate the head from the DHT is properly formatted
  /// and calculate the free list from it while we're here
  List<int> makeFreeList(List<RecordKey> linkedKeys, List<int> idx) {
    final newKeys = linkedKeys.toSet();
    assert(
      newKeys.length <=
          (DHTShortArray.maxElements + (_head._stride - 1)) ~/ _head._stride,
      'too many keys: $newKeys.length',
    );
    assert(newKeys.length == linkedKeys.length, 'duplicated linked keys');
    final newIndex = idx.toSet();
    assert(newIndex.length <= DHTShortArray.maxElements, 'too many indexes');
    assert(newIndex.length == idx.length, 'duplicated index locations');

    final indexCapacity = (linkedKeys.length + 1) * _head._stride;
    int? maxIndex;
    for (final i in newIndex) {
      assert(i >= 0 || i < indexCapacity, 'index out of range');
      if (maxIndex == null || i > maxIndex) {
        maxIndex = i;
      }
    }

    final freeList = <int>[];
    if (maxIndex != null) {
      for (var i = 0; i < maxIndex; i++) {
        if (!newIndex.contains(i)) {
          freeList.add(i);
        }
      }
    }
    return freeList;
  }

  /// Update this state from a network head proto.
  /// Opens new linked records, closes old ones, rebuilds state.
  Future<void> updateFromProto(proto.DHTShortArray head) async {
    final updatedLinkedKeys = head.keys.map((p) => p.toDart()).toList();
    final updatedIndex = List.of(head.index);
    final updatedSeqs = List.of(
      head.seqs.map((x) => x == 0xFFFFFFFF ? null : x),
    );
    final updatedFree = makeFreeList(updatedLinkedKeys, updatedIndex);

    final oldRecords = Map<RecordKey, DHTRecord>.fromEntries(
      linkedRecords.map((lr) => MapEntry(lr.key, lr)),
    );
    final newRecords = <RecordKey, DHTRecord>{};
    final sameRecords = <RecordKey, DHTRecord>{};
    final updatedLinkedRecords = <DHTRecord>[];
    try {
      for (var n = 0; n < updatedLinkedKeys.length; n++) {
        final newKey = updatedLinkedKeys[n];
        final oldRecord = oldRecords[newKey];
        if (oldRecord == null) {
          final newRecord = await _head.openLinkedRecord(newKey, n);
          newRecords[newKey] = newRecord;
          updatedLinkedRecords.add(newRecord);
        } else {
          sameRecords[newKey] = oldRecord;
          updatedLinkedRecords.add(oldRecord);
        }
      }
    } on Exception catch (_) {
      await Future.wait(newRecords.entries.map((e) => e.value.close()));
      rethrow;
    }

    await Future.wait(
      oldRecords.entries
          .where((e) => !sameRecords.containsKey(e.key))
          .map((e) => e.value.close()),
    );

    final localReports = await Future.wait(
      [_head._headRecord, ...updatedLinkedRecords].map((r) {
        final start = (r.key == _head._headRecord.key) ? 1 : 0;
        return r.inspect(
          subkeys: [ValueSubkeyRange.make(start, start + _head._stride - 1)],
        );
      }),
      eagerError: true,
    );
    final updatedLocalSeqs = localReports
        .map((l) => l.localSeqs)
        .expand((e) => e)
        .toList();

    linkedRecords = updatedLinkedRecords;
    index = updatedIndex;
    free = updatedFree;
    seqs = updatedSeqs;
    localSeqs = updatedLocalSeqs;
    needsRefresh = false;
  }
}
