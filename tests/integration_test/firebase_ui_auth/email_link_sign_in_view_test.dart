// Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:firebase_auth/firebase_auth.dart' as fba;
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:forui_firebase_ui_auth/forui_firebase_ui_auth.dart';
import 'package:forui_firebase_ui_localizations/forui_firebase_ui_localizations.dart';

import '../utils.dart';

final actionCodeSettings = fba.ActionCodeSettings(
  url: 'http://$testEmulatorHost:9099',
  handleCodeInApp: true,
  androidMinimumVersion: '1',
  androidPackageName: 'io.flutter.plugins.firebase_ui_example',
  iOSBundleId: 'io.flutter.plugins.flutterfireui.flutterfireUIExample',
);

final emailLinkProvider = EmailLinkAuthProvider(
  actionCodeSettings: actionCodeSettings,
);

void main() {
  setUpTests();
  const labels = DefaultLocalizations();

  group('EmailLinkSignInView', () {
    testWidgets('validates email', (tester) async {
      await render(tester, EmailLinkSignInView(provider: emailLinkProvider));
      await tester.pumpAndSettle();

      final input = find.byType(FTextFormField);
      await tester.tap(input);
      await tester.enterText(input, 'notanemail');
      // Let FTextFormField's FormField sync from the controller before validate.
      await tester.pump();
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();
      // Button path as a second validate in case IME action is a no-op on desktop.
      await tester.tap(find.text(labels.sendLinkButtonLabel));
      await pumpUntil(
        tester,
        () =>
            find.text(labels.isNotAValidEmailErrorText).evaluate().isNotEmpty,
      );

      expect(find.text(labels.isNotAValidEmailErrorText), findsOneWidget);
    });

    testWidgets('sends a link to an email', (tester) async {
      await render(tester, EmailLinkSignInView(provider: emailLinkProvider));
      await tester.pumpAndSettle();

      final input = find.byType(FTextFormField);
      await tester.enterText(input, 'test@test.com');
      await tester.pump();
      await tester.tap(find.text(labels.sendLinkButtonLabel));

      await pumpUntil(
        tester,
        () => find
            .text(labels.signInWithEmailLinkSentText)
            .evaluate()
            .isNotEmpty,
      );

      expect(find.text(labels.signInWithEmailLinkSentText), findsOneWidget);
    });
  });
}
