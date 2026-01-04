// Copyright 2024 - 2026 The Reunicorn Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:share_plus/share_plus.dart';

import '../../data/repositories/backup_dht.dart';
import 'cubit.dart';

class ManageBackupPage extends StatelessWidget {
  const ManageBackupPage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Backup')),
    body: BlocProvider(
      create: (context) => BackupCubit(context.read<BackupRepository>()),
      child: BlocConsumer<BackupCubit, BackupState>(
        listener: (context, state) => {},
        builder: (context, state) => SingleChildScrollView(
          padding: const EdgeInsets.only(left: 16, right: 16),
          child: Column(
            children: [
              // TODO: Persisted backup case: Already created backup -> still up to date, awesome; outdated and broken, omg!
              const Text(
                'Here, you can create a backup of your Reunicorn account. '
                'This is helpful to avoid losing your contacts when your '
                'phone breaks or is stolen. Also, it is a great way to '
                'migrate your data when you switch to a different phone.',
              ),
              const SizedBox(height: 8),
              if (state.status.isInitial || state.status.isFailure)
                FilledButton(
                  onPressed: context.read<BackupCubit>().backup,
                  child: const Text('Backup'),
                )
              else if (state.status.isCreate) ...[
                const CircularProgressIndicator(),
                const Text(
                  'Wait until your backup creation is complete to store '
                  'the displayed information for recovery.',
                ),
              ] else if (state.status.isSuccess) ...[
                const Text(
                  'Store this somewhere safe, separate from your phone, '
                  'where only you can access it:',
                ),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${state.dhtRecordKey}~${state.secret}',
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      onPressed: () => SharePlus.instance.share(
                        ShareParams(
                          text: '${state.dhtRecordKey}~${state.secret}',
                        ),
                      ),
                      icon: const Icon(Icons.copy),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 8),
              if (state.status.isFailure)
                const Text('Creating a backup failed, try again later.'),
            ],
          ),
        ),
      ),
    ),
  );
}
