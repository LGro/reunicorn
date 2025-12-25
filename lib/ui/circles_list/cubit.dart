// Copyright 2024 - 2025 The Reunicorn Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:uuid/uuid.dart';

import '../../data/models/circle.dart';
import '../../data/services/storage/base.dart';

part 'cubit.g.dart';
part 'state.dart';

class CirclesListCubit extends Cubit<CirclesListState> {
  CirclesListCubit(this.circleStorage)
    : super(const CirclesListState(CirclesListStatus.initial)) {
    // Start listening to circle changes
    _circleSubscription = circleStorage.changeEvents.listen(
      (circle) => _fetchData(),
    );
    // Initialize circle data
    unawaited(_fetchData());
  }

  final Storage<Circle> circleStorage;
  late final StreamSubscription<StorageEvent<Circle>> _circleSubscription;

  Future<void> _fetchData() async {
    final circles = await circleStorage.getAll();
    if (!isClosed) {
      emit(
        state.copyWith(
          circleMemberships: circlesByContactIds(circles.values),
          circles: circles.map((id, c) => MapEntry(id, c.name)),
        ),
      );
    }
  }

  Future<String> addCircle(String circleName) async {
    final circleId = Uuid().v4();
    await circleStorage.set(
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
