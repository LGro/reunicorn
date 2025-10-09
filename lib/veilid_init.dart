import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:veilid_support/veilid_support.dart';

import 'tools/tools.dart';
import 'veilid_processor/veilid_processor.dart';

class AppGlobalInit {
  AppGlobalInit._();

  // Initialize Veilid
  Future<void> _initializeVeilid(String bootstrapUrl) async {
    // Init Veilid
    Veilid.instance.initializeVeilidCore(
        await getDefaultVeilidPlatformConfig(kIsWeb, 'Reunicorn'));

    // Veilid logging
    initVeilidLog(kDebugMode);

    // Startup Veilid
    await ProcessorRepository.instance.startup(bootstrapUrl);

    // DHT Record Pool
    await DHTRecordPool.init(
        defaultKind: cryptoKindVLD0,
        logger: (message) => log.debug('DHTRecordPool: $message'));
  }

  static Future<AppGlobalInit> initialize(String bootstrapUrl) async {
    final appGlobalInit = AppGlobalInit._();

    log.info('Initializing Veilid');
    await appGlobalInit._initializeVeilid(bootstrapUrl);

    return appGlobalInit;
  }
}
