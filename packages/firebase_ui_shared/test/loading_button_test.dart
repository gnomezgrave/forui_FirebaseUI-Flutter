// Copyright 2023, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:forui_firebase_ui_shared/firebase_ui_shared.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';

import 'test_app.dart';

void main() {
  group('LoadingButton', () {
    testWidgets('shows label', (tester) async {
      await tester.pumpWidget(
        foruiTestApp(
          child: LoadingButton(label: 'label', onTap: () {}),
        ),
      );

      expect(find.text('label'), findsOneWidget);
    });

    testWidgets('shows loading indicator when isLoading = true', (
      tester,
    ) async {
      await tester.pumpWidget(
        foruiTestApp(
          child: LoadingButton(label: 'button', isLoading: true, onTap: () {}),
        ),
      );

      expect(find.byType(FCircularProgress), findsOneWidget);
      expect(find.text('button'), findsOneWidget);
    });

    testWidgets('hides loading indicator when isLoading = false', (
      tester,
    ) async {
      await tester.pumpWidget(
        foruiTestApp(
          child: LoadingButton(label: 'button', onTap: () {}),
        ),
      );

      expect(find.byType(FCircularProgress), findsNothing);
    });
  });
}
