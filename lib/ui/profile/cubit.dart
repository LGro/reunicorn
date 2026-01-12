// Copyright 2024 - 2025 The Reunicorn Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

import 'dart:async';
import 'dart:typed_data';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:uuid/uuid.dart';

import '../../data/models/circle.dart';
import '../../data/models/models.dart';
import '../../data/models/profile_info.dart';
import '../../data/services/storage/base.dart';
import '../../data/utils.dart';

part 'cubit.g.dart';
part 'state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit(this._profileStorage, this._circleStorage)
    : super(const ProfileState()) {
    _circlesSubscription = _circleStorage.changeEvents.listen(
      (_) => fetchData(),
    );
    _profileInfoSubscription = _profileStorage.changeEvents.listen(
      (_) => fetchData(),
    );
    unawaited(fetchData());
  }

  final Storage<ProfileInfo> _profileStorage;
  final Storage<Circle> _circleStorage;
  late final StreamSubscription<StorageEvent<ProfileInfo>>
  _profileInfoSubscription;
  late final StreamSubscription<StorageEvent<Circle>> _circlesSubscription;

  Future<void> fetchData() async {
    final profileInfo = await getProfileInfo(_profileStorage);
    final circles = await _circleStorage.getAll();

    if (!isClosed) {
      emit(
        state.copyWith(
          status: ProfileStatus.success,
          profileInfo: profileInfo,
          circles: circles.map((id, c) => MapEntry(id, c.name)),
          circleMemberships: circlesByContactIds(circles.values),
        ),
      );
    }
  }

  /// For circle ID and label pairs, add the new ones to the contacts repository
  Future<void> createCirclesIfNotExist(List<(String, String)> circles) async {
    final storedCircles = await _circleStorage.getAll();
    for (final (id, label) in circles) {
      if (!storedCircles.containsKey(id)) {
        final newCircle = Circle(id: id, name: label, memberIds: []);
        storedCircles[id] = newCircle;
        await _circleStorage.set(id, newCircle);
      }
    }
  }

  Future<void> updateDetails(ContactDetails details) async =>
      (state.profileInfo == null)
      ? null
      : _profileStorage.set(
          state.profileInfo!.id,
          state.profileInfo!.copyWith(details: details),
        );

  Future<void> updateAddressLocations(
    Map<String, ContactAddressLocation> addressLocations,
  ) async => (state.profileInfo == null)
      ? null
      : _profileStorage.set(
          state.profileInfo!.id,
          state.profileInfo!.copyWith(addressLocations: addressLocations),
        );

  Future<void> updateAvatar(String circleId, Uint8List picture) async {
    if (state.profileInfo == null) {
      return;
    }

    final pictures = {...state.profileInfo!.pictures};
    pictures[circleId] = picture;

    await _profileStorage.set(
      state.profileInfo!.id,
      state.profileInfo!.copyWith(pictures: pictures),
    );
  }

  Future<void> removeAvatar(String circleId) async {
    if (state.profileInfo == null) {
      return;
    }

    final pictures = {...state.profileInfo!.pictures}..remove(circleId);
    await _profileStorage.set(
      state.profileInfo!.id,
      state.profileInfo!.copyWith(pictures: pictures),
    );
  }

  Future<void> updateName(
    String id,
    String name,
    List<(String, String, bool)> circlesWithSelection,
  ) async {
    if (state.profileInfo == null) {
      return;
    }

    final names = {...state.profileInfo!.details.names};
    names[id] = name;

    await createCirclesIfNotExist(
      circlesWithSelection.map((e) => (e.$1, e.$2)).toList(),
    );

    final _sharingSettings = {...state.profileInfo!.sharingSettings.names};
    _sharingSettings[id] = circlesWithSelection
        .where((e) => e.$3)
        .map((c) => c.$1)
        .toList();

    final updatedProfile = state.profileInfo!.copyWith(
      details: state.profileInfo!.details.copyWith(names: names),
      sharingSettings: state.profileInfo!.sharingSettings.copyWith(
        names: _sharingSettings,
      ),
    );
    if (!isClosed) {
      emit(state.copyWith(profileInfo: updatedProfile));
    }
    await _profileStorage.set(updatedProfile.id, updatedProfile);
  }

  Future<void> updatePhone(
    String? oldLabel,
    String label,
    String value,
    List<(String, String, bool)> circlesWithSelection, {
    int? i,
  }) async {
    if (state.profileInfo == null) {
      return;
    }

    final details = {...state.profileInfo!.details.phones}..remove(oldLabel);
    details[label] = value;

    await createCirclesIfNotExist(
      circlesWithSelection.map((e) => (e.$1, e.$2)).toList(),
    );

    final _sharingSettings = {...state.profileInfo!.sharingSettings.phones}
      ..remove(oldLabel);
    _sharingSettings[label] = circlesWithSelection
        .where((e) => e.$3)
        .map((c) => c.$1)
        .toList();

    final updatedProfile = state.profileInfo!.copyWith(
      details: state.profileInfo!.details.copyWith(phones: details),
      sharingSettings: state.profileInfo!.sharingSettings.copyWith(
        phones: _sharingSettings,
      ),
    );
    if (!isClosed) {
      emit(state.copyWith(profileInfo: updatedProfile));
    }
    await _profileStorage.set(updatedProfile.id, updatedProfile);
  }

  Future<void> updateEmail(
    String? oldLabel,
    String label,
    String value,
    List<(String, String, bool)> circlesWithSelection, {
    int? i,
  }) async {
    if (state.profileInfo == null) {
      return;
    }

    final details = {...state.profileInfo!.details.emails}..remove(oldLabel);
    details[label] = value;

    await createCirclesIfNotExist(
      circlesWithSelection.map((e) => (e.$1, e.$2)).toList(),
    );

    final _sharingSettings = {...state.profileInfo!.sharingSettings.emails}
      ..remove(oldLabel);
    _sharingSettings[label] = circlesWithSelection
        .where((e) => e.$3)
        .map((c) => c.$1)
        .toList();

    final updatedProfile = state.profileInfo!.copyWith(
      details: state.profileInfo!.details.copyWith(emails: details),
      sharingSettings: state.profileInfo!.sharingSettings.copyWith(
        emails: _sharingSettings,
      ),
    );
    if (!isClosed) {
      emit(state.copyWith(profileInfo: updatedProfile));
    }
    await _profileStorage.set(updatedProfile.id, updatedProfile);
  }

  Future<void> updateSocialMedia(
    String? oldLabel,
    String label,
    String value,
    List<(String, String, bool)> circlesWithSelection, {
    int? i,
  }) async {
    if (state.profileInfo == null) {
      return;
    }

    final details = {...state.profileInfo!.details.socialMedias}
      ..remove(oldLabel);
    details[label] = value;

    await createCirclesIfNotExist(
      circlesWithSelection.map((e) => (e.$1, e.$2)).toList(),
    );

    final _sharingSettings = {
      ...state.profileInfo!.sharingSettings.socialMedias,
    }..remove(oldLabel);
    _sharingSettings[label] = circlesWithSelection
        .where((e) => e.$3)
        .map((c) => c.$1)
        .toList();

    final updatedProfile = state.profileInfo!.copyWith(
      details: state.profileInfo!.details.copyWith(socialMedias: details),
      sharingSettings: state.profileInfo!.sharingSettings.copyWith(
        socialMedias: _sharingSettings,
      ),
    );
    if (!isClosed) {
      emit(state.copyWith(profileInfo: updatedProfile));
    }
    await _profileStorage.set(updatedProfile.id, updatedProfile);
  }

  Future<void> updateWebsite(
    String? oldLabel,
    String label,
    String value,
    List<(String, String, bool)> circlesWithSelection,
  ) async {
    if (state.profileInfo == null) {
      return;
    }

    final details = {...state.profileInfo!.details.websites}..remove(oldLabel);
    details[label] = value;

    await createCirclesIfNotExist(
      circlesWithSelection.map((e) => (e.$1, e.$2)).toList(),
    );

    final _sharingSettings = {...state.profileInfo!.sharingSettings.websites}
      ..remove(oldLabel);
    _sharingSettings[label] = circlesWithSelection
        .where((e) => e.$3)
        .map((c) => c.$1)
        .toList();

    final updatedProfile = state.profileInfo!.copyWith(
      details: state.profileInfo!.details.copyWith(websites: details),
      sharingSettings: state.profileInfo!.sharingSettings.copyWith(
        websites: _sharingSettings,
      ),
    );
    if (!isClosed) {
      emit(state.copyWith(profileInfo: updatedProfile));
    }
    await _profileStorage.set(updatedProfile.id, updatedProfile);
  }

  Future<void> updateOrganization(
    String? existingId,
    Organization value,
    List<(String, String, bool)> circlesWithSelection,
  ) async {
    if (state.profileInfo == null) {
      return;
    }

    existingId = existingId ?? Uuid().v4();

    final details = {...state.profileInfo!.details.organizations}
      ..remove(existingId);
    details[existingId] = value;

    await createCirclesIfNotExist(
      circlesWithSelection.map((e) => (e.$1, e.$2)).toList(),
    );

    final _sharingSettings = {
      ...state.profileInfo!.sharingSettings.organizations,
    };
    _sharingSettings[existingId] = circlesWithSelection
        .where((e) => e.$3)
        .map((c) => c.$1)
        .toList();

    final updatedProfile = state.profileInfo!.copyWith(
      details: state.profileInfo!.details.copyWith(organizations: details),
      sharingSettings: state.profileInfo!.sharingSettings.copyWith(
        organizations: _sharingSettings,
      ),
    );
    if (!isClosed) {
      emit(state.copyWith(profileInfo: updatedProfile));
    }
    await _profileStorage.set(updatedProfile.id, updatedProfile);
  }

  Future<void> updateEvent(
    String? oldLabel,
    String label,
    DateTime value,
    List<(String, String, bool)> circlesWithSelection,
  ) async {
    if (state.profileInfo == null) {
      return;
    }

    final details = {...state.profileInfo!.details.events}..remove(oldLabel);
    details[label] = value;

    await createCirclesIfNotExist(
      circlesWithSelection.map((e) => (e.$1, e.$2)).toList(),
    );

    final _sharingSettings = {...state.profileInfo!.sharingSettings.events}
      ..remove(oldLabel);
    _sharingSettings[label] = circlesWithSelection
        .where((e) => e.$3)
        .map((c) => c.$1)
        .toList();

    final updatedProfile = state.profileInfo!.copyWith(
      details: state.profileInfo!.details.copyWith(events: details),
      sharingSettings: state.profileInfo!.sharingSettings.copyWith(
        events: _sharingSettings,
      ),
    );
    if (!isClosed) {
      emit(state.copyWith(profileInfo: updatedProfile));
    }
    await _profileStorage.set(updatedProfile.id, updatedProfile);
  }

  Future<void> updateMisc(
    String? oldLabel,
    String label,
    String value,
    List<(String, String, bool)> circlesWithSelection,
  ) async {
    if (state.profileInfo == null) {
      return;
    }

    final details = {...state.profileInfo!.details.misc}..remove(oldLabel);
    details[label] = value;

    await createCirclesIfNotExist(
      circlesWithSelection.map((e) => (e.$1, e.$2)).toList(),
    );

    final _sharingSettings = {...state.profileInfo!.sharingSettings.misc}
      ..remove(oldLabel);
    _sharingSettings[label] = circlesWithSelection
        .where((e) => e.$3)
        .map((c) => c.$1)
        .toList();

    final updatedProfile = state.profileInfo!.copyWith(
      details: state.profileInfo!.details.copyWith(misc: details),
      sharingSettings: state.profileInfo!.sharingSettings.copyWith(
        misc: _sharingSettings,
      ),
    );
    if (!isClosed) {
      emit(state.copyWith(profileInfo: updatedProfile));
    }
    await _profileStorage.set(updatedProfile.id, updatedProfile);
  }

  Future<void> updateTag(
    String id,
    String tag,
    List<(String, String, bool)> circlesWithSelection,
  ) async {
    if (state.profileInfo == null) {
      return;
    }

    final tags = {...state.profileInfo!.details.tags};
    tags[id] = tag.startsWith('#') ? tag : '#$tag';

    await createCirclesIfNotExist(
      circlesWithSelection.map((e) => (e.$1, e.$2)).toList(),
    );

    final _sharingSettings = {...state.profileInfo!.sharingSettings.tags};
    _sharingSettings[id] = circlesWithSelection
        .where((e) => e.$3)
        .map((c) => c.$1)
        .toList();

    final updatedProfile = state.profileInfo!.copyWith(
      details: state.profileInfo!.details.copyWith(tags: tags),
      sharingSettings: state.profileInfo!.sharingSettings.copyWith(
        tags: _sharingSettings,
      ),
    );
    if (!isClosed) {
      emit(state.copyWith(profileInfo: updatedProfile));
    }
    await _profileStorage.set(updatedProfile.id, updatedProfile);
  }

  Future<void> updateAddressLocation(
    String? oldLabel,
    String label,
    ContactAddressLocation contactAddress,
    List<(String, String, bool)> circlesWithSelection,
  ) async {
    if (state.profileInfo == null) {
      return;
    }

    await createCirclesIfNotExist(
      circlesWithSelection.map((e) => (e.$1, e.$2)).toList(),
    );

    final _sharingSettings = {...state.profileInfo!.sharingSettings.addresses}
      ..remove(oldLabel);
    _sharingSettings[label] = circlesWithSelection
        .where((e) => e.$3)
        .map((c) => c.$1)
        .toList();

    final _updatedAddressLocations = {...state.profileInfo!.addressLocations}
      ..remove(oldLabel);
    _updatedAddressLocations[label] = contactAddress;

    final updatedProfile = state.profileInfo!.copyWith(
      sharingSettings: state.profileInfo!.sharingSettings.copyWith(
        addresses: _sharingSettings,
      ),
      addressLocations: _updatedAddressLocations,
    );
    if (!isClosed) {
      emit(state.copyWith(profileInfo: updatedProfile));
    }
    await _profileStorage.set(updatedProfile.id, updatedProfile);
  }

  @override
  Future<void> close() {
    unawaited(_profileInfoSubscription.cancel());
    unawaited(_circlesSubscription.cancel());
    return super.close();
  }
}
