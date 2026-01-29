// Copyright 2026 The Reunicorn Authors. All rights reserved.
// SPDX-License-Identifier: AGPL-3.0-or-later

import 'utils.dart';

class Setting implements JsonEncodable {
  final Map<String, dynamic> _value;

  const Setting(this._value);

  Map<String, dynamic> get value => _value;

  @override
  Map<String, dynamic> toJson() => {..._value};
}
