// Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:forui_firebase_ui_oauth/forui_firebase_ui_oauth.dart';
import 'package:forui_firebase_ui_oauth_apple/forui_firebase_ui_oauth_apple.dart';
import 'package:forui_firebase_ui_oauth_facebook/forui_firebase_ui_oauth_facebook.dart';
import 'package:forui_firebase_ui_oauth_google/forui_firebase_ui_oauth_google.dart';
import 'package:forui_firebase_ui_oauth_twitter/forui_firebase_ui_oauth_twitter.dart';
import 'package:material_ui/material_ui.dart';
import 'package:forui/forui.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const OAuthProviderButtonExample());
}

class OAuthProviderButtonExample extends StatelessWidget {
  const OAuthProviderButtonExample({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(brightness: Brightness.light, useMaterial3: true),
      builder: (context, child) =>
          FTheme(data: FTheme.neutral.light.touch, child: child!),
      home: const FScaffold(child: Content()),
    );
  }
}

class Content extends StatefulWidget {
  const Content({super.key});

  @override
  State<Content> createState() => _ContentState();
}

class _ContentState extends State<Content> {
  String? loadingProvider;

  void Function() _onTap(String provider) {
    return () {
      setState(() {
        loadingProvider = provider;
      });
    };
  }

  Widget _button(OAuthProvider provider, String label) {
    return OAuthProviderButtonBase(
      provider: provider,
      label: label,
      onTap: _onTap(provider.providerId),
      isLoading: loadingProvider == provider.providerId,
      loadingIndicator: const FCircularProgress(),
      overrideDefaultTapAction: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 350,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _button(AppleProvider(), 'Sign in with Apple'),
            _button(
              FacebookProvider(clientId: '', redirectUri: ''),
              'Sign in with Facebook',
            ),
            _button(
              GoogleProvider(clientId: '', redirectUri: '', scopes: []),
              'Sign in with Google',
            ),
            _button(
              TwitterProvider(apiKey: '', apiSecretKey: '', redirectUri: ''),
              'Sign in with Twitter',
            ),
          ],
        ),
      ),
    );
  }
}
