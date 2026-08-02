// Copyright 2024 - 2026 The Reunicorn Authors. All rights reserved.
// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter_test/flutter_test.dart';
import 'package:reunicorn/data/models/coag_contact.dart';
import 'package:reunicorn/ui/navigation.dart';
import 'package:reunicorn/ui/router.dart';
import 'package:reunicorn/ui/routes.dart';

import '../mocked_providers.dart';

CoagContact _contact(String id) =>
    minimalBaseContact.copyWith(coagContactId: id, name: 'Contact $id');

void main() {
  // AppRouters builds a KaiselRouterConfig, which wires a
  // PlatformRouteInformationProvider and so needs the binding.
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppRouters routers;

  tearDown(() => routers.dispose());

  group('cross-branch navigation', () {
    setUp(() => routers = AppRouters(isFirstRun: false));

    test(
      'showContact pushes onto contacts and switches to that branch',
      () async {
        await showContact(routers, _contact('a'));

        expect(routers.contacts.stack.last, ContactView(_contact('a')));
        expect(routers.shell.activeBranch, AppBranch.contacts.index);
      },
    );

    test(
      'showContact from another branch leaves that branch untouched',
      () async {
        await routers.map.push(const LocationList());

        await showContact(routers, _contact('a'));

        // The map tab keeps its history — that is the state preservation the
        // old non-stateful ShellRoute could not give us.
        expect(routers.map.stack.last, const LocationList());
        expect(routers.shell.activeBranch, AppBranch.contacts.index);
      },
    );

    test('showMapAt replaces the map stack with the located map', () async {
      await routers.map.push(const LocationList());

      await showMapAt(routers, 52.5, 13.4);

      expect(routers.map.stack, const [
        MapView(latitude: 52.5, longitude: 13.4),
      ]);
      expect(routers.shell.activeBranch, AppBranch.map.index);
    });

    test('showImportIcs pushes the ICS payload onto the map branch', () async {
      await showImportIcs(routers, 'BEGIN:VCALENDAR');

      expect(routers.map.stack.last, const ImportIcs('BEGIN:VCALENDAR'));
      expect(routers.shell.activeBranch, AppBranch.map.index);
    });

    test(
      'the target branch is already correct when it becomes visible',
      () async {
        // Ordering matters: the stack mutation is awaited before the switch, so
        // the branch never renders its previous top.
        await showContact(routers, _contact('a'));

        final visible = routers.contacts.stack.last;
        expect(routers.shell.activeBranch, AppBranch.contacts.index);
        expect(visible, isA<ContactView>());
      },
    );
  });

  group('first-run guard', () {
    setUp(() => routers = AppRouters(isFirstRun: true));

    test('starts on Welcome when there is no profile', () {
      expect(routers.root.stack, const [Welcome()]);
    });

    test('redirects navigation away from the app back to Welcome', () async {
      await routers.root.push(const Introductions());

      expect(routers.root.stack, const [Welcome()]);
    });

    test('allows the legal screens during onboarding', () async {
      await routers.root.push(const Terms());

      expect(routers.root.stack.last, const Terms());
    });

    test('allows restoring a backup during onboarding', () async {
      await routers.root.push(const RestoreBackup());

      expect(routers.root.stack.last, const RestoreBackup());
    });

    test(
      'completeOnboarding lets the app through and lands on a branch',
      () async {
        await completeOnboarding(routers, landOn: AppBranch.contacts);

        expect(routers.hasProfile.value, isTrue);
        expect(routers.root.stack, const [ShellHost()]);
        expect(routers.shell.activeBranch, AppBranch.contacts.index);
      },
    );
  });

  group('returning users', () {
    setUp(() => routers = AppRouters(isFirstRun: false));

    test('start inside the shell on the profile branch', () {
      expect(routers.root.stack, const [ShellHost()]);
      expect(routers.shell.activeBranch, AppBranch.profile.index);
    });

    test('are not redirected by the guard', () async {
      await routers.root.push(const Introductions());

      expect(routers.root.stack.last, const Introductions());
    });
  });
}
