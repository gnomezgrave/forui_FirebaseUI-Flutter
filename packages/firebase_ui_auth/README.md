# Firebase UI Auth

[![pub package](https://img.shields.io/pub/v/forui_firebase_ui_auth.svg)](https://pub.dev/packages/forui_firebase_ui_auth)

Firebase UI Auth widgets for Flutter, ported to [Forui](https://forui.dev). Drop in sign-in, registration, profile, and related auth screens.

Requires Dart `^3.13.0`, Flutter **3.47+**, and an `FTheme` ancestor.

## Platform support

| Feature/platform   | Android | iOS | Web              | macOS            | Windows          | Linux            |
| ------------------ | ------- | --- | ---------------- | ---------------- | ---------------- | ---------------- |
| Email              | ✓       | ✓   | ✓                | ✓                | ✓ <sup>(1)</sup> | ✓ <sup>(1)</sup> |
| Phone              | ✓       | ✓   | ✓                | ╳                | ╳                | ╳                |
| Email link         | ✓       | ✓   | ╳                | ╳                | ╳                | ╳                |
| Email verification | ✓       | ✓   | ✓ <sup>(2)</sup> | ✓ <sup>(2)</sup> | ✓ <sup>(1)</sup> | ✓ <sup>(1)</sup> |
| Sign in with Apple | ✓       | ✓   | ✓                | ✓                | ╳                | ╳                |
| Google Sign in     | ✓       | ✓   | ✓                | ✓                | ✓ <sup>(1)</sup> | ✓ <sup>(1)</sup> |
| Twitter Login      | ✓       | ✓   | ✓                | ✓                | ✓ <sup>(1)</sup> | ✓ <sup>(1)</sup> |
| Facebook Sign in   | ✓       | ✓   | ✓                | ✓                | ✓ <sup>(1)</sup> | ✓ <sup>(1)</sup> |

1. Available with [flutterfire_desktop](https://github.com/invertase/flutterfire_desktop)
2. No deep-linking into app, so email verification link opens a web page

## Installation

```sh
flutter pub add forui_firebase_ui_auth forui
```

## Example

```dart
import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:firebase_auth/firebase_auth.dart' hide EmailAuthProvider;
import 'package:forui_firebase_ui_auth/firebase_ui_auth.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final providers = [EmailAuthProvider()];

    return MaterialApp(
      builder: (context, child) => FTheme(
        data: FTheme.neutral.light.touch,
        child: child!,
      ),
      initialRoute:
          FirebaseAuth.instance.currentUser == null ? '/sign-in' : '/profile',
      routes: {
        '/sign-in': (context) {
          return SignInScreen(
            providers: providers,
            actions: [
              AuthStateChangeAction<UserCreated>((context, state) {
                Navigator.pushReplacementNamed(context, '/profile');
              }),
              AuthStateChangeAction<SignedIn>((context, state) {
                Navigator.pushReplacementNamed(context, '/profile');
              }),
            ],
          );
        },
        '/profile': (context) {
          return ProfileScreen(
            providers: providers,
            actions: [
              SignedOutAction((context) {
                Navigator.pushReplacementNamed(context, '/sign-in');
              }),
            ],
          );
        },
      },
    );
  }
}
```

## Profile screen icons

If you're using `ProfileScreen`, add:

```yaml
fonts:
  - family: SocialIcons
    fonts:
      - asset: packages/firebase_ui_auth/fonts/SocialIcons.ttf
```

## Docs

- [Getting started](../../docs/firebase-ui-auth/README.md)
- [Theming](../../docs/firebase-ui-auth/theming.md)
- [Migration](../../docs/firebase-ui-auth/migration.md)
- [Email](../../docs/firebase-ui-auth/providers/email.md) · [Email link](../../docs/firebase-ui-auth/providers/email-link.md) · [Phone](../../docs/firebase-ui-auth/providers/phone.md) · [OAuth](../../docs/firebase-ui-auth/providers/oauth.md)
