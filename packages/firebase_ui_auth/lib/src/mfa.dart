// Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:firebase_auth/firebase_auth.dart' as fba;
import 'package:firebase_core/firebase_core.dart';
import 'package:forui_firebase_ui_auth/firebase_ui_auth.dart';
import 'package:forui_firebase_ui_auth/src/widgets/internal/universal_page_route.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

typedef SMSCodeInputScreenBuilder = Widget Function(
  BuildContext context,
  List<FirebaseUIAction> actions,
  Object flowKey,
  AuthAction action,
);

Future<fba.UserCredential> startMFAVerification({
  required BuildContext context,
  required fba.MultiFactorResolver resolver,
  fba.FirebaseAuth? auth,
  SMSCodeInputScreenBuilder? smsCodeInputScreenBuilder,
  void Function(FirebaseException e)? onError,
}) async {
  if (resolver.hints.first is fba.PhoneMultiFactorInfo) {
    return startPhoneMFAVerification(
      context: context,
      resolver: resolver,
      auth: auth,
      smsCodeInputScreenBuilder: smsCodeInputScreenBuilder,
      onError: onError,
    );
  } else {
    throw Exception('Unsupported MFA type');
  }
}

Future<fba.UserCredential> startPhoneMFAVerification({
  required BuildContext context,
  required fba.MultiFactorResolver resolver,
  fba.FirebaseAuth? auth,
  SMSCodeInputScreenBuilder? smsCodeInputScreenBuilder,
  void Function(FirebaseException e)? onError,
}) async {
  final session = resolver.session;
  final hint = resolver.hints.first;

  final navigator = Navigator.of(context);

  final provider = PhoneAuthProvider();
  provider.auth = auth ?? fba.FirebaseAuth.instance;

  // Use the same provider instance for sending and verifying the SMS code.
  final flow = PhoneAuthFlow(
    auth: auth ?? fba.FirebaseAuth.instance,
    action: AuthAction.none,
    provider: provider,
  );

  provider.authListener = flow;

  final flowKey = Object();

  final actions = [
    AuthStateChangeAction<CredentialReceived>((context, inner) async {
      final phoneCred = inner.credential as fba.PhoneAuthCredential;
      final assertion = fba.PhoneMultiFactorGenerator.getAssertion(phoneCred);
      try {
        final cred = await resolver.resolveSignIn(assertion);
        // Pop with the credential so await navigator.push completes successfully.
        if (context.mounted && Navigator.of(context).canPop()) {
          Navigator.of(context).pop(cred);
        }
      } catch (e) {
        if (e is FirebaseException) {
          onError?.call(e);
        }
        flow.onError(e);
      }
    }),
  ];

  SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
    provider.sendVerificationCode(
      hint: hint as fba.PhoneMultiFactorInfo,
      multiFactorSession: session,
      action: AuthAction.none,
    );
  });

  Widget builder(BuildContext context) {
    Widget child;

    if (smsCodeInputScreenBuilder != null) {
      child = smsCodeInputScreenBuilder.call(
        context,
        actions,
        flowKey,
        AuthAction.none,
      );
    } else {
      child = SMSCodeInputScreen(
        flowKey: flowKey,
        action: AuthAction.none,
        auth: auth,
        actions: actions,
      );
    }

    return AuthFlowBuilder<PhoneAuthController>(
      auth: auth,
      flow: flow,
      flowKey: flowKey,
      child: child,
    );
  }

  final pageRoute = createPageRoute<fba.UserCredential>(
    context: context,
    builder: builder,
  );

  final result = await navigator.push<fba.UserCredential>(pageRoute);

  // User dismissed the SMS screen without completing MFA.
  if (result == null) {
    throw fba.FirebaseAuthException(
      code: 'firebase-ui/mfa-cancelled',
      message: 'Multi-factor authentication was cancelled.',
    );
  }

  return result;
}
