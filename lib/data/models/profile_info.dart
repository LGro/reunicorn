// Copyright 2025 - 2026 The Reunicorn Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:veilid/veilid.dart';

import 'coag_contact.dart';
import 'contact_details.dart';
import 'contact_location.dart';
import 'profile_sharing/settings.dart';
import 'utils.dart';

part 'profile_info.g.dart';

@JsonSerializable()
class ProfileInfo extends Equatable implements JsonEncodable {
  const ProfileInfo(
    this.id, {
    this.details = const ContactDetails(),
    this.pictures = const {},
    this.addressLocations = const {},
    this.temporaryLocations = const {},
    this.sharingSettings = const ProfileSharingSettings(),
    this.mainKeyPair,
  });

  factory ProfileInfo.fromJson(Map<String, dynamic> json) =>
      _$ProfileInfoFromJson(json);

  final String id;
  final ContactDetails details;
  final Map<String, List<int>> pictures;

  /// Map from label to address location
  final Map<String, ContactAddressLocation> addressLocations;

  /// Map from label to temporary location
  final Map<String, ContactTemporaryLocation> temporaryLocations;
  final ProfileSharingSettings sharingSettings;

  /// The main key pair used for profile invites
  final KeyPair? mainKeyPair;

  Map<String, dynamic> toJson() => _$ProfileInfoToJson(this);

  ProfileInfo copyWith({
    ContactDetails? details,
    Map<String, List<int>>? pictures,
    Map<String, ContactAddressLocation>? addressLocations,
    Map<String, ContactTemporaryLocation>? temporaryLocations,
    ProfileSharingSettings? sharingSettings,
    KeyPair? mainKeyPair,
  }) => ProfileInfo(
    id,
    details: (details ?? this.details).copyWith(),
    pictures: {...pictures ?? this.pictures},
    addressLocations: {...addressLocations ?? this.addressLocations},
    temporaryLocations: {...temporaryLocations ?? this.temporaryLocations},
    sharingSettings: (sharingSettings ?? this.sharingSettings).copyWith(),
    mainKeyPair: mainKeyPair ?? this.mainKeyPair,
  );

  @override
  List<Object?> get props => [
    id,
    details,
    pictures,
    addressLocations,
    temporaryLocations,
    sharingSettings,
    mainKeyPair,
  ];
}

Future<ProfileInfo> profileMigrateFromJson(String json) async =>
    ProfileInfo.fromJson(
      migrateContactAddressLocationFromIntToLabelIndexing(
        jsonDecode(json) as Map<String, dynamic>,
      ),
    );
