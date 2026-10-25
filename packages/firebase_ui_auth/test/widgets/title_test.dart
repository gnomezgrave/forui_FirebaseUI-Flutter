// Copyright 2026, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:forui_firebase_ui_auth/src/widgets/internal/title.dart'
    as ui_title;
import 'package:material_ui/material_ui.dart';

void main() {
  group('Title', () {
    testWidgets('defaults to Forui display.md typography', (tester) async {
      late TextStyle expected;

      await tester.pumpWidget(
        MaterialApp(
          builder: (context, child) =>
              FTheme(data: FTheme.neutral.light.touch, child: child!),
          home: Builder(
            builder: (context) {
              expected = context.theme.typography.display.md;
              return const FScaffold(child: ui_title.Title(text: 'Hello'));
            },
          ),
        ),
      );

      final text = tester.widget<Text>(find.text('Hello'));
      expect(text.style?.fontSize, expected.fontSize);
      expect(text.style?.fontWeight, FontWeight.w600);
    });
  });
}
