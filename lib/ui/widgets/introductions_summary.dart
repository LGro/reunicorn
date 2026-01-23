// Copyright 2026 The Reunicorn Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

import 'package:flutter/material.dart';

class IntroductionsSummary extends StatelessWidget {
  final List<(String, bool)> _introducedContactsWithReadStatus;

  const IntroductionsSummary(
    this._introducedContactsWithReadStatus, {
    super.key,
  });

  int _numIntros() => _introducedContactsWithReadStatus.length;
  int _numPending() =>
      _introducedContactsWithReadStatus.where((i) => !i.$2).length;
  String _pendingNames() => _introducedContactsWithReadStatus
      .where((i) => !i.$2)
      .map((i) => i.$1)
      .join(', ');

  @override
  Widget build(BuildContext context) => (_numIntros() == 0)
      ? const SizedBox()
      : ListTile(
          title: const Text('Introductions'),
          subtitle: Text(_pendingNames(), overflow: TextOverflow.ellipsis),
          trailing: Text('${_numPending()}/${_numIntros()}'),
        );
}
