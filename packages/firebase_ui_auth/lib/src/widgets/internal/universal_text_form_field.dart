// Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';

/// {@template ui.auth.widgets.internal.universal_text_form_field}
/// Text form field backed by Forui [FTextFormField].
/// {@endtemplate}
class UniversalTextFormField extends StatelessWidget {
  final TextEditingController? controller;
  final String? placeholder;
  final String? Function(String?)? validator;
  final void Function(String?)? onSubmitted;
  final List<TextInputFormatter>? inputFormatters;
  final TextInputType? keyboardType;
  final bool autofocus;
  final bool obscureText;
  final FocusNode? focusNode;
  final bool? enableSuggestions;
  final bool autocorrect;
  final Widget? prefix;
  final Iterable<String>? autofillHints;
  final Widget? suffixIcon;

  const UniversalTextFormField({
    super.key,
    this.controller,
    this.prefix,
    this.placeholder,
    this.validator,
    this.onSubmitted,
    this.inputFormatters,
    this.keyboardType,
    this.autofocus = false,
    this.obscureText = false,
    this.focusNode,
    this.enableSuggestions,
    this.autocorrect = false,
    this.autofillHints,
    this.suffixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return FTextFormField(
      control: .managed(controller: controller),
      label: placeholder == null ? null : Text(placeholder!),
      focusNode: focusNode,
      autofocus: autofocus,
      obscureText: obscureText,
      autocorrect: autocorrect,
      enableSuggestions: enableSuggestions ?? true,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      autofillHints: autofillHints,
      validator: validator,
      onSubmit: onSubmitted == null ? null : (value) => onSubmitted!(value),
      prefixBuilder: prefix == null
          ? null
          : (context, style, variants) => prefix!,
      suffixBuilder: suffixIcon == null
          ? null
          : (context, style, variants) => suffixIcon!,
    );
  }
}
