// Copyright 2024 - 2025 The Reunicorn Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/repositories/contacts.dart';
import 'cubit.dart';

class SkelWidget extends StatelessWidget {
  const SkelWidget({super.key});

  @override
  Widget build(BuildContext context) => BlocProvider(
      create: (context) => SkelCubit(context.read<ContactsRepository>()),
      child: BlocConsumer<SkelCubit, SkelState>(
          listener: (context, state) async {},
          builder: (context, state) => const SizedBox()));
}
