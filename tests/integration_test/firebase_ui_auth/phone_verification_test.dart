// Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart' as fba;
import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui_firebase_ui_auth/forui_firebase_ui_auth.dart';
import 'package:forui_firebase_ui_localizations/forui_firebase_ui_localizations.dart';

import '../utils.dart';

/// [PhoneInput] EditableTexts are: FSelect label, dial code, national number.
Finder _phoneInputEditableTexts() => find.descendant(
  of: find.byType(PhoneInput),
  matching: find.byType(EditableText),
);

Finder phoneNumberField() => _phoneInputEditableTexts().last;

Finder countryCodeField() => _phoneInputEditableTexts().at(1);

/// Pumps until idle, but does not wait out a caret or other perpetual ticker.
/// On a live Android binding those frames never stop and [WidgetTester.pumpAndSettle]
/// would block until its 10 minute timeout.
Future<void> settle(WidgetTester tester) async {
  try {
    await tester.pumpAndSettle(
      const Duration(milliseconds: 100),
      EnginePhase.sendSemanticsUpdate,
      const Duration(seconds: 3),
    );
  } on FlutterError catch (error) {
    if (!error.message.contains('pumpAndSettle timed out')) rethrow;
  }
}

/// Submits [code] with the on-screen Verify control.
///
/// [TextInputAction.done] depends on an active IME connection. On Android that
/// connection is often inactive (`SmsRetriever` / headless emulator), so the
/// action never reaches [FOtpField.onSubmit].
Future<void> submitSmsCode(WidgetTester tester, String code) async {
  final editable = find.descendant(
    of: find.byType(SMSCodeInput),
    matching: find.byType(EditableText),
  );
  await tester.enterText(editable, code);
  await tester.pump();
  expect(
    (tester.widget<EditableText>(editable).controller).text,
    code,
    reason: 'SMS code was not applied to the OTP field',
  );

  FocusManager.instance.primaryFocus?.unfocus();
  await tester.pump();
  final verify = find.text(const DefaultLocalizations().verifyCodeButtonText);
  await tester.ensureVisible(verify);
  await tester.tap(verify);
  await settle(tester);
}

Future<void> sendSMS(WidgetTester tester, String phoneNumber) async {
  await tester.pump();

  await tester.enterText(phoneNumberField(), phoneNumber);
  await tester.tap(
    find.text(const DefaultLocalizations().verifyPhoneNumberButtonText),
  );
  await settle(tester);
}

