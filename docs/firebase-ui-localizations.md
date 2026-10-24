# Firebase UI Localizations

Firebase UI for Flutter supports localization, so every single label can be customized.

## Installation

```yaml
dependencies:
  material_ui: ^1.8.0 # or a pinned version; provides GlobalMaterialLocalizations
  forui_firebase_ui_localizations: ^0.1.0
```

Material/Cupertino/Widgets localization delegates ship with `material_ui` (not `flutter_localizations`). Do not import both — the `Global*` symbols clash.

## Usage

If your app supports only a single language, and you want to override labels – you will need to provide a custom class that implements one of the [exposed localizations](https://github.com/gnomezgrave/forui_FirebaseUI-Flutter/blob/main/packages/firebase_ui_localizations/lib/src/lang).

For example, we could override the Spanish localization class and customize the email and password labels:

```dart
import 'package:forui_firebase_ui_localizations/forui_firebase_ui_localizations.dart';

// EsLocalizations is a class that provides Spanish labels. We override it here:
class LabelOverrides extends EsLocalizations {
  const LabelOverrides();

  @override
  String get emailInputLabel => 'Enter your email';

  @override
  String get passwordInputLabel => 'Enter your password';
}
```

Once created, pass the instance of `LabelOverrides` to the `localizationsDelegates` list in your `MaterialApp` (and keep wrapping Firebase UI in `FTheme`):

```dart
import 'package:forui/forui.dart';
import 'package:material_ui/material_ui.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      builder: (context, child) => FTheme(
        data: FTheme.neutral.light.touch,
        child: child!,
      ),
      localizationsDelegates: [
        // Creates an instance of FirebaseUILocalizationDelegate with overridden labels
        FirebaseUILocalizations.withDefaultOverrides(const LabelOverrides()),

        // Material + Cupertino + Widgets delegates (from material_ui)
        ...GlobalMaterialLocalizations.delegates,

        // Required for labels that are not overridden by LabelOverrides
        FirebaseUILocalizations.delegate,
      ],
      // ...
    );
  }
}
```

If you need to support multiple languages – follow the [official Flutter localization guide](https://docs.flutter.dev/ui/internationalization)
and create a `LocalizationsDelegate` that resolves to a `FirebaseUILocalizations` subclass for each locale.
