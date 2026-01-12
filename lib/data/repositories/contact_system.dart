// Copyright 2025 - 2026 The Reunicorn Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:phone_numbers_parser/phone_numbers_parser.dart';

import '../models/coag_contact.dart';
import '../services/storage/base.dart';

const appManagedLabelSuffix = '🦄';

bool noAppLabelSuffix<T>(T detail) {
  if (detail is Phone) {
    return !detail.customLabel.endsWith(appManagedLabelSuffix);
  }
  if (detail is Email) {
    return !detail.customLabel.endsWith(appManagedLabelSuffix);
  }
  if (detail is Address) {
    return !detail.customLabel.endsWith(appManagedLabelSuffix);
  }
  if (detail is Website) {
    return !detail.customLabel.endsWith(appManagedLabelSuffix);
  }
  if (detail is SocialMedia) {
    return !detail.customLabel.endsWith(appManagedLabelSuffix);
  }
  if (detail is Event) {
    return !detail.customLabel.endsWith(appManagedLabelSuffix);
  }
  if (detail is Note) {
    return !detail.note.endsWith(appManagedLabelSuffix);
  }
  return true;
}

T updateContactDetailLabel<T>(
  T detail,
  String Function(String label) updateFunction,
) {
  if (detail is Phone) {
    return Phone(
          detail.number,
          label: PhoneLabel.custom,
          customLabel: updateFunction(detail.customLabel),
          normalizedNumber: detail.normalizedNumber,
          isPrimary: detail.isPrimary,
        )
        as T;
  }
  if (detail is Email) {
    return Email(
          detail.address,
          label: EmailLabel.custom,
          customLabel: updateFunction(detail.customLabel),
          isPrimary: detail.isPrimary,
        )
        as T;
  }
  if (detail is Address) {
    return Address(
          detail.address,
          label: detail.label = AddressLabel.custom,
          customLabel: updateFunction(detail.customLabel),
          street: detail.street,
          pobox: detail.pobox,
          neighborhood: detail.neighborhood,
          city: detail.city,
          state: detail.state,
          postalCode: detail.postalCode,
          country: detail.country,
          isoCountry: detail.isoCountry,
          subAdminArea: detail.subAdminArea,
          subLocality: detail.subLocality,
        )
        as T;
  }
  if (detail is Website) {
    return Website(
          detail.url,
          label: WebsiteLabel.custom,
          customLabel: updateFunction(detail.customLabel),
        )
        as T;
  }
  if (detail is SocialMedia) {
    return SocialMedia(
          detail.userName,
          label: SocialMediaLabel.custom,
          customLabel: updateFunction(detail.customLabel),
        )
        as T;
  }
  if (detail is Event) {
    return Event(
          year: detail.year,
          month: detail.month,
          day: detail.day,
          label: EventLabel.custom,
          customLabel: updateFunction(detail.customLabel),
        )
        as T;
  }
  if (detail is Note) {
    return Note(updateFunction(detail.note)) as T;
  }
  return detail;
}

String removeCountryCodePrefix(String number) {
  if (!number.startsWith('+')) {
    return number;
  }
  final parsed = PhoneNumber.parse(number);
  return number.replaceFirst(parsed.countryCode, '');
}

bool coveredByReunicorn<T>(T detail, List<T> coagDetails) {
  if (detail is Phone) {
    // TODO: Be smart about country codes
    return coagDetails.map((d) => (d as Phone).number).contains(detail.number);
  }
  if (detail is Email) {
    return coagDetails
        .map((d) => (d as Email).address)
        .contains(detail.address);
  }
  if (detail is Address) {
    return coagDetails
        .map((d) => (d as Address).address)
        .contains(detail.address);
  }
  if (detail is Website) {
    return coagDetails.map((d) => (d as Website).url).contains(detail.url);
  }
  if (detail is SocialMedia) {
    return coagDetails
        .map((d) => (d as SocialMedia).userName)
        .contains(detail.userName);
  }
  if (detail is Note) {
    return coagDetails.map((d) => (d as Note).note).contains(detail.note);
  }
  if (detail is Event) {
    // TODO: Figure out how to match these
    return false;
  }
  return false;
}

String addCoagSuffix(String value) =>
    '${removeCoagSuffix(value)} $appManagedLabelSuffix';

String removeCoagSuffix(String value) =>
    value.trimRight().replaceAll(appManagedLabelSuffix, '').trimRight();

String addCoagSuffixNewline(String value) =>
    '${removeCoagSuffix(value)}\n\n$appManagedLabelSuffix';

