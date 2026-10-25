// Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:firebase_auth/firebase_auth.dart' as fba;
import 'package:flutter/foundation.dart';
import 'package:forui_firebase_ui_auth/src/auth_controller.dart';
import 'package:forui_firebase_ui_auth/src/oauth/oauth_provider_button_style.dart';
import 'package:forui_firebase_ui_auth/src/providers/auth_provider.dart';

/// A listener of the [OAuthProvider].
/// See also:
///  * [OAuthFlow]
abstract class OAuthListener extends AuthListener {}

/// {@template ui.oauth.oauth_provider}
/// An [AuthProvider] that allows to authenticate using OAuth.
/// {@endtemplate}
abstract class OAuthProvider
    extends AuthProvider<OAuthListener, fba.OAuthCredential> {
  @override
  late OAuthListener authListener;

  /// {@macro ui.oauth.themed_oauth_provider_button_style}
  ThemedOAuthProviderButtonStyle get style;

  String get defaultRedirectUri =>
      'https://${auth.app.options.projectId}.firebaseapp.com/__/auth/handler';

  void signIn(TargetPlatform platform, AuthAction action) {
    authListener.onBeforeSignIn();
    platformSignIn(platform, action);
  }

  /// Redirects the flow to mobile or desktop sign-in based on [platform].
  ///
  /// Concrete OAuth packages typically implement this via
  /// `PlatformSignInMixin` from `forui_firebase_ui_oauth`.
  void platformSignIn(TargetPlatform platform, AuthAction action);

  Future<void> logOutProvider();
}
