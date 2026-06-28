import 'dart:io' show Platform;

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:veilid/veilid.dart';

// Allowed to pull sentinel value
// ignore: do_not_use_environment, omit_obvious_property_types
const bool kIsReleaseMode = bool.fromEnvironment('dart.vm.product');
// Allowed to pull sentinel value
// ignore: do_not_use_environment, omit_obvious_property_types
const bool kIsProfileMode = bool.fromEnvironment('dart.vm.profile');
const bool kIsDebugMode = !kIsReleaseMode && !kIsProfileMode;

Future<Map<String, dynamic>> getDefaultVeilidPlatformConfig(
  bool isWeb,
  String appName,
) async {
  final logDirectivesStr =
      // Allowed to change settings
      // ignore: do_not_use_environment
      const String.fromEnvironment('LOG_DIRECTIVES').trim();
  final logDirectives = logDirectivesStr.isEmpty
      ? <String>[]
      : logDirectivesStr.split(',').map((e) => e.trim()).toList();

  // Allowed to change settings
  // ignore: do_not_use_environment
  var flamePathStr = const String.fromEnvironment('FLAME').trim();
  if (flamePathStr == '1') {
    flamePathStr = p.join(
      (await getApplicationSupportDirectory()).absolute.path,
      '$appName.folded',
    );
    // Allowed for debugging
    // ignore: avoid_print
    print('Flame data logged to $flamePathStr');
  }

  // OTLP settings: enable by setting OTLP=1 at run time. Requires veilid-flutter
  // to be built with the `opentelemetry` cargo feature
  // (VEILID_CARGO_EXTRA_OPTIONS="--features opentelemetry") for spans to exist.
  // Allowed to change settings
  // ignore: do_not_use_environment
  final otlpEnabled = const String.fromEnvironment('OTLP').trim() == '1';
  final otlpEndpoint = const String.fromEnvironment(
    // Allowed to change settings
    // ignore: do_not_use_environment
    'OTLP_GRPC_ENDPOINT',
    defaultValue: '127.0.0.1:4317',
  ).trim();
  final otlpDirectivesStr =
      // Allowed to change settings
      // ignore: do_not_use_environment
      const String.fromEnvironment('OTLP_DIRECTIVES').trim();
  final otlpDirectives = otlpDirectivesStr.isEmpty
      ? <String>[]
      : otlpDirectivesStr.split(',').map((e) => e.trim()).toList();

  if (isWeb) {
    return VeilidWASMConfig(
      logging: VeilidWASMConfigLogging(
        performance: VeilidWASMConfigLoggingPerformance(
          enabled: true,
          level: kIsDebugMode
              ? VeilidConfigLogLevel.debug
              : VeilidConfigLogLevel.info,
          timings: true,
          console: VeilidWASMConfigLoggingPerformanceConsole(
            enabled: kIsDebugMode,
          ),
          directives: logDirectives,
        ),
        api: VeilidWASMConfigLoggingApi(
          enabled: true,
          level: VeilidConfigLogLevel.info,
          directives: logDirectives,
        ),
      ),
    ).toJson();
  }
  return VeilidFFIConfig(
    logging: VeilidFFIConfigLogging(
      terminal: VeilidFFIConfigLoggingTerminal(
        enabled: false,
        level: kIsDebugMode
            ? VeilidConfigLogLevel.debug
            : VeilidConfigLogLevel.info,
        directives: logDirectives,
      ),
      api: VeilidFFIConfigLoggingApi(
        enabled: true,
        level: VeilidConfigLogLevel.info,
        directives: logDirectives,
      ),
      otlp: VeilidFFIConfigLoggingOtlp(
        enabled: otlpEnabled,
        level: VeilidConfigLogLevel.trace,
        grpcEndpoint: otlpEndpoint,
        serviceName: appName,
        directives: otlpDirectives,
      ),
      flame: VeilidFFIConfigLoggingFlame(
        enabled: flamePathStr.isNotEmpty,
        path: flamePathStr,
      ),
    ),
  ).toJson();
}

Future<VeilidConfig> getVeilidConfig(bool isWeb, String programName) async {
  var config = await getDefaultVeilidConfig(
    isWeb: isWeb,
    programName: programName,
    // Allowed to change settings
    // ignore: avoid_redundant_argument_values, do_not_use_environment
    namespace: const String.fromEnvironment('NAMESPACE'),
    // Allowed to change settings
    // ignore: avoid_redundant_argument_values, do_not_use_environment
    bootstrap: const String.fromEnvironment('BOOTSTRAP'),
    // Allowed to change settings
    // ignore: avoid_redundant_argument_values, do_not_use_environment
    bootstrapKeys: const bool.hasEnvironment('BOOTSTRAP_KEYS')
        // Allowed to change settings
        // ignore: do_not_use_environment
        ? const String.fromEnvironment('BOOTSTRAP_KEYS')
        : null,
    // Allowed to change settings
    // ignore: avoid_redundant_argument_values, do_not_use_environment
    networkKeyPassword: const String.fromEnvironment('NETWORK_KEY'),
  );

  // Allowed to change settings
  // ignore: do_not_use_environment
  if (const String.fromEnvironment('DELETE_TABLE_STORE') == '1') {
    config = config.copyWith(
      tableStore: config.tableStore.copyWith(delete: true),
    );
  }
  // Allowed to change settings
  // ignore: do_not_use_environment
  if (const String.fromEnvironment('DELETE_PROTECTED_STORE') == '1') {
    config = config.copyWith(
      protectedStore: config.protectedStore.copyWith(delete: true),
    );
  }
  // Allowed to change settings
  // ignore: do_not_use_environment
  if (const String.fromEnvironment('DELETE_BLOCK_STORE') == '1') {
    config = config.copyWith(
      blockStore: config.blockStore.copyWith(delete: true),
    );
  }
  return config.copyWith(
    capabilities:
        // XXX: Remove after https://gitlab.com/veilid/veilid/-/issues/492
        const VeilidConfigCapabilities(disable: ['DHTV']),
    protectedStore:
        // Linux often does not have a secret storage mechanism installed
        config.protectedStore.copyWith(
          allowInsecureFallback: !isWeb && Platform.isLinux,
        ),
  );
}
