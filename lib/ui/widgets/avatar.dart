// Copyright 2024 The Reunicorn Authors. All rights reserved.
// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';

Widget avatar(
  Contact? contact, {
  double radius = 48.0,
  IconData defaultIcon = Icons.person,
}) {
  if (contact?.photoOrThumbnail != null) {
    return CircleAvatar(
      backgroundImage: MemoryImage(contact!.photoOrThumbnail!),
      radius: radius,
    );
  }
  return CircleAvatar(radius: radius, child: Icon(defaultIcon));
}
