import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:veilid_support/veilid_support.dart';

import '../../tools/tools.dart';

class VeilidProcessorRepository implements VeilidProcessorInterface {
  //////////////////////////////////////////////////////////////
  /// Singleton initialization

  // Public API
  // ignore: omit_obvious_property_types
  static VeilidProcessorRepository instance = VeilidProcessorRepository._();

  ////////////////////////////////////////////

  StreamSubscription<VeilidUpdate>? _updateSubscription;

  final StreamController<ProcessorConnectionState> _controllerConnectionState;

  bool startedUp;

  @override
  ProcessorConnectionState processorConnectionState;

  VeilidProcessorRepository._()
    : startedUp = false,
      _controllerConnectionState = StreamController.broadcast(sync: true),
      processorConnectionState = ProcessorConnectionState(
        attachment: VeilidStateAttachment(
          state: AttachmentState.detached,
          publicInternetReady: false,
          localNetworkReady: false,
          uptime: TimestampDuration(value: BigInt.zero),
          attachedUptime: null,
          reliablePeerCount: BigInt.zero,
          livePeerCount: BigInt.zero,
          estimatedNetworkSize: BigInt.zero,
          medianLatency: null,
          overAttachedNodes: BigInt.zero,
        ),
        network: VeilidStateNetwork(
          started: false,
          bpsDown: BigInt.zero,
          bpsUp: BigInt.zero,
          peers: [],
        ),
      );

  Future<void> startup(String bootstrapUrl) async {
    if (startedUp) {
      return;
    }

    var veilidVersion = '';

    try {
      veilidVersion = Veilid.instance.veilidVersionString();
    } on Exception {
      veilidVersion = 'Failed to get veilid version.';
    }

    log.info('Veilid version: $veilidVersion');

    final veilidConfig = await getVeilidConfig(kIsWeb, 'Reunicorn').then(
      (c) => kIsWeb
          ? c
          : c.copyWith(
              network: c.network.copyWith(
                routingTable: c.network.routingTable.copyWith(
                  bootstrap: [bootstrapUrl],
                ),
              ),
            ),
    );

    Stream<VeilidUpdate> updateStream;
    try {
      log.debug('Starting VeilidCore');
      updateStream = await Veilid.instance.startupVeilidCore(veilidConfig);
    } on VeilidAPIExceptionAlreadyInitialized catch (_) {
      log.debug(
        'VeilidCore is already started, shutting down and restarting...',
      );
      startedUp = true;
      await shutdown();
      updateStream = await Veilid.instance.startupVeilidCore(veilidConfig);
    }
    _updateSubscription = updateStream.listen((update) {
      if (update is VeilidLog) {
        processLog(update);
      } else if (update is VeilidUpdateAttachment) {
        processUpdateAttachment(update);
      } else if (update is VeilidUpdateConfig) {
        processUpdateConfig(update);
      } else if (update is VeilidUpdateNetwork) {
        processUpdateNetwork(update);
      } else if (update is VeilidAppMessage) {
        processAppMessage(update);
      } else if (update is VeilidAppCall) {
        log.info('AppCall: ${update.toJson()}');
      } else if (update is VeilidUpdateValueChange) {
        processUpdateValueChange(update);
      } else {
        log.trace('Update: ${update.toJson()}');
      }
    });

    startedUp = true;

    await Veilid.instance.attach();
  }

  Future<void> shutdown() async {
    if (!startedUp) {
      return;
    }
    await Veilid.instance.shutdownVeilidCore();
    await _updateSubscription?.cancel();
    _updateSubscription = null;

    startedUp = false;
  }

  Future<void> attach() async {
    if (!startedUp) return;
    log.debug('Veilid attach');
    try {
      await Veilid.instance.attach();
    } on VeilidAPIExceptionGeneric catch (e) {
      if (e.message.contains('Already attached')) {
        log.debug('Veilid already attached');
      } else {
        rethrow;
      }
    }
  }

  Future<void> detach() async {
    if (!startedUp) return;
    log.debug('Veilid detach');
    await Veilid.instance.detach();
  }

  Future<bool> waitForPublicInternet({
    Duration timeout = const Duration(seconds: 30),
  }) async {
    if (processorConnectionState.isPublicInternetReady) return true;
    try {
      await _controllerConnectionState.stream
          .where((s) => s.isPublicInternetReady)
          .first
          .timeout(timeout);
      return true;
    } on TimeoutException {
      log.warning('Timed out waiting for public internet');
      return false;
    }
  }

  @override
  Stream<ProcessorConnectionState> streamProcessorConnectionState() =>
      _controllerConnectionState.stream;

  void processUpdateAttachment(VeilidUpdateAttachment updateAttachment) {
    // Set connection meter and ui state for connection state
    processorConnectionState = processorConnectionState.copyWith(
      attachment: VeilidStateAttachment(
        state: updateAttachment.state,
        publicInternetReady: updateAttachment.publicInternetReady,
        localNetworkReady: updateAttachment.localNetworkReady,
        uptime: updateAttachment.uptime,
        attachedUptime: updateAttachment.attachedUptime,
        reliablePeerCount: updateAttachment.reliablePeerCount,
        livePeerCount: updateAttachment.livePeerCount,
        estimatedNetworkSize: updateAttachment.estimatedNetworkSize,
        medianLatency: updateAttachment.medianLatency,
        overAttachedNodes: updateAttachment.overAttachedNodes,
      ),
    );
    _controllerConnectionState.add(processorConnectionState);
  }

  void processUpdateConfig(VeilidUpdateConfig updateConfig) {
    log.debug('VeilidUpdateConfig: ${updateConfig.toJson()}');
  }

  void processUpdateNetwork(VeilidUpdateNetwork updateNetwork) {
    // Set connection meter and ui state for connection state
    processorConnectionState = processorConnectionState.copyWith(
      network: VeilidStateNetwork(
        started: updateNetwork.started,
        bpsDown: updateNetwork.bpsDown,
        bpsUp: updateNetwork.bpsUp,
        peers: updateNetwork.peers,
      ),
    );
    _controllerConnectionState.add(processorConnectionState);
  }

  void processAppMessage(VeilidAppMessage appMessage) {
    log.debug('VeilidAppMessage: ${appMessage.toJson()}');
  }

  void processUpdateValueChange(VeilidUpdateValueChange updateValueChange) {
    log.debug('UpdateValueChange: ${updateValueChange.toJson()}');

    // Send value updates to DHTRecordPool
    DHTRecordPool.instance.processRemoteValueChange(updateValueChange);
  }
}
