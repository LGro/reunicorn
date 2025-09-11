// Copyright 2024 - 2025 The Reunicorn Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../ui/batch_invite_management/page.dart';
import '../veilid_init.dart';

class BatchManagementApp extends StatelessWidget {
  const BatchManagementApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Reunicorn Batch Invite Management',
        home: FutureProvider<AppGlobalInit?>(
          initialData: null,
          create: (context) async => AppGlobalInit.initialize(),
          // AppGlobalInit.initialize can throw Already attached VeilidAPIException which is fine
          catchError: (context, error) => null,
          builder: (context, child) => (context.watch<AppGlobalInit?>() == null)
              ? const Center(child: CircularProgressIndicator())
              : const BatchInvitesPage(),
        ),
      );
}
