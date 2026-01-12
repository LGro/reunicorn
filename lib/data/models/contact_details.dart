// Copyright 2024 - 2026 The Reunicorn Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

import 'dart:typed_data';

import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import 'contact_location.dart';

part 'contact_details.freezed.dart';
part 'contact_details.g.dart';

@freezed
sealed class ContactDetails with _$ContactDetails {
  const factory ContactDetails({
    /// Binary integer representation of an image
    List<int>? picture,

    /// Public identity key
    String? publicKey,

    /// Names with unique key
    @Default({}) Map<String, String> names,

    /// Phone numbers
    @Default({}) Map<String, String> phones,

    /// E-mail addresses
    @Default({}) Map<String, String> emails,

    /// Websites
    @Default({}) Map<String, String> websites,

    /// Social media / instant messaging profiles
    @Default({}) Map<String, String> socialMedias,

    /// Events / birthdays
    @Default({}) Map<String, DateTime> events,

    /// Organizations like companies with role info
    @Default({}) Map<String, Organization> organizations,

    /// Miscellaneous fields
    @Default({}) Map<String, String> misc,

    /// Tags to indicate topics, preferences with unique key
    @Default({}) Map<String, String> tags,
  }) = _ContactDetails;
  const ContactDetails._();

  factory ContactDetails.fromJson(Map<String, dynamic> json) =>
      _$ContactDetailsFromJson(json);

  Contact toSystemContact(
    String displayName,
    Map<String, ContactAddressLocation> addresses,
  ) => Contact(
    displayName: displayName,
    photo: (picture == null) ? null : Uint8List.fromList(picture!),
    phones: phones.entries
        .map(
          (e) => Phone(e.value, label: PhoneLabel.custom, customLabel: e.key),
        )
        .toList(),
    emails: emails.entries
        .map(
          (e) => Email(e.value, label: EmailLabel.custom, customLabel: e.key),
        )
        .toList(),
    addresses: addresses.entries
        .map(
          (e) => Address(
            e.value.address ?? '',
            label: AddressLabel.custom,
            customLabel: e.key,
          ),
        )
        .toList(),
    websites: websites.entries
        .map(
          (e) =>
              Website(e.value, label: WebsiteLabel.custom, customLabel: e.key),
        )
        .toList(),
    socialMedias: socialMedias.entries
        .map(
          (e) => SocialMedia(
            e.value,
            label: SocialMediaLabel.custom,
            customLabel: e.key,
          ),
        )
        .toList(),
    events: events.entries
        .map(
          (e) => Event(
            day: e.value.day,
            month: e.value.month,
            year: e.value.year,
            label: EventLabel.custom,
            customLabel: e.key,
          ),
        )
        .toList(),
    organizations: [...organizations.values],
  );
}

(String, String) simplifyFlutterContactsDetailType<T>(T detail) {
  if (T == Phone) {
    final d = detail as Phone;
    return (
      (d.label == PhoneLabel.custom) ? d.customLabel : d.label.name,
      d.number,
    );
  }
  if (T == Email) {
    final d = detail as Email;
    return (
      (d.label == EmailLabel.custom) ? d.customLabel : d.label.name,
      d.address,
    );
  }
  if (T == Address) {
    final d = detail as Address;
    return (
      (d.label == AddressLabel.custom) ? d.customLabel : d.label.name,
      d.address,
    );
  }
  if (T == Website) {
    final d = detail as Website;
    return (
      (d.label == WebsiteLabel.custom) ? d.customLabel : d.label.name,
      d.url,
    );
  }
  if (T == SocialMedia) {
    final d = detail as SocialMedia;
    return (
      (d.label == SocialMediaLabel.custom) ? d.customLabel : d.label.name,
      d.userName,
    );
  }
  throw Exception(
    'Unexpected type $T for flutter contacts detail simplification',
  );
}

Map<String, dynamic>
migrateContactDetailsJsonFromFlutterContactsTypeToSimpleMaps(
  Map<String, dynamic> json,
) {
  final migrated = <String, dynamic>{};
  for (final key in json.keys) {
    if (json[key] is List<dynamic>) {
      if (key == 'phones') {
        migrated[key] = Map.fromEntries(
          (json[key] as List<dynamic>)
              .map((e) => Phone.fromJson(e as Map<String, dynamic>))
              .map(simplifyFlutterContactsDetailType)
              .map((v) => MapEntry(v.$1, v.$2)),
        );
      } else if (key == 'emails') {
        migrated[key] = Map.fromEntries(
          (json[key] as List<dynamic>)
              .map((e) => Email.fromJson(e as Map<String, dynamic>))
              .map(simplifyFlutterContactsDetailType)
              .map((v) => MapEntry(v.$1, v.$2)),
        );
      } else if (key == 'addresses') {
        migrated[key] = Map.fromEntries(
          (json[key] as List<dynamic>)
              .map((e) => Address.fromJson(e as Map<String, dynamic>))
              .map(simplifyFlutterContactsDetailType)
              .map((v) => MapEntry(v.$1, v.$2)),
        );
      } else if (key == 'websites') {
        migrated[key] = Map.fromEntries(
          (json[key] as List<dynamic>)
              .map((e) => Website.fromJson(e as Map<String, dynamic>))
              .map(simplifyFlutterContactsDetailType)
              .map((v) => MapEntry(v.$1, v.$2)),
        );
      } else if (key == 'social_medias') {
        migrated[key] = Map.fromEntries(
          (json[key] as List<dynamic>)
              .map((e) => SocialMedia.fromJson(e as Map<String, dynamic>))
              .map(simplifyFlutterContactsDetailType)
              .map((v) => MapEntry(v.$1, v.$2)),
        );
      } else if (key == 'events') {
        migrated[key] = <String, dynamic>{};
      } else {
        migrated[key] = json[key];
      }
    } else {
      migrated[key] = json[key];
    }
  }
  return migrated;
}
