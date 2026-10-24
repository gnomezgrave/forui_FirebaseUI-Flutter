// Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:forui_firebase_ui_localizations/forui_firebase_ui_localizations.dart';
import 'package:forui_firebase_ui_shared/forui_firebase_ui_shared.dart';
import 'package:flutter/widgets.dart';

import 'package:firebase_auth/firebase_auth.dart' as fba;
import 'package:forui_firebase_ui_auth/forui_firebase_ui_auth.dart';

typedef SMSCodeSubmitCallback = void Function(String smsCode);

/// {@template ui.auth.views.sms_code_input_view}
/// A view that could be used to build a custom [SMSCodeInputScreen].
/// {@endtemplate}
class SMSCodeInputView extends StatefulWidget {
  /// {@macro ui.auth.auth_controller.auth}
  final fba.FirebaseAuth? auth;

  /// {@macro ui.auth.auth_action}
  final AuthAction? action;

  /// A unique object that could be used to obtain an instance of the
  /// [PhoneAuthController].
  final Object flowKey;

  /// A callback that is being called when the code was successfully verified.
  final VoidCallback? onCodeVerified;

  /// A callback that is being called when the user submits a SMS code.
  final SMSCodeSubmitCallback? onSubmit;

  /// {@macro ui.auth.views.sms_code_input_view}
  const SMSCodeInputView({
    super.key,
    required this.flowKey,
    this.onCodeVerified,
    this.auth,
    this.action,
    this.onSubmit,
  });

  @override
  State<SMSCodeInputView> createState() => _SMSCodeInputViewState();
}

class _SMSCodeInputViewState extends State<SMSCodeInputView> {
  final columnKey = GlobalKey();
  final key = GlobalKey<SMSCodeInputState>();

  @override
  void initState() {
    super.initState();

    final state = AuthFlowBuilder.getState(widget.flowKey);

    if (state != null && state is SMSCodeSent) {
      _codeSentState = state;
    }
  }

  SMSCodeSent? _codeSentState;

  /// Code entered before [SMSCodeSent]. The screen is shown as soon as the
  /// SMS is requested, which is before Android delivers `codeSent`.
  String? _pendingCode;

  SMSCodeSent? _verificationState() {
    final cached = _codeSentState;
    if (cached != null) return cached;

    final state = AuthFlowBuilder.getState(widget.flowKey);
    if (state is SMSCodeSent) {
      _codeSentState = state;
      return state;
    }
    return null;
  }

  void _verify(String code, PhoneAuthController ctrl, SMSCodeSent sent) {
    ctrl.verifySMSCode(
      code,
      confirmationResult: sent.confirmationResult,
      verificationId: sent.verificationId,
    );
  }

  void _schedulePending(PhoneAuthController ctrl) {
    final pending = _pendingCode;
    if (pending == null) return;
    _pendingCode = null;
    // Microtask, not post-frame: integration tests can sit on a Future while
    // no frame is pumped, and verifySMSCode must not run inside notifyListeners.
    Future.microtask(() {
      if (!mounted) return;
      final sent = _verificationState();
      if (sent == null) {
        _pendingCode = pending;
        return;
      }
      _verify(pending, ctrl, sent);
    });
  }

  void submit(String code, PhoneAuthController ctrl) {
    if (widget.onSubmit != null) {
      widget.onSubmit!(code);
      return;
    }

    final sent = _verificationState();
    if (sent == null) {
      _pendingCode = code;
      return;
    }

    _pendingCode = null;
    _verify(code, ctrl, sent);
  }

  @override
  Widget build(BuildContext context) {
    final l = FirebaseUILocalizations.labelsOf(context);

    return AuthFlowBuilder<PhoneAuthController>(
      auth: widget.auth,
      action: widget.action,
      flowKey: widget.flowKey,
      listener: (oldState, newState, controller) {
        // CredentialReceived means the SMS credential was built, not that
        // Firebase accepted it. Only treat it as done for MFA (AuthAction.none);
        // link/sign-in wait for CredentialLinked / SignedIn.
        final codeVerified =
            newState is SignedIn ||
            newState is CredentialLinked ||
            (newState is CredentialReceived &&
                controller.action == AuthAction.none);
        if (codeVerified) {
          widget.onCodeVerified?.call();
        }

        if (newState is SMSCodeSent) {
          _codeSentState = newState;
          _schedulePending(controller);
        }
      },
      builder: (context, state, ctrl, child) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SMSCodeInput(
              key: key,
              onSubmit: (smsCode) {
                submit(smsCode, ctrl);
              },
            ),
            const SizedBox(height: 16),
            UniversalButton(
              onPressed: () {
                final code = key.currentState!.code;
                if (code.length < 6) return;
                submit(code, ctrl);
              },
              text: l.verifyCodeButtonText,
            ),
          ],
        );
      },
    );
  }
}
