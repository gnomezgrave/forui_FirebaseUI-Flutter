// Copyright 2023, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';

/// A builder that is invoked for each progress event.
typedef TaskProgressBuilder = Widget Function(
  BuildContext context,
  double progress,
);

/// A builder that is invoked when an error occurs.
typedef ErrorBuilder = Widget Function(BuildContext context, Object? error);

class _BindTaskWidget extends StatelessWidget {
  final Task task;
  final TaskProgressBuilder builder;
  final ErrorBuilder? errorBuilder;

  const _BindTaskWidget({
    required this.task,
    required this.builder,
    this.errorBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<TaskSnapshot>(
      stream: task.snapshotEvents,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return errorBuilder?.call(context, snapshot.error) ??
              const SizedBox();
        }

        double progress;

        if (!snapshot.hasData) {
          progress = 0;
        } else {
          final taskSnapshot = snapshot.requireData;
          progress = taskSnapshot.bytesTransferred / taskSnapshot.totalBytes;
          if (progress.isNaN) progress = 0;
        }

        return builder(context, progress);
      },
    );
  }
}

/// An abstract widget that simplifies building custom progress indicators for
/// upload and download tasks.
///
/// Example implementation:
///
/// ```dart
/// class MyProgressIndicator extends TaskProgressWidget {
///   final Task task;
///
///   const MyProgressIndicator({super.key, required this.task});
///
///   @override
///   Widget buildProgressIndicator(BuildContext context, double progress) {
///     return Text('Progress: ${progress.toStringAsFixed(2)}');
///   }
/// }
/// ```
abstract class TaskProgressWidget extends StatelessWidget {
  const TaskProgressWidget({super.key});

  /// The task to track.
  Task get task;

  /// A builder that is called when an error occurs.
  ErrorBuilder? get errorBuilder;

  /// A builder that is called for each progress event.
  Widget buildProgressIndicator(BuildContext context, double progress);

  @override
  Widget build(BuildContext context) {
    return _BindTaskWidget(
      task: task,
      errorBuilder: errorBuilder,
      builder: (context, progress) {
        return buildProgressIndicator(context, progress);
      },
    );
  }
}

/// Task progress indicator backed by Forui [FDeterminateProgress].
class TaskProgressIndicator extends StatelessWidget {
  /// The task to track.
  final Task task;

  /// A builder that is called when an error occurs.
  final Widget Function(BuildContext context, Object? error)? errorBuilder;

  const TaskProgressIndicator({
    super.key,
    required this.task,
    this.errorBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return _BindTaskWidget(
      task: task,
      errorBuilder: errorBuilder,
      builder: (context, progress) {
        return FDeterminateProgress(value: progress.clamp(0.0, 1.0));
      },
    );
  }
}
