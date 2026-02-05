// Copyright 2024 - 2026 The Reunicorn Authors. All rights reserved.
// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/repositories/backup_dht.dart';
import '../../data/repositories/settings.dart';
import '../../notification_service.dart';
import '../../veilid_processor/views/developer.dart';
import '../account_backup/page.dart';
import '../legal/privacy_policy.dart';
import '../legal/terms_and_conditions.dart';
import '../widgets/veilid_status/widget.dart';
import 'cubit.dart';
import 'debug_info/page.dart';
import 'licenses/page.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Settings')),
    body: BlocProvider(
      create: (_) => SettingsCubit(context.read<SettingsRepository>()),
      child: BlocConsumer<SettingsCubit, SettingsState>(
        listener: (context, state) => {},
        builder: (blocContext, state) => ListView(
          children: [
            const ListTile(
              title: Text('Network status'),
              trailing: Padding(
                padding: EdgeInsets.only(right: 4),
                child: VeilidStatusWidget(statusWidgets: {}),
              ),
            ),
            // TODO: Re-enable, add support in app.dart, and ask for app restart afterwards here
            //   ListTile(
            //       title: const Text('Dark mode'),
            //       trailing: Switch(
            //           value: state.darkMode,
            //           onChanged: blocContext
            //               .read<SettingsCubit>()
            //               .setDarkMode)),
            // TODO: Add option
            // const ListTile(title: Text('Set custom map server url')),
            // TODO: Move async things to cubit
            // if (Platform.isIOS) _backgroundPermissionStatus(),
            ListTile(
              title: const Text('Auto address resolution'),
              subtitle: const Text(
                'Resolve addresses when selecting locations on map',
              ),
              trailing: Switch(
                value: state.autoAddressResolution,
                onChanged:
                    blocContext.read<SettingsCubit>().setAutoAddressResolution,
              ),
            ),
            ListTile(
              // TODO: Prettier format
              title: Text(
                'Backup ${context.read<BackupRepository>().mostRecentBackupTime?.toIso8601String() ?? ''}',
              ),
              trailing: const Padding(
                padding: EdgeInsets.only(right: 20),
                child: Icon(Icons.arrow_right),
              ),
              // TODO: navigate via go router
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<ManageBackupPage>(
                  builder: (_) => const ManageBackupPage(),
                ),
              ),
            ),
            ListTile(
              title: const Text('Show open source licenses'),
              trailing: const Padding(
                padding: EdgeInsets.only(right: 20),
                child: Icon(Icons.arrow_right),
              ),
              onTap: () => Navigator.of(context).push(LicensesPage.route()),
            ),
            ListTile(
              title: const Text('Show Reunicorn debug info'),
              trailing: const Padding(
                padding: EdgeInsets.only(right: 20),
                child: Icon(Icons.arrow_right),
              ),
              onTap: () => Navigator.of(context).push(DebugInfoPage.route()),
            ),
            ListTile(
              title: const Text('Show Veilid debug info'),
              trailing: const Padding(
                padding: EdgeInsets.only(right: 20),
                child: Icon(Icons.arrow_right),
              ),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<DeveloperPage>(
                  builder: (_) => const DeveloperPage(),
                ),
              ),
            ),
            if (kDebugMode)
              ListTile(
                title: const Text('Add dummy contact'),
                onTap: blocContext.read<SettingsCubit>().addDummyContact,
              ),
            if (kDebugMode)
              ListTile(
                title: const Text('Notify'),
                onTap: () => NotificationService().showNotification(
                  0,
                  'Simple Notification',
                  'This is a simple notification example.',
                ),
              ),

            ListTile(
              title: const Text('Terms and conditions'),
              trailing: const Padding(
                padding: EdgeInsets.only(right: 20),
                child: Icon(Icons.arrow_right),
              ),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<TermsAndConditions>(
                  fullscreenDialog: true,
                  builder: (context) => const TermsAndConditions(),
                ),
              ),
            ),
            ListTile(
              title: const Text('Privacy policy'),
              trailing: const Padding(
                padding: EdgeInsets.only(right: 20),
                child: Icon(Icons.arrow_right),
              ),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<PrivacyPolicy>(
                  fullscreenDialog: true,
                  builder: (context) => const PrivacyPolicy(),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
