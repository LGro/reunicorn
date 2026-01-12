// Copyright 2026 The Reunicorn Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

import 'package:freezed_annotation/freezed_annotation.dart';

import '../profile_sharing/schema.dart';
import 'base.dart';
import 'contact_details.dart';

part 'contact_sharing_schema.freezed.dart';

@freezed
sealed class ContactSharingSchemaDiff with _$ContactSharingSchemaDiff {
  const factory ContactSharingSchemaDiff({
    required ContactDetailsDiff details,
    required Map<String, DiffStatus> addressLocations,
    required Map<String, DiffStatus> temporaryLocations,
    required DiffStatus introductions,
  }) = _ContactSharingSchemaDiff;
}

ContactSharingSchemaDiff diffContactSharingSchema(
  ContactSharingSchema old,
  ContactSharingSchema target,
) => ContactSharingSchemaDiff(
  details: diffContactDetails(old.details, target.details),
  addressLocations: diffMaps(old.addressLocations, target.addressLocations),
  temporaryLocations: diffMaps(
    old.temporaryLocations,
    target.temporaryLocations,
  ),
  introductions: diffLists(old.introductions, target.introductions),
);

DiffStatus diffLists(List<dynamic> old, List<dynamic> target) {
  if (old.isEmpty && target.isNotEmpty) {
    return DiffStatus.add;
  }
  if (old.isNotEmpty && target.isEmpty) {
    return DiffStatus.remove;
  }
  if (old != target) {
    return DiffStatus.change;
  }
  // old == target
  return DiffStatus.keep;
}
