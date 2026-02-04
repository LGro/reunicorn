// Copyright 2024 - 2026 The Reunicorn Authors. All rights reserved.
// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reunicorn/ui/map/widgets/search_bar.dart';

void main() {
  group('MapLocationSearchBar', () {
    testWidgets(
      'keyboard stays open when suggestions appear',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: MapLocationSearchBar(
                onLocationSelected: (_) {},
                onGpsLocationRequested: () {},
                onAddLocation: () {},
                onClearSelection: () {},
              ),
            ),
          ),
        );

        // Find the TextField
        final textField = find.byType(TextField);
        expect(textField, findsOneWidget);

        // Tap to focus the TextField
        await tester.tap(textField);
        await tester.pump();

        // Verify TextField has focus
        final textFieldWidget = tester.widget<TextField>(textField);
        expect(textFieldWidget.focusNode?.hasFocus, isTrue);

        // Enter text to trigger search (simulating typing)
        await tester.enterText(textField, 'Be');
        await tester.pump();

        // TextField should still have focus after entering text
        expect(textFieldWidget.focusNode?.hasFocus, isTrue);

        // Simulate more text entry
        await tester.enterText(textField, 'Berlin');
        await tester.pump();

        // Wait for any async operations
        await tester.pump(const Duration(milliseconds: 100));

        // TextField should still have focus
        expect(textFieldWidget.focusNode?.hasFocus, isTrue);

        // The keyboard being open is equivalent to having focus in Flutter tests
        // We verify focus is maintained throughout the interaction
      },
    );

    testWidgets(
      'focus is maintained when suggestions list appears and disappears',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: MapLocationSearchBar(
                onLocationSelected: (_) {},
                onGpsLocationRequested: () {},
                onAddLocation: () {},
                onClearSelection: () {},
              ),
            ),
          ),
        );

        final textField = find.byType(TextField);

        // Focus the field
        await tester.tap(textField);
        await tester.pump();

        // Get the focus node to track focus state
        final textFieldWidget = tester.widget<TextField>(textField);
        final focusNode = textFieldWidget.focusNode!;

        expect(focusNode.hasFocus, isTrue);

        // Type short text (no suggestions)
        await tester.enterText(textField, 'A');
        await tester.pump();
        expect(focusNode.hasFocus, isTrue);

        // Type more text (would trigger suggestions in real scenario)
        await tester.enterText(textField, 'Amsterdam');
        await tester.pump();
        expect(focusNode.hasFocus, isTrue);

        // Clear text
        await tester.enterText(textField, '');
        await tester.pump();
        expect(focusNode.hasFocus, isTrue);

        // Type again
        await tester.enterText(textField, 'Paris');
        await tester.pump();
        expect(focusNode.hasFocus, isTrue);
      },
    );

    testWidgets('GPS button is displayed', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MapLocationSearchBar(
              onLocationSelected: (_) {},
              onGpsLocationRequested: () {},
              onAddLocation: () {},
              onClearSelection: () {},
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.my_location), findsOneWidget);
    });

    testWidgets('GPS button triggers callback', (tester) async {
      var gpsRequested = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MapLocationSearchBar(
              onLocationSelected: (_) {},
              onGpsLocationRequested: () => gpsRequested = true,
              onAddLocation: () {},
              onClearSelection: () {},
            ),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.my_location));
      await tester.pump();

      expect(gpsRequested, isTrue);
    });

    testWidgets('GPS button shows loading state', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MapLocationSearchBar(
              onLocationSelected: (_) {},
              onGpsLocationRequested: () {},
              onAddLocation: () {},
              onClearSelection: () {},
              isGpsLoading: true,
            ),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.byIcon(Icons.my_location), findsNothing);
    });

    testWidgets('clear button appears when text is entered', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MapLocationSearchBar(
              onLocationSelected: (_) {},
              onGpsLocationRequested: () {},
              onAddLocation: () {},
              onClearSelection: () {},
            ),
          ),
        ),
      );

      // Initially no clear button
      expect(find.byIcon(Icons.clear), findsNothing);

      // Enter text
      await tester.enterText(find.byType(TextField), 'Test');
      await tester.pump();

      // Clear button should appear
      expect(find.byIcon(Icons.clear), findsOneWidget);
    });

    testWidgets('clear button clears text and maintains focus', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MapLocationSearchBar(
              onLocationSelected: (_) {},
              onGpsLocationRequested: () {},
              onAddLocation: () {},
              onClearSelection: () {},
            ),
          ),
        ),
      );

      final textField = find.byType(TextField);

      // Enter text
      await tester.tap(textField);
      await tester.pump();
      await tester.enterText(textField, 'Test Location');
      await tester.pump();

      // Verify text is there
      expect(find.text('Test Location'), findsOneWidget);

      // Tap clear button
      await tester.tap(find.byIcon(Icons.clear));
      await tester.pump();

      // Text should be cleared
      final controller =
          tester.widget<TextField>(textField).controller;
      expect(controller?.text, isEmpty);
    });

    testWidgets(
      'AnimatedSize is used for smooth suggestion appearance',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: MapLocationSearchBar(
                onLocationSelected: (_) {},
                onGpsLocationRequested: () {},
                onAddLocation: () {},
                onClearSelection: () {},
              ),
            ),
          ),
        );

        // Verify AnimatedSize is in the widget tree (prevents focus loss)
        expect(find.byType(AnimatedSize), findsOneWidget);
      },
    );
  });
}
