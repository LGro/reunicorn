// Copyright 2026 The Reunicorn Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

import '../../../../data/models/circle.dart';
import '../../../../data/models/diff/diff.dart';
import '../../../../data/models/models.dart';
import '../../../../data/models/profile_info.dart';
import '../../../../data/repositories/contact_dht.dart';
import '../../../../data/services/storage/base.dart';
import '../../../../data/utils.dart';

part 'state.dart';
part 'cubit.g.dart';

class SharedProfileCubit extends Cubit<SharedProfileState> {
  SharedProfileCubit(
    String contactId,
    this._contactStorage,
    this._circleStorage,
    this._profileStorage,
  ) : super(const SharedProfileState()) {
    _contactSubscription = _contactStorage.changeEvents.listen(
      (e) => e.map(
        set: (a) =>
            (a.oldValue != a.newValue && a.newValue.coagContactId == contactId)
            ? fetchData(contactId)
            : null,
        delete: (_) => null,
      ),
    );

    unawaited(fetchData(contactId));
  }

  final Storage<CoagContact> _contactStorage;
  final Storage<Circle> _circleStorage;
  final Storage<ProfileInfo> _profileStorage;
  late final StreamSubscription<StorageEvent<CoagContact>> _contactSubscription;

  Future<void> fetchData(String contactId) async {
    final contact = await _contactStorage.get(contactId);
    if (contact == null) {
      if (!isClosed) {
        emit(const SharedProfileState());
      }
      return;
    }

    final profileInfo = await getProfileInfo(_profileStorage);
    if (profileInfo == null) {
      if (!isClosed) {
        emit(const SharedProfileState());
      }
      return;
    }
    final contacts = await _contactStorage.getAll();
    final circleMemberships = await _circleStorage.getAll().then(
      (circles) => circlesByContactIds(circles.values),
    );
    final pending = await updateSharedProfile(
      contact,
      contacts,
      profileInfo,
      circleMemberships,
      [],
    );
    final diff = diffContactSharingSchema(
      contact.profileSharingStatus.sharedProfile!,
      pending,
    );
    if (!isClosed) {
      emit(
        SharedProfileState(
          current: contact.profileSharingStatus.sharedProfile,
          pending: pending,
          diff: diff,
        ),
      );
    }
  }

  @override
  Future<void> close() {
    unawaited(_contactSubscription.cancel());
    return super.close();
  }
}