void main() {
  const labels = DefaultLocalizations();
  setUpTests();

  group('PhoneInputScreen', () {
    testWidgets('allows to pick country code', (tester) async {
      await render(tester, const PhoneInputScreen());
      await tester.pump();

      // Default locale country (en_US → United States) via FSelect.
      expect(find.text('United States'), findsOneWidget);

      await tester.tap(find.text('United States'));
      await settle(tester);

      // List is long and opens near the selected country; scroll Australia on-screen.
      final australia = find.text('Australia');
      await tester.scrollUntilVisible(
        australia,
        -400,
        scrollable: find.byType(Scrollable).last,
      );
      await settle(tester);
      await tester.tap(australia);
      await settle(tester);

      expect(
        (countryCodeField().evaluate().single.widget as EditableText)
            .controller
            .text,
        '61',
      );
      expect(find.text('+'), findsWidgets);
      expect(find.text(labels.countryCode), findsOneWidget);
    });

    testWidgets('validates phone number', (tester) async {
      await render(tester, const PhoneInputScreen());

      await tester.pump();

      await tester.enterText(phoneNumberField(), '12345');
      await tester.tap(find.text(labels.verifyPhoneNumberButtonText));
      await settle(tester);

      final errorText = find.text(labels.phoneNumberInvalidErrorText);
      expect(errorText, findsOneWidget);
    });

    testWidgets('sends sms verification code when next is clicked', (
      tester,
    ) async {
      final completer = Completer<void>();

      await render(
        tester,
        PhoneInputScreen(
          actions: [
            AuthStateChangeAction<SMSCodeSent>((context, state) {
              if (!completer.isCompleted) completer.complete();
            }),
            AuthStateChangeAction<AuthFailed>((context, state) {
              fail('should not fail');
            }),
          ],
        ),
      );

      await sendSMS(tester, '555555555');

      await completer.future;

      final code = await getVerificationCode('+1555555555');
      expect(code, isNotEmpty);
    });

    testWidgets('opens sms verification screen when code is requested', (
      tester,
    ) async {
      await render(tester, const PhoneInputScreen());
      await sendSMS(tester, '123456789');

      expect(find.text(labels.enterSMSCodeText), findsOneWidget);
    });
  });

  group('SMSCodeInputScreen', () {
    testWidgets('allows to go back to phone input screen', (tester) async {
      await render(tester, const PhoneInputScreen());
      await sendSMS(tester, '123456789');

      final button = find.text(labels.goBackButtonLabel);
      expect(button, findsOneWidget);
      await tester.tap(button);
      await settle(tester);

      expect(find.byType(PhoneInputScreen), findsOneWidget);
    });

    testWidgets('shows error message if invalid code was entered', (
      tester,
    ) async {
      final completer = Completer<void>();

      await render(
        tester,
        AuthStateListener<PhoneAuthController>(
          listener: (oldState, newState, _) {
            if (newState is! AuthFailed) return;
            if (!completer.isCompleted) completer.complete();

            return null;
          },
          child: const PhoneInputScreen(),
        ),
      );
      await sendSMS(tester, '555555556');

      final smsCodeInput = find.byType(SMSCodeInput);
      expect(smsCodeInput, findsOneWidget);

      final code = await getVerificationCode('+1555555556');
      final invalidCode = code
          .split('')
          .map(int.parse)
          .map((v) => (v + 1) % 10)
          .join();

      await submitSmsCode(tester, invalidCode);
      await completer.future.timeout(const Duration(seconds: 15));

      await tester.pump();

      expect(find.byType(ErrorText), findsOneWidget);
      expect(
        find.text(labels.invalidVerificationCodeErrorText),
        findsOneWidget,
      );
    });

    testWidgets('signs in if the code is correct', (tester) async {
      final completer = Completer<fba.User>();

      await render(
        tester,
        FirebaseUIActions(
          actions: [
            AuthStateChangeAction<UserCreated>((context, state) {
              if (!completer.isCompleted) {
                completer.complete(state.credential.user!);
              }
            }),
            AuthStateChangeAction<AuthFailed>((context, state) {
              fail("shouldn't fail");
            }),
          ],
          child: const PhoneInputScreen(),
        ),
      );
      await sendSMS(tester, '555555557');

      expect(find.byType(SMSCodeInput), findsOneWidget);
      final code = await getVerificationCode('+1555555557');

      await submitSmsCode(tester, code);

      final user = await completer.future.timeout(const Duration(seconds: 10));

      expect(user.phoneNumber, '+1555555557');
    });
  });

  group('showReauthenticateDialog', () {
    testWidgets(
      'can reauthenticate using phone number',
      (tester) async {
        final credCompleter = Completer<fba.PhoneAuthCredential>();

        await auth.verifyPhoneNumber(
          phoneNumber: '+1555555558',
          verificationCompleted: credCompleter.complete,
          verificationFailed: credCompleter.completeError,
          codeSent: (verificationId, _) async {
            final code = await getVerificationCode('+1555555558');

            final credential = fba.PhoneAuthProvider.credential(
              verificationId: verificationId,
              smsCode: code,
            );

            credCompleter.complete(credential);
          },
          codeAutoRetrievalTimeout: (_) {},
        );

        final cred = await credCompleter.future;
        await auth.signInWithCredential(cred);

        final reauthenticationCompleter = Completer<void>();
        // emulator doesn't return a new sms code if the same phone number is
        // used within 30(?) seconds.
        await Future.delayed(const Duration(seconds: 30));
        bool onPhoneVerifiedCalled = false;

        await render(
          tester,
          Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () {
                  showReauthenticateDialog(
                    context: context,
                    providers: [PhoneAuthProvider()],
                    onSignedIn: () => reauthenticationCompleter.complete(),
                    onPhoneVerfifed: () => onPhoneVerifiedCalled = true,
                  );
                },
                child: const Text('Reauthenticate'),
              );
            },
          ),
        );

        await tester.tap(find.byType(ElevatedButton));
        await settle(tester);

        await tester.tap(find.text('Sign in with phone'));
        await settle(tester);

        await sendSMS(tester, '555555558');

        expect(find.byType(SMSCodeInput), findsOneWidget);
        final code = await getVerificationCode('+1555555558');

        await submitSmsCode(tester, code);

        final future = reauthenticationCompleter.future.timeout(
          const Duration(seconds: 5),
        );

        expect(future, completes);
        expect(onPhoneVerifiedCalled, isTrue);
      },
      // passes locally but fails in CI
      skip:
          isCI &&
          (defaultTargetPlatform == TargetPlatform.android ||
              defaultTargetPlatform == TargetPlatform.iOS),
    );
  });
}
