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
  });
}
