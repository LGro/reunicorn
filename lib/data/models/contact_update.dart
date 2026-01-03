// Copyright 2024 - 2026 The Reunicorn Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

import 'coag_contact.dart';
import 'utils.dart';

part 'contact_update.g.dart';

@JsonSerializable()
class ContactUpdate extends Equatable implements JsonEncodable {
  const ContactUpdate({
    required this.coagContactId,
    required this.oldContact,
    required this.newContact,
    required this.timestamp,
  });

  factory ContactUpdate.fromJson(Map<String, dynamic> json) =>
      _$ContactUpdateFromJson(json);

  final String? coagContactId;
  final CoagContact oldContact;
  final CoagContact newContact;
  final DateTime timestamp;

  Map<String, dynamic> toJson() => _$ContactUpdateToJson(this);

  ContactUpdate copyWith({
    String? coagContactId,
    CoagContact? oldContact,
    CoagContact? newContact,
    DateTime? timestamp,
  }) => ContactUpdate(
    coagContactId: coagContactId ?? this.coagContactId,
    oldContact: oldContact ?? this.oldContact,
    newContact: newContact ?? this.newContact,
    timestamp: timestamp ?? this.timestamp,
  );

  @override
  List<Object?> get props => [coagContactId, oldContact, newContact, timestamp];
}

Future<ContactUpdate> contactUpdateMigrateFromJson(String json) async =>
    ContactUpdate.fromJson(jsonDecode(json) as Map<String, dynamic>);
