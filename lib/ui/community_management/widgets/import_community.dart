// Copyright 2024 - 2026 The Reunicorn Authors. All rights reserved.
// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/models/community.dart';
import '../cubit.dart';

class ImportCommunity extends StatelessWidget {
  const ImportCommunity({super.key});

  @override
  Widget build(BuildContext context) => IconButton(
    icon: const Icon(Icons.upload_file),
    onPressed: () async {
      final result = await showDialog<String>(
        context: context,
        builder: (context) {
          final jsonController = TextEditingController();
          return AlertDialog(
            title: const Text('Import Community Management JSON'),
            content: ElevatedButton.icon(
              icon: const Icon(Icons.upload_file),
              label: const Text('Pick JSON file'),
              onPressed: () async {
                final result = await FilePicker.platform.pickFiles(
                  type: FileType.custom,
                  allowedExtensions: ['json'],
                );
                if (result != null &&
                    result.files.single.bytes != null &&
                    context.mounted) {
                  final jsonString = utf8.decode(result.files.single.bytes!);
                  Navigator.of(context).pop(jsonString);
                }
              },
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(jsonController.text),
                child: const Text('Import'),
              ),
            ],
          );
        },
      );
      if (result != null && result.trim().isNotEmpty) {
        try {
          final jsonMap = jsonDecode(result.trim()) as Map<String, dynamic>;
          if (context.mounted) {
            context.read<CommunityManagementCubit>().import(
              ManagedCommunity.fromJson(jsonMap),
            );
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Imported successfully')),
            );
          }
        } catch (e) {
          if (context.mounted) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('Failed to import: $e')));
          }
        }
      }
    },
  );
}
