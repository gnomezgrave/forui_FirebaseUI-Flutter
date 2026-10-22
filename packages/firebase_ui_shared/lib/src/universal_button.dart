// Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';

/// {@template ui.shared.widgets.button_variant}
/// An enumeration of the possible button variants.
/// {@endtemplate}
enum ButtonVariant {
  /// button variant that is rendered as a text without a background or border.
  text,

  /// button variant that has a background.
  filled,

  /// button variant that has a border.
  outlined,
}

/// Button widget backed by Forui [FButton].
///
/// Maps [ButtonVariant] to Forui variants:
/// * [ButtonVariant.text] → [FButtonVariant.ghost]
/// * [ButtonVariant.filled] → [FButtonVariant.primary]
/// * [ButtonVariant.outlined] → [FButtonVariant.outline]
class UniversalButton extends StatelessWidget {
  /// A callback that is called when the button is pressed.
  final VoidCallback? onPressed;

  /// The text to display in the button.
  /// If [child] is provided, this will be ignored.
  final String? text;

  /// The child to display in the button.
  final Widget? child;

  /// The icon to display in the button.
  final IconData? icon;

  /// Defines the order of the icon and the label.
  /// Icon will be placed on the left if [TextDirection.ltr] and on the right
  /// if [TextDirection.rtl].
  final TextDirection? direction;

  /// The variant of the button.
  /// If not provided, [ButtonVariant.filled] will be used.
  final ButtonVariant variant;

  /// The color of the button background.
  final Color? color;

  /// The color of the button content.
  final Color? contentColor;

  const UniversalButton({
    super.key,
    this.text,
    this.child,
    this.onPressed,
    this.icon,
    this.direction = TextDirection.ltr,
    this.variant = ButtonVariant.filled,
    this.color,
    this.contentColor,
  }) : assert(text != null || child != null);

  FButtonVariant get _foruiVariant => switch (variant) {
    ButtonVariant.text => .ghost,
    ButtonVariant.filled => .primary,
    ButtonVariant.outlined => .outline,
  };

  FButtonStyleDelta get _style {
    final bg = color;
    final fg = contentColor;

    return .delta(
      decoration: bg == null ? null : .delta([.all(.shapeDelta(color: bg))]),
      contentStyle: .delta(
        // Avoid Forui's default min width overflowing tight layouts (e.g. dialogs).
        constraints: const BoxConstraints(),
        textStyle: fg == null ? null : .delta([.all(.delta(color: fg))]),
        iconStyle: fg == null ? null : .delta([.all(.delta(color: fg))]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final label = child ?? Text(text!);
    final iconWidget = icon == null
        ? null
        : Icon(icon, size: 20, color: contentColor);

    final prefix = direction == TextDirection.rtl ? null : iconWidget;
    final suffix = direction == TextDirection.rtl ? iconWidget : null;

    final buttonChild = switch (label) {
      final Text textWidget =>
        textWidget.data == null
            ? textWidget
            : Text(
                textWidget.data!,
                overflow: .ellipsis,
                textAlign: .center,
                maxLines: 1,
              ),
      _ => label,
    };

    return FButton(
      variant: _foruiVariant,
      style: _style,
      onPress: onPressed,
      prefix: prefix,
      suffix: suffix,
      mainAxisSize: .max,
      mainAxisAlignment: .center,
      // Keep label flexible so stretched buttons don't overflow in tight layouts,
      // but center the label within the available width.
      builder: (context, style, textStyle, iconStyle, progressStyle, child) {
        return Expanded(
          child: Align(
            alignment: .center,
            child: DefaultTextStyle.merge(
              style: textStyle,
              textAlign: .center,
              child: child ?? const SizedBox.shrink(),
            ),
          ),
        );
      },
      child: buttonChild,
    );
  }
}
