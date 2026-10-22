# Firebase UI for authentication

Firebase UI for authentication provides screens and lower-level widgets for Firebase Auth, built with [Forui](https://forui.dev).

## Installation

```sh
dart pub global activate flutterfire_cli
flutter pub add firebase_core firebase_auth firebase_ui_auth forui
```

Configure Firebase:

```sh
flutterfire configure
```

Initialize Firebase and wrap your app in `FTheme`:

```dart
import 'package:forui/forui.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      builder: (context, child) => FTheme(
        data: FTheme.neutral.light.touch,
        child: child!,
      ),
      home: SignInScreen(providers: [EmailAuthProvider()]),
    );
  }
}
```

Requires Dart `^3.13.0` and Flutter **3.47+**.

## macOS entitlements

If you're building for macOS, make sure to add necessary entitlements. Learn more [from the official Flutter documentation](https://docs.flutter.dev/platform-integration/macos/building#setting-up-entitlements).

## Writing widget unit tests

```dart
setUpAll(() {
  setFirebaseUiIsTestMode(true);
});
```

Mock `FirebaseAuth` and pass it to Firebase UI widgets as needed. Test helpers should also wrap widgets in `FTheme`.

## Next steps

- Auth providers:
  - [EmailAuthProvider](./providers/email.md)
  - [EmailLinkAuthProvider](./providers/email-link.md)
  - [PhoneAuthProvider](./providers/phone.md)
  - [OAuth](./providers/oauth.md)
- [Localization](../firebase-ui-localizations.md)
- [Theming](./theming.md)
- [Navigation](./navigation.md)
- [Migration from Material Firebase UI](./migration.md)
