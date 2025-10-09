import 'dart:async';
import 'dart:typed_data';

abstract class CryptoCodec {
  Future<Uint8List> encrypt(Uint8List data);
  Future<Uint8List> decrypt(Uint8List data);
}
