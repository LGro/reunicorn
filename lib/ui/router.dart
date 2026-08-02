// Copyright 2024 - 2026 The Reunicorn Authors. All rights reserved.
// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:kaisel/kaisel.dart';
import 'package:provider/provider.dart';

import '../veilid_processor/views/developer.dart';
import 'account_backup/page.dart';
import 'account_restore/page.dart';
import 'circle_details/page.dart';
import 'circles_list/page.dart';
import 'codec.dart';
import 'contact_details/link_to_system_contact/page.dart';
import 'contact_details/page.dart';
import 'contact_list/page.dart';
import 'create_new_contact/page.dart';
import 'dashboard/page.dart';
import 'import_ics/page.dart';
import 'introduce_contacts/page.dart';
import 'introductions/page.dart';
import 'legal/privacy_policy.dart';
import 'legal/terms_and_conditions.dart';
import 'locations/schedule/widget.dart';
import 'locations/share_location/widget.dart';
import 'map/list_page.dart';
import 'map/page.dart';
import 'profile/page.dart';
import 'receive_request/cubit.dart';
import 'receive_request/page.dart';
import 'routes.dart';
import 'settings/debug_info/page.dart';
import 'settings/licenses/page.dart';
import 'settings/page.dart';
import 'updates/page.dart';
import 'welcome.dart';
import 'widgets/import_calendar_event.dart';

const _navBarItems = [
  BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Dashboard'),
  BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
  BottomNavigationBarItem(
    icon: Icon(Icons.bubble_chart_outlined),
    label: 'Circles',
  ),
  BottomNavigationBarItem(icon: Icon(Icons.contacts), label: 'Contacts'),
  BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Map'),
];

/// Owns every router in the app.
///
/// The branch routers are held here rather than by the shell (which is what
/// `KaiselBranchedShell.specs` would do) because navigation crosses branches
/// constantly — opening a contact from the dashboard, the map or a circle.
/// A shell-owned router is only reachable from inside its own branch, so the
/// app has to hold the typed references itself.
class AppRouters {
  AppRouters({required bool isFirstRun})
    : hasProfile = ValueNotifier<bool>(!isFirstRun) {
    dashboard = KaiselRouter<DashboardRoute>(initial: const DashboardView());
    profile = KaiselRouter<ProfileRoute>(initial: const ProfileHome());
    circles = KaiselRouter<CirclesRoute>(initial: const CirclesList());
    contacts = KaiselRouter<ContactsRoute>(initial: const ContactList());
    map = KaiselRouter<MapRoute>(initial: const MapView());

    shell = BranchedShellRouter(
      branches: [dashboard, profile, circles, contacts, map],
      // Returning users used to land on `/profile`.
      initialBranch: AppBranch.profile.index,
    );

    config = KaiselRouterConfig<AppRoute>(
      initial: isFirstRun ? const Welcome() : const ShellHost(),
      builder: _buildRootScreen,
      guards: [_firstRunGuard],
      codec: const AppCodec(),
      fallback: const [ShellHost()],
      androidPredictiveBack: true,
      restorationScopeId: 'reunicorn-main',
    );
  }

  /// Whether a profile exists yet. Seeded from the profile lookup in
  /// `main.dart` and flipped once onboarding or a restore completes; the
  /// first-run guard reads it on every stack mutation.
  final ValueNotifier<bool> hasProfile;

  late final KaiselRouter<DashboardRoute> dashboard;
  late final KaiselRouter<ProfileRoute> profile;
  late final KaiselRouter<CirclesRoute> circles;
  late final KaiselRouter<ContactsRoute> contacts;
  late final KaiselRouter<MapRoute> map;
  late final BranchedShellRouter shell;
  late final KaiselRouterConfig<AppRoute> config;

  /// The root stack's router.
  KaiselRouter<AppRoute> get root => config.router;

  static AppRouters of(BuildContext context) =>
      Provider.of<AppRouters>(context, listen: false);

  /// Until a profile exists, every stack resolves back to onboarding. This
  /// replaces the old one-shot `initialLocation`, which could be navigated
  /// away from.
  List<AppRoute> _firstRunGuard(
    List<AppRoute> current,
    List<AppRoute> proposed,
  ) {
    if (hasProfile.value) return proposed;
    // Judge the destination, not the whole stack: Welcome sits at the bottom
    // during onboarding, so an `any` check here would allow everything.
    return switch (proposed.last) {
      Welcome() || RestoreBackup() || Terms() || Privacy() => proposed,
      _ => [const Welcome()],
    };
  }

