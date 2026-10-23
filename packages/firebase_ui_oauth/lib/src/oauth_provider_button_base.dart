// Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:firebase_auth/firebase_auth.dart' as fba;
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:forui_firebase_ui_auth/firebase_ui_auth.dart';
import 'package:forui_firebase_ui_oauth/firebase_ui_oauth.dart';
import 'package:forui/forui.dart';

/// {@template ui.oauth.oauth_provider_button_base.error_builder}
/// A builder that is invoked to build a widget that indicates an error.
/// {@endtemplate}
typedef ErrorBuilder = Widget Function(Exception e);

/// {@template ui.oauth.oauth_provider_button_base.different_providers_found_callback}
/// A callback that is being called when there are different oauth providers
/// associated with the same email.
/// {@endtemplate}
typedef DifferentProvidersFoundCallback = void Function(
  List<String> providers,
  fba.AuthCredential? credential,
);

/// {@template ui.oauth.oauth_provider_button_base.signed_in_callback}
/// A callback that is being called when the user signs in.
/// {@endtemplate}
typedef SignedInCallback = void Function(fba.UserCredential credential);

/// {@template ui.oauth.oauth_provider_button_base}
/// A base widget that allows authentication using OAuth providers.
/// {@endtemplate}
class OAuthProviderButtonBase extends StatefulWidget {
  /// {@template ui.oauth.oauth_provider_button.label}
  /// Text that would be displayed on the button.
  /// {@endtemplate}
  final String label;

  /// {@template ui.oauth.oauth_provider_button.size}
  /// Font size of the button label. Padding of the buttons is calculated to
  /// meet the provider design requirements.
  /// {@endtemplate}
  final double size;
  final double _padding;

  /// {@template ui.oauth.oauth_provider_button.loading_indicator}
  /// A widget that would be displayed while the button is in loading state.
  /// {@endtemplate}
  final Widget loadingIndicator;

  /// {@macro ui.auth.auth_action}
  final AuthAction? action;

  /// {@macro ui.auth.auth_controller.auth}
  final fba.FirebaseAuth? auth;

  /// {@template ui.oauth.oauth_provider_button.on_tap}
  /// A callback that is being called when the button is tapped.
  /// {@endtemplate}
  final void Function()? onTap;

  /// {@macro ui.oauth.oauth_provider}
  final OAuthProvider provider;

  /// {@macro ui.oauth.oauth_provider_button_base.different_providers_found_callback}
  final DifferentProvidersFoundCallback? onDifferentProvidersFound;

  /// {@macro ui.oauth.oauth_provider_button_base.signed_in_callback}
  final SignedInCallback? onSignedIn;

  /// {@template ui.oauth.oauth_provider_button_base.on_error}
  /// A callback that is being called when an error occurs.
  /// {@endtemplate}
  final void Function(Exception exception)? onError;

  /// {@template ui.oauth.oauth_provider_button_base.on_cancelled}
  /// A callback that is being called when the user cancels the sign in.
  /// {@endtemplate}
  final VoidCallback? onCancelled;

  /// {@template ui.oauth.oauth_provider_button_base.override_default_tap_action}
  /// Indicates whether the default tap action should be overridden.
  /// If set to `true`, authentcation logic is not executed and should be
  /// handled by the user.
  /// {@endtemplate}
  final bool overrideDefaultTapAction;

  /// {@template ui.oauth.oauth_provider_button_base.is_loading}
  /// Indicates whether the sign in process is in progress.
  /// {@endtemplate}
  final bool isLoading;

  const OAuthProviderButtonBase({
    super.key,

    /// {@macro ui.oauth.oauth_provider_button.label}
    required this.label,

    /// {@macro ui.oauth.oauth_provider_button.loading_indicator}
    required this.loadingIndicator,

    /// {@macro ui.oauth.oauth_provider}
    required this.provider,

    /// {@macro ui.oauth.oauth_provider_button.on_tap}
    this.onTap,

    /// {@macro ui.auth.auth_controller.auth}
    this.auth,

    /// {@macro ui.auth.auth_action}
    this.action,

    /// {@macro ui.oauth.oauth_provider_button_base.different_providers_found_callback}
    this.onDifferentProvidersFound,

    /// {@macro ui.oauth.oauth_provider_button_base.signed_in_callback}
    this.onSignedIn,

    /// {@macro ui.oauth.oauth_provider_button_base.override_default_tap_action}
    this.overrideDefaultTapAction = false,

    /// {@macro ui.oauth.oauth_provider_button.size}
    this.size = 19,

    /// {@macro ui.oauth.oauth_provider_button_base.is_loading}
    this.isLoading = false,

    /// {@macro ui.oauth.oauth_provider_button_base.on_error}
    this.onError,

    /// {@macro ui.oauth.oauth_provider_button_base.on_cancelled}
    this.onCancelled,
  }) : assert(!overrideDefaultTapAction || onTap != null),
       _padding = size * 1.33 / 2;

  @override
  State<OAuthProviderButtonBase> createState() =>
      _OAuthProviderButtonBaseState();
}

