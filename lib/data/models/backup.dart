// Copyright 2024 - 2025 The Reunicorn Authors. All rights reserved.
// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

import 'coag_contact.dart';
import 'profile_info.dart';

part 'backup.g.dart';

@JsonSerializable()
class AccountBackup extends Equatable {
  const AccountBackup(
    this.profileInfo,
    this.contacts,
    this.circles,
    this.circleMemberships,
  );

  factory AccountBackup.fromJson(Map<String, dynamic> json) =>
      _$AccountBackupFromJson(json);

  // save profile info, including locations (exclude pictures?)
  final ProfileInfo profileInfo;
  // save contact dht sharing settings and names
  final List<CoagContact> contacts;
  final Map<String, String> circles;
  final Map<String, List<String>> circleMemberships;
  // TODO: app settings

  Map<String, dynamic> toJson() => _$AccountBackupToJson(this);

  @override
  List<Object?> get props => [
    profileInfo,
    contacts,
    circles,
    circleMemberships,
  ];
}
