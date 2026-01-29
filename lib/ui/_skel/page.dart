// Copyright 2024 - 2025 The Reunicorn Authors. All rights reserved.
// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/coag_contact.dart';
import '../../data/services/storage/base.dart';
import 'cubit.dart';

class SkelWidget extends StatelessWidget {
  const SkelWidget({super.key});

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (context) => SkelCubit(context.read<Storage<CoagContact>>()),
    child: BlocConsumer<SkelCubit, SkelState>(
      listener: (context, state) {},
      builder: (context, state) => const SizedBox(),
    ),
  );
}
