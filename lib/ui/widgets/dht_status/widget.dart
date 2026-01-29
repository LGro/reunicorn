// Copyright 2025 The Reunicorn Authors. All rights reserved.
// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:veilid/veilid.dart';

import 'cubit.dart';

class DhtStatusWidget extends StatelessWidget {
  const DhtStatusWidget({
    required this.statusWidgets,
    required this.recordKey,
    super.key,
  });

  final Map<String, Widget> statusWidgets;
  final RecordKey recordKey;

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (context) => DhtStatusCubit(recordKey: recordKey),
    child: BlocBuilder<DhtStatusCubit, DhtStatusState>(
      builder: (context, state) =>
          // TODO: Replace default with const SizedBox.shrink()
          statusWidgets[state.status] ?? Text(state.status),
    ),
  );
}
