// Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:firebase_auth/firebase_auth.dart' as fba;
import 'package:forui_firebase_ui_auth/forui_firebase_ui_auth.dart';
import 'package:forui_firebase_ui_oauth/forui_firebase_ui_oauth.dart';
import 'package:forui_firebase_ui_shared/forui_firebase_ui_shared.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';

class FakeAssetBundle extends Fake implements AssetBundle {
  final String svgStr = '''<svg viewBox="0 0 10 10"></svg>''';

  @override
  Future<String> loadString(String key, {bool cache = true}) async => svgStr;
}

// Duplicated from packages/firebase_ui_oauth_google/lib/src/theme.dart
// to prevent circular dependency
const _googleBlue = Color(0xff4285f4);
const _googleWhite = Color(0xffffffff);
const _googleDark = Color(0xff757575);

const _backgroundColor = ThemedColor(_googleBlue, _googleWhite);
const _color = ThemedColor(_googleWhite, _googleDark);
const _iconBackgroundColor = ThemedColor(_googleWhite, _googleWhite);

const _iconSvg = '''
<svg viewBox="0 0 18 18" xmlns="http://www.w3.org/2000/svg">
  <path fill="#4285F4" d="M17.64,9.20454545 C17.64,8.56636364 17.5827273,7.95272727 17.4763636,7.36363636 L9,7.36363636 L9,10.845 L13.8436364,10.845 C13.635,11.97 13.0009091,12.9231818 12.0477273,13.5613636 L12.0477273,15.8195455 L14.9563636,15.8195455 C16.6581818,14.2527273 17.64,11.9454545 17.64,9.20454545 L17.64,9.20454545 Z"/>
  <path fill="#34A853" d="M9,18 C11.43,18 13.4672727,17.1940909 14.9563636,15.8195455 L12.0477273,13.5613636 C11.2418182,14.1013636 10.2109091,14.4204545 9,14.4204545 C6.65590909,14.4204545 4.67181818,12.8372727 3.96409091,10.71 L0.957272727,10.71 L0.957272727,13.0418182 C2.43818182,15.9831818 5.48181818,18 9,18 L9,18 Z"/>
  <path fill="#FBBC05" d="M3.96409091,10.71 C3.78409091,10.17 3.68181818,9.59318182 3.68181818,9 C3.68181818,8.40681818 3.78409091,7.83 3.96409091,7.29 L3.96409091,4.95818182 L0.957272727,4.95818182 C0.347727273,6.17318182 0,7.54772727 0,9 C0,10.4522727 0.347727273,11.8268182 0.957272727,13.0418182 L3.96409091,10.71 L3.96409091,10.71 Z"/>
  <path fill="#EA4335" d="M9,3.57954545 C10.3213636,3.57954545 11.5077273,4.03363636 12.4404545,4.92545455 L15.0218182,2.34409091 C13.4631818,0.891818182 11.4259091,0 9,0 C5.48181818,0 2.43818182,2.01681818 0.957272727,4.95818182 L3.96409091,7.29 C4.67181818,5.16272727 6.65590909,3.57954545 9,3.57954545 L9,3.57954545 Z"/>
</svg>
''';

const _iconSrc = ThemedIconSrc(_iconSvg, _iconSvg);

class GoogleProviderButtonStyle extends ThemedOAuthProviderButtonStyle {
  const GoogleProviderButtonStyle();

  @override
  ThemedColor get backgroundColor => _backgroundColor;

  @override
  ThemedColor get color => _color;

  @override
  ThemedIconSrc get iconSrc => _iconSrc;

  @override
  ThemedColor get iconBackgroundColor => _iconBackgroundColor;

  @override
  double get iconPadding => 1;

  @override
  String get assetsPackage => 'forui_firebase_ui_oauth_google';
}

class FakeOAuthProvider extends OAuthProvider {
  @override
  ProviderArgs get desktopSignInArgs => throw UnimplementedError();

