// Copyright 2023, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:forui_firebase_ui_shared/src/universal_button.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';

import 'test_app.dart';

void main() {
  group('UniversalButton', () {
    testWidgets('renders text as content', (tester) async {
      await tester.pumpWidget(
        foruiTestApp(child: const UniversalButton(text: 'text')),
      );

      expect(find.text('text'), findsOneWidget);
    });

    testWidgets('prefers child over text', (tester) async {
      await tester.pumpWidget(
        foruiTestApp(
          child: const UniversalButton(text: 'text', child: Text('child')),
        ),
      );

      expect(find.text('text'), findsNothing);
      expect(find.text('child'), findsOneWidget);
    });

    testWidgets('renders FButton for text variant', (tester) async {
      await tester.pumpWidget(
        foruiTestApp(
          child: const UniversalButton(
            text: 'text',
            variant: ButtonVariant.text,
          ),
        ),
      );

      expect(find.byType(FButton), findsOneWidget);
    });

    testWidgets('renders FButton for outlined variant', (tester) async {
      await tester.pumpWidget(
        foruiTestApp(
          child: const UniversalButton(
            text: 'text',
            variant: ButtonVariant.outlined,
          ),
        ),
      );

      expect(find.byType(FButton), findsOneWidget);
    });

    testWidgets('renders FButton for filled variant', (tester) async {
      await tester.pumpWidget(
        foruiTestApp(
          child: const UniversalButton(
            text: 'text',
            variant: ButtonVariant.filled,
          ),
        ),
      );

      expect(find.byType(FButton), findsOneWidget);
    });

    testWidgets('calls onPressed when button is tapped', (tester) async {
      var pressed = 0;

      await tester.pumpWidget(
        foruiTestApp(
          child: UniversalButton(text: 'press me', onPressed: () => pressed++),
        ),
      );

      await tester.tap(find.byType(UniversalButton));
      await tester.pumpAndSettle();

      expect(pressed, 1);
    });

    testWidgets('lays out as a trailing action in a row', (tester) async {
      await tester.pumpWidget(
        foruiTestApp(
          child: const SizedBox(
            width: 400,
            child: Row(
              children: [
                Expanded(child: Text('Off')),
                UniversalButton(text: 'Enable', variant: ButtonVariant.text),
              ],
            ),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
      expect(find.text('Enable'), findsOneWidget);
      expect(tester.getSize(find.byType(FButton)).width, lessThan(200));
    });

    testWidgets('lays out under IntrinsicWidth', (tester) async {
      await tester.pumpWidget(
        foruiTestApp(
          child: const Align(
            alignment: Alignment.topLeft,
            child: IntrinsicWidth(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(width: 220, height: 48),
                  SizedBox(height: 16),
                  Padding(
                    padding: EdgeInsets.all(8),
                    child: UniversalButton(text: 'Verify'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
      expect(find.text('Verify'), findsOneWidget);
      // The stretched button matches the 220-wide sibling, minus the padding.
      expect(
        tester.getSize(find.byType(UniversalButton)).width,
        closeTo(204, 1),
      );
    });

    testWidgets('stretches to a bounded width and ellipsizes a long label', (
      tester,
    ) async {
      await tester.pumpWidget(
        foruiTestApp(
          child: const Center(
            child: SizedBox(
              width: 120,
              child: UniversalButton(
                text: 'This label is way too long to fit in the button',
              ),
            ),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
      expect(tester.getSize(find.byType(UniversalButton)).width, 120);
    });
  });
}
