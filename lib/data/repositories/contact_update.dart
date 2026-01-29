// Copyright 2025 - 2026 The Reunicorn Authors. All rights reserved.
// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:uuid/uuid.dart';

import '../../ui/utils.dart';
import '../models/contact_update.dart';
import '../models/models.dart';
import '../services/storage/base.dart';

typedef NotificationCallback =
    Future<void> Function(int id, String title, String body, {String? payload});

class UpdateRepository {
  final Storage<CoagContact> _contactStorage;
  final Storage<ContactUpdate> _updateStorage;
  late final NotificationCallback? _notificationCallback;

  UpdateRepository(
    this._contactStorage,
    this._updateStorage, {
    NotificationCallback? notificationCallback,
  }) {
    _notificationCallback = notificationCallback;
    _contactStorage.changeEvents.listen((e) async {
      await e.when(set: _onSetContact, delete: _onDeleteContact);
    });
  }

  Future<void> _onSetContact(
    CoagContact? oldContact,
    CoagContact newContact,
  ) async {
    final updates = await _updateStorage.getAll();
    if (!updates.values
        .map((u) => u.newContact.hashCode)
        .contains(newContact.hashCode)) {
      // TODO: Why doe we copy the contacts here instead of passing them? what info are we stripping?
      final update = ContactUpdate(
        coagContactId: newContact.coagContactId,
        oldContact: CoagContact(
          coagContactId: oldContact?.coagContactId ?? newContact.coagContactId,
          name: oldContact?.name ?? newContact.name,
          myIdentity: oldContact?.myIdentity ?? newContact.myIdentity,
          myIntroductionKeyPair:
              oldContact?.myIntroductionKeyPair ??
              newContact.myIntroductionKeyPair,
          dhtConnection: oldContact?.dhtConnection ?? newContact.dhtConnection,
          connectionCrypto:
              oldContact?.connectionCrypto ?? newContact.connectionCrypto,
          details:
              oldContact?.details?.copyWith() ?? newContact.details?.copyWith(),
          temporaryLocations:
              oldContact?.temporaryLocations ??
              {...newContact.temporaryLocations},
          addressLocations:
              oldContact?.addressLocations ?? {...newContact.addressLocations},
          profileSharingStatus: const ProfileSharingStatus(),
        ),
        newContact: CoagContact(
          coagContactId: newContact.coagContactId,
          name: newContact.name,
          myIdentity: newContact.myIdentity,
          myIntroductionKeyPair: newContact.myIntroductionKeyPair,
          dhtConnection: newContact.dhtConnection,
          connectionCrypto: newContact.connectionCrypto,
          details: newContact.details?.copyWith(),
          temporaryLocations: {...newContact.temporaryLocations},
          addressLocations: {...newContact.addressLocations},
          profileSharingStatus: const ProfileSharingStatus(),
        ),
        // TODO: Use update time from when the update was sent not received
        timestamp: DateTime.now(),
      );
      // TODO: Make ID part of update model?
      await _updateStorage.set(Uuid().v4(), update);

      // Trigger notification
      final updateSummary = contactUpdateSummary(
        update.oldContact,
        update.newContact,
      );
      final notificationTitle =
          (update.oldContact.details?.names.isNotEmpty ?? false)
          ? update.oldContact.details!.names.values.join(' / ')
          : update.newContact.details!.names.values.join(' / ');
      if (_notificationCallback != null && updateSummary.isNotEmpty) {
        await _notificationCallback!(
          0,
          notificationTitle,
          'Updated $updateSummary',
          payload: newContact.coagContactId,
        );
      }
    }
  }

  Future<void> _onDeleteContact(CoagContact contact) async {
    final updates = await _updateStorage.getAll();
    for (final update in updates.entries) {
      if (update.value.newContact.coagContactId == contact.coagContactId) {
        await _updateStorage.delete(update.key);
      }
    }
  }
}
