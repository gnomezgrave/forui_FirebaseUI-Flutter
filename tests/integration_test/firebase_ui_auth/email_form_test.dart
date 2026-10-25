// Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:forui_firebase_ui_auth/forui_firebase_ui_auth.dart';
import 'package:forui_firebase_ui_localizations/forui_firebase_ui_localizations.dart';
import 'package:forui_firebase_ui_shared/forui_firebase_ui_shared.dart';

import '../utils.dart';

void main() {
  const labels = DefaultLocalizations();

  group('EmailForm', () {
    testWidgets(
      'registers new user',
      (tester) async {
        final states = <AuthState>[];
        // Unique email avoids email-already-in-use if prior cleanup failed.
        final email =
            'register_${DateTime.now().microsecondsSinceEpoch}@test.com';

        await render(
          tester,
          AuthStateListener<EmailAuthController>(
            listener: (oldState, state, controller) {
              states.add(state);
              return null;
            },
            child: const EmailForm(action: AuthAction.signUp),
          ),
        );

        final inputs = find.byType(FTextFormField);

        await tester.enterText(inputs.at(0), email);
        await tester.enterText(inputs.at(1), 'password');
        await tester.enterText(inputs.at(2), 'password');
        FocusManager.instance.primaryFocus?.unfocus();
        await tester.pump(const Duration(milliseconds: 400));
        final register = find.widgetWithText(
          UniversalButton,
          labels.registerActionText,
        );
        await tester.ensureVisible(register);
        await tester.tap(register);
        await tester.pump();

        expect(find.byType(LoadingIndicator), findsOneWidget);
        // New accounts emit [UserCreated]; failures emit [AuthFailed].
        await pumpUntil(
          tester,
          () => states.any(
            (s) => s is UserCreated || s is SignedIn || s is AuthFailed,
          ),
          timeout: const Duration(seconds: 30),
        );

        expect(
          states.whereType<AuthFailed>(),
          isEmpty,
          reason: states.whereType<AuthFailed>().map((e) => e.exception).join(),
        );
        expect(auth.currentUser, isNotNull);
        expect(auth.currentUser!.email, email);
      },
      skip:
          skipMacOSAuthKeychain ||
          (isCI && defaultTargetPlatform == TargetPlatform.android),
    );

    testWidgets('shows wrong password error', (tester) async {
      await auth.createUserWithEmailAndPassword(
        email: 'test@test.com',
        password: 'password',
      );

      await auth.signOut();

      await render(tester, const EmailForm(action: AuthAction.signIn));

      final inputs = find.byType(FTextFormField);

      await tester.enterText(inputs.at(0), 'test@test.com');
      await tester.enterText(inputs.at(1), 'wrongpassword');
      await tester.tap(find.text(labels.signInActionText));

      final error = find.text(labels.wrongOrNoPasswordErrorText);
      await pumpUntil(tester, () => error.evaluate().isNotEmpty);

      expect(error, findsOneWidget);
    }, skip: skipMacOSAuthKeychain);

    testWidgets(
      'signs in the user',
      (tester) async {
        await auth.createUserWithEmailAndPassword(
          email: 'test@test.com',
          password: 'password',
        );

        await auth.signOut();

        final signedIn = Completer<void>();

        await render(
          tester,
          FirebaseUIActions(
            actions: [
              AuthStateChangeAction<SignedIn>((context, state) {
                expect(state, isA<SignedIn>());
                expect(state.user, isNotNull);
                expect(state.user!.email, equals('test@test.com'));
                signedIn.complete();
              }),
              AuthStateChangeAction<AuthFailed>((context, state) {
                signedIn.completeError(state.exception);
              }),
            ],
            child: const EmailForm(action: AuthAction.signIn),
          ),
        );

        final inputs = find.byType(FTextFormField);

        await tester.enterText(inputs.at(0), 'test@test.com');
        await tester.enterText(inputs.at(1), 'password');
        await tester.tap(find.text(labels.signInActionText));
        await tester.pumpAndSettle();
        await signedIn.future.timeout(const Duration(seconds: 15));
      },
      skip:
          skipMacOSAuthKeychain ||
          (isCI && defaultTargetPlatform == TargetPlatform.android),
    );

    testWidgets(
      'links email and password when auth action is link',
      (tester) async {
        await auth.signInAnonymously();
        final anonymousUid = auth.currentUser!.uid;

        await render(tester, const EmailForm(action: AuthAction.link));

        final inputs = find.byType(FTextFormField);

        await tester.enterText(inputs.at(0), 'test@test.com');
        await tester.enterText(inputs.at(1), 'password');
        await tester.enterText(inputs.at(2), 'password');
        await tester.tap(find.text(labels.linkEmailButtonText));
        await tester.pumpAndSettle();

        expect(auth.currentUser!.email, 'test@test.com');
        expect(auth.currentUser!.uid, anonymousUid);
      },
      // see https://github.com/gnomezgrave/forui_FirebaseUI-Flutter/issues/150
      skip: true,
    );
  });
}
