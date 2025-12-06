// Copyright 2025 The Reunicorn Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

import '../../data/models/circle.dart';
import '../../data/models/close_by_match.dart';
import '../../data/models/coag_contact.dart';
import '../../data/models/contact_update.dart';
import '../../data/models/profile_info.dart';
import '../../data/services/storage/base.dart';
import '../../data/utils.dart';
import '../utils.dart';

part 'cubit.g.dart';
part 'state.dart';

class DashboardCubit extends Cubit<DashboardState> {
  DashboardCubit(
    this._contactStorage,
    this._circleStorage,
    this._updateStorage,
    this._profileStorage,
  ) : super(const DashboardState(DashboardStatus.initial)) {
    _contactSubscription = _contactStorage.changeEvents.listen((_) async {
      final contacts = await _contactStorage.getAll();
      final circles = await _circleStorage.getAll();
      final profile = await getProfileInfo(_profileStorage);
      if (!isClosed) {
        emit(
          state.copyWith(
            contacts: contacts.values.toList()
              ..sortBy((c) => c.name.toLowerCase()),
            closeByMatches: (profile == null)
                ? state.closeByMatches
                : closeByMatches(profile, contacts.values, circles.values),
          ),
        );
      }
    });
    _updateSubscription = _updateStorage.changeEvents.listen((_) async {
      final updates = await _updateStorage.getAll();
      if (!isClosed) {
        emit(
          state.copyWith(
            updates: updates.values.toList().reversed.where(
              (u) =>
                  contactUpdateSummary(u.oldContact, u.newContact).isNotEmpty,
            ),
          ),
        );
      }
    });
    unawaited(initialize());
  }

  final Storage<CoagContact> _contactStorage;
  final Storage<ContactUpdate> _updateStorage;
  final Storage<Circle> _circleStorage;
  final Storage<ProfileInfo> _profileStorage;
  late final StreamSubscription<StorageEvent<CoagContact>> _contactSubscription;
  late final StreamSubscription<StorageEvent<ContactUpdate>>
  _updateSubscription;

  Future<void> initialize() async {
    final contacts = await _contactStorage.getAll();
    final circles = await _circleStorage.getAll();
    final updates = await _updateStorage.getAll();
    final profile = await getProfileInfo(_profileStorage);
    if (!isClosed) {
      emit(
        DashboardState(
          DashboardStatus.success,
          circles: circles.map((id, circle) => MapEntry(id, circle.name)),
          contacts: contacts.values.toList()
            ..sortBy((c) => c.name.toLowerCase()),
          updates: updates.values.toList().reversed.where(
            (u) => contactUpdateSummary(u.oldContact, u.newContact).isNotEmpty,
          ),
          closeByMatches: (profile == null)
              ? state.closeByMatches
              : closeByMatches(profile, contacts.values, circles.values),
        ),
      );
    }
  }

  @override
  Future<void> close() {
    unawaited(_updateSubscription.cancel());
    unawaited(_contactSubscription.cancel());
    return super.close();
  }
}
