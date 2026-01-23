// Copyright 2024 - 2026 The Reunicorn Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../data/models/coag_contact.dart';
import '../../data/models/community.dart';
import '../../data/services/storage/base.dart';
import '../introduce_contacts/page.dart';
import '../utils.dart';
import 'cubit.dart';

class IntroductionListTile extends StatelessWidget {
  const IntroductionListTile({
    required this.introducerName,
    required this.otherName,
    required this.message,
    required this.acceptCallback,
    super.key,
  });

  final String introducerName;
  final String otherName;
  final String? message;
  final Future<String?> Function() acceptCallback;

  @override
  Widget build(BuildContext context) => ListTile(
    title: Text('$otherName via $introducerName', softWrap: true),
    subtitle: (message == null) ? null : Text(message!, softWrap: true),
    onTap: () => showDialog<void>(
      context: context,
      builder: (alertContext) => AlertDialog(
        titlePadding: const EdgeInsets.only(left: 16, right: 16, top: 16),
        title: Text('Accept introduction to $otherName'),
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
                final coagContactId = await acceptCallback();
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
                      content: Text('Accepting introduction failed.'),
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
      create: (context) => IntroductionsCubit(
        context.read<Storage<CoagContact>>(),
        context.read<Storage<Community>>(),
      ),
      child: BlocConsumer<IntroductionsCubit, IntroductionsState>(
        listener: (context, state) {},
        builder: (context, state) {
          final introductionTiles = [
            ...pendingIntroductions(state.contacts.values).map(
              (entry) => IntroductionListTile(
                introducerName: entry.$1.name,
                otherName: entry.$2.otherName,
                message: entry.$2.message,
                acceptCallback: () => context.read<IntroductionsCubit>().accept(
                  entry.$1,
                  entry.$2,
                ),
              ),
            ),
            ...pendingCommunityIntroductions(
              state.communities.values,
              state.contacts.values,
            ).map(
              (e) => IntroductionListTile(
                introducerName: e.$1 ?? 'Unknown Community',
                otherName: e.$2.name,
                message: e.$2.comment,
                // TODO(LGro): Implement community member add callback,
                // community dht repo might already have something to use
                acceptCallback: () => context
                    .read<IntroductionsCubit>()
                    .acceptCommunityMember(e.$2),
              ),
            ),
          ];
          return ListView(
            children: introductionTiles.isEmpty
                ? _noIntroductionsBody(context)
                : introductionTiles,
          );
        },
      ),
    ),
  );
}
