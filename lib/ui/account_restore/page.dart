// Copyright 2024 - 2026 The Reunicorn Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:veilid/veilid.dart';

import '../../data/repositories/backup_dht.dart';
import 'cubit.dart';

class RestoreBackupPage extends StatelessWidget {
  RestoreBackupPage({super.key});

  final _textFieldKey = GlobalKey<FormFieldState<String>>();

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Backup')),
    body: BlocProvider(
      create: (context) => RestoreCubit(context.read<BackupRepository>()),
      child: BlocConsumer<RestoreCubit, RestoreState>(
        listener: (context, state) => {
          if (state.status.isSuccess) {context.pushReplacementNamed('profile')},
        },
        builder: (context, state) => SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: switch (state.status) {
            RestoreStatus.attaching => const Center(
              child: Text(
                'Connecting to the network, please wait.',
                textScaler: TextScaler.linear(1.2),
              ),
            ),
            RestoreStatus.restoring => const Center(
              child: Text(
                'Restoring backup, please wait.',
                textScaler: TextScaler.linear(1.2),
              ),
            ),
            RestoreStatus.ready || RestoreStatus.failure => Column(
              children: [
                if (state.status.isFailure)
                  const Text('Backup restoration failed.'),
                const Text(
                  'Did you already use Reunicorn before and have a backup '
                  'secret to restore your profile and contacts? Then paste it '
                  'here:',
                  textScaler: TextScaler.linear(1.2),
                ),
                TextFormField(
                  key: _textFieldKey,
                  onChanged: (v) {
                    if (_textFieldKey.currentState?.validate() ?? false) {}
                  },
                  validator: (value) {
                    if (value == null) {
                      return null;
                    }
                    final splits = value.split('~');
                    if (splits.length != 2) {
                      return 'Invalid backup secret.';
                    }
                    try {
                      final recordKey = RecordKey.fromString(splits.first);
                      final secret = SharedSecret.fromString(splits.last);
                      unawaited(
                        context.read<RestoreCubit>().restore(recordKey, secret),
                      );
                    } on Exception {
                      return 'Invalid backup secret.';
                    }
                    return null;
                  },
                ),
              ],
            ),
            _ => const SizedBox(),
          },
        ),
      ),
    ),
  );
}
