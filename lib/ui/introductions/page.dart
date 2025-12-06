// Copyright 2024 - 2025 The Reunicorn Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../data/models/coag_contact.dart';
import '../../data/models/contact_introduction.dart';
import '../../data/services/storage/base.dart';
import '../introduce_contacts/page.dart';
import '../utils.dart';
import 'cubit.dart';

class IntroductionListTile extends StatelessWidget {
  const IntroductionListTile({
    required this.introducer,
    required this.introduction,
    super.key,
  });

  final CoagContact introducer;
  final ContactIntroduction introduction;

  @override
  Widget build(BuildContext context) => ListTile(
    title: Text(
      '${introduction.otherName} via ${introducer.name}',
      softWrap: true,
    ),
    subtitle: (introduction.message == null)
        ? null
        : Text(introduction.message!, softWrap: true),
    onTap: () => showDialog<void>(
      context: context,
      builder: (alertContext) => AlertDialog(
        titlePadding: const EdgeInsets.only(left: 16, right: 16, top: 16),
        title: Text(
          'Accept introduction to '
          '${introduction.otherName}',
        ),
        actions: [
          const SizedBox(height: 4),
          Center(
            child: FilledButton.tonal(
              onPressed: alertContext.pop,
              child: const Text('Cancel'),
            ),
          ),
          const SizedBox(height: 4),
          Center(
            child: FilledButton(
              onPressed: () async {
                final coagContactId = await context
                    .read<IntroductionsCubit>()
                    .accept(introducer, introduction);
                if (context.mounted && coagContactId != null) {
                  context.goNamed(
                    'contactDetails',
                    pathParameters: {'coagContactId': coagContactId},
                  );
                  // FIXME: This doesn't seem to work correctly
                  alertContext.pop();
                } else if (context.mounted && coagContactId == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Accepting introduction failed. '
                        'Ask the introducer to send one again.',
                      ),
                    ),
                  );
                }
              },
              child: const Text('Accept & configure sharing'),
            ),
          ),
        ],
      ),
    ),
  );
}

class IntroductionsPage extends StatelessWidget {
  const IntroductionsPage({super.key});

  List<Widget> _noIntroductionsBody(BuildContext context) => [
    Container(
      padding: const EdgeInsets.all(20),
      child: const Text(
        'Nobody has introduced you to any of their contacts yet.',
        style: TextStyle(fontSize: 16),
      ),
    ),
    const SizedBox(height: 16),
    Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        FilledButton(
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute<IntroduceContactsPage>(
              builder: (context) => const IntroduceContactsPage(),
            ),
          ),
          child: const Text('Make an introduction'),
        ),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Introductions')),
    body: BlocProvider(
      create: (context) =>
          IntroductionsCubit(context.read<Storage<CoagContact>>()),
      child: BlocConsumer<IntroductionsCubit, IntroductionsState>(
        listener: (context, state) {},
        builder: (context, state) {
          final introductions = pendingIntroductions(state.contacts.values);
          return ListView(
            children: introductions.isEmpty
                ? _noIntroductionsBody(context)
                : introductions
                      .map(
                        (entry) => IntroductionListTile(
                          introducer: entry.$1,
                          introduction: entry.$2,
                        ),
                      )
                      .toList(),
          );
        },
      ),
    ),
  );
}
