// Copyright 2024 - 2025 The Reunicorn Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'privacy_policy.dart';
import 'terms_and_conditions.dart';
import 'utils.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen(this.setInitialInfoCallback, {super.key});

  final Future<void> Function({
    required String name,
    required String bootstrapUrl,
  })
  setInitialInfoCallback;

  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _bootstrapServerController =
      TextEditingController();

  Future<void> _onSubmit() async {
    if (_nameController.text.isNotEmpty) {
      await widget.setInitialInfoCallback(
        name: _nameController.text.trim(),
        bootstrapUrl: _bootstrapServerController.text.trim(),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.loc.welcomeErrorNameMissing)),
      );
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Padding(
      padding: const EdgeInsets.all(16),
      child: LayoutBuilder(
        builder: (context, constraints) => SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: IntrinsicHeight(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Expanded(child: SizedBox()),
                  const SizedBox(height: 16),
                  Text(
                    context.loc.welcomeHeadline,
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    context.loc.welcomeText,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: context.loc.name.capitalize(),
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Align(
                    alignment: Alignment.centerRight,
                    child: FilledButton(
                      onPressed: _onSubmit,
                      child: Text(context.loc.welcomeCallToActionButton),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Expanded(child: SizedBox()),
                  const Text(
                    'Disclaimer: Reunicorn is still beta software, things '
                    'might break, please tell us about these cases. '
                    'Also, privacy and security are implemented diligently '
                    'but have not been audited by an independent third '
                    'party yet.',
                    softWrap: true,
                  ),
                  const Expanded(child: SizedBox()),
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      text: 'These ',
                      style: DefaultTextStyle.of(context).style,
                      children: [
                        TextSpan(
                          text: 'terms and conditions',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            decoration: TextDecoration.underline,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () => Navigator.of(context).push(
                              MaterialPageRoute<TermsAndConditions>(
                                fullscreenDialog: true,
                                builder: (context) =>
                                    const TermsAndConditions(),
                              ),
                            ),
                        ),
                        const TextSpan(text: ' and '),
                        TextSpan(
                          text: 'privacy policy',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            decoration: TextDecoration.underline,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () => Navigator.of(context).push(
                              MaterialPageRoute<PrivacyPolicy>(
                                fullscreenDialog: true,
                                builder: (context) => const PrivacyPolicy(),
                              ),
                            ),
                        ),
                        const TextSpan(text: ' apply.'),
                      ],
                    ),
                  ),
                  // TextField(
                  //   controller: _bootstrapServerController,
                  //   decoration: const InputDecoration(
                  //     labelText: 'Custom Veilid bootstrap URL',
                  //     border: OutlineInputBorder(),
                  //   ),
                  // ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
