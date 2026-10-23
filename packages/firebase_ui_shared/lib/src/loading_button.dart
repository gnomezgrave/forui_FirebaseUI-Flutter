// Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:forui_firebase_ui_shared/forui_firebase_ui_shared.dart';
import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';

class _LoadingButtonContent extends StatelessWidget {
  final String label;
  final bool isLoading;
  final Color? color;

  const _LoadingButtonContent({
    required this.label,
    required this.isLoading,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    Widget child = Text(
      label,
      style: color == null ? null : TextStyle(color: color),
    );

    if (isLoading) {
      child = Stack(
        alignment: .center,
        children: [
          Opacity(opacity: 0, child: child),
          LoadingIndicator(size: 16, borderWidth: 1, color: color),
        ],
      );
    }

    return child;
  }
}

/// Button capable of displaying a loading indicator when [isLoading] is true.
///
/// Backed by [UniversalButton] / Forui [FButton].
class LoadingButton extends StatelessWidget {
  /// Indicates that a loading indicator should be displayed.
  final bool isLoading;

  /// The text to display in the button.
  final String label;

  /// The icon to display in the button.
  final IconData? icon;

  /// The color of the button background.
  final Color? color;

  /// The color of the button content.
  final Color? labelColor;

  /// A callback that is called when the button is pressed.
  final VoidCallback onTap;

  /// The variant of the button. See [ButtonVariant] for more information.
  final ButtonVariant variant;

  const LoadingButton({
    super.key,
    required this.label,
    required this.onTap,
    this.isLoading = false,
    this.icon,
    this.color,
    this.labelColor,
    this.variant = ButtonVariant.outlined,
  });

  @override
  Widget build(BuildContext context) {
    final content = _LoadingButtonContent(
      label: label,
      isLoading: isLoading,
      color: labelColor,
    );

    return UniversalButton(
      color: color,
      icon: icon,
      contentColor: labelColor,
      onPressed: isLoading ? null : onTap,
      variant: variant,
      child: content,
    );
  }
}
