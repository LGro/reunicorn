// Copyright 2024 - 2026 The Reunicorn Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reunicorn/data/models/circle.dart';
import 'package:reunicorn/data/models/models.dart';
import 'package:reunicorn/data/models/profile_info.dart';
import 'package:reunicorn/data/services/storage/base.dart';
import 'package:reunicorn/data/services/storage/memory.dart';
import 'package:reunicorn/l10n/app_localizations.dart';
import 'package:reunicorn/ui/profile/cubit.dart';
import 'package:reunicorn/ui/profile/page.dart';

Future<Widget> createProfilePage(
  Storage<ProfileInfo> profileStorage,
  Storage<Circle> circleStorage,
) async => MultiRepositoryProvider(
  providers: [
    RepositoryProvider.value(value: profileStorage),
    RepositoryProvider.value(value: circleStorage),
  ],
  child: const MaterialApp(
    home: Directionality(
      textDirection: TextDirection.ltr,
      child: ProfilePage(),
    ),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
  ),
);

void main() {
  test('update circles for social medias', () async {
    final profileStorage = MemoryStorage<ProfileInfo>();
    final circleStorage = MemoryStorage<Circle>();

    await profileStorage.set(
      'pId',
      const ProfileInfo(
        'pId',
        details: ContactDetails(socialMedias: {'l1': 'v1', 'l2': 'v2'}),
      ),
    );
    await circleStorage.set(
      'cId',
      Circle(id: 'cId', name: 'circleName', memberIds: []),
    );

    final cubit = ProfileCubit(profileStorage, circleStorage);
    await cubit.fetchData();
    await cubit.updateSocialMedia('l1', 'l1', 'new1', [
      ('cId', 'circleName', true),
    ]);

    expect(
      cubit.state.profileInfo?.sharingSettings.socialMedias,
      equals({
        'l1': ['cId'],
      }),
    );
  });

  testWidgets('Test Chosen Profile Displayed', (tester) async {
    final profileStorage = MemoryStorage<ProfileInfo>();
    final circleStorage = MemoryStorage<Circle>();

    await profileStorage.set(
      'pId',
      const ProfileInfo(
        'pId',
        details: ContactDetails(socialMedias: {'l1': 'v1', 'l2': 'v2'}),
      ),
    );
    await circleStorage.set(
      'cId',
      Circle(id: 'cId', name: 'circleName', memberIds: []),
    );

    // final cubit = ProfileCubit(profileStorage, circleStorage);
    // await cubit.fetchData();

    final pageWidget = await createProfilePage(profileStorage, circleStorage);
    await tester.pumpWidget(pageWidget);
    await tester.pumpWidget(pageWidget);

    expect(find.text('l1'), findsOneWidget);
    expect(find.text('v1'), findsOneWidget);
    expect(find.text('l2'), findsOneWidget);
    expect(find.text('v2'), findsOneWidget);

    // await tester.tap(find.byKey(const Key('addProfileDetailSocials')));
    // await tester.pump();
  });

  // testWidgets('Test circle creation and assignment', (tester) async {
  //   final contactsRepository = ContactsRepository(
  //     DummyPersistentStorage(
  //       [_profileContact].asMap().map((_, v) => MapEntry(v.coagContactId, v)),
  //     )..profileContactId = '1',
  //     DummyDistributedStorage(),
  //     DummySystemContacts([_profileContact.systemContact!]),
  //   );

  //   final pageWidget = await createProfilePage(contactsRepository);
  //   await tester.pumpWidget(pageWidget);

  //   await tester.tap(find.byKey(const Key('emailsCirclesMgmt0')));
  //   await tester.pump();
  //   expect(find.textContaining('Share'), findsOneWidget);
  //   expect(find.text('New Circle'), findsOneWidget);

  //   const circleName = 'new circle name';
  //   await tester.enterText(
  //     find.byKey(const Key('circlesForm_newCircleInput')),
  //     circleName,
  //   );

  //   await tester.tap(find.byKey(const Key('circlesForm_submit')));
  //   await tester.pump();

  //   await tester.tap(find.byKey(const Key('websitesCirclesMgmt0')));
  //   await tester.pump();
  //   // TODO: This should come back true, why doesn't it?
  //   // expect(find.textContaining(circleName), findsOneWidget);
  // });

  //   testWidgets('Test Chosen Profile Displayed', (tester) async {
  //     final contactsRepository = ContactsRepository(
  //         DummyPersistentStorage([_profileContact]
  //             .asMap()
  //             .map((_, v) => MapEntry(v.coagContactId, v)))
  //           ..profileContactId = '1',
  //         DummyDistributedStorage(),
  //         DummySystemContacts([_profileContact.systemContact!]));

  //     final pageWidget = await createProfilePage(contactsRepository);
  //     await tester.pumpWidget(pageWidget);

  //     expect(
  //         find.text(_profileContact.systemContact!.displayName), findsOneWidget);
  //     expect(find.text(_profileContact.systemContact!.phones[0].number),
  //         findsOneWidget);
  //     expect(find.text(_profileContact.systemContact!.emails[0].address),
  //         findsOneWidget);
  //     expect(find.text(_profileContact.systemContact!.socialMedias[0].userName),
  //         findsOneWidget);
  //     expect(find.text(_profileContact.systemContact!.websites[0].url),
  //         findsOneWidget);
  //   });

  //   testWidgets('Test circle creation and assignment', (tester) async {
  //     final contactsRepository = ContactsRepository(
  //         DummyPersistentStorage([_profileContact]
  //             .asMap()
  //             .map((_, v) => MapEntry(v.coagContactId, v)))
  //           ..profileContactId = '1',
  //         DummyDistributedStorage(),
  //         DummySystemContacts([_profileContact.systemContact!]));

  //     final pageWidget = await createProfilePage(contactsRepository);
  //     await tester.pumpWidget(pageWidget);

  //     await tester.tap(find.byKey(const Key('emailsCirclesMgmt0')));
  //     await tester.pump();
  //     expect(find.textContaining('Share'), findsOneWidget);
  //     expect(find.text('New Circle'), findsOneWidget);

  //     const circleName = 'new circle name';
  //     await tester.enterText(
  //         find.byKey(const Key('circlesForm_newCircleInput')), circleName);

  //     await tester.tap(find.byKey(const Key('circlesForm_submit')));
  //     await tester.pump();

  //     await tester.tap(find.byKey(const Key('websitesCirclesMgmt0')));
  //     await tester.pump();
  //     // TODO: This should come back true, why doesn't it?
  //     // expect(find.textContaining(circleName), findsOneWidget);
  //   });

  //   testWidgets('Test No Contact', (tester) async {
  //     final contactsRepository = ContactsRepository(DummyPersistentStorage({}),
  //         DummyDistributedStorage(), DummySystemContacts([]));

  //     final pageWidget = await createProfilePage(contactsRepository);
  //     await tester.pumpWidget(pageWidget);

  //     expect(find.textContaining('Welcome to Reunicorn'), findsOneWidget);
  //   });

  //   // testWidgets('Choose system contact as profile', (tester) async {
  //   //   final contactsRepository = ContactsRepository(
  //   //       DummyPersistentStorage({}),
  //   //       DummyDistributedStorage(),
  //   //       DummySystemContacts([
  //   //         Contact(
  //   //             displayName: 'Sys Contact',
  //   //             name: Name(first: 'Sys', last: 'Contact'))
  //   //       ]));
  //   //   final page = await createProfilePage(contactsRepository);
  //   //   await tester.pumpWidget(page);

  //   //   await tester.tap(find.byKey(const Key('profilePickContactAsProfile')));

  //   //   await tester.pump();

  //   //   // start with no profile contact
  //   //   // push choose contact button
  //   //   // have predefined contact returned from provider
  //   //   // check that its displayed

  //   //   expect(find.text('Sys Contact'), findsOneWidget);

  //   //   contactsRepository.timerDhtRefresh?.cancel();
  //   //   contactsRepository.timerPersistentStorageRefresh?.cancel();
  //   // });
}
