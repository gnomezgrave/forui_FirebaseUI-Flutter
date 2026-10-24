// Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';

class Subtitle extends StatelessWidget {
  final String text;
  final FontWeight? fontWeight;

  const Subtitle({super.key, required this.text, this.fontWeight});

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Text(
      text,
      style: theme.typography.body.md.copyWith(
        fontWeight: fontWeight,
        color: theme.colors.mutedForeground,
      ),
    );
  }
}
