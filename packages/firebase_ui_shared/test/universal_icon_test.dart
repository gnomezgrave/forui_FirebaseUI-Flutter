// Copyright 2023, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:forui_firebase_ui_shared/firebase_ui_shared.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';

import 'test_app.dart';

void main() {
  group('UniversalIcon', () {
    testWidgets('renders the given icon', (tester) async {
      await tester.pumpWidget(
        foruiTestApp(
          child: const FScaffold(
            child: UniversalIcon(icon: FLucideIcons.check),
          ),
        ),
      );

      expect(find.byIcon(FLucideIcons.check), findsOneWidget);
    });
  });
}
