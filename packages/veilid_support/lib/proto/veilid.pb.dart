//
//  Generated code. Do not modify.
//  source: veilid.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

/// Byte Array Types
class BarePublicKey extends $pb.GeneratedMessage {
  factory BarePublicKey({
    $core.List<$core.int>? data,
  }) {
    final $result = create();
    if (data != null) {
      $result.data = data;
    }
    return $result;
  }
  BarePublicKey._() : super();
  factory BarePublicKey.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory BarePublicKey.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'BarePublicKey', package: const $pb.PackageName(_omitMessageNames ? '' : 'veilid'), createEmptyInstance: create)
    ..a<$core.List<$core.int>>(1, _omitFieldNames ? '' : 'data', $pb.PbFieldType.OY)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  BarePublicKey clone() => BarePublicKey()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  BarePublicKey copyWith(void Function(BarePublicKey) updates) => super.copyWith((message) => updates(message as BarePublicKey)) as BarePublicKey;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static BarePublicKey create() => BarePublicKey._();
  BarePublicKey createEmptyInstance() => create();
  static $pb.PbList<BarePublicKey> createRepeated() => $pb.PbList<BarePublicKey>();
  @$core.pragma('dart2js:noInline')
  static BarePublicKey getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<BarePublicKey>(create);
  static BarePublicKey? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<$core.int> get data => $_getN(0);
  @$pb.TagNumber(1)
  set data($core.List<$core.int> v) { $_setBytes(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasData() => $_has(0);
  @$pb.TagNumber(1)
  void clearData() => clearField(1);
}

class BareSignature extends $pb.GeneratedMessage {
  factory BareSignature({
    $core.List<$core.int>? data,
  }) {
    final $result = create();
    if (data != null) {
      $result.data = data;
    }
    return $result;
  }
  BareSignature._() : super();
  factory BareSignature.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory BareSignature.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'BareSignature', package: const $pb.PackageName(_omitMessageNames ? '' : 'veilid'), createEmptyInstance: create)
    ..a<$core.List<$core.int>>(1, _omitFieldNames ? '' : 'data', $pb.PbFieldType.OY)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  BareSignature clone() => BareSignature()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  BareSignature copyWith(void Function(BareSignature) updates) => super.copyWith((message) => updates(message as BareSignature)) as BareSignature;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static BareSignature create() => BareSignature._();
  BareSignature createEmptyInstance() => create();
  static $pb.PbList<BareSignature> createRepeated() => $pb.PbList<BareSignature>();
  @$core.pragma('dart2js:noInline')
  static BareSignature getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<BareSignature>(create);
  static BareSignature? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<$core.int> get data => $_getN(0);
  @$pb.TagNumber(1)
  set data($core.List<$core.int> v) { $_setBytes(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasData() => $_has(0);
  @$pb.TagNumber(1)
  void clearData() => clearField(1);
}

class BareSecretKey extends $pb.GeneratedMessage {
  factory BareSecretKey({
    $core.List<$core.int>? data,
  }) {
    final $result = create();
    if (data != null) {
      $result.data = data;
    }
    return $result;
  }
  BareSecretKey._() : super();
  factory BareSecretKey.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory BareSecretKey.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'BareSecretKey', package: const $pb.PackageName(_omitMessageNames ? '' : 'veilid'), createEmptyInstance: create)
    ..a<$core.List<$core.int>>(1, _omitFieldNames ? '' : 'data', $pb.PbFieldType.OY)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  BareSecretKey clone() => BareSecretKey()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  BareSecretKey copyWith(void Function(BareSecretKey) updates) => super.copyWith((message) => updates(message as BareSecretKey)) as BareSecretKey;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static BareSecretKey create() => BareSecretKey._();
  BareSecretKey createEmptyInstance() => create();
  static $pb.PbList<BareSecretKey> createRepeated() => $pb.PbList<BareSecretKey>();
  @$core.pragma('dart2js:noInline')
  static BareSecretKey getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<BareSecretKey>(create);
  static BareSecretKey? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<$core.int> get data => $_getN(0);
  @$pb.TagNumber(1)
  set data($core.List<$core.int> v) { $_setBytes(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasData() => $_has(0);
  @$pb.TagNumber(1)
  void clearData() => clearField(1);
}

class BareSharedSecret extends $pb.GeneratedMessage {
  factory BareSharedSecret({
    $core.List<$core.int>? data,
  }) {
    final $result = create();
    if (data != null) {
      $result.data = data;
    }
    return $result;
  }
  BareSharedSecret._() : super();
  factory BareSharedSecret.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory BareSharedSecret.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'BareSharedSecret', package: const $pb.PackageName(_omitMessageNames ? '' : 'veilid'), createEmptyInstance: create)
    ..a<$core.List<$core.int>>(1, _omitFieldNames ? '' : 'data', $pb.PbFieldType.OY)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  BareSharedSecret clone() => BareSharedSecret()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  BareSharedSecret copyWith(void Function(BareSharedSecret) updates) => super.copyWith((message) => updates(message as BareSharedSecret)) as BareSharedSecret;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static BareSharedSecret create() => BareSharedSecret._();
  BareSharedSecret createEmptyInstance() => create();
  static $pb.PbList<BareSharedSecret> createRepeated() => $pb.PbList<BareSharedSecret>();
  @$core.pragma('dart2js:noInline')
  static BareSharedSecret getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<BareSharedSecret>(create);
  static BareSharedSecret? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<$core.int> get data => $_getN(0);
  @$pb.TagNumber(1)
  set data($core.List<$core.int> v) { $_setBytes(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasData() => $_has(0);
  @$pb.TagNumber(1)
  void clearData() => clearField(1);
}

class BareHashDigest extends $pb.GeneratedMessage {
  factory BareHashDigest({
    $core.List<$core.int>? data,
  }) {
    final $result = create();
    if (data != null) {
      $result.data = data;
    }
    return $result;
  }
  BareHashDigest._() : super();
  factory BareHashDigest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory BareHashDigest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'BareHashDigest', package: const $pb.PackageName(_omitMessageNames ? '' : 'veilid'), createEmptyInstance: create)
    ..a<$core.List<$core.int>>(1, _omitFieldNames ? '' : 'data', $pb.PbFieldType.OY)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  BareHashDigest clone() => BareHashDigest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  BareHashDigest copyWith(void Function(BareHashDigest) updates) => super.copyWith((message) => updates(message as BareHashDigest)) as BareHashDigest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static BareHashDigest create() => BareHashDigest._();
  BareHashDigest createEmptyInstance() => create();
  static $pb.PbList<BareHashDigest> createRepeated() => $pb.PbList<BareHashDigest>();
  @$core.pragma('dart2js:noInline')
  static BareHashDigest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<BareHashDigest>(create);
  static BareHashDigest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<$core.int> get data => $_getN(0);
  @$pb.TagNumber(1)
  set data($core.List<$core.int> v) { $_setBytes(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasData() => $_has(0);
  @$pb.TagNumber(1)
  void clearData() => clearField(1);
}

class BareOpaqueRecordKey extends $pb.GeneratedMessage {
  factory BareOpaqueRecordKey({
    $core.List<$core.int>? data,
  }) {
    final $result = create();
    if (data != null) {
      $result.data = data;
    }
    return $result;
  }
  BareOpaqueRecordKey._() : super();
  factory BareOpaqueRecordKey.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory BareOpaqueRecordKey.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'BareOpaqueRecordKey', package: const $pb.PackageName(_omitMessageNames ? '' : 'veilid'), createEmptyInstance: create)
    ..a<$core.List<$core.int>>(1, _omitFieldNames ? '' : 'data', $pb.PbFieldType.OY)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  BareOpaqueRecordKey clone() => BareOpaqueRecordKey()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  BareOpaqueRecordKey copyWith(void Function(BareOpaqueRecordKey) updates) => super.copyWith((message) => updates(message as BareOpaqueRecordKey)) as BareOpaqueRecordKey;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static BareOpaqueRecordKey create() => BareOpaqueRecordKey._();
  BareOpaqueRecordKey createEmptyInstance() => create();
  static $pb.PbList<BareOpaqueRecordKey> createRepeated() => $pb.PbList<BareOpaqueRecordKey>();
  @$core.pragma('dart2js:noInline')
  static BareOpaqueRecordKey getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<BareOpaqueRecordKey>(create);
  static BareOpaqueRecordKey? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<$core.int> get data => $_getN(0);
  @$pb.TagNumber(1)
  set data($core.List<$core.int> v) { $_setBytes(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasData() => $_has(0);
  @$pb.TagNumber(1)
  void clearData() => clearField(1);
}

class BareRouteId extends $pb.GeneratedMessage {
  factory BareRouteId({
    $core.List<$core.int>? data,
  }) {
    final $result = create();
    if (data != null) {
      $result.data = data;
    }
    return $result;
  }
  BareRouteId._() : super();
  factory BareRouteId.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory BareRouteId.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'BareRouteId', package: const $pb.PackageName(_omitMessageNames ? '' : 'veilid'), createEmptyInstance: create)
    ..a<$core.List<$core.int>>(1, _omitFieldNames ? '' : 'data', $pb.PbFieldType.OY)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  BareRouteId clone() => BareRouteId()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  BareRouteId copyWith(void Function(BareRouteId) updates) => super.copyWith((message) => updates(message as BareRouteId)) as BareRouteId;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static BareRouteId create() => BareRouteId._();
  BareRouteId createEmptyInstance() => create();
  static $pb.PbList<BareRouteId> createRepeated() => $pb.PbList<BareRouteId>();
  @$core.pragma('dart2js:noInline')
  static BareRouteId getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<BareRouteId>(create);
  static BareRouteId? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<$core.int> get data => $_getN(0);
  @$pb.TagNumber(1)
  set data($core.List<$core.int> v) { $_setBytes(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasData() => $_has(0);
  @$pb.TagNumber(1)
  void clearData() => clearField(1);
}

class BareNodeId extends $pb.GeneratedMessage {
  factory BareNodeId({
    $core.List<$core.int>? data,
  }) {
    final $result = create();
    if (data != null) {
      $result.data = data;
    }
    return $result;
  }
  BareNodeId._() : super();
  factory BareNodeId.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory BareNodeId.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'BareNodeId', package: const $pb.PackageName(_omitMessageNames ? '' : 'veilid'), createEmptyInstance: create)
    ..a<$core.List<$core.int>>(1, _omitFieldNames ? '' : 'data', $pb.PbFieldType.OY)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  BareNodeId clone() => BareNodeId()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  BareNodeId copyWith(void Function(BareNodeId) updates) => super.copyWith((message) => updates(message as BareNodeId)) as BareNodeId;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static BareNodeId create() => BareNodeId._();
  BareNodeId createEmptyInstance() => create();
  static $pb.PbList<BareNodeId> createRepeated() => $pb.PbList<BareNodeId>();
  @$core.pragma('dart2js:noInline')
  static BareNodeId getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<BareNodeId>(create);
  static BareNodeId? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<$core.int> get data => $_getN(0);
  @$pb.TagNumber(1)
  set data($core.List<$core.int> v) { $_setBytes(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasData() => $_has(0);
  @$pb.TagNumber(1)
  void clearData() => clearField(1);
}

class BareMemberId extends $pb.GeneratedMessage {
  factory BareMemberId({
    $core.List<$core.int>? data,
  }) {
    final $result = create();
    if (data != null) {
      $result.data = data;
    }
    return $result;
  }
  BareMemberId._() : super();
  factory BareMemberId.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory BareMemberId.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'BareMemberId', package: const $pb.PackageName(_omitMessageNames ? '' : 'veilid'), createEmptyInstance: create)
    ..a<$core.List<$core.int>>(1, _omitFieldNames ? '' : 'data', $pb.PbFieldType.OY)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  BareMemberId clone() => BareMemberId()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  BareMemberId copyWith(void Function(BareMemberId) updates) => super.copyWith((message) => updates(message as BareMemberId)) as BareMemberId;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static BareMemberId create() => BareMemberId._();
  BareMemberId createEmptyInstance() => create();
  static $pb.PbList<BareMemberId> createRepeated() => $pb.PbList<BareMemberId>();
  @$core.pragma('dart2js:noInline')
  static BareMemberId getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<BareMemberId>(create);
  static BareMemberId? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<$core.int> get data => $_getN(0);
  @$pb.TagNumber(1)
  set data($core.List<$core.int> v) { $_setBytes(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasData() => $_has(0);
  @$pb.TagNumber(1)
  void clearData() => clearField(1);
}

class Nonce extends $pb.GeneratedMessage {
  factory Nonce({
    $core.List<$core.int>? data,
  }) {
    final $result = create();
    if (data != null) {
      $result.data = data;
    }
    return $result;
  }
  Nonce._() : super();
  factory Nonce.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory Nonce.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'Nonce', package: const $pb.PackageName(_omitMessageNames ? '' : 'veilid'), createEmptyInstance: create)
    ..a<$core.List<$core.int>>(1, _omitFieldNames ? '' : 'data', $pb.PbFieldType.OY)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  Nonce clone() => Nonce()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  Nonce copyWith(void Function(Nonce) updates) => super.copyWith((message) => updates(message as Nonce)) as Nonce;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Nonce create() => Nonce._();
  Nonce createEmptyInstance() => create();
  static $pb.PbList<Nonce> createRepeated() => $pb.PbList<Nonce>();
  @$core.pragma('dart2js:noInline')
  static Nonce getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Nonce>(create);
  static Nonce? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<$core.int> get data => $_getN(0);
  @$pb.TagNumber(1)
  set data($core.List<$core.int> v) { $_setBytes(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasData() => $_has(0);
  @$pb.TagNumber(1)
  void clearData() => clearField(1);
}

/// Type-prefixed Types
class PublicKey extends $pb.GeneratedMessage {
  factory PublicKey({
    $core.int? kind,
    $core.List<$core.int>? data,
  }) {
    final $result = create();
    if (kind != null) {
      $result.kind = kind;
    }
    if (data != null) {
      $result.data = data;
    }
    return $result;
  }
  PublicKey._() : super();
  factory PublicKey.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory PublicKey.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'PublicKey', package: const $pb.PackageName(_omitMessageNames ? '' : 'veilid'), createEmptyInstance: create)
    ..a<$core.int>(1, _omitFieldNames ? '' : 'kind', $pb.PbFieldType.OF3)
    ..a<$core.List<$core.int>>(2, _omitFieldNames ? '' : 'data', $pb.PbFieldType.OY)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  PublicKey clone() => PublicKey()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  PublicKey copyWith(void Function(PublicKey) updates) => super.copyWith((message) => updates(message as PublicKey)) as PublicKey;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static PublicKey create() => PublicKey._();
  PublicKey createEmptyInstance() => create();
  static $pb.PbList<PublicKey> createRepeated() => $pb.PbList<PublicKey>();
  @$core.pragma('dart2js:noInline')
  static PublicKey getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<PublicKey>(create);
  static PublicKey? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get kind => $_getIZ(0);
  @$pb.TagNumber(1)
  set kind($core.int v) { $_setUnsignedInt32(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasKind() => $_has(0);
  @$pb.TagNumber(1)
  void clearKind() => clearField(1);

  @$pb.TagNumber(2)
  $core.List<$core.int> get data => $_getN(1);
  @$pb.TagNumber(2)
  set data($core.List<$core.int> v) { $_setBytes(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasData() => $_has(1);
  @$pb.TagNumber(2)
  void clearData() => clearField(2);
}

class Signature extends $pb.GeneratedMessage {
  factory Signature({
    $core.int? kind,
    $core.List<$core.int>? data,
  }) {
    final $result = create();
    if (kind != null) {
      $result.kind = kind;
    }
    if (data != null) {
      $result.data = data;
    }
    return $result;
  }
  Signature._() : super();
  factory Signature.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory Signature.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'Signature', package: const $pb.PackageName(_omitMessageNames ? '' : 'veilid'), createEmptyInstance: create)
    ..a<$core.int>(1, _omitFieldNames ? '' : 'kind', $pb.PbFieldType.OF3)
    ..a<$core.List<$core.int>>(2, _omitFieldNames ? '' : 'data', $pb.PbFieldType.OY)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  Signature clone() => Signature()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  Signature copyWith(void Function(Signature) updates) => super.copyWith((message) => updates(message as Signature)) as Signature;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Signature create() => Signature._();
  Signature createEmptyInstance() => create();
  static $pb.PbList<Signature> createRepeated() => $pb.PbList<Signature>();
  @$core.pragma('dart2js:noInline')
  static Signature getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Signature>(create);
  static Signature? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get kind => $_getIZ(0);
  @$pb.TagNumber(1)
  set kind($core.int v) { $_setUnsignedInt32(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasKind() => $_has(0);
  @$pb.TagNumber(1)
  void clearKind() => clearField(1);

  @$pb.TagNumber(2)
  $core.List<$core.int> get data => $_getN(1);
  @$pb.TagNumber(2)
  set data($core.List<$core.int> v) { $_setBytes(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasData() => $_has(1);
  @$pb.TagNumber(2)
  void clearData() => clearField(2);
}

class SecretKey extends $pb.GeneratedMessage {
  factory SecretKey({
    $core.int? kind,
    $core.List<$core.int>? data,
  }) {
    final $result = create();
    if (kind != null) {
      $result.kind = kind;
    }
    if (data != null) {
      $result.data = data;
    }
    return $result;
  }
  SecretKey._() : super();
  factory SecretKey.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory SecretKey.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SecretKey', package: const $pb.PackageName(_omitMessageNames ? '' : 'veilid'), createEmptyInstance: create)
    ..a<$core.int>(1, _omitFieldNames ? '' : 'kind', $pb.PbFieldType.OF3)
    ..a<$core.List<$core.int>>(2, _omitFieldNames ? '' : 'data', $pb.PbFieldType.OY)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  SecretKey clone() => SecretKey()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  SecretKey copyWith(void Function(SecretKey) updates) => super.copyWith((message) => updates(message as SecretKey)) as SecretKey;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SecretKey create() => SecretKey._();
  SecretKey createEmptyInstance() => create();
  static $pb.PbList<SecretKey> createRepeated() => $pb.PbList<SecretKey>();
  @$core.pragma('dart2js:noInline')
  static SecretKey getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SecretKey>(create);
  static SecretKey? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get kind => $_getIZ(0);
  @$pb.TagNumber(1)
  set kind($core.int v) { $_setUnsignedInt32(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasKind() => $_has(0);
  @$pb.TagNumber(1)
  void clearKind() => clearField(1);

  @$pb.TagNumber(2)
  $core.List<$core.int> get data => $_getN(1);
  @$pb.TagNumber(2)
  set data($core.List<$core.int> v) { $_setBytes(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasData() => $_has(1);
  @$pb.TagNumber(2)
  void clearData() => clearField(2);
}

class HashDigest extends $pb.GeneratedMessage {
  factory HashDigest({
    $core.int? kind,
    $core.List<$core.int>? data,
  }) {
    final $result = create();
    if (kind != null) {
      $result.kind = kind;
    }
    if (data != null) {
      $result.data = data;
    }
    return $result;
  }
  HashDigest._() : super();
  factory HashDigest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory HashDigest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'HashDigest', package: const $pb.PackageName(_omitMessageNames ? '' : 'veilid'), createEmptyInstance: create)
    ..a<$core.int>(1, _omitFieldNames ? '' : 'kind', $pb.PbFieldType.OF3)
    ..a<$core.List<$core.int>>(2, _omitFieldNames ? '' : 'data', $pb.PbFieldType.OY)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  HashDigest clone() => HashDigest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  HashDigest copyWith(void Function(HashDigest) updates) => super.copyWith((message) => updates(message as HashDigest)) as HashDigest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static HashDigest create() => HashDigest._();
  HashDigest createEmptyInstance() => create();
  static $pb.PbList<HashDigest> createRepeated() => $pb.PbList<HashDigest>();
  @$core.pragma('dart2js:noInline')
  static HashDigest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<HashDigest>(create);
  static HashDigest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get kind => $_getIZ(0);
  @$pb.TagNumber(1)
  set kind($core.int v) { $_setUnsignedInt32(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasKind() => $_has(0);
  @$pb.TagNumber(1)
  void clearKind() => clearField(1);

  @$pb.TagNumber(2)
  $core.List<$core.int> get data => $_getN(1);
  @$pb.TagNumber(2)
  set data($core.List<$core.int> v) { $_setBytes(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasData() => $_has(1);
  @$pb.TagNumber(2)
  void clearData() => clearField(2);
}

class OpaqueRecordKey extends $pb.GeneratedMessage {
  factory OpaqueRecordKey({
    $core.int? kind,
    $core.List<$core.int>? data,
  }) {
    final $result = create();
    if (kind != null) {
      $result.kind = kind;
    }
    if (data != null) {
      $result.data = data;
    }
    return $result;
  }
  OpaqueRecordKey._() : super();
  factory OpaqueRecordKey.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory OpaqueRecordKey.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'OpaqueRecordKey', package: const $pb.PackageName(_omitMessageNames ? '' : 'veilid'), createEmptyInstance: create)
    ..a<$core.int>(1, _omitFieldNames ? '' : 'kind', $pb.PbFieldType.OF3)
    ..a<$core.List<$core.int>>(2, _omitFieldNames ? '' : 'data', $pb.PbFieldType.OY)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  OpaqueRecordKey clone() => OpaqueRecordKey()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  OpaqueRecordKey copyWith(void Function(OpaqueRecordKey) updates) => super.copyWith((message) => updates(message as OpaqueRecordKey)) as OpaqueRecordKey;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static OpaqueRecordKey create() => OpaqueRecordKey._();
  OpaqueRecordKey createEmptyInstance() => create();
  static $pb.PbList<OpaqueRecordKey> createRepeated() => $pb.PbList<OpaqueRecordKey>();
  @$core.pragma('dart2js:noInline')
  static OpaqueRecordKey getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<OpaqueRecordKey>(create);
  static OpaqueRecordKey? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get kind => $_getIZ(0);
  @$pb.TagNumber(1)
  set kind($core.int v) { $_setUnsignedInt32(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasKind() => $_has(0);
  @$pb.TagNumber(1)
  void clearKind() => clearField(1);

  @$pb.TagNumber(2)
  $core.List<$core.int> get data => $_getN(1);
  @$pb.TagNumber(2)
  set data($core.List<$core.int> v) { $_setBytes(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasData() => $_has(1);
  @$pb.TagNumber(2)
  void clearData() => clearField(2);
}

class SharedSecret extends $pb.GeneratedMessage {
  factory SharedSecret({
    $core.int? kind,
    $core.List<$core.int>? data,
  }) {
    final $result = create();
    if (kind != null) {
      $result.kind = kind;
    }
    if (data != null) {
      $result.data = data;
    }
    return $result;
  }
  SharedSecret._() : super();
  factory SharedSecret.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory SharedSecret.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SharedSecret', package: const $pb.PackageName(_omitMessageNames ? '' : 'veilid'), createEmptyInstance: create)
    ..a<$core.int>(1, _omitFieldNames ? '' : 'kind', $pb.PbFieldType.OF3)
    ..a<$core.List<$core.int>>(2, _omitFieldNames ? '' : 'data', $pb.PbFieldType.OY)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  SharedSecret clone() => SharedSecret()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  SharedSecret copyWith(void Function(SharedSecret) updates) => super.copyWith((message) => updates(message as SharedSecret)) as SharedSecret;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SharedSecret create() => SharedSecret._();
  SharedSecret createEmptyInstance() => create();
  static $pb.PbList<SharedSecret> createRepeated() => $pb.PbList<SharedSecret>();
  @$core.pragma('dart2js:noInline')
  static SharedSecret getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SharedSecret>(create);
  static SharedSecret? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get kind => $_getIZ(0);
  @$pb.TagNumber(1)
  set kind($core.int v) { $_setUnsignedInt32(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasKind() => $_has(0);
  @$pb.TagNumber(1)
  void clearKind() => clearField(1);

  @$pb.TagNumber(2)
  $core.List<$core.int> get data => $_getN(1);
  @$pb.TagNumber(2)
  set data($core.List<$core.int> v) { $_setBytes(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasData() => $_has(1);
  @$pb.TagNumber(2)
  void clearData() => clearField(2);
}

class RouteId extends $pb.GeneratedMessage {
  factory RouteId({
    $core.int? kind,
    $core.List<$core.int>? data,
  }) {
    final $result = create();
    if (kind != null) {
      $result.kind = kind;
    }
    if (data != null) {
      $result.data = data;
    }
    return $result;
  }
  RouteId._() : super();
  factory RouteId.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory RouteId.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'RouteId', package: const $pb.PackageName(_omitMessageNames ? '' : 'veilid'), createEmptyInstance: create)
    ..a<$core.int>(1, _omitFieldNames ? '' : 'kind', $pb.PbFieldType.OF3)
    ..a<$core.List<$core.int>>(2, _omitFieldNames ? '' : 'data', $pb.PbFieldType.OY)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  RouteId clone() => RouteId()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  RouteId copyWith(void Function(RouteId) updates) => super.copyWith((message) => updates(message as RouteId)) as RouteId;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static RouteId create() => RouteId._();
  RouteId createEmptyInstance() => create();
  static $pb.PbList<RouteId> createRepeated() => $pb.PbList<RouteId>();
  @$core.pragma('dart2js:noInline')
  static RouteId getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<RouteId>(create);
  static RouteId? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get kind => $_getIZ(0);
  @$pb.TagNumber(1)
  set kind($core.int v) { $_setUnsignedInt32(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasKind() => $_has(0);
  @$pb.TagNumber(1)
  void clearKind() => clearField(1);

  @$pb.TagNumber(2)
  $core.List<$core.int> get data => $_getN(1);
  @$pb.TagNumber(2)
  set data($core.List<$core.int> v) { $_setBytes(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasData() => $_has(1);
  @$pb.TagNumber(2)
  void clearData() => clearField(2);
}

class NodeId extends $pb.GeneratedMessage {
  factory NodeId({
    $core.int? kind,
    $core.List<$core.int>? data,
  }) {
    final $result = create();
    if (kind != null) {
      $result.kind = kind;
    }
    if (data != null) {
      $result.data = data;
    }
    return $result;
  }
  NodeId._() : super();
  factory NodeId.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory NodeId.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'NodeId', package: const $pb.PackageName(_omitMessageNames ? '' : 'veilid'), createEmptyInstance: create)
    ..a<$core.int>(1, _omitFieldNames ? '' : 'kind', $pb.PbFieldType.OF3)
    ..a<$core.List<$core.int>>(2, _omitFieldNames ? '' : 'data', $pb.PbFieldType.OY)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  NodeId clone() => NodeId()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  NodeId copyWith(void Function(NodeId) updates) => super.copyWith((message) => updates(message as NodeId)) as NodeId;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static NodeId create() => NodeId._();
  NodeId createEmptyInstance() => create();
  static $pb.PbList<NodeId> createRepeated() => $pb.PbList<NodeId>();
  @$core.pragma('dart2js:noInline')
  static NodeId getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<NodeId>(create);
  static NodeId? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get kind => $_getIZ(0);
  @$pb.TagNumber(1)
  set kind($core.int v) { $_setUnsignedInt32(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasKind() => $_has(0);
  @$pb.TagNumber(1)
  void clearKind() => clearField(1);

  @$pb.TagNumber(2)
  $core.List<$core.int> get data => $_getN(1);
  @$pb.TagNumber(2)
  set data($core.List<$core.int> v) { $_setBytes(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasData() => $_has(1);
  @$pb.TagNumber(2)
  void clearData() => clearField(2);
}

class MemberId extends $pb.GeneratedMessage {
  factory MemberId({
    $core.int? kind,
    $core.List<$core.int>? data,
  }) {
    final $result = create();
    if (kind != null) {
      $result.kind = kind;
    }
    if (data != null) {
      $result.data = data;
    }
    return $result;
  }
  MemberId._() : super();
  factory MemberId.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory MemberId.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'MemberId', package: const $pb.PackageName(_omitMessageNames ? '' : 'veilid'), createEmptyInstance: create)
    ..a<$core.int>(1, _omitFieldNames ? '' : 'kind', $pb.PbFieldType.OF3)
    ..a<$core.List<$core.int>>(2, _omitFieldNames ? '' : 'data', $pb.PbFieldType.OY)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  MemberId clone() => MemberId()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  MemberId copyWith(void Function(MemberId) updates) => super.copyWith((message) => updates(message as MemberId)) as MemberId;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static MemberId create() => MemberId._();
  MemberId createEmptyInstance() => create();
  static $pb.PbList<MemberId> createRepeated() => $pb.PbList<MemberId>();
  @$core.pragma('dart2js:noInline')
  static MemberId getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<MemberId>(create);
  static MemberId? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get kind => $_getIZ(0);
  @$pb.TagNumber(1)
  set kind($core.int v) { $_setUnsignedInt32(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasKind() => $_has(0);
  @$pb.TagNumber(1)
  void clearKind() => clearField(1);

  @$pb.TagNumber(2)
  $core.List<$core.int> get data => $_getN(1);
  @$pb.TagNumber(2)
  set data($core.List<$core.int> v) { $_setBytes(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasData() => $_has(1);
  @$pb.TagNumber(2)
  void clearData() => clearField(2);
}

/// Key pair
class BareKeyPair extends $pb.GeneratedMessage {
  factory BareKeyPair({
    $core.List<$core.int>? key,
    $core.List<$core.int>? secret,
  }) {
    final $result = create();
    if (key != null) {
      $result.key = key;
    }
    if (secret != null) {
      $result.secret = secret;
    }
    return $result;
  }
  BareKeyPair._() : super();
  factory BareKeyPair.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory BareKeyPair.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'BareKeyPair', package: const $pb.PackageName(_omitMessageNames ? '' : 'veilid'), createEmptyInstance: create)
    ..a<$core.List<$core.int>>(1, _omitFieldNames ? '' : 'key', $pb.PbFieldType.OY)
    ..a<$core.List<$core.int>>(2, _omitFieldNames ? '' : 'secret', $pb.PbFieldType.OY)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  BareKeyPair clone() => BareKeyPair()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  BareKeyPair copyWith(void Function(BareKeyPair) updates) => super.copyWith((message) => updates(message as BareKeyPair)) as BareKeyPair;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static BareKeyPair create() => BareKeyPair._();
  BareKeyPair createEmptyInstance() => create();
  static $pb.PbList<BareKeyPair> createRepeated() => $pb.PbList<BareKeyPair>();
  @$core.pragma('dart2js:noInline')
  static BareKeyPair getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<BareKeyPair>(create);
  static BareKeyPair? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<$core.int> get key => $_getN(0);
  @$pb.TagNumber(1)
  set key($core.List<$core.int> v) { $_setBytes(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasKey() => $_has(0);
  @$pb.TagNumber(1)
  void clearKey() => clearField(1);

  @$pb.TagNumber(2)
  $core.List<$core.int> get secret => $_getN(1);
  @$pb.TagNumber(2)
  set secret($core.List<$core.int> v) { $_setBytes(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasSecret() => $_has(1);
  @$pb.TagNumber(2)
  void clearSecret() => clearField(2);
}

class KeyPair extends $pb.GeneratedMessage {
  factory KeyPair({
    $core.int? kind,
    $core.List<$core.int>? key,
    $core.List<$core.int>? secret,
  }) {
    final $result = create();
    if (kind != null) {
      $result.kind = kind;
    }
    if (key != null) {
      $result.key = key;
    }
    if (secret != null) {
      $result.secret = secret;
    }
    return $result;
  }
  KeyPair._() : super();
  factory KeyPair.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory KeyPair.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'KeyPair', package: const $pb.PackageName(_omitMessageNames ? '' : 'veilid'), createEmptyInstance: create)
    ..a<$core.int>(1, _omitFieldNames ? '' : 'kind', $pb.PbFieldType.OF3)
    ..a<$core.List<$core.int>>(2, _omitFieldNames ? '' : 'key', $pb.PbFieldType.OY)
    ..a<$core.List<$core.int>>(3, _omitFieldNames ? '' : 'secret', $pb.PbFieldType.OY)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  KeyPair clone() => KeyPair()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  KeyPair copyWith(void Function(KeyPair) updates) => super.copyWith((message) => updates(message as KeyPair)) as KeyPair;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static KeyPair create() => KeyPair._();
  KeyPair createEmptyInstance() => create();
  static $pb.PbList<KeyPair> createRepeated() => $pb.PbList<KeyPair>();
  @$core.pragma('dart2js:noInline')
  static KeyPair getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<KeyPair>(create);
  static KeyPair? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get kind => $_getIZ(0);
  @$pb.TagNumber(1)
  set kind($core.int v) { $_setUnsignedInt32(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasKind() => $_has(0);
  @$pb.TagNumber(1)
  void clearKind() => clearField(1);

  @$pb.TagNumber(2)
  $core.List<$core.int> get key => $_getN(1);
  @$pb.TagNumber(2)
  set key($core.List<$core.int> v) { $_setBytes(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasKey() => $_has(1);
  @$pb.TagNumber(2)
  void clearKey() => clearField(2);

  @$pb.TagNumber(3)
  $core.List<$core.int> get secret => $_getN(2);
  @$pb.TagNumber(3)
  set secret($core.List<$core.int> v) { $_setBytes(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasSecret() => $_has(2);
  @$pb.TagNumber(3)
  void clearSecret() => clearField(3);
}

/// Record Key
class BareRecordKey extends $pb.GeneratedMessage {
  factory BareRecordKey({
    $core.List<$core.int>? key,
    $core.List<$core.int>? encryptionKey,
  }) {
    final $result = create();
    if (key != null) {
      $result.key = key;
    }
    if (encryptionKey != null) {
      $result.encryptionKey = encryptionKey;
    }
    return $result;
  }
  BareRecordKey._() : super();
  factory BareRecordKey.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory BareRecordKey.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'BareRecordKey', package: const $pb.PackageName(_omitMessageNames ? '' : 'veilid'), createEmptyInstance: create)
    ..a<$core.List<$core.int>>(1, _omitFieldNames ? '' : 'key', $pb.PbFieldType.OY)
    ..a<$core.List<$core.int>>(2, _omitFieldNames ? '' : 'encryptionKey', $pb.PbFieldType.OY)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  BareRecordKey clone() => BareRecordKey()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  BareRecordKey copyWith(void Function(BareRecordKey) updates) => super.copyWith((message) => updates(message as BareRecordKey)) as BareRecordKey;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static BareRecordKey create() => BareRecordKey._();
  BareRecordKey createEmptyInstance() => create();
  static $pb.PbList<BareRecordKey> createRepeated() => $pb.PbList<BareRecordKey>();
  @$core.pragma('dart2js:noInline')
  static BareRecordKey getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<BareRecordKey>(create);
  static BareRecordKey? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<$core.int> get key => $_getN(0);
  @$pb.TagNumber(1)
  set key($core.List<$core.int> v) { $_setBytes(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasKey() => $_has(0);
  @$pb.TagNumber(1)
  void clearKey() => clearField(1);

  @$pb.TagNumber(2)
  $core.List<$core.int> get encryptionKey => $_getN(1);
  @$pb.TagNumber(2)
  set encryptionKey($core.List<$core.int> v) { $_setBytes(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasEncryptionKey() => $_has(1);
  @$pb.TagNumber(2)
  void clearEncryptionKey() => clearField(2);
}

class RecordKey extends $pb.GeneratedMessage {
  factory RecordKey({
    $core.int? kind,
    $core.List<$core.int>? key,
    $core.List<$core.int>? encryptionKey,
  }) {
    final $result = create();
    if (kind != null) {
      $result.kind = kind;
    }
    if (key != null) {
      $result.key = key;
    }
    if (encryptionKey != null) {
      $result.encryptionKey = encryptionKey;
    }
    return $result;
  }
  RecordKey._() : super();
  factory RecordKey.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory RecordKey.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'RecordKey', package: const $pb.PackageName(_omitMessageNames ? '' : 'veilid'), createEmptyInstance: create)
    ..a<$core.int>(1, _omitFieldNames ? '' : 'kind', $pb.PbFieldType.OF3)
    ..a<$core.List<$core.int>>(2, _omitFieldNames ? '' : 'key', $pb.PbFieldType.OY)
    ..a<$core.List<$core.int>>(3, _omitFieldNames ? '' : 'encryptionKey', $pb.PbFieldType.OY)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  RecordKey clone() => RecordKey()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  RecordKey copyWith(void Function(RecordKey) updates) => super.copyWith((message) => updates(message as RecordKey)) as RecordKey;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static RecordKey create() => RecordKey._();
  RecordKey createEmptyInstance() => create();
  static $pb.PbList<RecordKey> createRepeated() => $pb.PbList<RecordKey>();
  @$core.pragma('dart2js:noInline')
  static RecordKey getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<RecordKey>(create);
  static RecordKey? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get kind => $_getIZ(0);
  @$pb.TagNumber(1)
  set kind($core.int v) { $_setUnsignedInt32(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasKind() => $_has(0);
  @$pb.TagNumber(1)
  void clearKind() => clearField(1);

  @$pb.TagNumber(2)
  $core.List<$core.int> get key => $_getN(1);
  @$pb.TagNumber(2)
  set key($core.List<$core.int> v) { $_setBytes(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasKey() => $_has(1);
  @$pb.TagNumber(2)
  void clearKey() => clearField(2);

  @$pb.TagNumber(3)
  $core.List<$core.int> get encryptionKey => $_getN(2);
  @$pb.TagNumber(3)
  set encryptionKey($core.List<$core.int> v) { $_setBytes(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasEncryptionKey() => $_has(2);
  @$pb.TagNumber(3)
  void clearEncryptionKey() => clearField(3);
}


const _omitFieldNames = $core.bool.fromEnvironment('protobuf.omit_field_names');
const _omitMessageNames = $core.bool.fromEnvironment('protobuf.omit_message_names');
