// Copyright 2024 - 2026 The Reunicorn Authors. All rights reserved.
// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:kaisel/kaisel.dart';

import '../data/models/coag_contact.dart';
import '../data/models/contact_location.dart';
import 'receive_request/cubit.dart' show ReceiveRequestStatus;

/// The branches of the bottom navigation shell, in display order.
///
/// The index is what [BranchedShellRouter.switchTo] takes, so the order here
/// is the single source of truth for both the nav bar items and the codec.
enum AppBranch { dashboard, profile, circles, contacts, map }

// -----------------------------------------------------------------------
// Root stack
// -----------------------------------------------------------------------

/// Routes on the root stack. Everything here renders fullscreen, without the
/// bottom navigation bar. Routes reachable from more than one branch live
/// here so they don't force a jarring tab switch.
sealed class AppRoute extends KaiselRoute {
  const AppRoute();
}

final class Welcome extends AppRoute {
  const Welcome();
}

final class RestoreBackup extends AppRoute {
  const RestoreBackup();
}

final class Introductions extends AppRoute {
  const Introductions();
}

final class IntroduceContact extends AppRoute {
  const IntroduceContact([this.contact]);

  final CoagContact? contact;

  @override
  List<Object?> get props => [contact];
}

final class Terms extends AppRoute {
  const Terms();
}

final class Privacy extends AppRoute {
  const Privacy();
}

/// Replaces go_router's `errorBuilder`: an unrecognized URL decodes to this
/// route, so a bad deep link is a screen we control rather than a crash.
final class NotFound extends AppRoute {
  const NotFound(this.uri);

  final Uri uri;

  @override
  List<Object?> get props => [uri];
}

/// Hosts the branched shell (bottom navigation bar + the five branches).
final class ShellHost extends AppRoute {
  const ShellHost();
}

// -----------------------------------------------------------------------
// Branch 0: dashboard
// -----------------------------------------------------------------------

sealed class DashboardRoute extends KaiselRoute {
  const DashboardRoute();
}

final class DashboardView extends DashboardRoute {
  const DashboardView();
}

final class Updates extends DashboardRoute {
  const Updates();
}

final class Settings extends DashboardRoute {
  const Settings();
}

final class ManageBackup extends DashboardRoute {
  const ManageBackup();
}

final class Licenses extends DashboardRoute {
  const Licenses();
}

final class DebugInfo extends DashboardRoute {
  const DebugInfo();
}

final class Developer extends DashboardRoute {
  const Developer();
}

// -----------------------------------------------------------------------
// Branch 1: profile
// -----------------------------------------------------------------------

sealed class ProfileRoute extends KaiselRoute {
  const ProfileRoute();
}

final class ProfileHome extends ProfileRoute {
  const ProfileHome();
}

// -----------------------------------------------------------------------
// Branch 2: circles
// -----------------------------------------------------------------------

sealed class CirclesRoute extends KaiselRoute {
  const CirclesRoute();
}

final class CirclesList extends CirclesRoute {
  const CirclesList();
}

final class CircleDetails extends CirclesRoute {
  const CircleDetails(this.circleId);

  final String circleId;

  @override
  List<Object?> get props => [circleId];
}

// -----------------------------------------------------------------------
// Branch 3: contacts
// -----------------------------------------------------------------------

sealed class ContactsRoute extends KaiselRoute {
  const ContactsRoute();
}

final class ContactList extends ContactsRoute {
  const ContactList();
}

/// Carries the whole contact, so it cannot round-trip through a URL. The
/// codec encodes it best-effort as `/contacts`.
final class ContactView extends ContactsRoute {
  const ContactView(this.contact);

  final CoagContact contact;

  @override
  List<Object?> get props => [contact];
}

final class CreateNewContact extends ContactsRoute {
  const CreateNewContact();
}

final class LinkToSystemContact extends ContactsRoute {
  const LinkToSystemContact(this.coagContactId);

  final String coagContactId;

  @override
  List<Object?> get props => [coagContactId];
}

/// The single route behind the `/c`, `/p`, `/o` and `/i` deep links. Which
/// link arrived is carried by [status]; the payload rides in [fragment].
final class ReceiveRequest extends ContactsRoute {
  const ReceiveRequest(this.status, {this.fragment});

  final ReceiveRequestStatus status;
  final String? fragment;

  @override
  List<Object?> get props => [status, fragment];
}

// -----------------------------------------------------------------------
// Branch 4: map
// -----------------------------------------------------------------------

sealed class MapRoute extends KaiselRoute {
  const MapRoute();
}

/// Covers both the plain map and the old `/mapAtLocation/:lat/:lng` route.
final class MapView extends MapRoute {
  const MapView({this.latitude, this.longitude});

  final double? latitude;
  final double? longitude;

  @override
  List<Object?> get props => [latitude, longitude];
}

final class ImportIcs extends MapRoute {
  const ImportIcs(this.icsData);

  final String icsData;

  @override
  List<Object?> get props => [icsData];
}

final class LocationList extends MapRoute {
  const LocationList();
}

/// Opened with `pushForResult<ETEvent>`; the picked event comes back via
/// `context.pop(event)`.
final class CalendarEvents extends MapRoute {
  const CalendarEvents();
}

/// Scheduling a location. Both fields travel together and are both optional:
/// [location] prefills the form, [locationId] names the entry to overwrite
/// (absent means a new one). Carrying a location makes this in-app only, so
/// the codec encodes it back to plain `/map`.
final class ScheduleLocation extends MapRoute {
  const ScheduleLocation({this.locationId, this.location});

  final String? locationId;
  final ContactTemporaryLocation? location;

  @override
  List<Object?> get props => [locationId, location];
}

/// Sharing a location — same shape as [ScheduleLocation].
final class ShareLocation extends MapRoute {
  const ShareLocation({this.locationId, this.location});

  final String? locationId;
  final ContactTemporaryLocation? location;

  @override
  List<Object?> get props => [locationId, location];
}
