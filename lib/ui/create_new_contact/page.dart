// Copyright 2024 - 2026 The Reunicorn Authors. All rights reserved.
// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:reunicorn/data/repositories/contact_dht.dart';

class CreateNewContactPage extends StatefulWidget {
  const CreateNewContactPage({super.key});

  @override
  _CreateNewContactPageState createState() => _CreateNewContactPageState();
}

class _CreateNewContactPageState extends State<CreateNewContactPage> {
  final _nameController = TextEditingController();

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Create invite')),
    body: Padding(
      padding: const EdgeInsets.only(left: 16, right: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // const Text('Already have them in your address book?'),
          // const SizedBox(height: 4),
          // Align(
          //     alignment: Alignment.center,
          //     child: FilledButton(
          //         onPressed: () {}, child: Text('Pick from address book'))),
          // const SizedBox(height: 16),
          // const Text('or provide their Reunicorn link'),
          // const SizedBox(height: 4),
          // On submit also use createContactForInvite but include pubkey
          // TextField(
          //   controller: TextEditingController(text: ''),
          //   onChanged: (value) {},
          //   autofocus: true,
          //   autocorrect: false,
          //   decoration: const InputDecoration(border: OutlineInputBorder()),
          // ),
          // const SizedBox(height: 16),
          const Text('Just provide their name'),
          const SizedBox(height: 4),
          TextField(
            controller: _nameController,
            autofocus: true,
            autocorrect: false,
            decoration: const InputDecoration(border: OutlineInputBorder()),
          ),
          const SizedBox(height: 4),
          Align(
            alignment: Alignment.center,
            child: FilledButton(
              onPressed: () async {
                final contact = await context
                    .read<ContactDhtRepository>()
                    .createContactForInvite(_nameController.text.trim());
                if (context.mounted) {
                  context.goNamed('contactDetails', extra: contact);
                }
              },
              child: const Text('Prepare invite'),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    ),
  );
}
