// This is a generated file - do not edit.
//
// Generated from dht.deprecated.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

import 'veilid.deprecated.pb.dart' as $0;

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

class DHTData extends $pb.GeneratedMessage {
  factory DHTData({
    $core.Iterable<$0.TypedKey>? keys,
    $0.TypedKey? hash,
    $core.int? chunk,
    $core.int? size,
  }) {
    final result = create();
    if (keys != null) result.keys.addAll(keys);
    if (hash != null) result.hash = hash;
    if (chunk != null) result.chunk = chunk;
    if (size != null) result.size = size;
    return result;
  }

  DHTData._();

  factory DHTData.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory DHTData.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'DHTData',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'dht.deprecated'),
      createEmptyInstance: create)
    ..pPM<$0.TypedKey>(1, _omitFieldNames ? '' : 'keys',
        subBuilder: $0.TypedKey.create)
    ..aOM<$0.TypedKey>(2, _omitFieldNames ? '' : 'hash',
        subBuilder: $0.TypedKey.create)
    ..aI(3, _omitFieldNames ? '' : 'chunk', fieldType: $pb.PbFieldType.OU3)
    ..aI(4, _omitFieldNames ? '' : 'size', fieldType: $pb.PbFieldType.OU3)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DHTData clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DHTData copyWith(void Function(DHTData) updates) =>
      super.copyWith((message) => updates(message as DHTData)) as DHTData;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DHTData create() => DHTData._();
  @$core.override
  DHTData createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static DHTData getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<DHTData>(create);
  static DHTData? _defaultInstance;

  /// Other keys to concatenate
  /// Uses the same writer as this DHTList with SMPL schema
  @$pb.TagNumber(1)
  $pb.PbList<$0.TypedKey> get keys => $_getList(0);

  /// Hash of reassembled data to verify contents
  @$pb.TagNumber(2)
  $0.TypedKey get hash => $_getN(1);
  @$pb.TagNumber(2)
  set hash($0.TypedKey value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasHash() => $_has(1);
  @$pb.TagNumber(2)
  void clearHash() => $_clearField(2);
  @$pb.TagNumber(2)
  $0.TypedKey ensureHash() => $_ensure(1);

  /// Chunk size per subkey
  @$pb.TagNumber(3)
  $core.int get chunk => $_getIZ(2);
  @$pb.TagNumber(3)
  set chunk($core.int value) => $_setUnsignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasChunk() => $_has(2);
  @$pb.TagNumber(3)
  void clearChunk() => $_clearField(3);

  /// Total data size
  @$pb.TagNumber(4)
  $core.int get size => $_getIZ(3);
  @$pb.TagNumber(4)
  set size($core.int value) => $_setUnsignedInt32(3, value);
  @$pb.TagNumber(4)
  $core.bool hasSize() => $_has(3);
  @$pb.TagNumber(4)
  void clearSize() => $_clearField(4);
}

/// DHTLog - represents a ring buffer of many elements with append/truncate semantics
/// Header in subkey 0 of first key follows this structure
class DHTLog extends $pb.GeneratedMessage {
  factory DHTLog({
    $core.int? head,
    $core.int? tail,
    $core.int? stride,
  }) {
    final result = create();
    if (head != null) result.head = head;
    if (tail != null) result.tail = tail;
    if (stride != null) result.stride = stride;
    return result;
  }

  DHTLog._();

  factory DHTLog.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory DHTLog.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'DHTLog',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'dht.deprecated'),
      createEmptyInstance: create)
    ..aI(1, _omitFieldNames ? '' : 'head', fieldType: $pb.PbFieldType.OU3)
    ..aI(2, _omitFieldNames ? '' : 'tail', fieldType: $pb.PbFieldType.OU3)
    ..aI(3, _omitFieldNames ? '' : 'stride', fieldType: $pb.PbFieldType.OU3)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DHTLog clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DHTLog copyWith(void Function(DHTLog) updates) =>
      super.copyWith((message) => updates(message as DHTLog)) as DHTLog;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DHTLog create() => DHTLog._();
  @$core.override
  DHTLog createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static DHTLog getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<DHTLog>(create);
  static DHTLog? _defaultInstance;

  /// Position of the start of the log (oldest items)
  @$pb.TagNumber(1)
  $core.int get head => $_getIZ(0);
  @$pb.TagNumber(1)
  set head($core.int value) => $_setUnsignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasHead() => $_has(0);
  @$pb.TagNumber(1)
  void clearHead() => $_clearField(1);

  /// Position of the end of the log (newest items)
  @$pb.TagNumber(2)
  $core.int get tail => $_getIZ(1);
  @$pb.TagNumber(2)
  set tail($core.int value) => $_setUnsignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasTail() => $_has(1);
  @$pb.TagNumber(2)
  void clearTail() => $_clearField(2);

  /// Stride of each segment of the dhtlog
  @$pb.TagNumber(3)
  $core.int get stride => $_getIZ(2);
  @$pb.TagNumber(3)
  set stride($core.int value) => $_setUnsignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasStride() => $_has(2);
  @$pb.TagNumber(3)
  void clearStride() => $_clearField(3);
}

