// Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:firebase_auth/firebase_auth.dart' as fba;
import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';

/// {@template ui.auth.widgets.user_avatar}
///
/// A widget that displays the user's avatar.
///
/// Shows a placeholder if user doesn't have a profile photo.
/// {@endtemplate}
class UserAvatar extends StatefulWidget {
  /// {@macro ui.auth.auth_controller.auth}
  final fba.FirebaseAuth? auth;

  /// {@template ui.auth.widgets.user_avatar.size}
  /// A size of the avatar.
  /// {@endtemplate}
  final double? size;

  /// {@template ui.auth.widgets.user_avatar.shape}
  /// Previously used to set avatar shape. Forui avatars are circular; this is
  /// kept for API compatibility and currently ignored.
  /// {@endtemplate}
  final ShapeBorder? shape;

  /// {@template ui.auth.widgets.user_avatar.placeholder_color}
  /// A color of the avatar placeholder background.
  /// {@endtemplate}
  final Color? placeholderColor;

  /// {@macro ui.auth.widgets.user_avatar}
  const UserAvatar({
    super.key,
    this.auth,
    this.size,
    this.shape,
    this.placeholderColor,
  });

  @override
  State<UserAvatar> createState() => _UserAvatarState();
}

class _UserAvatarState extends State<UserAvatar> {
  fba.FirebaseAuth get auth => widget.auth ?? fba.FirebaseAuth.instance;
  double get size => widget.size ?? 120;

  late String? photoUrl = auth.currentUser?.photoURL;

  @override
  Widget build(BuildContext context) {
    final FAvatarStyleDelta style = widget.placeholderColor == null
        ? const .context()
        : .delta(backgroundColor: widget.placeholderColor);

    if (photoUrl == null) {
      return FAvatar.raw(size: size, style: style);
    }

    return FAvatar(
      image: NetworkImage(photoUrl!),
      size: size,
      style: style,
    );
  }
}
