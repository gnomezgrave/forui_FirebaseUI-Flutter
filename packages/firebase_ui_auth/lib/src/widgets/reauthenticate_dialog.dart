// Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:firebase_auth/firebase_auth.dart' as fba;
import 'package:forui_firebase_ui_shared/forui_firebase_ui_shared.dart';
import 'package:flutter/widgets.dart' hide Title;
import 'package:forui_firebase_ui_auth/forui_firebase_ui_auth.dart';
import 'package:forui_firebase_ui_localizations/forui_firebase_ui_localizations.dart';
import 'package:forui/forui.dart';

import 'internal/title.dart';

/// {@template ui.auth.widgets.reauthenticate_dialog}
/// A dialog that prompts the user to re-authenticate their account
/// Used to confirm destructive actions (like account deletion or disabling MFA).
/// {@endtemplate}
class ReauthenticateDialog extends StatelessWidget {
  /// {@macro ui.auth.auth_controller.auth}
  final fba.FirebaseAuth? auth;

  /// A list of all supported auth providers.
  final List<AuthProvider> providers;

  /// A callback that is being called when the user has successfully signed in.
  final VoidCallback? onSignedIn;

  /// {@macro ui.auth.views.reauthenticate_view.on_phone_verified}
  final VoidCallback? onPhoneVerfifed;

  /// A label that would be used for the "Sign in" button.
  final String? actionButtonLabelOverride;

  /// {@macro ui.auth.widgets.reauthenticate_dialog}
  const ReauthenticateDialog({
    super.key,
    required this.providers,
    this.auth,
    this.onSignedIn,
    this.actionButtonLabelOverride,
    this.onPhoneVerfifed,
  });

  @override
  Widget build(BuildContext context) {
    final l = FirebaseUILocalizations.labelsOf(context);

    const verticalPadding = EdgeInsets.symmetric(vertical: 16);
    const horizontalPadding = EdgeInsets.symmetric(horizontal: 16);

    final reauthenticateView = ReauthenticateView(
      auth: auth,
      providers: providers,
      onSignedIn: onSignedIn,
      onPhoneVerfifed: onPhoneVerfifed,
      actionButtonLabelOverride: actionButtonLabelOverride,
    );

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: FDialog(
          builder: (context, style) {
            return Padding(
              padding: verticalPadding,
              child: Column(
                mainAxisSize: .min,
                crossAxisAlignment: .stretch,
                children: [
                  Padding(
                    padding: horizontalPadding,
                    child: Title(text: l.verifyItsYouText),
                  ),
                  const SizedBox(height: 16),
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: MediaQuery.sizeOf(context).shortestSide / 1.5,
                    ),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        children: [
                          reauthenticateView,
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: horizontalPadding.copyWith(
                      top: verticalPadding.top,
                    ),
                    child: UniversalButton(
                      text: l.cancelButtonLabel,
                      variant: ButtonVariant.text,
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