  void dispose() {
    config.dispose();
    shell.dispose();
    dashboard.dispose();
    profile.dispose();
    circles.dispose();
    contacts.dispose();
    map.dispose();
    hasProfile.dispose();
  }

  Widget _buildRootScreen(BuildContext context, AppRoute route) =>
      switch (route) {
        Welcome() => const WelcomeScreen(),
        RestoreBackup() => RestoreBackupPage(),
        Introductions() => const IntroductionsPage(),
        IntroduceContact(:final contact) => IntroduceContactsPage(
          contact: contact,
        ),
        Terms() => const TermsAndConditions(),
        Privacy() => const PrivacyPolicy(),
        NotFound(:final uri) => _NotFoundScreen(uri: uri),
        ShellHost() => _buildShell(),
      };

  Widget _buildShell() => KaiselBranchedShell(
    shell: shell,
    branches: [
      KaiselBranch<DashboardRoute>(
        router: dashboard,
        pageBuilder: (context, route) => switch (route) {
          DashboardView() => const DashboardPage(),
          Updates() => const UpdatesPage(),
          Settings() => const SettingsPage(),
          ManageBackup() => const ManageBackupPage(),
          Licenses() => const LicensesPage(),
          DebugInfo() => const DebugInfoPage(),
          Developer() => const DeveloperPage(),
        },
      ),
      KaiselBranch<ProfileRoute>(
        router: profile,
        pageBuilder: (context, route) => switch (route) {
          ProfileHome() => const ProfilePage(),
        },
      ),
      KaiselBranch<CirclesRoute>(
        router: circles,
        pageBuilder: (context, route) => switch (route) {
          CirclesList() => const CirclesListPage(),
          CircleDetails(:final circleId) => CircleDetailsPage(
            circleId: circleId,
          ),
        },
      ),
      KaiselBranch<ContactsRoute>(
        router: contacts,
        pageBuilder: (context, route) => switch (route) {
          ContactList() => const ContactListPage(),
          ContactView(:final contact) => ContactPage(contact: contact),
          CreateNewContact() => const CreateNewContactPage(),
          LinkToSystemContact(:final coagContactId) => LinkToSystemContactPage(
            coagContactId: coagContactId,
          ),
          ReceiveRequest(:final status, :final fragment) => ReceiveRequestPage(
            initialState: ReceiveRequestState(status, fragment: fragment),
          ),
        },
      ),
      KaiselBranch<MapRoute>(
        router: map,
        pageBuilder: (context, route) => switch (route) {
          MapView(:final latitude, :final longitude) => MapPage(
            latitude: latitude,
            longitude: longitude,
          ),
          ImportIcs(:final icsData) => ImportIcsPage(icsData: icsData),
          LocationList() => const LocationListPage(),
          CalendarEvents() => const CalendarEventsPage(),
          ScheduleLocation(:final locationId, :final location) =>
            ScheduleWidget(locationId: locationId, location: location),
          ShareLocation(:final locationId, :final location) =>
            ShareLocationWidget(locationId: locationId, location: location),
        },
      ),
    ],
    chromeBuilder: (context, activeBranch, branchContent, switchBranch) =>
        Scaffold(
          body: branchContent,
          bottomNavigationBar: BottomNavigationBar(
            items: _navBarItems,
            type: BottomNavigationBarType.fixed,
            selectedItemColor: Theme.of(context).colorScheme.primary,
            selectedFontSize: 12,
            currentIndex: activeBranch,
            showUnselectedLabels: true,
            onTap: switchBranch,
          ),
        ),
  );
}

class _NotFoundScreen extends StatelessWidget {
  const _NotFoundScreen({required this.uri});

  final Uri uri;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Link not recognized')),
    body: Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.link_off, size: 48),
            const SizedBox(height: 16),
            const Text(
              "This link doesn't point anywhere in Reunicorn.",
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              '$uri',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () =>
                  context.router<AppRoute>().set(const [ShellHost()]),
              child: const Text('Go to Reunicorn'),
            ),
          ],
        ),
      ),
    ),
  );
}
