// Copyright 2024 - 2025 The Reunicorn Authors. All rights reserved.
// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter_test/flutter_test.dart';
import 'package:reunicorn/ui/contact_details/widgets/temporary_locations.dart';

void main() {
  test('Test number of contacts a location is shared with', () {
    final memberships = {
      'contact1': ['circle2'],
      'contact2': ['circle1', 'circle2'],
    };
    expect(numberContactsShared([], []), 0);
    expect(numberContactsShared([[]], []), 0);
    expect(numberContactsShared(memberships.values, []), 0);
    expect(numberContactsShared(memberships.values, ['circle1']), 1);
    expect(numberContactsShared(memberships.values, ['circle3']), 0);
    expect(numberContactsShared(memberships.values, ['circle2']), 2);
    expect(numberContactsShared(memberships.values, ['circle1', 'circle2']), 2);
  });
  group('Contact Details Page Widget Tests', () {
    // testWidgets('Circles update causes details page update', (tester) async {
    //   final contact = CoagContact(
    //       coagContactId: '1',
    //       details: ContactDetails(
    //           displayName: 'Test Name',
    //           name: Name(first: 'Test', last: 'Name')));
    //   final contactsRepository = _contactsRepositoryFromContact(contact);
    //   await contactsRepository.addCircle('c1', 'circle1');
    //   // Add our contact with id 1 to circle c1
    //   await contactsRepository.updateCircleMemberships({
    //     '1': ['c1']
    //   });

    //   final contactPage =
    //       await createContactPage(contactsRepository, contact.coagContactId);
    //   await tester.pumpWidget(contactPage);

    //   await contactsRepository.updateCirclesForContact('1', ['c1']);
    //   await tester.pump();

    //   expect(find.text('circle1'), findsOneWidget);
    //   expect(find.text('Add them to circles'), findsNothing);
    // });
  });
}
