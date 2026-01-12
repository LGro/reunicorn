// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'crypto_state.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CryptoInitializedSymmetric _$CryptoInitializedSymmetricFromJson(
  Map<String, dynamic> json,
) => CryptoInitializedSymmetric(
  initialSharedSecret: Typed<BareSharedSecret>.fromJson(
    json['initial_shared_secret'],
  ),
  myNextKeyPair: KeyPair.fromJson(json['my_next_key_pair']),
  $type: json['runtimeType'] as String?,
);

Map<String, dynamic> _$CryptoInitializedSymmetricToJson(
  CryptoInitializedSymmetric instance,
) => <String, dynamic>{
  'initial_shared_secret': instance.initialSharedSecret.toJson(),
  'my_next_key_pair': instance.myNextKeyPair.toJson(),
  'runtimeType': instance.$type,
};

CryptoEstablishedSymmetric _$CryptoEstablishedSymmetricFromJson(
  Map<String, dynamic> json,
) => CryptoEstablishedSymmetric(
  initialSharedSecret: Typed<BareSharedSecret>.fromJson(
    json['initial_shared_secret'],
  ),
  myNextKeyPair: KeyPair.fromJson(json['my_next_key_pair']),
  theirNextPublicKey: Typed<BarePublicKey>.fromJson(
    json['their_next_public_key'],
  ),
  $type: json['runtimeType'] as String?,
);

Map<String, dynamic> _$CryptoEstablishedSymmetricToJson(
  CryptoEstablishedSymmetric instance,
) => <String, dynamic>{
  'initial_shared_secret': instance.initialSharedSecret.toJson(),
  'my_next_key_pair': instance.myNextKeyPair.toJson(),
  'their_next_public_key': instance.theirNextPublicKey.toJson(),
  'runtimeType': instance.$type,
};

CryptoInitializedAsymmetric _$CryptoInitializedAsymmetricFromJson(
  Map<String, dynamic> json,
) => CryptoInitializedAsymmetric(
  initialSharedSecret: Typed<BareSharedSecret>.fromJson(
    json['initial_shared_secret'],
  ),
  myKeyPair: KeyPair.fromJson(json['my_key_pair']),
  myNextKeyPair: KeyPair.fromJson(json['my_next_key_pair']),
  theirNextPublicKey: Typed<BarePublicKey>.fromJson(
    json['their_next_public_key'],
  ),
  $type: json['runtimeType'] as String?,
);

Map<String, dynamic> _$CryptoInitializedAsymmetricToJson(
  CryptoInitializedAsymmetric instance,
) => <String, dynamic>{
  'initial_shared_secret': instance.initialSharedSecret.toJson(),
  'my_key_pair': instance.myKeyPair.toJson(),
  'my_next_key_pair': instance.myNextKeyPair.toJson(),
  'their_next_public_key': instance.theirNextPublicKey.toJson(),
  'runtimeType': instance.$type,
};

CryptoEstablishedAsymmetric _$CryptoEstablishedAsymmetricFromJson(
  Map<String, dynamic> json,
) => CryptoEstablishedAsymmetric(
  myKeyPair: KeyPair.fromJson(json['my_key_pair']),
  myNextKeyPair: KeyPair.fromJson(json['my_next_key_pair']),
  theirPublicKey: Typed<BarePublicKey>.fromJson(json['their_public_key']),
  theirNextPublicKey: Typed<BarePublicKey>.fromJson(
    json['their_next_public_key'],
  ),
  $type: json['runtimeType'] as String?,
);

Map<String, dynamic> _$CryptoEstablishedAsymmetricToJson(
  CryptoEstablishedAsymmetric instance,
) => <String, dynamic>{
  'my_key_pair': instance.myKeyPair.toJson(),
  'my_next_key_pair': instance.myNextKeyPair.toJson(),
  'their_public_key': instance.theirPublicKey.toJson(),
  'their_next_public_key': instance.theirNextPublicKey.toJson(),
  'runtimeType': instance.$type,
};
