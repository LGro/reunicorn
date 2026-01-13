// Copyright 2024 - 2025 The Reunicorn Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

// ignore_for_file: avoid_redundant_argument_values

import 'package:flutter_test/flutter_test.dart';
import 'package:reunicorn/data/models/close_by_match.dart';
import 'package:reunicorn/data/models/contact_location.dart';

void main() {
  group('test getOverlapOrOffset ', () {
    test('1 ends before 2 begins', () {
      final (start, end, offset) = getOverlapOrOffset(
        start1: DateTime(1, 1, 1),
        end1: DateTime(1, 1, 2),
        start2: DateTime(1, 1, 3),
        end2: DateTime(1, 1, 4),
      );
      expect(start, DateTime(1, 1, 3));
      expect(end, DateTime(1, 1, 4));
      expect(offset, const Duration(days: 1));
    });

    test('2 ends before 1 begins', () {
      final (start, end, offset) = getOverlapOrOffset(
        start1: DateTime(1, 1, 3),
        end1: DateTime(1, 1, 4),
        start2: DateTime(1, 1, 1),
        end2: DateTime(1, 1, 2),
      );
      expect(start, DateTime(1, 1, 1));
      expect(end, DateTime(1, 1, 2));
      expect(offset, const Duration(days: -1));
    });

    test('perfect overlap', () {
      final (start, end, offset) = getOverlapOrOffset(
        start1: DateTime(1),
        end1: DateTime(2),
        start2: DateTime(1),
        end2: DateTime(2),
      );
      expect(start, DateTime(1));
      expect(end, DateTime(2));
      expect(offset, Duration.zero);
    });

    test('1 within 2', () {
      final (start, end, offset) = getOverlapOrOffset(
        start1: DateTime(1, 1, 2),
        end1: DateTime(1, 1, 3),
        start2: DateTime(1, 1, 1),
        end2: DateTime(1, 1, 4),
      );
      expect(start, DateTime(1, 1, 2));
      expect(end, DateTime(1, 1, 3));
      expect(offset, Duration.zero);
    });

    test('2 within 1', () {
      final (start, end, offset) = getOverlapOrOffset(
        start1: DateTime(1, 1, 1),
        end1: DateTime(1, 1, 4),
        start2: DateTime(1, 1, 2),
        end2: DateTime(1, 1, 3),
      );
      expect(start, DateTime(1, 1, 2));
      expect(end, DateTime(1, 1, 3));
      expect(offset, Duration.zero);
    });

    test('1 overlaps into 2', () {
      final (start, end, offset) = getOverlapOrOffset(
        start1: DateTime(1, 1, 1),
        end1: DateTime(1, 1, 3),
        start2: DateTime(1, 1, 2),
        end2: DateTime(1, 1, 4),
      );
      expect(start, DateTime(1, 1, 2));
      expect(end, DateTime(1, 1, 3));
      expect(offset, Duration.zero);
    });

    test('2 overlaps into 1', () {
      final (start, end, offset) = getOverlapOrOffset(
        start1: DateTime(1, 1, 2),
        end1: DateTime(1, 1, 4),
        start2: DateTime(1, 1, 1),
        end2: DateTime(1, 1, 3),
      );
      expect(start, DateTime(1, 1, 2));
      expect(end, DateTime(1, 1, 3));
      expect(offset, Duration.zero);
    });
  });

  test('test closeByAddressWithTemporary', () {
    final matches = closeByAddressWithTemporary(
      myAddressLocations: {
        'myAddr1': const ContactAddressLocation(latitude: 1, longitude: 1),
      },
      theirTemporaryLocations: {
        'theirAddr1': ContactTemporaryLocation(
          name: 'theirAddr1Label',
          latitude: 1,
          longitude: 1,
          start: DateTime(2000),
          end: DateTime(2001),
          details: '',
        ),
      },
      timeThreshold: Duration.zero,
      distanceThresholdKm: 0.1,
      mySharedLocationIds: const {},
      coagContactId: '1',
      theirName: 'contactName',
    );

    expect(matches, hasLength(1));
    expect(
      matches.first,
      CloseByMatch(
        myLocationLabel: 'myAddr1',
        theirLocationLabel: 'theirAddr1Label',
        theirLocationId: 'theirAddr1',
        coagContactId: '1',
        coagContactName: 'contactName',
        start: DateTime(2000),
        end: DateTime(2001),
        offset: Duration.zero,
        theyKnow: false,
      ),
    );
  });
  test('test closeByTemporaryWithTemporary', () {
    final matches = closeByTemporaryWithTemporary(
      myTemporaryLocations: {
        'myAddr1': ContactTemporaryLocation(
          name: 'myAddr1Label',
          latitude: 1,
          longitude: 1,
          start: DateTime(2000),
          end: DateTime(2002),
          details: '',
        ),
      },
      theirTemporaryLocations: {
        'theirAddr1': ContactTemporaryLocation(
          name: 'theirAddr1Label',
          latitude: 1,
          longitude: 1,
          start: DateTime(2001),
          end: DateTime(2003),
          details: '',
        ),
      },
      timeThreshold: Duration.zero,
      distanceThresholdKm: 0.1,
      mySharedLocationIds: const {},
      coagContactId: '1',
      theirName: 'contactName',
    );

    expect(matches, hasLength(1));
    expect(
      matches.first,
      CloseByMatch(
        myLocationLabel: 'myAddr1Label',
        theirLocationLabel: 'theirAddr1Label',
        theirLocationId: 'theirAddr1',
        coagContactId: '1',
        coagContactName: 'contactName',
        start: DateTime(2001),
        end: DateTime(2002),
        offset: Duration.zero,
        theyKnow: false,
      ),
    );
  });

  test('test closeByTemporaryWithAddress overlap unknown', () {
    final matches = closeByTemporaryWithAddress(
      myTemporaryLocations: {
        'myAddr1': ContactTemporaryLocation(
          name: 'myAddr1Label',
          latitude: 1,
          longitude: 1,
          start: DateTime(2000),
          end: DateTime(2001),
          details: '',
        ),
      },
      theirAddressLocations: {
        'theirAddr1': const ContactAddressLocation(latitude: 1, longitude: 1),
      },
      timeThreshold: Duration.zero,
      distanceThresholdKm: 0.1,
      mySharedLocationIds: const {'unrelatedLocation'},
      coagContactId: '1',
      theirName: 'contactName',
    );

    expect(matches, hasLength(1));
    expect(
      matches.first,
      CloseByMatch(
        myLocationLabel: 'myAddr1Label',
        theirLocationLabel: 'theirAddr1',
        theirLocationId: 'theirAddr1',
        coagContactId: '1',
        coagContactName: 'contactName',
        start: DateTime(2000),
        end: DateTime(2001),
        offset: Duration.zero,
        theyKnow: false,
      ),
    );
  });

  test('test closeByTemporaryWithAddress overlap known', () {
    final matches = closeByTemporaryWithAddress(
      myTemporaryLocations: {
        'myAddr1': ContactTemporaryLocation(
          name: 'myAddr1Label',
          latitude: 1,
          longitude: 1,
          start: DateTime(2000),
          end: DateTime(2001),
          details: '',
        ),
      },
      theirAddressLocations: {
        'theirAddr1': const ContactAddressLocation(latitude: 1, longitude: 1),
      },
      timeThreshold: Duration.zero,
      distanceThresholdKm: 0.1,
      mySharedLocationIds: const {'myAddr1'},
      coagContactId: '1',
      theirName: 'contactName',
    );

    expect(matches, hasLength(1));
    expect(
      matches.first,
      CloseByMatch(
        myLocationLabel: 'myAddr1Label',
        theirLocationLabel: 'theirAddr1',
        theirLocationId: 'theirAddr1',
        coagContactId: '1',
        coagContactName: 'contactName',
        start: DateTime(2000),
        end: DateTime(2001),
        offset: Duration.zero,
        theyKnow: true,
      ),
    );
  });
}
