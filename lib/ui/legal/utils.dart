// Copyright 2025 - 2026 The Reunicorn Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

import 'package:flutter/widgets.dart';

Widget headline(String number, String text) => Padding(
  padding: const EdgeInsets.only(top: 8, bottom: 4),
  child: Text(
    (number.isEmpty) ? text : '$number $text',
    style: const TextStyle(fontWeight: FontWeight.bold),
  ),
);

Text firstBoldThenNormal(String first, String rest) => Text.rich(
  TextSpan(
    children: [
      if (first.isNotEmpty)
        TextSpan(
          text: first,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      if (rest.isNotEmpty) TextSpan(text: rest),
    ],
  ),
);
