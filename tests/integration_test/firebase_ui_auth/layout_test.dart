// Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:firebase_auth/firebase_auth.dart' as fba;
import 'package:forui_firebase_ui_auth/forui_firebase_ui_auth.dart';
import 'package:forui_firebase_ui_oauth_apple/forui_firebase_ui_oauth_apple.dart';
import 'package:forui_firebase_ui_oauth_google/forui_firebase_ui_oauth_google.dart';
import 'package:material_ui/material_ui.dart';
import 'package:forui/forui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

void main() {
  group('Reauthenticate dialog', () {
    testWidgets("doesn't have an overflow when keyboard is visible", (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          builder: (context, child) =>
              FTheme(data: FTheme.neutral.light.touch, child: child!),
          home: FScaffold(
            child: ReauthenticateDialog(
              providers: [
                EmailAuthProvider(),
                PhoneAuthProvider(),
                GoogleProvider(clientId: 'mock'),
                AppleProvider(),
              ],
              auth: MockAuth(),
            ),
          ),
        ),
      );

      // Simulate a reduced viewport (keyboard) so the dialog must scroll
      // instead of overflowing. Integration tests do not always raise a real
      // IME when tapping a Forui text field.
      final view = tester.view;
      view.viewInsets = const FakeViewPadding(bottom: 300);
      addTearDown(view.resetViewInsets);
      await tester.pumpAndSettle();

      // No need for an expect.
      // Test will fail if there is an overflow.
      // This is a built-in flutter functionality

      final cancel = find.text('Cancel');
      await tester.ensureVisible(cancel);
      await tester.tap(cancel);
      await tester.pumpAndSettle();
    });
  });
}

const _user = {'uid': 'uid', 'isAnonymous': false, 'isEmailVerified': false};

class MockUser extends Mock implements fba.User {
  @override
  List<fba.UserInfo> get providerData {
    return [
      fba.UserInfo.fromJson({..._user, 'providerId': 'password'}),
      fba.UserInfo.fromJson({..._user, 'providerId': 'google.com'}),
      fba.UserInfo.fromJson({..._user, 'providerId': 'apple.com'}),
      fba.UserInfo.fromJson({..._user, 'providerId': 'phone'}),
    ];
  }
}

class MockAuth extends Mock implements fba.FirebaseAuth {
  @override
  fba.User? get currentUser => MockUser();
}
