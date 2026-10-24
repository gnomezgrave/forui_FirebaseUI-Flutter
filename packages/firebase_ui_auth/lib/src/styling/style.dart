// Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:flutter/widgets.dart';

import 'theme.dart';

/// An abstract class that should be implemented by all styling classes.
abstract class FirebaseUIStyle {
  const FirebaseUIStyle();

  /// Resolves the style object via [BuildContext] and provides a [defaultValue]
  /// if none was found.
  static T ofType<T extends FirebaseUIStyle>(
    BuildContext context,
    T defaultValue,
  ) {
    final el = context
        .getElementForInheritedWidgetOfExactType<FirebaseUITheme>();
    if (el == null) return defaultValue;

    context.dependOnInheritedElement(el, aspect: T);
    final style = (el as FirebaseUIThemeElement).styles[T];

    if (style == null) return defaultValue;
    return style as T;
  }

  /// Wires the style with the widget tree and makes sure it is accessible
  /// from the [child] or its descendants.
  Widget mount({required Widget child}) {
    return FirebaseUITheme(styles: {this}, child: child);
  }
}
