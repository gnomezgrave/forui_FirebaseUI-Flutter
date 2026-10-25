// Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// ignore_for_file: constant_identifier_names

import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';
import 'package:forui_firebase_ui_auth/forui_firebase_ui_auth.dart';

const GOOGLE_PROVIDER_ID = 'google.com';
const APPLE_PROVIDER_ID = 'apple.com';
const TWITTER_PROVIDER_ID = 'twitter.com';
const FACEBOOK_PROVIDER_ID = 'facebook.com';
const PHONE_PROVIDER_ID = 'phone';
const PASSWORD_PROVIDER_ID = 'password';

/// Resolves an icon given a [providerId].
///
/// ```dart
/// final icon = providerIcon(context, 'google.com');
/// Icon(icon);
/// ```
Widget providerIcon(BuildContext context, AuthProvider provider) {
  final providerId = provider.providerId;

  final IconData? data;
  switch (providerId) {
    case GOOGLE_PROVIDER_ID:
      data = SocialIcons.google;
      break;
    case APPLE_PROVIDER_ID:
      data = SocialIcons.apple;
      break;
    case TWITTER_PROVIDER_ID:
      data = SocialIcons.twitter;
      break;
    case FACEBOOK_PROVIDER_ID:
      data = SocialIcons.facebook;
      break;
    case PHONE_PROVIDER_ID:
      data = FLucideIcons.phone;
      break;
    case PASSWORD_PROVIDER_ID:
      data = FLucideIcons.mail;
      break;
    default:
      data = null;
  }

  if (data != null) {
    return Icon(data);
  }

  if (provider is OAuthProvider) {
    final brightness = context.theme.colors.brightness;
    return provider.style.iconWidget.getValue(brightness);
  }

  throw Exception('Unknown provider: $providerId');
}