// TODO: Figure out what to do about the (display) name
Contact mergeSystemContacts(Contact system, Contact app) => system
  ..phones = [
    ...system.phones
        .where(noAppLabelSuffix)
        .where((v) => !coveredByReunicorn(v, app.phones)),
    ...app.phones.map((v) => updateContactDetailLabel(v, addCoagSuffix)),
  ]
  ..emails = [
    ...system.emails
        .where(noAppLabelSuffix)
        .where((v) => !coveredByReunicorn(v, app.emails)),
    ...app.emails.map((v) => updateContactDetailLabel(v, addCoagSuffix)),
  ]
  ..addresses = [
    ...system.addresses
        .where(noAppLabelSuffix)
        .where((v) => !coveredByReunicorn(v, app.addresses)),
    ...app.addresses.map((v) => updateContactDetailLabel(v, addCoagSuffix)),
  ]
  ..websites = [
    ...system.websites
        .where(noAppLabelSuffix)
        .where((v) => !coveredByReunicorn(v, app.websites)),
    ...app.websites.map((v) => updateContactDetailLabel(v, addCoagSuffix)),
  ]
  ..socialMedias = [
    ...system.socialMedias
        .where(noAppLabelSuffix)
        .where((v) => !coveredByReunicorn(v, app.socialMedias)),
    ...app.socialMedias.map((v) => updateContactDetailLabel(v, addCoagSuffix)),
  ]
  ..events = [
    ...system.events
        .where(noAppLabelSuffix)
        .where((v) => !coveredByReunicorn(v, app.events)),
    ...app.events.map((v) => updateContactDetailLabel(v, addCoagSuffix)),
  ]
  ..notes = [
    ...system.notes
        .where(noAppLabelSuffix)
        .where((v) => !coveredByReunicorn(v, app.notes)),
    ...app.notes.map((v) => updateContactDetailLabel(v, addCoagSuffixNewline)),
  ];

Contact removeCoagManagedSuffixes(Contact contact) => contact
  ..phones = [
    ...contact.phones.map((v) => updateContactDetailLabel(v, removeCoagSuffix)),
  ]
  ..emails = [
    ...contact.emails.map((v) => updateContactDetailLabel(v, removeCoagSuffix)),
  ]
  ..addresses = [
    ...contact.addresses.map(
      (v) => updateContactDetailLabel(v, removeCoagSuffix),
    ),
  ]
  ..websites = [
    ...contact.websites.map(
      (v) => updateContactDetailLabel(v, removeCoagSuffix),
    ),
  ]
  ..socialMedias = [
    ...contact.socialMedias.map(
      (v) => updateContactDetailLabel(v, removeCoagSuffix),
    ),
  ]
  ..events = [
    ...contact.events.map((v) => updateContactDetailLabel(v, removeCoagSuffix)),
  ]
  ..notes = [
    ...contact.notes.map((v) => updateContactDetailLabel(v, removeCoagSuffix)),
  ];

Set<String> getAllLinkedSystemContactIds(Iterable<CoagContact> contacts) =>
    contacts.map((c) => c.systemContactId).whereType<String>().toSet();

Future<CoagContact> updateSystemContact(CoagContact contact) async {
  if (contact.systemContactId == null) {
    return contact;
  }

  final permission = await Permission.contacts.status;
  if (!permission.isGranted) {
    return contact;
  }

  final systemContact = await FlutterContacts.getContact(
    contact.systemContactId!,
    withAccounts: true,
    withGroups: true,
  );
  if (systemContact == null) {
    // TODO: Is there a better way to remove it?
    final contactJson = contact.toJson()..remove('system_contact_id');
    return CoagContact.fromJson(contactJson);
  }

  if (contact.details == null) {
    return contact;
  }

  // We combine into a display name but the system display name is kept
  // TODO: Claim existing values
  final updatedSystemContact = mergeSystemContacts(
    systemContact,
    contact.details!.toSystemContact(
      contact.details!.names.values.join(' | '),
      contact.addressLocations,
    ),
  );
  await FlutterContacts.updateContact(updatedSystemContact);

  return contact;
}

Future<CoagContact> unlinkSystemContact(CoagContact contact) async {
  if (contact.systemContactId == null) {
    return contact;
  }

  final permission = await Permission.contacts.status;
  if (!permission.isGranted) {
    return contact;
  }

  final systemContact = await FlutterContacts.getContact(
    contact.systemContactId!,
    withAccounts: true,
    withGroups: true,
  );
  if (systemContact != null) {
    await FlutterContacts.updateContact(
      removeCoagManagedSuffixes(systemContact),
    );
  }
  // TODO: Is there a better way to remove it?
  final contactJson = contact.toJson()..remove('system_contact_id');
  return CoagContact.fromJson(contactJson);
}

// TODO: store coag contact and system contact links separate

class SystemContactRepository {
  final Storage<CoagContact> _contactStorage;

  SystemContactRepository(this._contactStorage) {
    _contactStorage.changeEvents.listen(
      (e) => e.when(
        set: (oldContact, newContact) => updateSystemContact(newContact),
        delete: unlinkSystemContact,
      ),
    );
  }
}
