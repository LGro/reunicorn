// Copyright 2024 - 2026 The Reunicorn Authors. All rights reserved.
// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reunicorn/data/models/models.dart';

void main() {
  test('contact details from address book types to simple maps', () {
    final json = {
      'phones': [
        Phone(
          number: '123',
          label: Label(PhoneLabel.custom, 'bananaphone'),
        ).toJson(),
      ],
      'emails': [
        Email(
          address: 'hi@test.local',
          label: Label(EmailLabel.custom, 'custom-email'),
        ).toJson(),
      ],
      'addresses': [
        Address(
          formatted: 'Home Sweet Home',
          label: Label(AddressLabel.custom, 'custom-address'),
        ).toJson(),
      ],
      'websites': [
        Website(
          url: 'awesomesite',
          label: Label(WebsiteLabel.custom, 'custom-website'),
        ).toJson(),
      ],
      'social_medias': [
        SocialMedia(username: '@coag', label: Label(SocialMediaLabel.icq)).toJson(),
      ],
    };
    final details = ContactDetails.fromJson(
      migrateContactDetailsJsonFromFlutterContactsTypeToSimpleMaps(json),
    );
    expect(details.phones, {'bananaphone': '123'});
    expect(details.emails, {'custom-email': 'hi@test.local'});
    expect(details.websites, {'custom-website': 'awesomesite'});
    expect(details.socialMedias, {'icq': '@coag'});
  });
}
