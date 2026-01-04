// Copyright 2026 The Reunicorn Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

import 'dart:async';

import 'package:loggy/loggy.dart';
import 'package:veilid/veilid.dart';

import '../../veilid_processor/veilid_processor.dart';

abstract class BaseDhtRepository {
  var isDhtAvailable = false;

  BaseDhtRepository() {
    unawaited(_initIsDhtAvailable());
    ProcessorRepository.instance.streamProcessorConnectionState().listen(
      _veilidConnectionStateChangeCallback,
    );
  }

  Future<void> _initIsDhtAvailable() async {
    try {
      final state = await Veilid.instance.getVeilidState();
      isDhtAvailable =
          state.attachment.publicInternetReady &&
          state.attachment.state == AttachmentState.fullyAttached;
    } on VeilidAPIExceptionNotInitialized {}
  }

  void _veilidConnectionStateChangeCallback(ProcessorConnectionState event) {
    logDebug('rncrn-veilid-connection-state-changed: $event');
    if (event.isPublicInternetReady && event.isAttached && !isDhtAvailable) {
      isDhtAvailable = true;
      unawaited(dhtBecameAvailableCallback());
    }

    if (!event.isPublicInternetReady || !event.isAttached) {
      isDhtAvailable = false;
    }
  }

  Future<void> dhtBecameAvailableCallback();
}
