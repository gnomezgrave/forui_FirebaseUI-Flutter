// Copyright 2023, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';

import '../test_utils.dart';

void main() {
  group("$RegisterScreen", () {
    setUpAll(() {
      setFirebaseUiIsTestMode(true);
    });

    testWidgets("doesn't have password visibility toggle by default", (
      tester,
    ) async {
      await tester.pumpWidget(
        TestMaterialApp(
          child: RegisterScreen(
            auth: MockAuth(),
            providers: [EmailAuthProvider()],
          ),
        ),
      );

      expect(find.byIcon(FLucideIcons.eye), findsNothing);
    });

    testWidgets('allows to add password visibility toggle', (tester) async {
      await tester.pumpWidget(
        TestMaterialApp(
          child: RegisterScreen(
            auth: MockAuth(),
            providers: [EmailAuthProvider()],
            showPasswordVisibilityToggle: true,
          ),
        ),
      );

      expect(find.byIcon(FLucideIcons.eye), findsNWidgets(2));
    });
  });
}
