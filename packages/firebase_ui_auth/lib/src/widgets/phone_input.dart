// Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:firebase_ui_localizations/firebase_ui_localizations.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';
import '../validators.dart';

import '../widgets/internal/universal_text_form_field.dart';

part '../configs/countries.dart';

class _CountryCodeItem {
  final String countryCode;
  final String phoneCode;
  final String name;

  _CountryCodeItem({
    required this.countryCode,
    required this.phoneCode,
    required this.name,
  });

  static _CountryCodeItem fromJson(Map<String, String> data) {
    return _CountryCodeItem(
      countryCode: data['countryCode']!,
      phoneCode: data['phoneCode']!,
      name: data['name']!,
    );
  }
}

typedef SubmitCallback = void Function(String value);

/// {@template ui.auth.widgets.phone_input}
/// An input that allows to enter a phone number and select a country code.
/// {@endtemplate}
class PhoneInput extends StatefulWidget {
  /// A callback that is being called when the input is submitted.
  final SubmitCallback? onSubmit;

  /// An initial country code that should be selected in the country code
  /// picker.
  final String? initialCountryCode;

  /// Whether the phone input text field should be focused as soon as it's visible.
  final bool autoFocus;

  /// Returns a phone number from the [PhoneInput] that was provided a [key].
  static String? getPhoneNumber(GlobalKey<PhoneInputState> key) {
    final state = key.currentState!;

    if (state.formKey.currentState!.validate()) {
      return state.phoneNumber;
    }

    return null;
  }

  /// {@macro ui.auth.widgets.phone_input}
  const PhoneInput({
    super.key,
    this.initialCountryCode,
    this.autoFocus = true,
    this.onSubmit,
  });

  @override
  PhoneInputState createState() => PhoneInputState();
}

/// A state of the [PhoneInput].
///
/// Shouldn't be used directly.
/// Should be used only to construct a key for phone input.
///
/// ```dart
/// final key = GlobalKey<PhoneInputState>();
/// return PhoneInput(key: key);
/// ```
class PhoneInputState extends State<PhoneInput> {
  late final countryController = TextEditingController()
    ..addListener(_onCountryChanged);
  final numberController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  final numberFocusNode = FocusNode();

  String get phoneNumber =>
      '+${countryController.text}${numberController.text}';

  String? country;
  bool isValidCountryCode = true;

  // ignore: library_private_types_in_public_api
  _CountryCodeItem? countryCodeItem;

  void _onSubmitted(void _) {
    if (formKey.currentState!.validate()) {
      widget.onSubmit?.call(phoneNumber);
    }
  }

  @override
  void initState() {
    _setCountry(countryCode: widget.initialCountryCode);
    super.initState();
  }

  void _setCountry({
    String? phoneCode,
    String? countryCode,
    bool updateCountryInput = true,
  }) {
    try {
      final newItem = countries.firstWhere(
        (element) =>
            element.countryCode == countryCode ||
            element.phoneCode == phoneCode,
      );

      if (phoneCode != null &&
          newItem.phoneCode == countryCodeItem?.phoneCode) {
        return;
      }

      countryCodeItem = newItem;
      isValidCountryCode = true;
    } catch (_) {
      countryCodeItem = null;
      isValidCountryCode = false;
    }

    if (updateCountryInput) {
      countryController.text = countryCodeItem?.phoneCode ?? '';
    }
  }

  void _onCountryChanged() {
    setState(() {
      _setCountry(phoneCode: countryController.text, updateCountryInput: false);
    });
  }

  @override
  void dispose() {
    countryController.dispose();
    numberController.dispose();
    numberFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = FirebaseUILocalizations.labelsOf(context);
    final countryItems = {
      for (final country in countries) country.name: country.countryCode,
    };

    return Form(
      key: formKey,
      child: Column(
        children: [
          FSelect<String>.search(
            items: countryItems,
            hint: countryController.text.isNotEmpty && !isValidCountryCode
                ? l.invalidCountryCode
                : l.chooseACountry,
            control: .lifted(
              value: countryCodeItem?.countryCode,
              onChange: (code) {
                if (code != null) {
                  setState(() {
                    _setCountry(countryCode: code);
                  });
                }
              },
            ),
            filter: (query) {
              final q = query.toLowerCase();
              return [
                for (final country in countries)
                  if (country.name.toLowerCase().contains(q) ||
                      country.phoneCode.contains(q) ||
                      country.countryCode.toLowerCase().contains(q))
                    country.countryCode,
              ];
            },
          ),
          const SizedBox(height: 16),
          Directionality(
            textDirection: TextDirection.ltr,
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 90,
                    child: UniversalTextFormField(
                      autofillHints: const [
                        AutofillHints.telephoneNumberCountryCode,
                      ],
                      controller: countryController,
                      prefix: const Padding(
                        padding: EdgeInsetsDirectional.only(
                          start: 12,
                          end: 4,
                        ),
                        child: Text('+'),
                      ),
                      placeholder: l.countryCode,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      keyboardType: TextInputType.phone,
                      validator: NotEmpty('').validate,
                      onSubmitted: (_) {
                        numberFocusNode.requestFocus();
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: UniversalTextFormField(
                      autofillHints: const [
                        AutofillHints.telephoneNumberNational,
                      ],
                      autofocus: widget.autoFocus,
                      focusNode: numberFocusNode,
                      controller: numberController,
                      placeholder: l.phoneInputLabel,
                      validator: Validator.validateAll([
                        NotEmpty(l.phoneNumberIsRequiredErrorText),
                        PhoneValidator(l.phoneNumberInvalidErrorText),
                      ]),
                      onSubmitted: _onSubmitted,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      keyboardType: TextInputType.phone,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
