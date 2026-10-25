// Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:firebase_auth/firebase_auth.dart' as fba;
import 'package:forui_firebase_ui_localizations/forui_firebase_ui_localizations.dart';
import 'package:flutter/services.dart' show PlatformException;
import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';

import '../flows/phone_auth_flow.dart';

String? localizedErrorText(
  String? errorCode,
  FirebaseUILocalizationLabels labels,
) {
  switch (errorCode) {
    case 'user-not-found':
      return labels.userNotFoundErrorText;
    case 'email-already-in-use':
      return labels.emailTakenErrorText;
    case 'too-many-requests':
      return labels.accessDisabledErrorText;
    case 'wrong-password':
    // Identity Toolkit / Auth emulator often return this instead of
    // wrong-password for email+password failures.
    case 'invalid-credential':
    case 'INVALID_LOGIN_CREDENTIALS':
      return labels.wrongOrNoPasswordErrorText;
    case 'credential-already-in-use':
      return labels.credentialAlreadyInUseErrorText;
    case 'invalid-verification-code':
      return labels.invalidVerificationCodeErrorText;
    case 'email-link-wrong-device':
      return labels.emailLinkWrongDeviceErrorText;
    case 'email-link-different-anonymous-user':
      return labels.emailLinkDifferentAnonymousUserErrorText;
    case 'weak-password':
      return labels.weakPasswordErrorText;

    default:
      return null;
  }
}

/// {@template ui.auth.widgets.error_text}
/// A widget which displays error text for a given Firebase error code.
/// {@endtemplate}
class ErrorText extends StatelessWidget {
  /// A way to customize localized error messages for [FirebaseAuthException].
  static String Function(
    BuildContext context,
    fba.FirebaseAuthException exception,
  )?
  localizeError;

  /// A way to customize error message for [PlatformException].
  static String Function(BuildContext context, PlatformException exception)?
  localizePlatformError;

  /// A way to customize the widget that is used across the library to show
  /// error hints. By default a localized text is used with
  /// [FColors.destructive].
  static Widget Function(BuildContext context, String message)? builder;

  /// An exception that contains error details.
  /// Often this is a [FirebaseAuthException].
  final Exception exception;

  /// How the text should be aligned horizontally.
  final TextAlign? textAlign;

  /// {@macro ui.auth.widgets.error_text}
  const ErrorText({super.key, required this.exception, this.textAlign});

  @override
  Widget build(BuildContext context) {
    final color = context.theme.colors.destructive;
    final l = FirebaseUILocalizations.labelsOf(context);
    String text = l.unknownError;

    if (exception is AutoresolutionFailedException) {
      text = l.smsAutoresolutionFailedError;
    }

    if (exception is fba.FirebaseAuthException) {
      if (localizeError != null) {
        text = localizeError!(context, exception as fba.FirebaseAuthException);
      } else {
        final e = exception as fba.FirebaseAuthException;
        final code = e.code;
        final newText = localizedErrorText(code, l) ?? e.message;

        if (newText != null) {
          text = newText;
        }
      }
    }

    if (exception is PlatformException && localizePlatformError != null) {
      text = localizePlatformError!(context, exception as PlatformException);
    }

    if (builder != null) {
      return builder!(context, text);
    }

    return Text(
      text,
      textAlign: textAlign,
      style: TextStyle(color: color),
    );
  }
}
