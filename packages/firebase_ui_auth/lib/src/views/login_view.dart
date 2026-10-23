// Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:firebase_auth/firebase_auth.dart' as fba;
import 'package:forui_firebase_ui_auth/forui_firebase_ui_auth.dart';
import 'package:forui_firebase_ui_localizations/forui_firebase_ui_localizations.dart';
import 'package:forui_firebase_ui_oauth/forui_firebase_ui_oauth.dart'
    hide OAuthProviderButtonBase;
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart' hide Title;
import 'package:forui/forui.dart';

import '../widgets/internal/title.dart';

typedef AuthViewContentBuilder = Widget Function(
  BuildContext context,
  AuthAction action,
);

/// {@template ui.auth.views.login_view}
/// A view that could be used to build a custom [SignInScreen] or
/// [RegisterScreen].
/// {@endtemplate}
class LoginView extends StatefulWidget {
  /// {@macro ui.auth.auth_controller.auth}
  final fba.FirebaseAuth? auth;

  /// {@macro ui.auth.auth_action}
  final AuthAction action;

  /// Indicates whether icon-only or icon and text OAuth buttons should be used.
  /// Icon-only buttons are placed in a row.
  final OAuthButtonVariant? oauthButtonVariant;
  final bool? showTitle;
  final String? email;

  /// {@template ui.auth.views.login_view.title_style}
  /// Style for the "Sign in" / "Register" title.
  /// {@endtemplate}
  final TextStyle? titleStyle;

  /// Whether the "Login/Register" link should be displayed. The link changes
  /// the type of the [AuthAction] from [AuthAction.signIn]
  /// and [AuthAction.signUp] and vice versa.
  final bool? showAuthActionSwitch;

  /// {@template ui.auth.views.login_view.footer_builder}
  /// A returned widget would be placed down the authentication related widgets.
  /// {@endtemplate}
  final AuthViewContentBuilder? footerBuilder;

  /// {@template ui.auth.views.login_view.subtitle_builder}
  /// A returned widget would be placed up the authentication related widgets.
  /// {@endtemplate}
  final AuthViewContentBuilder? subtitleBuilder;

  final List<AuthProvider> providers;

  /// A label that would be used for the "Sign in" button.
  final String? actionButtonLabelOverride;

  /// {@macro ui.auth.widgets.email_from.showPasswordVisibilityToggle}
  final bool showPasswordVisibilityToggle;

  /// {@macro ui.auth.views.login_view}
  const LoginView({
    super.key,
    required this.action,
    required this.providers,
    this.oauthButtonVariant = OAuthButtonVariant.icon_and_text,
    this.auth,
    this.showTitle = true,
    this.email,
    this.titleStyle,
    this.showAuthActionSwitch,
    this.footerBuilder,
    this.subtitleBuilder,
    this.actionButtonLabelOverride,
    this.showPasswordVisibilityToggle = false,
  });

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  late AuthAction _action = widget.action;
  bool get _showTitle => widget.showTitle ?? true;
  bool get _showAuthActionSwitch => widget.showAuthActionSwitch ?? true;
  bool _buttonsBuilt = false;

  void setAction(AuthAction action) {
    setState(() {
      _action = action;
    });
  }

  Widget _buildOAuthButtons(TargetPlatform platform) {
    final oauthProviders = widget.providers.whereType<OAuthProvider>().where(
      (element) => element.supportsPlatform(platform),
    );

    _buttonsBuilt = true;

    final oauthButtonsList = oauthProviders.map((provider) {
      return OAuthProviderButton(
        provider: provider,
        auth: widget.auth,
        action: _action,
        variant: widget.oauthButtonVariant,
      );
    }).toList();
    Widget? button;
    if (widget.oauthButtonVariant == OAuthButtonVariant.icon_and_text) {
      button = Column(mainAxisSize: .min, children: oauthButtonsList);
    } else {
      // Align so a stretched parent Column doesn't force the row full-width
      // (which made spaceBetween pin icons to the edges).
      button = Row(
        mainAxisAlignment: .center,
        mainAxisSize: .min,
        children: oauthButtonsList,
      );
    }
    return Padding(padding: const EdgeInsets.only(top: 2), child: button);
  }

  void _handleDifferentAuthAction(BuildContext context) {
    if (_action == AuthAction.signIn) {
      setState(() {
        _action = AuthAction.signUp;
      });
    } else {
      setState(() {
        _action = AuthAction.signIn;
      });
    }
  }

  List<Widget> _buildHeader(BuildContext context) {
    final l = FirebaseUILocalizations.labelsOf(context);
    final theme = context.theme;

    late String title;
    late String hint;
    late String actionText;

    if (_action == AuthAction.signIn) {
      title = l.signInText;
      hint = l.registerHintText;
      actionText = l.registerText;
    } else if (_action == AuthAction.signUp) {
      title = l.registerText;
      hint = l.signInHintText;
      actionText = l.signInText;
    }

    final hintStyle = theme.typography.body.sm.copyWith(
      color: theme.colors.mutedForeground,
    );
    final actionStyle = theme.typography.body.sm.copyWith(
      color: theme.colors.primary,
      fontWeight: .w600,
    );

    return [
      Title(text: title, style: widget.titleStyle),
      const SizedBox(height: 16),
      if (widget.subtitleBuilder != null)
        widget.subtitleBuilder!(context, _action),
      if (_showAuthActionSwitch) ...[
        Text.rich(
          TextSpan(
            children: [
              TextSpan(text: '$hint ', style: hintStyle),
              TextSpan(
                text: actionText,
                style: actionStyle,
                mouseCursor: SystemMouseCursors.click,
                recognizer: TapGestureRecognizer()
                  ..onTap = () => _handleDifferentAuthAction(context),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
      ],
    ];
  }

  @override
  void didUpdateWidget(covariant LoginView oldWidget) {
    if (oldWidget.action != widget.action) {
      _action = widget.action;
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    final l = FirebaseUILocalizations.labelsOf(context);
    final platform = defaultTargetPlatform;
    _buttonsBuilt = false;

    return Column(
      mainAxisSize: .min,
      crossAxisAlignment: .stretch,
      children: [
        if (_showTitle) ..._buildHeader(context),
        for (var provider in widget.providers)
          if (provider.supportsPlatform(platform))
            if (provider is EmailAuthProvider) ...[
              const SizedBox(height: 8),
              EmailForm(
                key: ValueKey(_action),
                auth: widget.auth,
                action: _action,
                provider: provider,
                email: widget.email,
                actionButtonLabelOverride: widget.actionButtonLabelOverride,
                showPasswordVisibilityToggle:
                    widget.showPasswordVisibilityToggle,
              ),
            ] else if (provider is PhoneAuthProvider) ...[
              const SizedBox(height: 8),
              PhoneVerificationButton(
                label: l.signInWithPhoneButtonText,
                action: _action,
                auth: widget.auth,
              ),
              const SizedBox(height: 8),
            ] else if (provider is EmailLinkAuthProvider) ...[
              const SizedBox(height: 8),
              EmailLinkSignInButton(auth: widget.auth, provider: provider),
            ] else if (provider is OAuthProvider && !_buttonsBuilt)
              _buildOAuthButtons(platform),
        if (widget.footerBuilder != null)
          widget.footerBuilder!(context, _action),
      ],
    );
  }
}