  @override
  get firebaseAuthProvider => throw UnimplementedError();

  @override
  OAuthCredential fromDesktopAuthResult(AuthResult result) {
    throw UnimplementedError();
  }

  @override
  Future<void> logOutProvider() {
    throw UnimplementedError();
  }

  @override
  void mobileSignIn(AuthAction action) {}

  @override
  String get providerId => 'fake';

  @override
  ThemedOAuthProviderButtonStyle get style => const GoogleProviderButtonStyle();

  @override
  bool supportsPlatform(TargetPlatform platform) {
    return true;
  }
}

class FakeAuth extends Fake implements fba.FirebaseAuth {}

void main() {
  final provider = FakeOAuthProvider();

  const style = GoogleProviderButtonStyle();
  late Widget button;

  Widget renderMaterialButton([Brightness brightness = Brightness.dark]) {
    button = OAuthProviderButtonBase(
      provider: provider,
      label: 'Sign in with Google',
      loadingIndicator: const LoadingIndicator(size: 20, borderWidth: 2),
      auth: FakeAuth(),
    );

    return DefaultAssetBundle(
      bundle: FakeAssetBundle(),
      child: MaterialApp(
        theme: ThemeData(brightness: brightness),
        builder: (context, child) => FTheme(
          data: brightness == Brightness.dark
              ? FTheme.neutral.dark.touch
              : FTheme.neutral.light.touch,
          child: child!,
        ),
        home: FScaffold(child: button),
      ),
    );
  }

  group('OAuthProviderButton', () {
    testWidgets('renders label', (tester) async {
      await tester.pumpWidget(renderMaterialButton());

      final textFinder = find.text('Sign in with Google');
      expect(textFinder, findsOneWidget);
    });

    testWidgets('renders an FButton', (tester) async {
      await tester.pumpWidget(renderMaterialButton());

      expect(find.byType(FButton), findsOneWidget);
    });

    testWidgets('applies text color from style via DefaultTextStyle', (
      tester,
    ) async {
      await tester.pumpWidget(renderMaterialButton());

      final expected = style.color.getValue(Brightness.dark);
      final styleFinder = find.byWidgetPredicate((widget) {
        if (widget is! DefaultTextStyle) return false;
        final color = widget.style.color;
        return color?.r == expected.r &&
            color?.g == expected.g &&
            color?.b == expected.b;
      });

      expect(styleFinder, findsWidgets);
    });

    testWidgets('applies light theme text color from style', (tester) async {
      await tester.pumpWidget(renderMaterialButton(Brightness.light));

      final expected = style.color.getValue(Brightness.light);
      final styleFinder = find.byWidgetPredicate((widget) {
        if (widget is! DefaultTextStyle) return false;
        final color = widget.style.color;
        return color?.r == expected.r &&
            color?.g == expected.g &&
            color?.b == expected.b;
      });

      expect(styleFinder, findsWidgets);
    });

    testWidgets('renders an icon', (tester) async {
      await tester.pumpWidget(renderMaterialButton());

      final iconFinder = find.byWidgetPredicate(
        (widget) => widget is SvgPicture,
      );

      expect(iconFinder, findsOneWidget);
    });

    testWidgets('has layout flow aware padding', (tester) async {
      await tester.pumpWidget(
        DefaultAssetBundle(
          bundle: FakeAssetBundle(),
          child: MaterialApp(
            builder: (context, child) =>
                FTheme(data: FTheme.neutral.light.touch, child: child!),
            home: FScaffold(
              child: Row(
                children: [
                  Expanded(
                    child: OAuthProviderButtonBase(
                      provider: provider,
                      auth: FakeAuth(),
                      label: 'Sign in with Fake provider',
                      loadingIndicator:
                          const LoadingIndicator(size: 20, borderWidth: 2),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      expect(find.byType(LayoutFlowAwarePadding), findsOneWidget);
    });
  });
}
