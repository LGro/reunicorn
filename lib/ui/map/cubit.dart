// Copyright 2024 - 2026 The Reunicorn Authors. All rights reserved.
// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

import '../../data/models/circle.dart';
import '../../data/models/coag_contact.dart';
import '../../data/models/profile_info.dart';
import '../../data/repositories/settings.dart';
import '../../data/services/storage/base.dart';
import '../../data/utils.dart';

part 'cubit.g.dart';
part 'state.dart';

class MapCubit extends Cubit<MapState> {
  MapCubit(
    this.contactStorage,
    this.circleStorage,
    this.profileStorage,
    this.settingsRepository,
  ) : super(const MapState(status: MapStatus.initial)) {
    _profileSubscription = profileStorage.changeEvents.listen((_) => refresh());
    _circleSubscription = circleStorage.changeEvents.listen((_) => refresh());
    // TODO: Does it help the performance significantly to only update the affected contact's data?
    _contactSubscription = contactStorage.changeEvents.listen((_) => refresh());

    unawaited(refresh());
  }

  final Storage<CoagContact> contactStorage;
  final Storage<ProfileInfo> profileStorage;
  final Storage<Circle> circleStorage;
  final SettingsRepository settingsRepository;
  late final StreamSubscription<StorageEvent<Circle>> _circleSubscription;
  late final StreamSubscription<StorageEvent<CoagContact>> _contactSubscription;
  late final StreamSubscription<StorageEvent<ProfileInfo>> _profileSubscription;

  Future<void> refresh() async {
    final profileInfo = await getProfileInfo(profileStorage);
    final circles = await circleStorage.getAll();
    final circleMemberships = circlesByContactIds(circles.values);
    final contacts = await contactStorage.getAll().then(
      (contacts) => contacts.values,
    );

    if (!isClosed) {
      emit(
        MapState(
          status: MapStatus.success,
          profileInfo: profileInfo,
          contacts: contacts.toList(),
          circleMemberships: circleMemberships,
          circles: circles.map((id, c) => MapEntry(id, c.name)),
        ),
      );
    }
  }

  Future<void> removeLocation(String locationId) async {
    final profileInfo = await getProfileInfo(profileStorage);
    if (profileInfo == null) {
      return;
    }
    await profileStorage.set(
      profileInfo.id,
      profileInfo.copyWith(
        temporaryLocations: {...profileInfo.temporaryLocations}
          ..remove(locationId),
      ),
    );
  }

  @override
  Future<void> close() {
    _circleSubscription.cancel();
    _contactSubscription.cancel();
    _profileSubscription.cancel();
    return super.close();
  }
}
