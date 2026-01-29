// Copyright 2026 The Reunicorn Authors. All rights reserved.
// SPDX-License-Identifier: AGPL-3.0-or-later

List<(String, String, bool, int)> circlesWithStatus({
  required Map<String, String> circles,
  required Map<String, List<String>> circleMemberships,
  required List<String> detailSharingSettingsForLabel,
  require,
}) => circles
    .map(
      (cId, cLabel) => MapEntry(cId, (
        cId,
        cLabel,
        detailSharingSettingsForLabel.contains(cId),
        circleMemberships.values
            .where((circles) => circles.contains(cId))
            .length,
      )),
    )
    .values
    .toList();
