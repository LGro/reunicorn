// Copyright 2024 - 2026 The Reunicorn Authors. All rights reserved.
// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:reunicorn/data/models/models.dart';
import 'package:uuid/uuid.dart';

import '../../data/models/circle.dart';
import '../../data/services/storage/base.dart';

part 'cubit.g.dart';
part 'state.dart';

class CirclesListCubit extends Cubit<CirclesListState> {
  CirclesListCubit(this._circleStorage, this._contactStorage)
    : super(const CirclesListState(CirclesListStatus.initial)) {
    // Start listening to circle changes
    _circleSubscription = _circleStorage.changeEvents.listen(
      (circle) => _fetchData(),
    );
    // Initialize circle data
    unawaited(_fetchData());
  }

  final Storage<Circle> _circleStorage;
  // TODO(LGro): Also add contact storage subscription to react to picture updates
  final Storage<CoagContact> _contactStorage;
  late final StreamSubscription<StorageEvent<Circle>> _circleSubscription;

  Future<void> _fetchData() async {
    final circles = await _circleStorage.getAll();
    final contacts = await _contactStorage.getAll();
    final circleMemberPictures = circles.map(
      (circleId, circle) => MapEntry(
        circleId,
        circle.memberIds
            .map((contactId) => contacts[contactId]?.details?.picture)
            .whereType<List<int>>()
            .toList(),
      ),
    );
    if (!isClosed) {
      emit(
        state.copyWith(
          circleMemberships: circlesByContactIds(circles.values),
          circles: circles.map((id, c) => MapEntry(id, c.name)),
          circleMemberPictures: circleMemberPictures,
        ),
      );
    }
  }

  Future<String> addCircle(String circleName) async {
    final circleId = Uuid().v4();
    await _circleStorage.set(
      circleId,
      Circle(id: circleId, name: circleName, memberIds: []),
    );
    return circleId;
  }

  @override
  Future<void> close() {
    _circleSubscription.cancel();
    return super.close();
  }
}
