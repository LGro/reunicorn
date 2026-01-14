// Copyright 2026 The Reunicorn Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

enum DiffStatus { add, change, remove, keep }

extension DiffStatusCheckers on DiffStatus {
  bool get isAdd => this == DiffStatus.add;
  bool get isChange => this == DiffStatus.change;
  bool get isRemove => this == DiffStatus.remove;
  bool get isKeep => this == DiffStatus.keep;
}

Map<String, DiffStatus> diffMaps(
  Map<String, dynamic> old,
  Map<String, dynamic> target,
) {
  final _target = {...target};
  final result = <String, DiffStatus>{};

  for (final o in old.entries) {
    final t = _target.remove(o.key);
    if (t == null) {
      result[o.key] = DiffStatus.remove;
      continue;
    }
    if (t == o.value) {
      result[o.key] = DiffStatus.keep;
      continue;
    }
    if (t != o.value) {
      result[o.key] = DiffStatus.change;
      continue;
    }
  }

  for (final t in _target.keys) {
    result[t] = DiffStatus.add;
  }

  return result;
}
