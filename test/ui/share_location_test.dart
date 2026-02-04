// Copyright 2024 - 2026 The Reunicorn Authors. All rights reserved.
// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reunicorn/data/models/circle.dart';
import 'package:reunicorn/data/models/contact_location.dart';
import 'package:reunicorn/data/models/profile_info.dart';
import 'package:reunicorn/data/repositories/settings.dart';
import 'package:reunicorn/data/services/storage/base.dart';
import 'package:reunicorn/data/services/storage/memory.dart';
import 'package:reunicorn/l10n/app_localizations.dart';
import 'package:reunicorn/ui/locations/share_location/widget.dart';

class MockSettingsRepository extends SettingsRepository {
  MockSettingsRepository() : super(darkMode: false);

  @override
  String get mapStyleString =>
      'https://api.maptiler.com/maps/streets/style.json?key=test';
}

Widget createShareLocationWidget(
  Storage<ProfileInfo> profileStorage,
  Storage<Circle> circleStorage, {
  ContactTemporaryLocation? initialLocation,
}) => MultiRepositoryProvider(
  providers: [
    RepositoryProvider<Storage<ProfileInfo>>.value(value: profileStorage),
    RepositoryProvider<Storage<Circle>>.value(value: circleStorage),
    RepositoryProvider<SettingsRepository>.value(
      value: MockSettingsRepository(),
    ),
  ],
  child: MaterialApp(
    home: Directionality(
      textDirection: TextDirection.ltr,
      child: ShareLocationWidget(location: initialLocation),
    ),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
  ),
);

void main() {
  group('ShareLocationWidget', () {
    testWidgets('renders title and description fields', (tester) async {
      final profileStorage = MemoryStorage<ProfileInfo>();
      final circleStorage = MemoryStorage<Circle>();

      await profileStorage.set('pId', const ProfileInfo('pId'));

      final widget = createShareLocationWidget(profileStorage, circleStorage);
      await tester.pumpWidget(widget);
      await tester.pump();

      expect(find.text('Share a location'), findsOneWidget);
      expect(find.text('Title'), findsOneWidget);
      expect(find.text('Description'), findsOneWidget);
    });

    testWidgets('displays circles for selection', (tester) async {
      final profileStorage = MemoryStorage<ProfileInfo>();
      final circleStorage = MemoryStorage<Circle>();

      await profileStorage.set('pId', const ProfileInfo('pId'));
      await circleStorage.set(
        'circle1',
        Circle(id: 'circle1', name: 'Family', memberIds: ['c1', 'c2']),
      );
      await circleStorage.set(
        'circle2',
        Circle(id: 'circle2', name: 'Friends', memberIds: ['c3']),
      );

      final widget = createShareLocationWidget(profileStorage, circleStorage);
      await tester.pumpWidget(widget);
      await tester.pumpAndSettle();

      expect(find.text('Family (2)'), findsOneWidget);
      expect(find.text('Friends (1)'), findsOneWidget);
    });

    testWidgets('submit button is disabled initially', (tester) async {
      final profileStorage = MemoryStorage<ProfileInfo>();
      final circleStorage = MemoryStorage<Circle>();

      await profileStorage.set('pId', const ProfileInfo('pId'));

      final widget = createShareLocationWidget(profileStorage, circleStorage);
      await tester.pumpWidget(widget);
      await tester.pump();

      final submitButton = find.byKey(const Key('shareLocationForm_submit'));
      expect(submitButton, findsOneWidget);

      final button = tester.widget<FilledButton>(submitButton);
      expect(button.onPressed, isNull);
    });

    testWidgets('displays date/time picker buttons', (tester) async {
      final profileStorage = MemoryStorage<ProfileInfo>();
      final circleStorage = MemoryStorage<Circle>();

      await profileStorage.set('pId', const ProfileInfo('pId'));

      final widget = createShareLocationWidget(profileStorage, circleStorage);
      await tester.pumpWidget(widget);
      await tester.pump();

      expect(find.text('Pick Start Date'), findsOneWidget);
      expect(find.text('Pick End Date'), findsOneWidget);
    });

    testWidgets('displays GPS location button', (tester) async {
      final profileStorage = MemoryStorage<ProfileInfo>();
      final circleStorage = MemoryStorage<Circle>();

      await profileStorage.set('pId', const ProfileInfo('pId'));

      final widget = createShareLocationWidget(profileStorage, circleStorage);
      await tester.pumpWidget(widget);
      await tester.pump();

      expect(find.text('Use current GPS location'), findsOneWidget);
    });

    testWidgets('pre-fills form when location is provided', (tester) async {
      final profileStorage = MemoryStorage<ProfileInfo>();
      final circleStorage = MemoryStorage<Circle>();

      await profileStorage.set('pId', const ProfileInfo('pId'));
      await circleStorage.set(
        'circle1',
        Circle(id: 'circle1', name: 'Family', memberIds: []),
      );

      final existingLocation = ContactTemporaryLocation(
        longitude: 10.0,
        latitude: 20.0,
        name: 'Test Location',
        details: 'Test Details',
        start: DateTime(2025, 1, 15, 10, 0),
        end: DateTime(2025, 1, 15, 18, 0),
        circles: ['circle1'],
      );

      final widget = createShareLocationWidget(
        profileStorage,
        circleStorage,
        initialLocation: existingLocation,
      );
      await tester.pumpWidget(widget);
      await tester.pumpAndSettle();

      expect(find.text('Test Location'), findsOneWidget);
      expect(find.text('Test Details'), findsOneWidget);
    });

    testWidgets('can toggle circle selection', (tester) async {
      final profileStorage = MemoryStorage<ProfileInfo>();
      final circleStorage = MemoryStorage<Circle>();

      await profileStorage.set('pId', const ProfileInfo('pId'));
      await circleStorage.set(
        'circle1',
        Circle(id: 'circle1', name: 'TestCircle', memberIds: []),
      );

      final widget = createShareLocationWidget(profileStorage, circleStorage);
      await tester.pumpWidget(widget);
      await tester.pumpAndSettle();

      // Find the checkbox for the circle
      final checkbox = find.byType(Checkbox);
      expect(checkbox, findsOneWidget);

      // Initially unchecked
      final initialCheckbox = tester.widget<Checkbox>(checkbox);
      expect(initialCheckbox.value, false);

      // Tap to select
      await tester.tap(find.text('TestCircle (0)'));
      await tester.pump();

      // Now checked
      final updatedCheckbox = tester.widget<Checkbox>(checkbox);
      expect(updatedCheckbox.value, true);
    });
  });

  group('LocationSelectionMode', () {
    test('has expected values', () {
      expect(LocationSelectionMode.values, [
        LocationSelectionMode.search,
        LocationSelectionMode.map,
        LocationSelectionMode.gps,
      ]);
    });
  });
}
