// Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';

/// Icon button backed by Forui [FButton.icon].
class UniversalIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final double? size;
  final Color? color;

  const UniversalIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.size,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return FButton.icon(
      variant: .ghost,
      onPress: onPressed,
      child: Icon(icon, size: size, color: color),
    );
  }
}
