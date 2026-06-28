// Adapted from veilidchat licensed MPL-2.0
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:veilid_support/veilid_support.dart';

import 'tools/tools.dart';
import 'veilid_processor/veilid_processor.dart';

List<String> rootAssets = [];

class AppGlobalInit {
  AppGlobalInit._();

  // Initialize Veilid
  Future<void> _initializeVeilid(String bootstrapUrl) async {
    // Init Veilid
    try {
      Veilid.instance.initializeVeilidCore(
        await getDefaultVeilidPlatformConfig(kIsWeb, 'Reunicorn'),
      );
    } on VeilidAPIExceptionAlreadyInitialized {
      log.debug('Already initialized, not reinitializing veilid-core');
    }

    // Veilid logging
    initVeilidLog(kIsDebugMode);

    // Startup Veilid
    await VeilidProcessorRepository.instance.startup(bootstrapUrl);

    // DHT Record Pool
    await DHTRecordPool.init(
      defaultKind: cryptoKindVLD0,
      logger: (message) => log.debug('DHTRecordPool: $message'),
      processor: VeilidProcessorRepository.instance,
    );
  }

  // Initialize repositories
  Future<void> _initializeRepositories() async {}

  // Initialize asset manifest
  static Future<void> loadAssetManifest() async {
    final assetManifest = await AssetManifest.loadFromAssetBundle(rootBundle);
    rootAssets = assetManifest.listAssets();
  }

  static Future<AppGlobalInit> initialize(String bootstrapUrl) async {
    final appGlobalInit = AppGlobalInit._();

    await loadAssetManifest();

    log.info('Initializing Veilid');
    await appGlobalInit._initializeVeilid(bootstrapUrl);
    log.info('Initializing Repositories');
    await appGlobalInit._initializeRepositories();

    return appGlobalInit;
  }
}
