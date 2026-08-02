// Copyright 2024 - 2026 The Reunicorn Authors. All rights reserved.
// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter_test/flutter_test.dart';
import 'package:kaisel/kaisel.dart';
import 'package:reunicorn/ui/codec.dart';
import 'package:reunicorn/ui/receive_request/cubit.dart'
    show ReceiveRequestStatus;
import 'package:reunicorn/ui/routes.dart';

/// The active branch's stack for a decoded config, or `null` when the config
/// doesn't land inside the shell.
({int branch, List<KaiselRoute> stack})? shellOf(
  KaiselConfig<AppRoute>? config,
) {
  final nested = config?.nestedState;
  if (nested is! KaiselShellConfig) return null;
  return (branch: nested.activeBranch, stack: nested.activeBranchStack);
}

void main() {
  const codec = AppCodec();

  group('deep links', () {
    // Fragments in the shape the builders in ui/utils.dart produce.
    const directFragment = 'Alice~VLD0:aabbcc~SECRET123';
    const profileFragment = 'Bob~VLD0:pubkey999';
    const offerFragment = 'Carol~VLD0:rec111~VLD0:pub222';
    const communityFragment = 'VLD0:rec333~VLD0:writer444';

    test('/c decodes to a direct sharing request on the contacts branch', () {
      final shell = shellOf(
        codec.decode(Uri.parse('https://reunicorn.app/c#$directFragment')),
      );

      expect(shell, isNotNull);
      expect(shell!.branch, AppBranch.contacts.index);
      // Breadcrumb, so back from a cold deep link lands on the contact list.
      expect(shell.stack.first, const ContactList());
      expect(
        shell.stack.last,
        const ReceiveRequest(
          ReceiveRequestStatus.handleDirectSharing,
          fragment: directFragment,
        ),
      );
    });

    test('/p, /o and /i map onto their request statuses', () {
      final cases = {
        '/p#$profileFragment': (
          ReceiveRequestStatus.handleProfileLink,
          profileFragment,
        ),
        '/o#$offerFragment': (
          ReceiveRequestStatus.handleSharingOffer,
          offerFragment,
        ),
        '/i#$communityFragment': (
          ReceiveRequestStatus.handleCommunityInvite,
          communityFragment,
        ),
      };

      for (final entry in cases.entries) {
        final shell = shellOf(
          codec.decode(Uri.parse('https://reunicorn.app${entry.key}')),
        );
        expect(shell, isNotNull, reason: entry.key);
        expect(
          shell!.stack.last,
          ReceiveRequest(entry.value.$1, fragment: entry.value.$2),
          reason: entry.key,
        );
      }
    });

    test('the trailing-slash /c/ variant decodes the same as /c', () {
      final withSlash = codec.decode(
        Uri.parse('https://reunicorn.app/c/#$directFragment'),
      );
      final without = codec.decode(
        Uri.parse('https://reunicorn.app/c#$directFragment'),
      );

      expect(shellOf(withSlash)!.stack, shellOf(without)!.stack);
    });

    test('an invite round-trips back to its own URL', () {
      const path = '/c';
      final decoded = codec.decode(
        Uri.parse('https://reunicorn.app$path#$directFragment'),
      );

      final encoded = codec.encode(decoded!);

      expect(encoded.path, path);
      expect(encoded.fragment, directFragment);
    });
  });

  group('map coordinates', () {
    test('/mapAtLocation parses both coordinates', () {
      final shell = shellOf(
        codec.decode(Uri.parse('/mapAtLocation/52.5/13.4')),
      );

      expect(shell!.branch, AppBranch.map.index);
      expect(
        shell.stack.single,
        const MapView(latitude: 52.5, longitude: 13.4),
      );
    });

    test('malformed coordinates degrade to a null-coordinate map', () {
      final shell = shellOf(
        codec.decode(Uri.parse('/mapAtLocation/north/13.4')),
      );

      expect(shell!.stack.single, const MapView(longitude: 13.4));
    });

    test('a located map round-trips through encode', () {
      final decoded = codec.decode(Uri.parse('/mapAtLocation/52.5/13.4'));

      expect(codec.encode(decoded!).path, '/mapAtLocation/52.5/13.4');
    });

    test('a plain map encodes without coordinates', () {
      final decoded = codec.decode(Uri.parse('/map'));

      expect(codec.encode(decoded!).path, '/map');
    });
  });

  group('tab roots', () {
    test('each root path selects its own branch', () {
      final cases = {
        '/': AppBranch.dashboard,
        '/profile': AppBranch.profile,
        '/circles': AppBranch.circles,
        '/contacts': AppBranch.contacts,
        '/map': AppBranch.map,
      };

      for (final entry in cases.entries) {
        final shell = shellOf(codec.decode(Uri.parse(entry.key)));
        expect(shell?.branch, entry.value.index, reason: entry.key);
      }
    });

    test('paths are matched case-insensitively', () {
      expect(
        shellOf(codec.decode(Uri.parse('/Profile')))?.branch,
        AppBranch.profile.index,
      );
    });
  });

  group('unknown paths', () {
    test('decode to NotFound carrying the offending URI', () {
      final uri = Uri.parse('https://reunicorn.app/nope/whatever');

      final config = codec.decode(uri);

      expect(config!.mainStack.single, NotFound(uri));
      expect(config.nestedState, isNull);
    });

    test('/b has no route and falls through to NotFound', () {
      // Declared in the Android manifest but never routed.
      final config = codec.decode(Uri.parse('https://reunicorn.app/b'));

      expect(config!.mainStack.single, isA<NotFound>());
    });

    test('NotFound encodes back to the URI it was built from', () {
      final uri = Uri.parse('https://reunicorn.app/nope');

      expect(codec.encode(codec.decode(uri)!), uri);
    });
  });
}
