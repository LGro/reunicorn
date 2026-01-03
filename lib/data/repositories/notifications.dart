// Copyright 2026 The Reunicorn Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

import 'dart:convert';

import 'package:uuid/uuid.dart';
import 'package:veilid/veilid.dart';

import '../models/coag_contact.dart';
import '../models/setting.dart';
import '../services/storage/base.dart';

const apnsSettingKey = 'apns';

// TODO(LGro): Android FCM, UnifiedPush support
class PushNotificationRepository {
  final Storage<CoagContact> _contactStorage;
  final Storage<String> _notificationSettingsStorage;
  final Storage<Setting> _settingStorage;

  final _contactTransactionLock = <String>{};

  Typed<BareRouteId>? _pushBridgeRouteId;

  PushNotificationRepository(
    this._contactStorage,
    this._notificationSettingsStorage,
    this._settingStorage,
  ) {
    _contactStorage.changeEvents.listen(
      (e) => e.when(
        set: (oldContact, newContact) =>
            (oldContact != newContact) ? _register(newContact) : null,
        delete: _unregister,
      ),
    );
    // TODO(LGro): Listen for change in push settings, update all contacts
    try {
      _pushBridgeRouteId = Typed<BareRouteId>.fromString(
        String.fromEnvironment('REUNICORN_PUSH_BRIDGE_ROUTE'),
      );
    } on Exception catch (e) {
      // TODO(LGro): Log
    }
  }

  Future<String?> _getDeviceToken() => _settingStorage
      .get(apnsSettingKey)
      .then((s) => s?.value['token'] as String?);

  /// For contacts without a push notification topic, create one and
  Future<void> _register(CoagContact contact) async {
    if (_pushBridgeRouteId == null) {
      return;
    }

    // If we're already handling that contact in parallel, skip
    if (_contactTransactionLock.contains(contact.coagContactId)) {
      return;
    }
    _contactTransactionLock.add(contact.coagContactId);

    // Skip if we don't even have an APNs device token
    final token = await _getDeviceToken();
    if (token == null) {
      return;
    }

    // Skip if we already have a topic for that contact ...
    var contactPushNotificationTopic = await _notificationSettingsStorage.get(
      contact.coagContactId,
    );
    if (contactPushNotificationTopic != null) {
      return;
    }

    // ... otherwise, register topic at push bridge and store for contact
    contactPushNotificationTopic = Uuid().v4();
    try {
      await Veilid.instance.routingContext().then(
        (rc) => rc.appMessage(
          TargetRouteId(routeId: _pushBridgeRouteId!),
          utf8.encode(
            json.encode({
              'action': 'register',
              'token': token,
              'topic': contactPushNotificationTopic,
            }),
          ),
        ),
      );

      await _notificationSettingsStorage.set(
        contact.coagContactId,
        contactPushNotificationTopic,
      );
    } on Exception catch (e) {
      // TODO(LGro): Handle more specific exception and log
    }

    _contactTransactionLock.remove(contact.coagContactId);
  }

  Future<void> _unregister(CoagContact contact) async {
    if (_pushBridgeRouteId == null) {
      return;
    }

    // Skip contacts that do not have a topic assigned
    final contactPushNotificationTopic = await _notificationSettingsStorage.get(
      contact.coagContactId,
    );
    if (contactPushNotificationTopic == null) {
      return;
    }

    // If we have a device token, try to unregister topic at push bridge
    final token = await _getDeviceToken();
    try {
      if (token != null) {
        await Veilid.instance.routingContext().then(
          (rc) => rc.appMessage(
            TargetRouteId(routeId: _pushBridgeRouteId!),
            utf8.encode(
              json.encode({
                'action': 'unregister',
                'token': token,
                'topic': contactPushNotificationTopic,
              }),
            ),
          ),
        );
      }

      await _notificationSettingsStorage.delete(contact.coagContactId);
    } on Exception catch (e) {
      // TODO(LGro): Handle more specific exception and log
    }
  }
}
