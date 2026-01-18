// Copyright 2026 The Reunicorn Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

import 'package:freezed_annotation/freezed_annotation.dart';

import '../profile_sharing/schema.dart';
import 'base.dart';
import 'contact_details.dart';

part 'contact_sharing_schema.freezed.dart';
part 'contact_sharing_schema.g.dart';

@freezed
sealed class ContactSharingSchemaDiff with _$ContactSharingSchemaDiff {
  const factory ContactSharingSchemaDiff({
    required ContactDetailsDiff details,
    required Map<String, DiffStatus> addressLocations,
    required Map<String, DiffStatus> temporaryLocations,
    required DiffStatus introductions,
  }) = _ContactSharingSchemaDiff;

  factory ContactSharingSchemaDiff.fromJson(Map<String, dynamic> json) =>
      _$ContactSharingSchemaDiffFromJson(json);
}

extension ConvenienceGetters on ContactSharingSchemaDiff {
  bool get areAllKeep {
    if (!introductions.isKeep) {
      return false;
    }
    if (addressLocations.values.where((v) => !v.isKeep).isNotEmpty) {
      return false;
    }
    if (temporaryLocations.values.where((v) => !v.isKeep).isNotEmpty) {
      return false;
    }
    return details.areAllKeep;
  }
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
