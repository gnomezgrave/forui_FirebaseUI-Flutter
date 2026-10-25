// Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:firebase_auth/firebase_auth.dart' show PhoneAuthCredential;
import 'package:forui_firebase_ui_auth/forui_firebase_ui_auth.dart';
import 'package:forui_firebase_ui_localizations/forui_firebase_ui_localizations.dart';
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
        final smsCode = (authState.credential as PhoneAuthCredential).smsCode;
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
    final theme = context.theme;

    Widget? status;
    if (state is CredentialReceived ||
        state is SigningIn ||
        state is SignedIn) {
      status = Text(
        l.verifyingSMSCodeText,
        textAlign: TextAlign.center,
        style: theme.typography.body.sm,
      );
    }

    if (state is AuthFailed) {
      status = ErrorText(
        exception: state.exception,
        textAlign: TextAlign.center,
      );
    }

    status ??= widget.text;

    // Stretch so label/error `textAlign: center` have a full line width.
    // UnconstrainedBox keeps FOtpField at its intrinsic width and centered
    // (FLabel uses crossAxisAlignment.start, which left-aligns if expanded).
    return Column(
      mainAxisSize: .min,
      crossAxisAlignment: .stretch,
      children: [
        Text(
          l.enterSMSCodeText,
          textAlign: TextAlign.center,
          style: theme.typography.body.sm.copyWith(
            fontWeight: .w600,
            color: theme.colors.foreground,
          ),
        ),
        const SizedBox(height: 8),
        UnconstrainedBox(
          child: FOtpField(
            control: .managed(controller: controller),
            autofocus: widget.autofocus,
            autofillHints: const [AutofillHints.oneTimeCode],
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            onSubmit: (v) {
              if (v.length < 6) return;
              widget.onSubmit?.call(v);
            },
          ),
        ),
        if (status != null)
          Padding(padding: const EdgeInsets.only(top: 8), child: status),
      ],
    );
  }
}
