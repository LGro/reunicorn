// Copyright 2024 - 2025 The Reunicorn Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

import '../../data/models/coag_contact.dart';
import '../../data/models/contact_update.dart';
import '../../data/repositories/contacts.dart';
import '../utils.dart';

part 'cubit.g.dart';
part 'state.dart';

class DashboardCubit extends Cubit<DashboardState> {
  DashboardCubit(this.contactsRepository)
      : super(const DashboardState(DashboardStatus.initial)) {
    // TODO: Also listen to circle updates?
    _contactsSubscription = contactsRepository.getContactStream().listen((
      idUpdatedContact,
    ) {
      if (!isClosed) {
        emit(
          state.copyWith(
            circleMemberships: contactsRepository.getCircleMemberships(),
            circles: contactsRepository.getCircles(),
            contacts: contactsRepository.getContacts().values.toList()
              ..sortBy((c) => c.name.toLowerCase()),
          ),
        );
      }
    });
    _updatesSubscription = contactsRepository.getUpdatesStream().listen(
          (_) => emit(
            state.copyWith(
              updates: contactsRepository.getContactUpdates().reversed.where(
                    (u) => contactUpdateSummary(u.oldContact, u.newContact)
                        .isNotEmpty,
                  ),
            ),
          ),
        );

    emit(
      DashboardState(
        DashboardStatus.success,
        contacts: contactsRepository.getContacts().values.toList()
          ..sortBy((c) => c.name.toLowerCase()),
        circles: contactsRepository.getCircles(),
        circleMemberships: contactsRepository.getCircleMemberships(),
        updates: contactsRepository.getContactUpdates().reversed.where(
              (u) =>
                  contactUpdateSummary(u.oldContact, u.newContact).isNotEmpty,
            ),
      ),
    );

    // TODO: Is that really necessary?
    unawaited(contactsRepository.updateCloseByMatches());
  }

  final ContactsRepository contactsRepository;
  late final StreamSubscription<String> _contactsSubscription;
  late final StreamSubscription<ContactUpdate> _updatesSubscription;

  @override
  Future<void> close() {
    _updatesSubscription.cancel();
    _contactsSubscription.cancel();
    return super.close();
  }
}
