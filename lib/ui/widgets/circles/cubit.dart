// Copyright 2024 - 2026 The Reunicorn Authors. All rights reserved.
// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:reunicorn/ui/utils.dart';

import '../../../data/models/circle.dart';
import '../../../data/services/storage/base.dart';

part 'cubit.g.dart';
part 'state.dart';

// TODO: Switch view model to use Map<String, Circle> circles instead of this
List<(String, String, bool, int)> circlesWithMembership(
  String contactId,
  Map<String, Circle> circles,
) => sortCirclesByNameAsc(
  circles
      .map(
        (id, circle) => MapEntry(id, (
          id,
          circle.name,
          circle.memberIds.contains(contactId),
          circle.memberIds.length,
        )),
      )
      .values
      .toList(),
);

class CirclesCubit extends Cubit<CirclesState> {
  CirclesCubit(this._circleStorage, this.contactId)
    : super(const CirclesState([])) {
    _circleSubscription = _circleStorage.changeEvents.listen(
      (_) => fetchData(),
    );
    unawaited(fetchData());
  }

  final Storage<Circle> _circleStorage;
  final String contactId;
  late final StreamSubscription<StorageEvent<Circle>> _circleSubscription;

  Future<void> fetchData() async {
    final circles = await _circleStorage.getAll();
    if (!isClosed) {
      emit(CirclesState(circlesWithMembership(contactId, circles)));
    }
  }

  Future<void> update(List<(String, String, bool)> circles) async {
    // Check if there is a new circle, add it
    final storedCircles = await _circleStorage.getAll();
    for (final (id, label, _) in circles) {
      if (!storedCircles.containsKey(id)) {
        final newCircle = Circle(id: id, name: label, memberIds: []);
        storedCircles[id] = newCircle;
        await _circleStorage.set(id, newCircle);
      }
    }

    for (final (id, _, isMember) in circles) {
      final circle = storedCircles[id];
      if (circle == null) {
        // Shouldn't happen since we just added all new circles above
        continue;
      }
      if (isMember && !circle.memberIds.contains(contactId)) {
        await _circleStorage.set(
          circle.id,
          circle.copyWith(memberIds: [contactId, ...circle.memberIds]),
        );
      }
      if (!isMember && circle.memberIds.contains(contactId)) {
        await _circleStorage.set(
          circle.id,
          circle.copyWith(memberIds: [...circle.memberIds]..remove(contactId)),
        );
      }
    }
  }

  @override
  Future<void> close() {
    unawaited(_circleSubscription.cancel());
    return super.close();
  }
}
