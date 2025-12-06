// Copyright 2024 - 2025 The Reunicorn Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

import '../../data/models/circle.dart';
import '../../data/models/coag_contact.dart';
import '../../data/models/profile_info.dart';
import '../../data/services/storage/base.dart';

part 'cubit.g.dart';
part 'state.dart';

class CircleDetailsCubit extends Cubit<CircleDetailsState> {
  CircleDetailsCubit(
    this._circleStorage,
    this._contactStorage,
    this._profileStorage, [
    String? circleId,
  ]) : super(const CircleDetailsState(CircleDetailsStatus.initial)) {
    unawaited(_updateState(circleId));
    _circleSubscription = _circleStorage.changeEvents.listen(
      (_) => _updateState(circleId),
    );
    _profileSubscription = _profileStorage.changeEvents.listen(
      (_) => _updateState(circleId),
    );
  }

  final Storage<Circle> _circleStorage;
  final Storage<ProfileInfo> _profileStorage;
  final Storage<CoagContact> _contactStorage;
  late final StreamSubscription<StorageEvent<Circle>> _circleSubscription;
  late final StreamSubscription<StorageEvent<ProfileInfo>> _profileSubscription;

  Future<void> _updateState(String? circleId) async {
    final circles = await _circleStorage.getAll();
    final circleMemberships = circlesByContactIds(circles.values);
    final contacts = await _contactStorage.getAll().then(
      (contacts) =>
          contacts.values.toList()..sortBy((c) => c.name.toLowerCase()),
    );
    final profileInfo = await _profileStorage.getAll().then(
      (profiles) => profiles.values.firstOrNull,
    );
    emit(
      CircleDetailsState(
        CircleDetailsStatus.success,
        circleId: circleId,
        profileInfo: profileInfo,
        circles: circles.map((id, c) => MapEntry(id, c.name)),
        circleMemberships: circleMemberships,
        contacts: [
          // Circle members
          ...contacts.where(
            (c) =>
                circleMemberships[c.coagContactId]?.contains(circleId) ?? false,
          ),
          // Not circle members
          ...contacts.where(
            (c) =>
                !(circleMemberships[c.coagContactId]?.contains(circleId) ??
                    false),
          ),
        ],
      ),
    );
  }

  Future<void> updateCircleMembership(String contactId, bool member) async {
    if (state.circleId == null) {
      return;
    }
    final circle = await _circleStorage.get(state.circleId!);
    if (circle == null) {
      return;
    }
    if (member && !circle.memberIds.contains(contactId)) {
      await _circleStorage.set(
        circle.id,
        circle.copyWith(memberIds: [contactId, ...circle.memberIds]),
      );
    }
    if (!member && circle.memberIds.contains(contactId)) {
      await _circleStorage.set(
        circle.id,
        circle.copyWith(memberIds: [...circle.memberIds]..remove(contactId)),
      );
    }
  }

  Future<void> updateCirclePicture(List<int>? picture) async {
    if (state.profileInfo == null || state.circleId == null) {
      return;
    }

    final pictures = {...state.profileInfo!.pictures};
    if (picture == null) {
      pictures.remove(state.circleId);
    } else {
      pictures[state.circleId!] = picture;
    }

    // TODO: Update shared profiles, via use case?
    await _profileStorage.set(
      state.profileInfo!.id,
      state.profileInfo!.copyWith(pictures: pictures),
    );
  }

  Future<void> updateLocationSharing(String locationId, bool doShare) async {
    if (state.profileInfo == null ||
        state.circleId == null ||
        !state.profileInfo!.temporaryLocations.containsKey(locationId)) {
      return;
    }

    final temporaryLocations = {...state.profileInfo!.temporaryLocations};
    if (doShare) {
      temporaryLocations[locationId] = temporaryLocations[locationId]!.copyWith(
        circles: {
          ...temporaryLocations[locationId]!.circles,
          state.circleId!,
        }.toList(),
      );
    } else {
      temporaryLocations[locationId] = temporaryLocations[locationId]!.copyWith(
        circles: {...temporaryLocations[locationId]!.circles}.toList()
          ..remove(state.circleId),
      );
    }

    // TODO: Update shared profiles, via use case?
    await _profileStorage.set(
      state.profileInfo!.id,
      state.profileInfo!.copyWith(temporaryLocations: temporaryLocations),
    );
  }

  Future<void> removeCircle() async {
    if (state.circleId != null) {
      await _circleStorage.delete(state.circleId!);
    }
  }

  @override
  Future<void> close() {
    unawaited(_circleSubscription.cancel());
    unawaited(_profileSubscription.cancel());
    return super.close();
  }
}
