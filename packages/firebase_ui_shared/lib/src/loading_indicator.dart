// Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';

/// A loading indicator backed by Forui [FCircularProgress].
///
/// Centered by default when placed in an unbounded parent via [SizedBox].
class LoadingIndicator extends StatelessWidget {
  /// The size of the loading indicator.
  ///
  /// Mapped to the nearest Forui circular progress size variant.
  final double size;

  /// Previously the Material progress border width. Unused with Forui; kept for
  /// API compatibility.
  final double borderWidth;

  /// The color of the loading indicator.
  final Color? color;

  const LoadingIndicator({
    super.key,
    required this.size,
    required this.borderWidth,
    this.color,
  });

  FCircularProgressSizeVariant get _sizeVariant {
    if (size <= 14) return .xs;
    if (size <= 16) return .sm;
    if (size <= 20) return .md;
    if (size <= 24) return .lg;
    return .xl;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Center(
        child: FCircularProgress(
          size: _sizeVariant,
          style: color == null
              ? const .context()
              : .delta(iconStyle: .delta(color: color)),
        ),
      ),
    );
  }
}
