// Copyright 2024 - 2025 The Reunicorn Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

import '../../data/models/circle.dart';
import '../../data/models/coag_contact.dart';
import '../../data/repositories/contact_system.dart';
import '../../data/services/storage/base.dart';
import '../../data/utils.dart';

part 'cubit.g.dart';
part 'state.dart';

Map<String, String> circlesForContact(
  Iterable<Circle> circles,
  String contactId,
) => Map.fromEntries(
  circles
      .where((circle) => circle.memberIds.contains(contactId))
      .map((circle) => MapEntry(circle.id, circle.name)),
);

class ContactDetailsCubit extends Cubit<ContactDetailsState> {
  ContactDetailsCubit(
    this._contactStorage,
    this._circleStorage,
    String coagContactId,
  ) : super(const ContactDetailsState(ContactDetailsStatus.initial)) {
    _circleSubscription = _circleStorage.changeEvents.listen((_) async {
      final circles = await _circleStorage.getAll();
      if (!isClosed) {
        emit(
          state.copyWith(
            circles: circlesForContact(circles.values, coagContactId),
          ),
        );
      }
    });
    _contactSubscription = _contactStorage.changeEvents.listen((e) async {
      if (e is SetEvent<CoagContact> &&
          e.newValue.coagContactId == coagContactId) {
        final contacts = await _contactStorage.getAll();
        final circles = await _circleStorage.getAll();
        if (!isClosed) {
          emit(
            state.copyWith(
              status: ContactDetailsStatus.success,
              contact: e.newValue,
              knownContacts: knownContacts(coagContactId, contacts),
              allContacts: contacts,
              circles: circlesForContact(circles.values, coagContactId),
            ),
          );
        }
      } else if (e is DeleteEvent<CoagContact>) {
        // TODO: Emit status to redirect to contact list
      }
    });

    unawaited(loadContact(coagContactId));
    // TODO: Is this still needed?
    // Attempt to share straight await, when a contact details page is visited
    // if (state.contact != null) {
    //   unawaited(
    //     _contactDhtRepository.updateContact(state.contact!.coagContactId),
    //   );
    // }
  }

  final Storage<CoagContact> _contactStorage;
  final Storage<Circle> _circleStorage;
  late final StreamSubscription<StorageEvent<CoagContact>> _contactSubscription;
  late final StreamSubscription<StorageEvent<Circle>> _circleSubscription;

  Future<void> loadContact(String contactId) async {
    final contact = await _contactStorage.get(contactId);
    if (!isClosed) {
      emit(state.copyWith(contact: contact));
    }
  }

  Future<void> updateComment(String comment) => _contactStorage.set(
    state.contact!.coagContactId,
    state.contact!.copyWith(comment: comment),
  );

  Future<void> updateName(String name) async {
    if (state.contact == null) {
      return;
    }
    await _contactStorage.set(
      state.contact!.coagContactId,
      state.contact!.copyWith(name: name),
    );
  }

  Future<bool> delete(String coagContactId) async {
    await _contactStorage.delete(coagContactId);
    return false;
  }

  Future<void> unlinkFromSystemContact() async {
    if (state.contact == null) {
      return;
    }
    final updatedContact = await unlinkSystemContact(state.contact!);
    await _contactStorage.set(updatedContact.coagContactId, updatedContact);
  }

  // TODO: This takes looong, can we speed it up?
  Future<(bool, bool)> refresh() async {
    // if (state.contact == null) {
    return (false, false);
    // }
    // TODO: Is this still necessary?
    // _contactDhtRepository.updateContact();
    // return (results[0], results[1]);
  }

  bool wasNotIntroduced(CoagContact contact) => state.allContacts.values
      .where(
        (c) => c.introductionsByThem
            .map((i) => i.dhtRecordKeyReceiving)
            .contains(contact.dhtSettings.recordKeyThemSharing),
      )
      .isEmpty;

  @override
  Future<void> close() {
    unawaited(_contactSubscription.cancel());
    unawaited(_circleSubscription.cancel());
    return super.close();
  }
}
