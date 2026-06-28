#!/bin/bash
set -e
dart run build_runner build

pushd lib > /dev/null
protoc --dart_out=proto -I proto -I dht_support/proto dht.proto
protoc --dart_out=proto -I proto -I dht_support/proto dht.deprecated.proto
protoc --dart_out=proto -I proto veilid.proto
protoc --dart_out=proto -I proto veilid.deprecated.proto
popd > /dev/null
