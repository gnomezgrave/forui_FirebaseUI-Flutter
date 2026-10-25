// Copyright 2026, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';

/// Wraps [child] in [FTheme] for widget tests.
Widget foruiTestApp({required Widget child}) {
  return FTheme(
    data: FTheme.neutral.light.touch,
    child: Directionality(textDirection: TextDirection.ltr, child: child),
  );
}
