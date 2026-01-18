// Copyright 2026 The Reunicorn Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

import 'package:collection/equality.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../contact_details.dart';
import 'base.dart';

part 'contact_details.freezed.dart';
part 'contact_details.g.dart';

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

  factory ContactDetailsDiff.fromJson(Map<String, dynamic> json) =>
      _$ContactDetailsDiffFromJson(json);
}

extension ConvenienceGetters on ContactDetailsDiff {
  bool get areAllKeep {
    if (!picture.isKeep) {
      return false;
    }
    if (names.values.where((v) => !v.isKeep).isNotEmpty) {
      return false;
    }
    if (phones.values.where((v) => !v.isKeep).isNotEmpty) {
      return false;
    }
    if (emails.values.where((v) => !v.isKeep).isNotEmpty) {
      return false;
    }
    if (websites.values.where((v) => !v.isKeep).isNotEmpty) {
      return false;
    }
    if (socialMedias.values.where((v) => !v.isKeep).isNotEmpty) {
      return false;
    }
    if (events.values.where((v) => !v.isKeep).isNotEmpty) {
      return false;
    }
    if (organizations.values.where((v) => !v.isKeep).isNotEmpty) {
      return false;
    }
    if (misc.values.where((v) => !v.isKeep).isNotEmpty) {
      return false;
    }
    if (tags.values.where((v) => !v.isKeep).isNotEmpty) {
      return false;
    }
    return true;
  }
}

ContactDetailsDiff diffContactDetails(
  ContactDetails old,
  ContactDetails target,
) => ContactDetailsDiff(
  picture: diffLists(old.picture, target.picture),
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

DiffStatus diffLists(List<dynamic>? old, List<dynamic>? target) {
  if ((old?.isEmpty ?? true) && (target?.isNotEmpty ?? false)) {
    return DiffStatus.add;
  }
  if ((old?.isNotEmpty ?? false) && (target?.isEmpty ?? true)) {
    return DiffStatus.remove;
  }
  if (!ListEquality().equals(old, target)) {
    return DiffStatus.change;
  }
  // old == target
  return DiffStatus.keep;
}
