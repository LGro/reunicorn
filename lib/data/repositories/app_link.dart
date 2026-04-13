// Copyright 2026 The Reunicorn Authors. All rights reserved.
// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:reunicorn/data/repositories/base_dht.dart';

class AppLinkRepository extends BaseDhtRepository {
  // needs storage: contact, applink, update?
  @override
  Future<void> dhtBecameAvailableCallback() {
    // TODO: implement dhtBecameAvailableCallback
    throw UnimplementedError();
  }

  // listen on app link storage changes
  //    -> populate dht record and writer pairs for new contact app links
  //    -> remove app link record key writer pairs
  // listen to contact updates
  //    -> update app link record with contact record, record writer or remove if no longer linked
  // listen to app link record updates for new contacts
  //    -> for new contacts, add contacts if auto add configured, add update?
}
