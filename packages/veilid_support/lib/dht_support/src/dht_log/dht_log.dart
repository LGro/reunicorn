import 'dart:async';
import 'dart:math';
import 'dart:typed_data';

import 'package:async_tools/async_tools.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

import '../../../src/veilid_log.dart';
import '../../../veilid_support.dart';
import '../../proto/proto.dart' as proto;
import 'dht_log_migration_codec.dart';

part 'dht_log_spine.dart';
part 'dht_log_spine_state.dart';
part 'dht_log_read.dart';
part 'dht_log_write.dart';

/// Composable interface for DHTLog internals.
typedef DHTLogComposable =
    DHTComposable<DHTLogReadOperations, DHTLogWriteOperations>;

///////////////////////////////////////////////////////////////////////

@immutable
class DHTLogUpdate extends Equatable {
  final int headDelta;

  final int tailDelta;

  final int length;

  const DHTLogUpdate({
    required this.headDelta,
    required this.tailDelta,
    required this.length,
  }) : assert(headDelta >= 0, 'should never have negative head delta'),
       assert(tailDelta >= 0, 'should never have negative tail delta'),
       assert(length >= 0, 'should never have negative length');

  @override
  List<Object?> get props => [headDelta, tailDelta, length];
}

/// DHTLog is a ring-buffer queue like data structure with the following
/// operations:
///  * Add elements to the tail
///  * Remove elements from the head
/// The structure has a 'spine' record that acts as an indirection table of
/// DHTShortArray record pointers spread over its subkeys.
/// Subkey 0 of the DHTLog is a head subkey that contains housekeeping data:
///  * The head and tail position of the log
///    - subkeyIdx = pos / recordsPerSubkey
///    - recordIdx = pos % recordsPerSubkey
class DHTLog
    extends
        DefaultDHTCollection<
          _DHTLogSpine,
          DHTLogReadOperations,
          DHTLogWriteOperations,
          DHTLogUpdate
        >
    implements DHTDeleteScoped<DHTLog> {
  ////////////////////////////////////////////////////////////////
  // Fields

  final _DHTLogSpine _inner;

  ////////////////////////////////////////////////////////////////
  // Constructors

  DHTLog._({required _DHTLogSpine spine}) : _inner = spine, super(inner: spine);

  /// Create a DHTLog
  static Future<DHTLog> create({
    required String debugName,
    CryptoKind? kind,
    int stride = DHTShortArray.maxElements,
    VeilidRoutingContext? routingContext,
    RecordKey? parent,
    CryptoCodec? crypto,
    KeyPair? writer,
    EncryptionKeyOverride? encryptionKeyOverride,
    DHTComposableSharedState? composableSharedState,
  }) => DHTException.wrap(() async {
    assert(stride <= DHTShortArray.maxElements, 'stride too long');

    final spine = await _DHTLogSpine.create(
      debugName: debugName,
      stride: stride,
      kind: kind,
      routingContext: routingContext,
      parent: parent,
      crypto: crypto,
      writer: writer,
      encryptionKeyOverride: encryptionKeyOverride,
      composableSharedState: composableSharedState,
    );
    return DHTLog._(spine: spine);
  });

  static Future<DHTLog> openRead(
    RecordKey logRecordKey, {
    required String debugName,
    VeilidRoutingContext? routingContext,
    RecordKey? parent,
    CryptoCodec? crypto,
    DHTComposableSharedState? composableSharedState,
  }) => DHTException.wrap(() async {
    final spine = await _DHTLogSpine.openRead(
      logRecordKey,
      debugName: debugName,
      routingContext: routingContext,
      parent: parent,
      crypto: crypto,
      composableSharedState: composableSharedState,
    );
    final dhtLog = DHTLog._(spine: spine);

    // Best-effort pull if behind; offline, serve the local snapshot.
    if (!spine.isComposed && spine.needsRefresh) {
      try {
        await dhtLog.refresh();
      } on DHTExceptionNotAvailable {
        // offline — serve local cache, refresh later
      } on DHTExceptionOutdated {
        // transient consensus — serve local cache, refresh later
      }
    }

    return dhtLog;
  });

  static Future<DHTLog> openWrite(
    RecordKey logRecordKey,
    KeyPair writer, {
    required String debugName,
    VeilidRoutingContext? routingContext,
    RecordKey? parent,
    CryptoCodec? crypto,
    DHTComposableSharedState? composableSharedState,
  }) => DHTException.wrap(() async {
    final spine = await _DHTLogSpine.openWrite(
      logRecordKey,
      writer,
      debugName: debugName,
      routingContext: routingContext,
      parent: parent,
      crypto: crypto,
      composableSharedState: composableSharedState,
    );
    final dhtLog = DHTLog._(spine: spine);

    // Best-effort pull if behind; offline, serve the local snapshot.
    if (!spine.isComposed && spine.needsRefresh) {
      try {
        await dhtLog.refresh();
      } on DHTExceptionNotAvailable {
        // offline — serve local cache, refresh later
      } on DHTExceptionOutdated {
        // transient consensus — serve local cache, refresh later
      }
    }

    return dhtLog;
  });

  static Future<DHTLog> openOwned(
    OwnedDHTRecordPointer ownedLogRecordPointer, {
    required String debugName,
    required RecordKey parent,
    VeilidRoutingContext? routingContext,
    CryptoCodec? crypto,
    DHTComposableSharedState? composableSharedState,
  }) => openWrite(
    ownedLogRecordPointer.recordKey,
    ownedLogRecordPointer.ownerKeyPair,
    debugName: debugName,
    routingContext: routingContext,
    parent: parent,
    crypto: crypto,
    composableSharedState: composableSharedState,
  );

  ////////////////////////////////////////////////////////////////////////////
  // DebugName

  @override
  String get debugName => 'DHTLog(${_inner.recordKey})';

  ////////////////////////////////////////////////////////////////////////////
  // DHTScoped

  /// The type of the openable scope
  @override
  FutureOr<DHTLog> scoped() => this;

  ////////////////////////////////////////////////////////////////
  // DHTCollection

  @override
  bool get needsRefresh => _inner.needsRefresh;

  ////////////////////////////////////////////////////////////////////////////
  // Public API

  /// Get the record key for this log
  RecordKey get recordKey => _inner.recordKey;

  /// Get the writer for the log
  KeyPair? get writer => _inner._spineRecord.writer;

  /// Get the record pointer for this log
  OwnedDHTRecordPointer? get recordPointer => _inner.recordPointer;
}
