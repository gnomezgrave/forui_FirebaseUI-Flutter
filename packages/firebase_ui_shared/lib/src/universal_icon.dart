// Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:flutter/widgets.dart';

/// An icon widget.
class UniversalIcon extends StatelessWidget {
  final IconData icon;
  final Color? color;
  final double? size;

  const UniversalIcon({
    super.key,
    required this.icon,
    this.color,
    this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Icon(icon, color: color, size: size);
  }
}
