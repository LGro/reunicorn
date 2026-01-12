// Copyright 2026 The Reunicorn Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

import 'package:freezed_annotation/freezed_annotation.dart';

import '../contact_details.dart';
import 'base.dart';

part 'contact_details.freezed.dart';

@freezed
sealed class ContactDetailsDiff with _$ContactDetailsDiff {
  const factory ContactDetailsDiff({
    required DiffStatus picture,
    required Map<String, DiffStatus> names,
    required Map<String, DiffStatus> phones,
    required Map<String, DiffStatus> emails,
    required Map<String, DiffStatus> websites,
    required Map<String, DiffStatus> socialMedias,
    required Map<String, DiffStatus> events,
    required Map<String, DiffStatus> organizations,
    required Map<String, DiffStatus> misc,
    required Map<String, DiffStatus> tags,
  }) = _ContactDetailsDiff;
  const ContactDetailsDiff._();
}

ContactDetailsDiff diffContactDetails(
  ContactDetails old,
  ContactDetails target,
) => ContactDetailsDiff(
  picture: diffPicture(old.picture, target.picture),
  names: diffMaps(old.names, target.names),
  phones: diffMaps(old.phones, target.phones),
  emails: diffMaps(old.emails, target.emails),
  websites: diffMaps(old.websites, target.websites),
  socialMedias: diffMaps(old.socialMedias, target.socialMedias),
  events: diffMaps(old.events, target.events),
  organizations: diffMaps(old.organizations, target.organizations),
  misc: diffMaps(old.misc, target.misc),
  tags: diffMaps(old.tags, target.tags),
);

DiffStatus diffPicture(List<int>? old, List<int>? target) =>
    switch ((old, target)) {
      (null, null) => DiffStatus.keep,
      (null, _) => DiffStatus.add,
      (_, null) => DiffStatus.remove,
      _ when old != target => DiffStatus.change,
      // old == target
      _ => DiffStatus.keep,
    };