class _OAuthProviderButtonBaseState extends State<OAuthProviderButtonBase>
    implements OAuthListener {
  @override
  late final OAuthProvider provider = widget.provider;

  late bool isLoading = widget.isLoading;

  @override
  void initState() {
    super.initState();

    provider.auth = widget.auth ?? fba.FirebaseAuth.instance;
    provider.authListener = this;
  }

  void _signIn() {
    if (widget.overrideDefaultTapAction) {
      widget.onTap!.call();
    } else {
      provider.signIn(
        defaultTargetPlatform,
        widget.action ?? AuthAction.signIn,
      );
    }
  }

  /// Prefix glyph size relative to the label font size. Glyph-only SVGs fill
  /// this box; keep close to 1 so logos match capital-letter height.
  static const _prefixIconToTextScale = 1;

  /// Inset around the glyph inside an icon-only button.
  static const _iconOnlyPadding = 8.0;

  /// Icon-only buttons are larger than the labelled-button height so the logo
  /// can stay big while still having clear padding.
  static const _iconOnlyExtentScale = 1.35;

  double _prefixIconSizeFor(double fontSize) =>
      fontSize * _prefixIconToTextScale;

  Widget _providerIcon(OAuthProviderButtonStyle style, double iconSize) {
    // Fixed square + contain keeps the glyph optically centered with the label
    // (provider SVGs are glyph-only with tight viewBoxes).
    return SizedBox.square(
      dimension: iconSize,
      child: Center(
        child: SvgPicture.string(
          style.iconSrc,
          width: iconSize,
          height: iconSize,
          fit: BoxFit.contain,
          alignment: Alignment.center,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final brightness = context.theme.colors.brightness;
    final style = provider.style.withBrightness(brightness);
    // Labelled-button height (pre-Forui formula). Icon-only uses a larger square.
    final labelledExtent = widget.size + widget._padding * 2;
    final iconOnlyExtent = labelledExtent * _iconOnlyExtentScale;
    final margin = labelledExtent / 10;
    final fontSize = widget.size;
    final prefixIconSize = _prefixIconSizeFor(fontSize);
    final iconOnlyGlyphSize = iconOnlyExtent - _iconOnlyPadding * 1.5;
    final isIconOnly = widget.label.isEmpty;

    final buttonStyle = FButtonStyleDelta.delta(
      decoration: .delta([
        .all(
          .shapeDelta(
            color: isIconOnly
                ? style.iconBackgroundColor
                : style.backgroundColor,
          ),
        ),
      ]),
      contentStyle: .delta(
        constraints: const BoxConstraints(),
        // height: 1 so the text box matches [fontSize] and centers with the icon.
        textStyle: .delta([
          .all(.delta(color: style.color, fontSize: fontSize, height: 1)),
        ]),
        iconStyle: .delta([
          .all(.delta(color: style.color, size: prefixIconSize)),
        ]),
      ),
      iconContentStyle: .delta(
        constraints: BoxConstraints.tightFor(
          width: iconOnlyExtent,
          height: iconOnlyExtent,
        ),
        padding: .value(const EdgeInsets.all(_iconOnlyPadding)),
        iconStyle: .delta([
          .all(.delta(color: style.color, size: iconOnlyGlyphSize)),
        ]),
      ),
    );

    final Widget content;
    if (isLoading) {
      content = SizedBox.square(
        dimension: isIconOnly ? iconOnlyGlyphSize : prefixIconSize,
        child: widget.loadingIndicator,
      );
    } else if (isIconOnly) {
      content = Padding(
        padding: const EdgeInsets.all(_iconOnlyPadding),
        child: _providerIcon(style, iconOnlyGlyphSize),
      );
    } else {
      content = Text(
        widget.label,
        overflow: .ellipsis,
        textAlign: .center,
        maxLines: 1,
      );
    }

    final button = isIconOnly
        ? FButton.icon(
            variant: .outline,
            style: buttonStyle,
            onPress: isLoading ? null : _signIn,
            child: content,
          )
        : FButton(
            variant: .outline,
            style: buttonStyle,
            onPress: isLoading ? null : _signIn,
            mainAxisSize: .max,
            mainAxisAlignment: .center,
            crossAxisAlignment: .center,
            prefixBuilder: isLoading
                ? null
                : (
                    context,
                    buttonStyle,
                    textStyle,
                    iconStyle,
                    progressStyle,
                    child,
                  ) {
                    final resolved = _prefixIconSizeFor(
                      textStyle.fontSize ?? fontSize,
                    );
                    return _providerIcon(style, resolved);
                  },
            child: content,
          );

    return LayoutFlowAwarePadding(
      padding: EdgeInsets.all(margin),
      child: button,
    );
  }

  @override
  fba.FirebaseAuth get auth => widget.auth ?? fba.FirebaseAuth.instance;

  void safeSetState(void Function() update) {
    if (mounted) {
      setState(update);
    }
  }

  @override
  void onCredentialReceived(fba.AuthCredential credential) {
    safeSetState(() {
      isLoading = true;
    });
  }

  @override
  void onMFARequired(fba.MultiFactorResolver resolver) {
    startMFAVerification(context: context, resolver: resolver);
  }

  @override
  void onBeforeSignIn() {
    safeSetState(() {
      isLoading = true;
    });
  }

  @override
  void onCredentialLinked(fba.AuthCredential credential) {
    safeSetState(() {
      isLoading = false;
    });
  }

  @override
  void onSignedIn(fba.UserCredential credential) {
    safeSetState(() {
      isLoading = false;
    });

    widget.onSignedIn?.call(credential);
  }

  @override
  void onError(Object error) {
    safeSetState(() {
      isLoading = false;
    });

    try {
      defaultOnAuthError(provider, error);
    } on Exception catch (err) {
      widget.onError?.call(err);
    }
  }

  @override
  void onCanceled() {
    safeSetState(() {
      isLoading = false;
    });

    widget.onCancelled?.call();
  }

  @override
  void didUpdateWidget(covariant OAuthProviderButtonBase oldWidget) {
    if (oldWidget.isLoading != widget.isLoading) {
      isLoading = widget.isLoading;
    }

    super.didUpdateWidget(oldWidget);
  }
}
