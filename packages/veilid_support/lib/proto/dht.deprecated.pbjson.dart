//
//  Generated code. Do not modify.
//  source: dht.deprecated.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:convert' as $convert;
import 'dart:core' as $core;
import 'dart:typed_data' as $typed_data;

@$core.Deprecated('Use dHTDataDescriptor instead')
const DHTData$json = {
  '1': 'DHTData',
  '2': [
    {'1': 'keys', '3': 1, '4': 3, '5': 11, '6': '.veilid.deprecated.TypedKey', '10': 'keys'},
    {'1': 'hash', '3': 2, '4': 1, '5': 11, '6': '.veilid.deprecated.TypedKey', '10': 'hash'},
    {'1': 'chunk', '3': 3, '4': 1, '5': 13, '10': 'chunk'},
    {'1': 'size', '3': 4, '4': 1, '5': 13, '10': 'size'},
  ],
};

/// Descriptor for `DHTData`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List dHTDataDescriptor = $convert.base64Decode(
    'CgdESFREYXRhEi8KBGtleXMYASADKAsyGy52ZWlsaWQuZGVwcmVjYXRlZC5UeXBlZEtleVIEa2'
    'V5cxIvCgRoYXNoGAIgASgLMhsudmVpbGlkLmRlcHJlY2F0ZWQuVHlwZWRLZXlSBGhhc2gSFAoF'
    'Y2h1bmsYAyABKA1SBWNodW5rEhIKBHNpemUYBCABKA1SBHNpemU=');

@$core.Deprecated('Use dHTLogDescriptor instead')
const DHTLog$json = {
  '1': 'DHTLog',
  '2': [
    {'1': 'head', '3': 1, '4': 1, '5': 13, '10': 'head'},
    {'1': 'tail', '3': 2, '4': 1, '5': 13, '10': 'tail'},
    {'1': 'stride', '3': 3, '4': 1, '5': 13, '10': 'stride'},
  ],
};

/// Descriptor for `DHTLog`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List dHTLogDescriptor = $convert.base64Decode(
    'CgZESFRMb2cSEgoEaGVhZBgBIAEoDVIEaGVhZBISCgR0YWlsGAIgASgNUgR0YWlsEhYKBnN0cm'
    'lkZRgDIAEoDVIGc3RyaWRl');

@$core.Deprecated('Use dHTShortArrayDescriptor instead')
const DHTShortArray$json = {
  '1': 'DHTShortArray',
  '2': [
    {'1': 'keys', '3': 1, '4': 3, '5': 11, '6': '.veilid.deprecated.TypedKey', '10': 'keys'},
    {'1': 'index', '3': 2, '4': 1, '5': 12, '10': 'index'},
    {'1': 'seqs', '3': 3, '4': 3, '5': 13, '10': 'seqs'},
  ],
};

/// Descriptor for `DHTShortArray`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List dHTShortArrayDescriptor = $convert.base64Decode(
    'Cg1ESFRTaG9ydEFycmF5Ei8KBGtleXMYASADKAsyGy52ZWlsaWQuZGVwcmVjYXRlZC5UeXBlZE'
    'tleVIEa2V5cxIUCgVpbmRleBgCIAEoDFIFaW5kZXgSEgoEc2VxcxgDIAMoDVIEc2Vxcw==');

@$core.Deprecated('Use ownedDHTRecordPointerDescriptor instead')
const OwnedDHTRecordPointer$json = {
  '1': 'OwnedDHTRecordPointer',
  '2': [
    {'1': 'record_key', '3': 1, '4': 1, '5': 11, '6': '.veilid.deprecated.TypedKey', '10': 'recordKey'},
    {'1': 'owner', '3': 2, '4': 1, '5': 11, '6': '.veilid.deprecated.KeyPair', '10': 'owner'},
  ],
};

/// Descriptor for `OwnedDHTRecordPointer`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List ownedDHTRecordPointerDescriptor = $convert.base64Decode(
    'ChVPd25lZERIVFJlY29yZFBvaW50ZXISOgoKcmVjb3JkX2tleRgBIAEoCzIbLnZlaWxpZC5kZX'
    'ByZWNhdGVkLlR5cGVkS2V5UglyZWNvcmRLZXkSMAoFb3duZXIYAiABKAsyGi52ZWlsaWQuZGVw'
    'cmVjYXRlZC5LZXlQYWlyUgVvd25lcg==');

