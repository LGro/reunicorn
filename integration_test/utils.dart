// Copyright 2024 - 2025 The Reunicorn Authors. All rights reserved.
// SPDX-License-Identifier: AGPL-3.0-or-later

/// Veilid bootstrap URL for integration tests
const veilidBootstrapUrl = 'bootstrap-v1.veilid.net';

Future<void> retryUntilTimeout(
  int timeoutSeconds,
  Future<void> Function() callable,
) async {
  final end = DateTime.now().add(Duration(seconds: timeoutSeconds));
  while (DateTime.now().isBefore(end)) {
    try {
      await callable();
    } on Exception {}
    await Future<void>.delayed(const Duration(milliseconds: 100));
  }
  await callable();
}
