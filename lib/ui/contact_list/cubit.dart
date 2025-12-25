// Copyright 2024 - 2025 The Reunicorn Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:json_annotation/json_annotation.dart';

import '../../data/models/circle.dart';
import '../../data/models/coag_contact.dart';
import '../../data/services/storage/base.dart';

part 'cubit.g.dart';
part 'state.dart';

class ContactListCubit extends Cubit<ContactListState> {
  ContactListCubit(this.contactStorage, this.circleStorage)
    : super(const ContactListState(ContactListStatus.initial)) {
    _contactsSubscription = contactStorage.changeEvents.listen(
      (e) => fetchData(),
    );

    unawaited(fetchData());
  }

  final Storage<CoagContact> contactStorage;
  final Storage<Circle> circleStorage;
  late final StreamSubscription<StorageEvent<CoagContact>>
  _contactsSubscription;

  Future<void> fetchData() async {
    final circles = await circleStorage.getAll();
    final contacts = await contactStorage.getAll().then(
      (contacts) =>
          contacts.values.toList()..sortBy((c) => c.name.toLowerCase()),
    );
    if (!isClosed) {
      emit(
        ContactListState(
          ContactListStatus.success,
          contacts: contacts,
          circles: circles,
          circleMemberships: circlesByContactIds(circles.values),
        ),
      );
    }
  }

  Future<bool> refresh() async {
    // FIXME
    return false;
    // final results = await Future.wait([
    //   contactsRepository.updateAndWatchReceivingDHT(),
    //   contactsRepository.updateSharingDHT(),
    //   contactsRepository.updateAllBatchInvites().then((_) => true),
    // ]);
    // return results.every((r) => r);
  }

  @override
  Future<void> close() {
    unawaited(_contactsSubscription.cancel());
    return super.close();
  }
}
