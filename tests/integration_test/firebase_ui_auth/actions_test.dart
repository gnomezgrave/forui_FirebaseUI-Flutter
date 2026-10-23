// Copyright 2023, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';

import 'package:forui_firebase_ui_auth/forui_firebase_ui_auth.dart';
import 'package:forui_firebase_ui_localizations/forui_firebase_ui_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';

import '../utils.dart';

void main() {
  const labels = DefaultLocalizations();
  setUpTests();
  group('getControllerForType', () {
    setUp(() async {
      await auth.createUserWithEmailAndPassword(
        email: 'test@test.com',
        password: '123456',
      );
      // createUser leaves the session signed in; sign out so EmailForm must auth.
      await auth.signOut();
    });

    Future<void> authenticate(WidgetTester tester) async {
      final inputs = find.byType(FTextFormField);

      await tester.enterText(inputs.at(0), 'test@test.com');
      await tester.enterText(inputs.at(1), '123456');
      await tester.tap(find.text(labels.signInActionText));
      await tester.pumpAndSettle();
    }

    testWidgets('getControllerForState returns correct controller type', (
      tester,
    ) async {
      final completer = Completer<AuthController>();

      await render(
        tester,
        FirebaseUIActions(
          actions: [
            AuthStateChangeAction<SignedIn>((context, state) {
              completer.complete(getControllerForState(state));
            }),
            AuthStateChangeAction<AuthFailed>((context, state) {
              completer.completeError(state.exception);
            }),
          ],
          child: const EmailForm(action: AuthAction.signIn),
        ),
      );

      await authenticate(tester);

      final controller = await completer.future.timeout(
        const Duration(seconds: 15),
      );
      expect(controller, isA<EmailAuthController>());
    }, skip: skipMacOSAuthKeychain);

    testWidgets('throws a StateError if used outside of the FirebaseUIAction', (
      tester,
    ) async {
      late AuthState state;
      final completer = Completer<void>();

      await render(
        tester,
        AuthStateListener<EmailAuthController>(
          listener: (oldState, newState, _) {
            state = newState;
            if (newState is SignedIn || newState is AuthFailed) {
              completer.complete();
            }
            return null;
          },
          child: const EmailForm(action: AuthAction.signIn),
        ),
      );

      await authenticate(tester);
      await completer.future.timeout(const Duration(seconds: 15));

      expect(() => getControllerForState(state), throwsStateError);
    }, skip: skipMacOSAuthKeychain);
  });
}