/// DHTShortArray - represents a re-orderable collection of up to 256 individual elements
/// Header in subkey 0 of first key follows this structure
///
/// stride = descriptor subkey count on first key - 1
/// Subkeys 1..=stride on the first key are individual elements
/// Subkeys 0..stride on the 'keys' keys are also individual elements
///
/// Keys must use writable schema in order to make this list mutable
class DHTShortArray extends $pb.GeneratedMessage {
  factory DHTShortArray({
    $core.Iterable<$0.TypedKey>? keys,
    $core.List<$core.int>? index,
    $core.Iterable<$core.int>? seqs,
  }) {
    final result = create();
    if (keys != null) result.keys.addAll(keys);
    if (index != null) result.index = index;
    if (seqs != null) result.seqs.addAll(seqs);
    return result;
  }

  DHTShortArray._();

  factory DHTShortArray.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory DHTShortArray.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'DHTShortArray',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'dht.deprecated'),
      createEmptyInstance: create)
    ..pPM<$0.TypedKey>(1, _omitFieldNames ? '' : 'keys',
        subBuilder: $0.TypedKey.create)
    ..a<$core.List<$core.int>>(
        2, _omitFieldNames ? '' : 'index', $pb.PbFieldType.OY)
    ..p<$core.int>(3, _omitFieldNames ? '' : 'seqs', $pb.PbFieldType.KU3)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DHTShortArray clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DHTShortArray copyWith(void Function(DHTShortArray) updates) =>
      super.copyWith((message) => updates(message as DHTShortArray))
          as DHTShortArray;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DHTShortArray create() => DHTShortArray._();
  @$core.override
  DHTShortArray createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static DHTShortArray getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<DHTShortArray>(create);
  static DHTShortArray? _defaultInstance;

  /// Other keys to concatenate
  /// Uses the same writer as this DHTList with SMPL schema
  @$pb.TagNumber(1)
  $pb.PbList<$0.TypedKey> get keys => $_getList(0);

  /// Item position index (uint8[256./])
  /// Actual item location is:
  ///   idx = index[n] + 1 (offset for header at idx 0)
  ///   key = idx / stride
  ///   subkey = idx % stride
  @$pb.TagNumber(2)
  $core.List<$core.int> get index => $_getN(1);
  @$pb.TagNumber(2)
  set index($core.List<$core.int> value) => $_setBytes(1, value);
  @$pb.TagNumber(2)
  $core.bool hasIndex() => $_has(1);
  @$pb.TagNumber(2)
  void clearIndex() => $_clearField(2);

  /// Most recent sequence numbers for elements
  @$pb.TagNumber(3)
  $pb.PbList<$core.int> get seqs => $_getList(2);
}

/// A pointer to an child DHT record
class OwnedDHTRecordPointer extends $pb.GeneratedMessage {
  factory OwnedDHTRecordPointer({
    $0.TypedKey? recordKey,
    $0.KeyPair? owner,
  }) {
    final result = create();
    if (recordKey != null) result.recordKey = recordKey;
    if (owner != null) result.owner = owner;
    return result;
  }

  OwnedDHTRecordPointer._();

  factory OwnedDHTRecordPointer.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory OwnedDHTRecordPointer.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'OwnedDHTRecordPointer',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'dht.deprecated'),
      createEmptyInstance: create)
    ..aOM<$0.TypedKey>(1, _omitFieldNames ? '' : 'recordKey',
        subBuilder: $0.TypedKey.create)
    ..aOM<$0.KeyPair>(2, _omitFieldNames ? '' : 'owner',
        subBuilder: $0.KeyPair.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  OwnedDHTRecordPointer clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  OwnedDHTRecordPointer copyWith(
          void Function(OwnedDHTRecordPointer) updates) =>
      super.copyWith((message) => updates(message as OwnedDHTRecordPointer))
          as OwnedDHTRecordPointer;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static OwnedDHTRecordPointer create() => OwnedDHTRecordPointer._();
  @$core.override
  OwnedDHTRecordPointer createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static OwnedDHTRecordPointer getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<OwnedDHTRecordPointer>(create);
  static OwnedDHTRecordPointer? _defaultInstance;

  /// DHT Record key
  @$pb.TagNumber(1)
  $0.TypedKey get recordKey => $_getN(0);
  @$pb.TagNumber(1)
  set recordKey($0.TypedKey value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasRecordKey() => $_has(0);
  @$pb.TagNumber(1)
  void clearRecordKey() => $_clearField(1);
  @$pb.TagNumber(1)
  $0.TypedKey ensureRecordKey() => $_ensure(0);

  /// DHT record owner key
  @$pb.TagNumber(2)
  $0.KeyPair get owner => $_getN(1);
  @$pb.TagNumber(2)
  set owner($0.KeyPair value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasOwner() => $_has(1);
  @$pb.TagNumber(2)
  void clearOwner() => $_clearField(2);
  @$pb.TagNumber(2)
  $0.KeyPair ensureOwner() => $_ensure(1);
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
