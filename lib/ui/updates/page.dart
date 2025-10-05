// Copyright 2024 - 2025 The Reunicorn Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../data/models/coag_contact.dart';
import '../../data/repositories/contacts.dart';
import '../utils.dart';
import 'cubit.dart';

String formatTimeDifference(Duration d) {
  if (d.isNegative || d < const Duration(minutes: 1)) {
    return 'now';
  }
  if (d < const Duration(hours: 1)) {
    return '${d.inMinutes}m';
  }
  if (d < const Duration(days: 1)) {
    return '${d.inHours}h';
  }
  return '${d.inDays}d';
}

String getContactNameForUpdate(CoagContact oldContact, CoagContact newContact) {
  if (newContact.name.isNotEmpty && newContact.name != '???') {
    return newContact.name;
  }
  if (oldContact.name.isNotEmpty && oldContact.name != '???') {
    return oldContact.name;
  }
  final sharedName = (oldContact.details?.names.isNotEmpty ?? false)
      ? oldContact.details!.names.values.join(' / ')
      : newContact.details!.names.values.join(' / ');
  if (sharedName.isNotEmpty) {
    return sharedName;
  }
  return '???';
}

Widget updateTile(
  String name,
  String timing,
  String change, {
  required void Function()? onTap,
  List<int>? picture,
}) =>
    ListTile(
      onTap: onTap,
      leading: (picture == null || picture.isEmpty)
          ? const CircleAvatar(radius: 18, child: Icon(Icons.person))
          : CircleAvatar(
              backgroundImage: MemoryImage(Uint8List.fromList(picture)),
              radius: 18),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(child: Text(name, overflow: TextOverflow.ellipsis)),
          Text(timing),
        ],
      ),
      subtitle: Row(
        children: [
          // TODO: Use flexible for old and new value to trim them both dynamically
          // Or use Expanded for dynamic multiline
          Expanded(child: Text('Updated $change')),
        ],
      ),
    );

// updateTile(
//     'Ronja Dudeli van Makolle Longname The Fourth',
//     '(today)',
//     'Name: Timo => Ronja Dudeli van Makolle Longname The Fourth'),
// updateTile('Ronja Dudeli', '(4 days)',
//     'Will be near Hamburg, 2024-10-21 till 2024-10-28'),
// updateTile(
//     'Ronja Dudeli', '(5 days)', 'Started sharing with you'),
// updateTile('Timo Dudeli', '(1 month)',
//     'Home: Heimsheimer St... => Burgstraße 21, 81992 Heidelberg'),
// updateTile('Helli Schmudela', '(2 years)',
//     'Work: +3011311411 => +2144242200'),]

class UpdatesPage extends StatelessWidget {
  const UpdatesPage({super.key});

  @override
  Widget build(BuildContext context) => BlocProvider(
      create: (ctx) => UpdatesCubit(ctx.read<ContactsRepository>()),
      child: Builder(
        builder: (context) => Scaffold(
          appBar: AppBar(title: const Text('Updates')),
          body: RefreshIndicator(
            onRefresh: () async => context.read<UpdatesCubit>().refresh().then(
                  (success) => context.mounted
                      ? (success
                          ? ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Successfully refreshed!'),
                              ),
                            )
                          : ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Refreshing failed, try again later!',
                                ),
                              ),
                            ))
                      : null,
                ),
            child: BlocConsumer<UpdatesCubit, UpdatesState>(
              listener: (context, state) {},
              builder: (context, state) => ListView(
                children: (state.updates.isEmpty)
                    ? [
                        Container(
                          padding: const EdgeInsets.all(20),
                          child: const Text(
                            'No updates yet, share with others or ask others to share with you!',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ]
                    : state.updates
                        .map(
                          (u) => updateTile(
                            getContactNameForUpdate(u.oldContact, u.newContact),
                            formatTimeDifference(
                                DateTime.now().difference(u.timestamp)),
                            contactUpdateSummary(u.oldContact, u.newContact),
                            // TODO: For location updates, bring to map, centered around location with time slider at right time instead
                            onTap: (u.coagContactId == null)
                                ? null
                                : () {
                                    final contact = context
                                        .read<ContactsRepository>()
                                        .getContact(u.coagContactId!);
                                    if (contact == null) {
                                      // TODO: display error?
                                      return;
                                    }
                                    context.goNamed('contactDetails',
                                        pathParameters: {
                                          'coagContactId': contact.coagContactId
                                        });
                                  },
                            picture: u.newContact.details?.picture,
                          ),
                        )
                        .toList(),
              ),
            ),
          ),
        ),
      ));
}
