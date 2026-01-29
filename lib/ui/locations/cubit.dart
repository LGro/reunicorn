// Copyright 2024 - 2025 The Reunicorn Authors. All rights reserved.
// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

import '../../data/models/circle.dart';
import '../../data/models/contact_location.dart';
import '../../data/models/profile_info.dart';
import '../../data/services/storage/base.dart';
import '../../data/utils.dart';

part 'cubit.g.dart';
part 'state.dart';

class LocationsCubit extends Cubit<LocationsState> {
  LocationsCubit(this._profileStorage, this._circleStorage)
    : super(const LocationsState()) {
    _profileSubscription = _profileStorage.changeEvents.listen(
      (e) => fetchData(),
    );
    unawaited(fetchData());
  }

  final Storage<ProfileInfo> _profileStorage;
  final Storage<Circle> _circleStorage;
  late final StreamSubscription<StorageEvent<ProfileInfo>> _profileSubscription;

  Future<void> fetchData() async {
    final circleMemberships = await _circleStorage.getAll().then(
      (circles) => circlesByContactIds(circles.values),
    );
    final temporaryLocations = await getProfileInfo(
      _profileStorage,
    ).then((p) => p?.temporaryLocations);

    if (!isClosed) {
      emit(
        LocationsState(
          temporaryLocations: temporaryLocations ?? {},
          circleMemberships: circleMemberships,
        ),
      );
    }
  }

  Future<void> removeLocation(String locationId) async {
    final profileInfo = await getProfileInfo(_profileStorage);
    if (profileInfo == null) {
      return;
    }
    await _profileStorage.set(
      profileInfo.id,
      profileInfo.copyWith(
        temporaryLocations: {...profileInfo.temporaryLocations}
          ..remove(locationId),
      ),
    );
  }

  Future<void> toggleCheckInExisting(String locationId) async {
    final profileInfo = await getProfileInfo(_profileStorage);
    if (profileInfo == null) {
      return;
    }
    // TODO: Test that this is responsive also when location is shared with many contacts
    await _profileStorage.set(
      profileInfo.id,
      profileInfo.copyWith(
        temporaryLocations: Map.fromEntries(
          profileInfo.temporaryLocations.entries.map(
            (l) => (l.key == locationId)
                ? MapEntry(
                    l.key,
                    l.value.copyWith(checkedIn: !l.value.checkedIn),
                  )
                : MapEntry(l.key, l.value.copyWith(checkedIn: false)),
          ),
        ),
      ),
    );
  }

  @override
  Future<void> close() {
    unawaited(_profileSubscription.cancel());
    return super.close();
  }
}
