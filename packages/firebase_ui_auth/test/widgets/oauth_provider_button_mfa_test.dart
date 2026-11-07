// Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:firebase_auth/firebase_auth.dart' as fba;
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui_firebase_ui_auth/forui_firebase_ui_auth.dart';
import 'package:forui_firebase_ui_shared/forui_firebase_ui_shared.dart';
import 'package:mockito/mockito.dart';

import '../test_utils.dart';

class _MockPhoneMultiFactorInfo extends Mock
    implements fba.PhoneMultiFactorInfo {
  @override
  String get phoneNumber => '+1234567890';
}

class _MockMultiFactorSession extends Mock implements fba.MultiFactorSession {}

class _MockMultiFactorResolver extends Mock implements fba.MultiFactorResolver {
  final _session = _MockMultiFactorSession();
  final _hints = <fba.MultiFactorInfo>[_MockPhoneMultiFactorInfo()];

  @override
  fba.MultiFactorSession get session => _session;

  @override
  List<fba.MultiFactorInfo> get hints => _hints;
}

class _FakeOAuthStyle extends ThemedOAuthProviderButtonStyle {
  const _FakeOAuthStyle();

  @override
  ThemedColor get backgroundColor =>
      const ThemedColor(Color(0xff000000), Color(0xffffffff));

  @override
  ThemedColor get color =>
      const ThemedColor(Color(0xffffffff), Color(0xff000000));

  @override
  ThemedIconSrc get iconSrc => const ThemedIconSrc(
    '<svg viewBox="0 0 10 10"></svg>',
    '<svg viewBox="0 0 10 10"></svg>',
  );

  @override
  ThemedColor get iconBackgroundColor => backgroundColor;

  @override
  double get iconPadding => 0;

  @override
  String get assetsPackage => 'forui_firebase_ui_auth';
}

class _FakeOAuthProvider extends OAuthProvider {
  @override
  Future<void> logOutProvider() async {}

  @override
  void platformSignIn(TargetPlatform platform, AuthAction action) {}

  @override
  String get providerId => 'fake';

  @override
  ThemedOAuthProviderButtonStyle get style => const _FakeOAuthStyle();

  @override
  bool supportsPlatform(TargetPlatform platform) => true;
}

void main() {
  setUpAll(() {
    setFirebaseUiIsTestMode(true);
  });

  testWidgets(
    'passes button auth into startMFAVerification when MFA is required',
    (tester) async {
      final auth = MockAuth();
      final provider = _FakeOAuthProvider();

      await tester.pumpWidget(
        TestMaterialApp(
          child: OAuthProviderButtonBase(
            provider: provider,
            label: 'Sign in with Fake',
            loadingIndicator: const LoadingIndicator(size: 20, borderWidth: 2),
            auth: auth,
          ),
        ),
      );

      expect(provider.authListener, isNotNull);
      provider.authListener!.onMFARequired(_MockMultiFactorResolver());
      await tester.pumpAndSettle();

      final screen = tester.widget<SMSCodeInputScreen>(
        find.byType(SMSCodeInputScreen),
      );
      expect(screen.auth, same(auth));
    },
  );
}
