// Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';

class Title extends StatelessWidget {
  final String text;

  /// Overrides the default title [TextStyle].
  ///
  /// When null, uses Forui [FTypography.display] `xl2` with semibold weight.
  final TextStyle? style;

  const Title({super.key, required this.text, this.style});

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final defaultStyle = theme.typography.display.xl2.copyWith(
      fontWeight: .w600,
      color: theme.colors.foreground,
      height: 1,
    );

    return Text(text, style: defaultStyle.merge(style));
  }
}
