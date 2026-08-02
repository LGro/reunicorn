// Copyright 2024 - 2026 The Reunicorn Authors. All rights reserved.
// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter/widgets.dart';

import '../data/models/coag_contact.dart';
import 'router.dart';
import 'routes.dart';

/// Navigation that crosses shell branches.
///
/// A branch router is only reachable from inside its own branch, so anything
/// that jumps between tabs goes through [AppRouters] here instead of through
/// `context.router<R>()` at the call site. Each helper sets the target
/// branch's stack *before* switching to it — the two are separate mutations,
/// and doing it in this order means the branch is already showing the right
/// screen when it becomes visible.
///
/// Every helper takes an [AppRouters] rather than resolving it internally, so
/// they can be exercised in tests without a widget tree; the `context`
/// variants are thin wrappers for call sites.
///
/// Stack mutations are asynchronous (they run through the guard pipeline), so
/// the helpers `await` them before calling the synchronous [switchTo] — the
/// branch is then already showing the right screen at the moment it becomes
/// visible, rather than flashing its previous top.

Future<void> showContact(AppRouters routers, CoagContact contact) async {
  await routers.contacts.push(ContactView(contact));
  routers.shell.switchTo(AppBranch.contacts.index);
}

Future<void> showContactList(AppRouters routers) async {
  await routers.contacts.set(const [ContactList()]);
  routers.shell.switchTo(AppBranch.contacts.index);
}

Future<void> showMapAt(
  AppRouters routers,
  double? latitude,
  double? longitude,
) async {
  await routers.map.set([MapView(latitude: latitude, longitude: longitude)]);
  routers.shell.switchTo(AppBranch.map.index);
}

Future<void> showImportIcs(AppRouters routers, String icsData) async {
  await routers.map.push(ImportIcs(icsData));
  routers.shell.switchTo(AppBranch.map.index);
}

Future<void> showProfile(AppRouters routers) async {
  await routers.profile.set(const [ProfileHome()]);
  routers.shell.switchTo(AppBranch.profile.index);
}

/// Leaves onboarding for the main app. Flips [AppRouters.hasProfile] first so
/// the first-run guard stops redirecting back to [Welcome], and selects the
/// landing branch before the shell is shown.
Future<void> completeOnboarding(
  AppRouters routers, {
  required AppBranch landOn,
}) async {
  routers.hasProfile.value = true;
  routers.shell.switchTo(landOn.index);
  await routers.root.set(const [ShellHost()]);
}

// ---------------------------------------------------------------------
// BuildContext conveniences
// ---------------------------------------------------------------------

extension AppNavigationX on BuildContext {
  Future<void> goToContact(CoagContact contact) =>
      showContact(AppRouters.of(this), contact);

  Future<void> goToContactList() => showContactList(AppRouters.of(this));

  Future<void> goToMapAt(double? latitude, double? longitude) =>
      showMapAt(AppRouters.of(this), latitude, longitude);

  Future<void> goToImportIcs(String icsData) =>
      showImportIcs(AppRouters.of(this), icsData);

  Future<void> goToProfile() => showProfile(AppRouters.of(this));

  Future<void> finishOnboarding({required AppBranch landOn}) =>
      completeOnboarding(AppRouters.of(this), landOn: landOn);
}
