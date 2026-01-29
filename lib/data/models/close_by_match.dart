// Copyright 2024 - 2025 The Reunicorn Authors. All rights reserved.
// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:geolocator/geolocator.dart';

import 'circle.dart';
import 'coag_contact.dart';
import 'contact_location.dart';
import 'profile_info.dart';
import 'utils.dart';

part 'close_by_match.freezed.dart';
part 'close_by_match.g.dart';

(DateTime, DateTime, Duration) getOverlapOrOffset({
  required DateTime start1,
  required DateTime end1,
  required DateTime start2,
  required DateTime end2,
}) {
  // In case they don't overlap
  if (start1.isAfter(end2)) {
    return (start2, end2, end2.difference(start1));
  }
  if (start2.isAfter(end1)) {
    return (start2, end2, start2.difference(end1));
  }
  // otherwise, return overlap
  return (
    start1.isAfter(start2) ? start1 : start2,
    end1.isBefore(end2) ? end1 : end2,
    Duration.zero,
  );
}

@freezed
sealed class CloseByMatch with _$CloseByMatch implements JsonEncodable {
  factory CloseByMatch({
    required String myLocationLabel,
    required String theirLocationId,
    required String theirLocationLabel,
    required String coagContactId,
    required String coagContactName,
    required DateTime start,
    required DateTime end,
    required Duration offset,
    required bool theyKnow,
  }) = _CloseByMatch;

  factory CloseByMatch.fromJson(Map<String, dynamic> json) =>
      _$CloseByMatchFromJson(json);
}

Iterable<CloseByMatch> closeByAddressWithTemporary({
  required Map<String, ContactAddressLocation> myAddressLocations,
  required Map<String, ContactTemporaryLocation> theirTemporaryLocations,
  required Duration timeThreshold,
  required double distanceThresholdKm,
  required Set<String> mySharedLocationIds,
  required String coagContactId,
  required String theirName,
}) {
  final matches = <CloseByMatch>[];
  for (final my in myAddressLocations.entries) {
    for (final their in theirTemporaryLocations.entries) {
      if (Geolocator.distanceBetween(
            my.value.latitude,
            my.value.longitude,
            their.value.latitude,
            their.value.longitude,
          ) <
          distanceThresholdKm * 1000) {
        matches.add(
          CloseByMatch(
            myLocationLabel: my.key,
            theirLocationId: their.key,
            theirLocationLabel: their.value.name,
            coagContactId: coagContactId,
            coagContactName: theirName,
            start: their.value.start,
            end: their.value.end,
            offset: Duration.zero,
            theyKnow: mySharedLocationIds.contains(my.key),
          ),
        );
      }
    }
  }
  return matches;
}

Iterable<CloseByMatch> closeByTemporaryWithTemporary({
  required Map<String, ContactTemporaryLocation> myTemporaryLocations,
  required Map<String, ContactTemporaryLocation> theirTemporaryLocations,
  required Duration timeThreshold,
  required double distanceThresholdKm,
  required Set<String> mySharedLocationIds,
  required String coagContactId,
  required String theirName,
}) {
  final matches = <CloseByMatch>[];
  for (final my in myTemporaryLocations.entries) {
    for (final their in theirTemporaryLocations.entries) {
      final (start, end, offset) = getOverlapOrOffset(
        start1: my.value.start,
        end1: my.value.end,
        start2: their.value.start,
        end2: their.value.end,
      );
      if (Geolocator.distanceBetween(
                my.value.latitude,
                my.value.longitude,
                their.value.latitude,
                their.value.longitude,
              ) <
              distanceThresholdKm * 1000 &&
          offset.abs() <= timeThreshold) {
        matches.add(
          CloseByMatch(
            myLocationLabel: my.value.name,
            theirLocationId: their.key,
            theirLocationLabel: their.value.name,
            coagContactId: coagContactId,
            coagContactName: theirName,
            start: start,
            end: end,
            offset: offset,
            theyKnow: mySharedLocationIds.contains(my.key),
          ),
        );
      }
    }
  }
  return matches;
}

