// Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:firebase_auth/firebase_auth.dart' as fba;
import 'package:forui_firebase_ui_localizations/firebase_ui_localizations.dart';
import 'package:forui_firebase_ui_shared/firebase_ui_shared.dart';
import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';

import '../actions.dart';
import 'internal/subtitle.dart';
import 'internal/universal_icon_button.dart';
import 'internal/universal_text_form_field.dart';

/// {@template ui.auth.widgets.editable_user_display_name}
/// A widget that displays user name and allows to edit it.
/// {@endtemplate}
class EditableUserDisplayName extends StatefulWidget {
  /// {@macro ui.auth.auth_controller.auth}
  final fba.FirebaseAuth? auth;

  /// {@macro ui.auth.widgets.editable_user_display_name}
  const EditableUserDisplayName({super.key, this.auth});

  @override
  // ignore: library_private_types_in_public_api
  _EditableUserDisplayNameState createState() =>
      _EditableUserDisplayNameState();
}

class _EditableUserDisplayNameState extends State<EditableUserDisplayName> {
  fba.FirebaseAuth get auth => widget.auth ?? fba.FirebaseAuth.instance;
  String? get displayName => auth.currentUser?.displayName;

  late final ctrl = TextEditingController(text: displayName ?? '');

  late bool _editing = displayName == null;
  bool _isLoading = false;

  void _onEdit() {
    setState(() {
      _editing = true;
    });
  }

  Future<void> _finishEditing() async {
    try {
      if (displayName == ctrl.text) return;

      setState(() {
        _isLoading = true;
      });

      final previousDisplayName = displayName;
      await auth.currentUser?.updateDisplayName(ctrl.text);
      await auth.currentUser?.reload();

      if (!mounted) return;

      FirebaseUIAction.ofType<DisplayNameChangedAction>(
        context,
      )?.callback(context, previousDisplayName, ctrl.text);
    } finally {
      setState(() {
        _editing = false;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final l = FirebaseUILocalizations.labelsOf(context);

    final iconButton = UniversalIconButton(
      icon: _editing ? FLucideIcons.check : FLucideIcons.pencil,
      color: theme.colors.primary,
      onPressed: _editing ? _finishEditing : _onEdit,
    );

    if (!_editing) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 5.5),
        child: IntrinsicWidth(
          child: Row(
            children: [
              Subtitle(text: displayName ?? 'Unknown'),
              iconButton,
            ],
          ),
        ),
      );
    }

    return Row(
      children: [
        Expanded(
          child: UniversalTextFormField(
            autofocus: true,
            controller: ctrl,
            placeholder: l.name,
            onSubmitted: (_) => _finishEditing(),
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 50,
          height: 32,
          child: Stack(
            children: [
              if (_isLoading)
                const LoadingIndicator(size: 24, borderWidth: 1)
              else
                Align(alignment: .topLeft, child: iconButton),
            ],
          ),
        ),
      ],
    );
  }
}
