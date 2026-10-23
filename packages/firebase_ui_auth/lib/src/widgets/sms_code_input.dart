// Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:firebase_auth/firebase_auth.dart' show PhoneAuthCredential;
import 'package:forui_firebase_ui_auth/firebase_ui_auth.dart';
import 'package:forui_firebase_ui_localizations/firebase_ui_localizations.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';

typedef SMSCodeSubmitCallback = void Function(String smsCode);

/// {@template ui.auth.widgets.sms_code_input}
///
/// A widget that allows the user to enter the SMS code sent to the user's
/// phone.
///
/// This input is autofilled if SMS autoresolution is supported.
/// {@endtemplate}
class SMSCodeInput extends StatefulWidget {
  /// Whether the input should have a focus by default.
  final bool autofocus;

  /// Rendered under the input.
  final Widget? text;

  /// A callback that is being called when SMS code is submitted.
  final SMSCodeSubmitCallback? onSubmit;

  /// {@macro ui.auth.widgets.sms_code_input}
  const SMSCodeInput({
    super.key,
    this.autofocus = true,
    this.text,
    this.onSubmit,
  });

  @override
  SMSCodeInputState createState() => SMSCodeInputState();
}

class SMSCodeInputState extends State<SMSCodeInput> {
  late final controller = FOtpController();

  /// The currently entered SMS code.
  String get code => controller.text;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    final authState = AuthState.maybeOf(context);

    if (authState is PhoneVerified) {
      if (authState.credential is PhoneAuthCredential) {
        final smsCode =
            (authState.credential as PhoneAuthCredential).smsCode;
        if (smsCode != null && controller.text != smsCode) {
          controller.text = smsCode;
        }
      }
    }

    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final l = FirebaseUILocalizations.labelsOf(context);
    final state = AuthState.maybeOf(context);

    Widget? text;
    if (state is CredentialReceived ||
        state is SigningIn ||
        state is SignedIn) {
      text = Text(l.verifyingSMSCodeText);
    }

    if (state is AuthFailed) {
      text = ErrorText(exception: state.exception);
    }

    return Column(
      mainAxisSize: .min,
      crossAxisAlignment: .start,
      children: [
        FOtpField(
          control: .managed(controller: controller),
          autofocus: widget.autofocus,
          autofillHints: const [AutofillHints.oneTimeCode],
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          label: Text(l.enterSMSCodeText),
          onSubmit: (v) {
            if (v.length < 6) return;
            widget.onSubmit?.call(v);
          },
        ),
        if (widget.text != null || text != null)
          Padding(
            padding: const EdgeInsets.all(6),
            child: widget.text ?? text,
          ),
      ],
    );
  }
}
