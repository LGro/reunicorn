// Copyright 2024 - 2025 The Reunicorn Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/repositories/contacts.dart';
import '../../data/repositories/settings.dart';
import '../../notification_service.dart';
import '../batch_invite_management/page.dart';
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
          create: (_) => SettingsCubit(
            context.read<ContactsRepository>(),
            context.read<SettingsRepository>(),
          ),
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
                if (kDebugMode)
                  ListTile(
                    onTap: () async => Navigator.of(context).push(
                      MaterialPageRoute<BatchInvitesPage>(
                        builder: (_) => const BatchInvitesPage(),
                      ),
                    ),
                    title: const Text('Invitation batches'),
                    trailing: const Padding(
                      padding: EdgeInsets.only(right: 20),
                      child: Icon(Icons.arrow_right),
                    ),
                  ),
                ListTile(
                  title: const Text('Show open source licenses'),
                  trailing: const Padding(
                    padding: EdgeInsets.only(right: 20),
                    child: Icon(Icons.arrow_right),
                  ),
                  onTap: () async =>
                      Navigator.of(context).push(LicensesPage.route()),
                ),
                ListTile(
                  title: const Text('Show developer debug info'),
                  trailing: const Padding(
                    padding: EdgeInsets.only(right: 20),
                    child: Icon(Icons.arrow_right),
                  ),
                  onTap: () async =>
                      Navigator.of(context).push(DebugInfoPage.route()),
                ),
                if (kDebugMode)
                  ListTile(
                    title: const Text('Add dummy contact'),
                    onTap: blocContext.read<SettingsCubit>().addDummyContact,
                  ),
                if (kDebugMode)
                  ListTile(
                    title: const Text('Notify'),
                    onTap: () async => NotificationService().showNotification(
                      0,
                      'Simple Notification',
                      'This is a simple notification example.',
                    ),
                  ),
              ],
            ),
          ),
        ),
      );
}
