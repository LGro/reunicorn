// Copyright 2024 The Reunicorn Authors. All rights reserved.
// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:geolocator/geolocator.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:uuid/uuid.dart';

import '../../../data/models/circle.dart';
import '../../../data/models/contact_location.dart';
import '../../../data/models/profile_info.dart';
import '../../../data/services/storage/base.dart';
import '../../../data/utils.dart';

part 'cubit.g.dart';
part 'state.dart';

Future<CheckInStatus> checkLocationAccess() async {
  // Test if location services are enabled.
  final serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    // Location services are not enabled don't continue
    // accessing the position and request users of the
    // App to enable the location services.
    return CheckInStatus.locationDisabled;
  }

  var permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      // Permissions are denied, next time you could try
      // requesting permissions again (this is also where
      // Android's shouldShowRequestPermissionRationale
      // returned true. According to Android guidelines
      // your App should show an explanatory UI now.
      return CheckInStatus.locationDenied;
    }
  }

  if (permission == LocationPermission.deniedForever) {
    // Permissions are denied forever, handle appropriately.
    // return Future.error(
    //     'Location permissions are permanently denied, we cannot request permissions.');
    return CheckInStatus.locationDeniedPermanent;
  }

  return CheckInStatus.readyForCheckIn;
}

class CheckInCubit extends Cubit<CheckInState> {
  CheckInCubit(this._circleStorage, this._profileStorage)
    : super(
        const CheckInState(
          status: CheckInStatus.initial,
          circles: {},
          circleMemberships: {},
        ),
      ) {
    unawaited(initialPermissionsCheck());
  }

  final Storage<Circle> _circleStorage;
  final Storage<ProfileInfo> _profileStorage;

  Future<void> initialPermissionsCheck() async {
    final circles = await _circleStorage.getAll();
    final status = await checkLocationAccess();
    if (!isClosed) {
      emit(
        state.copyWith(
          circles: circles.map((id, c) => MapEntry(id, c.name)),
          circleMemberships: circlesByContactIds(circles.values),
          status: status,
        ),
      );
    }
  }

  // TODO: Check in is e.g. called as the on submit callback in the check in form,
  // but the errors are not handled transparently for the user
  Future<bool> checkIn({
    required String name,
    required String details,
    required List<String> circles,
    required DateTime end,
  }) async {
    if (!isClosed) {
      emit(state.copyWith(status: CheckInStatus.checkingIn));
    }

    final profileInfo = await getProfileInfo(_profileStorage);
    if (profileInfo == null) {
      return false;
    }
    try {
      final location = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          timeLimit: Duration(seconds: 30),
        ),
      );

      await _profileStorage.set(
        profileInfo.id,
        profileInfo.copyWith(
          temporaryLocations: Map.fromEntries([
            // Ensure all others are checked out
            ...profileInfo.temporaryLocations.entries.map(
              (l) => MapEntry(l.key, l.value.copyWith(checkedIn: false)),
            ),
            // Add new one as checked in
            MapEntry(
              Uuid().v4(),
              ContactTemporaryLocation(
                longitude: location.longitude,
                latitude: location.latitude,
                start: DateTime.now(),
                name: name,
                details: details,
                end: end,
                circles: circles,
                checkedIn: true,
              ),
            ),
          ]),
        ),
      );

      // TODO: Emit success status?
      // if (!isClosed) {
      //   emit(state.copyWith(checkingIn: false));
      // }
      return true;
    } on TimeoutException {
      if (!isClosed) {
        // TODO: Where can this be picked up by the UI?
        emit(state.copyWith(status: CheckInStatus.locationTimeout));
      }
      return false;
    } on LocationServiceDisabledException {
      if (!isClosed) {
        emit(state.copyWith(status: CheckInStatus.locationDisabled));
      }
      return false;
    }
  }
}