Iterable<CloseByMatch> closeByTemporaryWithAddress({
  required Map<String, ContactTemporaryLocation> myTemporaryLocations,
  required Map<String, ContactAddressLocation> theirAddressLocations,
  required Duration timeThreshold,
  required double distanceThresholdKm,
  required Set<String> mySharedLocationIds,
  required String coagContactId,
  required String theirName,
}) {
  final matches = <CloseByMatch>[];
  for (final my in myTemporaryLocations.entries) {
    for (final their in theirAddressLocations.entries) {
      if (Geolocator.distanceBetween(
            my.value.latitude,
            my.value.longitude,
            their.value.latitude,
            their.value.longitude,
          ) <
          distanceThresholdKm * 1000) {
        matches.add(
          CloseByMatch(
            myLocationLabel: my.value.name,
            theirLocationId: their.key,
            theirLocationLabel: their.key,
            coagContactId: coagContactId,
            coagContactName: theirName,
            start: my.value.start,
            end: my.value.end,
            offset: Duration.zero,
            theyKnow: mySharedLocationIds.contains(my.key),
          ),
        );
      }
    }
  }
  return matches;
}

// TODO: Runtime benchmark this and see if optimizations are necessary
List<CloseByMatch> closeByMatchesForContact(
  ProfileInfo profileInfo,
  CoagContact contact,
  Set<String> circleIds,
  Duration timeThreshold,
  double distanceThresholdKm, {
  bool includePastTemporaryLocations = false,
}) {
  // Get labels of address locations I share with any of the given circle IDs
  final mySharedAddressLocationIds = profileInfo
      .sharingSettings
      .addresses
      .entries
      .where((e) => e.value.toSet().intersectsWith(circleIds))
      .map((e) => e.key)
      .toSet();

  // Get IDs of temporary locations I share with any of the given circle IDs
  final mySharedTemporaryLocationIds = profileInfo.temporaryLocations.entries
      .where((e) => e.value.circles.toSet().intersectsWith(circleIds))
      .map((e) => e.key)
      .toSet();

  // Optionally, remove locations that were scheduled to end in the past
  final myTemporaryLocations =
      includePastTemporaryLocations
            ? profileInfo.temporaryLocations
            : {...profileInfo.temporaryLocations}
        ..removeWhere((k, v) => v.end.isBefore(DateTime.now()));
  final theirTemporaryLocations =
      includePastTemporaryLocations
            ? contact.temporaryLocations
            : {...contact.temporaryLocations}
        ..removeWhere((k, v) => v.end.isBefore(DateTime.now()));

  // Combine all potential location matches
  final matches = [
    ...closeByAddressWithTemporary(
      myAddressLocations: profileInfo.addressLocations,
      theirTemporaryLocations: theirTemporaryLocations,
      timeThreshold: timeThreshold,
      distanceThresholdKm: distanceThresholdKm,
      mySharedLocationIds: mySharedAddressLocationIds,
      coagContactId: contact.coagContactId,
      theirName: contact.name,
    ),
    ...closeByTemporaryWithTemporary(
      myTemporaryLocations: myTemporaryLocations,
      theirTemporaryLocations: theirTemporaryLocations,
      timeThreshold: timeThreshold,
      distanceThresholdKm: distanceThresholdKm,
      mySharedLocationIds: mySharedTemporaryLocationIds,
      coagContactId: contact.coagContactId,
      theirName: contact.name,
    ),
    ...closeByTemporaryWithAddress(
      myTemporaryLocations: myTemporaryLocations,
      theirAddressLocations: contact.addressLocations,
      timeThreshold: timeThreshold,
      distanceThresholdKm: distanceThresholdKm,
      mySharedLocationIds: mySharedTemporaryLocationIds,
      coagContactId: contact.coagContactId,
      theirName: contact.name,
    ),
  ];

  return matches;
}

List<CloseByMatch> closeByMatches(
  ProfileInfo profile,
  Iterable<CoagContact> contacts,
  Iterable<Circle> circles,
) {
  const timeThreshold = Duration.zero;
  const distanceThresholdKm = 10.0;
  return contacts
      .map(
        (contact) => closeByMatchesForContact(
          profile,
          contact,
          circles
              .where(
                (circle) => circle.memberIds.contains(contact.coagContactId),
              )
              .map((circle) => circle.id)
              .toSet(),
          timeThreshold,
          distanceThresholdKm,
        ),
      )
      .expand((x) => x)
      .toList()
    ..sort((a, b) {
      if (a.start.isBefore(b.start)) {
        return -1;
      }
      if (b.start.isBefore(a.start)) {
        return 1;
      }
      return 0;
    });
}
