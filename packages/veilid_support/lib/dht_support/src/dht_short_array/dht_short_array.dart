import 'dart:async';
import 'dart:typed_data';

import 'package:async_tools/async_tools.dart';

import '../../../src/veilid_log.dart';
import '../../../veilid_support.dart';
import '../../proto/proto.dart' as proto;
import 'dht_short_array_migration_codec.dart';

part 'dht_short_array_head.dart';
part 'dht_short_array_head_state.dart';
part 'dht_short_array_read.dart';
part 'dht_short_array_write.dart';

/// Composable interface for DHTShortArray internals.
typedef DHTShortArrayComposable =
    DHTComposable<DHTShortArrayReadOperations, DHTShortArrayWriteOperations>;

/// DHTShortArray is a vector-like data structure with random access read and
/// write operations. It can have up to 256 elements, and can span over
/// multiple DHT records. It is configurable with a 'stride' parameter that
/// determines how many elements are stored in each DHT record. The size of
/// each element is also dependent on the stride because the elements are stored
/// in the subkeys of the DHT records.
class DHTShortArray
    extends
        DefaultDHTCollection<
          _DHTShortArrayHead,
          DHTShortArrayReadOperations,
          DHTShortArrayWriteOperations,
          void
        >
    implements DHTDeleteScoped<DHTShortArray> {
  ////////////////////////////////////////////////////////////////
  // Fields

  static const maxElements = 256;
  static const minStride = ((1024 * 1024) ~/ ValueData.maxLen) - 1; // 31

  final _DHTShortArrayHead _inner;

  ////////////////////////////////////////////////////////////////
  // Constructors

  DHTShortArray._({required _DHTShortArrayHead head})
    : _inner = head,
      super(inner: head);

  static Future<DHTShortArray> create({
    required String debugName,
    CryptoKind? kind,
    int stride = maxElements,
    VeilidRoutingContext? routingContext,
    RecordKey? parent,
    CryptoCodec? crypto,
    KeyPair? writer,
    EncryptionKeyOverride? encryptionKeyOverride,
    DHTComposableSharedState? composableSharedState,
  }) => DHTException.wrap(() async {
    final head = await _DHTShortArrayHead.create(
      debugName: debugName,
      kind: kind,
      stride: stride,
      routingContext: routingContext,
      parent: parent,
      crypto: crypto,
      writer: writer,
      encryptionKeyOverride: encryptionKeyOverride,
      composableSharedState: composableSharedState,
    );
    return DHTShortArray._(head: head);
  });

  static Future<DHTShortArray> openRead(
    RecordKey headRecordKey, {
    required String debugName,
    VeilidRoutingContext? routingContext,
    RecordKey? parent,
    CryptoCodec? crypto,
    DHTComposableSharedState? composableSharedState,
  }) => DHTException.wrap(() async {
    final head = await _DHTShortArrayHead.openRead(
      headRecordKey,
      debugName: debugName,
      routingContext: routingContext,
      parent: parent,
      crypto: crypto,
      composableSharedState: composableSharedState,
    );
    final dhtShortArray = DHTShortArray._(head: head);
    // Best-effort pull if behind; offline, serve the local snapshot.
    if (!head.isComposed && head.needsRefresh) {
      try {
        await dhtShortArray.refresh();
      } on DHTExceptionNotAvailable {
        // offline — serve local cache, refresh later
      } on DHTExceptionOutdated {
        // transient consensus — serve local cache, refresh later
      }
    }
    return dhtShortArray;
  });

  static Future<DHTShortArray> openWrite(
    RecordKey headRecordKey,
    KeyPair writer, {
    required String debugName,
    VeilidRoutingContext? routingContext,
    RecordKey? parent,
    CryptoCodec? crypto,
    DHTComposableSharedState? composableSharedState,
  }) => DHTException.wrap(() async {
    final head = await _DHTShortArrayHead.openWrite(
      headRecordKey,
      writer,
      debugName: debugName,
      routingContext: routingContext,
      parent: parent,
      crypto: crypto,
      composableSharedState: composableSharedState,
    );
    final dhtShortArray = DHTShortArray._(head: head);
    // Best-effort pull if behind; offline, serve the local snapshot.
    if (!head.isComposed && head.needsRefresh) {
      try {
        await dhtShortArray.refresh();
      } on DHTExceptionNotAvailable {
        // offline — serve local cache, refresh later
      } on DHTExceptionOutdated {
        // transient consensus — serve local cache, refresh later
      }
    }
    return dhtShortArray;
  });

  static Future<DHTShortArray> openOwned(
    OwnedDHTRecordPointer ownedShortArrayRecordPointer, {
    required String debugName,
    required RecordKey parent,
    VeilidRoutingContext? routingContext,
    CryptoCodec? crypto,
    DHTComposableSharedState? composableSharedState,
  }) => openWrite(
    ownedShortArrayRecordPointer.recordKey,
    ownedShortArrayRecordPointer.ownerKeyPair,
    debugName: debugName,
    routingContext: routingContext,
    parent: parent,
    crypto: crypto,
    composableSharedState: composableSharedState,
  );

  ////////////////////////////////////////////////////////////////
  // DebugName
  @override
  String get debugName => 'DHTShortArray: ${_inner.debugName}';

  ////////////////////////////////////////////////////////////////
  // DHTScoped

  /// The type of the openable scope
  @override
  FutureOr<DHTShortArray> scoped() => this;

  ////////////////////////////////////////////////////////////////
  // DHTCollection

  @override
  bool get needsRefresh => _inner.needsRefresh;

  ////////////////////////////////////////////////////////////////
  // Public API

  /// Get the record key for this shortarray
  RecordKey get recordKey => _inner.recordKey;

  /// Get the writer for the log
  KeyPair? get writer => _inner.writer;

  /// Get the record pointer foir this shortarray
  OwnedDHTRecordPointer? get recordPointer => _inner.recordPointer;
}
