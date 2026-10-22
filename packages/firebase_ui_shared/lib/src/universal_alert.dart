// Copyright 2023, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';

/// Alert dialog content backed by Forui [FDialog].
///
/// Typically returned from a dialog route builder (e.g. [showFDialog] or
/// [Navigator] dialog APIs).
class UniversalAlert extends StatelessWidget {
  final void Function() onConfirm;
  final void Function() onCancel;

  final String title;
  final String message;

  final String confirmButtonText;
  final String cancelButtonText;

  const UniversalAlert({
    super.key,
    required this.onConfirm,
    required this.onCancel,
    required this.title,
    required this.confirmButtonText,
    required this.cancelButtonText,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return FDialog(
      builder: (context, style) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: .min,
            crossAxisAlignment: .stretch,
            children: [
              Text(title, style: style.titleTextStyle),
              const SizedBox(height: 8),
              Text(message, style: style.bodyTextStyle),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: .end,
                spacing: 8,
                children: [
                  FButton(
                    variant: .ghost,
                    mainAxisSize: .min,
                    onPress: onCancel,
                    child: Text(cancelButtonText),
                  ),
                  FButton(
                    variant: .destructive,
                    mainAxisSize: .min,
                    onPress: onConfirm,
                    child: Text(confirmButtonText),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
