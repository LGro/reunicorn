// Copyright 2025 The Reunicorn Authors. All rights reserved.
// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'cubit.dart';

class VeilidStatusWidget extends StatelessWidget {
  const VeilidStatusWidget({required this.statusWidgets, super.key});

  final Map<String, Widget> statusWidgets;

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (context) => VeilidStatusCubit(),
    child: BlocBuilder<VeilidStatusCubit, VeilidStatusState>(
      builder: (context, state) =>
          // TODO: Replace default with const SizedBox.shrink()
          statusWidgets[state.status] ?? Text(state.status),
    ),
  );
}
