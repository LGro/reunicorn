import 'package:async_tools/async_tools.dart';

import '../../../veilid_support.dart';

/// Total number of times to try in a 'VeilidAPIExceptionKeyNotFound' loop
const kDHTKeyNotFoundTries = 1;

/// Total number of times to try in a 'VeilidAPIExceptionTryAgain' loop
const kDHTTryAgainTries = 3;

// Wrap all veilid-flutter DHT operations to apply both retry mechanism
// and translation of handled exceptions to veilid_support exceptions
Future<T> dhtRetryLoop<T>(Future<T> Function() closure) async {
  var retryTryAgain = kDHTTryAgainTries;
  var retryKeyNotFound = kDHTKeyNotFoundTries;

  while (true) {
    try {
      return await closure();
    } on VeilidAPIExceptionTryAgain {
      await asyncSleep();
      retryTryAgain--;
      if (retryTryAgain == 0) {
        throw const DHTExceptionNotAvailable();
      }
    } on VeilidAPIExceptionKeyNotFound {
      await asyncSleep();
      retryKeyNotFound--;
      if (retryKeyNotFound == 0) {
        throw const DHTExceptionNoRecord();
      }
    }
  }
}
