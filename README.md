# Firebase UI for Flutter (Forui)

Firebase UI is a set of Flutter packages that connect common UI flows to Firebase APIs. This repository is a **Forui** port of the original Firebase UI for Flutter libraries — widgets are built with [Forui](https://forui.dev) instead of Material/Cupertino dual paths.

**Requirements:** Dart `^3.13.0`, Flutter **3.47+**, and an [`FTheme`](https://forui.dev/docs) ancestor around Firebase UI widgets.

## Available packages

| package                                                                | pub                                                                                                                                |
| ---------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------- |
| [`firebase_ui_auth`](./packages/firebase_ui_auth/)                     | [![pub package](https://img.shields.io/pub/v/firebase_ui_auth.svg)](https://pub.dev/packages/firebase_ui_auth)                     |
| [`firebase_ui_database`](./packages/firebase_ui_database/)             | [![pub package](https://img.shields.io/pub/v/firebase_ui_database.svg)](https://pub.dev/packages/firebase_ui_database)             |
| [`firebase_ui_firestore`](./packages/firebase_ui_firestore/)           | [![pub package](https://img.shields.io/pub/v/firebase_ui_firestore.svg)](https://pub.dev/packages/firebase_ui_firestore)           |
| [`firebase_ui_localizations`](./packages/firebase_ui_localizations/)   | [![pub package](https://img.shields.io/pub/v/firebase_ui_localizations.svg)](https://pub.dev/packages/firebase_ui_localizations)   |
| [`firebase_ui_oauth`](./packages/firebase_ui_oauth/)                   | [![pub package](https://img.shields.io/pub/v/firebase_ui_oauth.svg)](https://pub.dev/packages/firebase_ui_oauth)                   |
| [`firebase_ui_oauth_apple`](./packages/firebase_ui_oauth_apple/)       | [![pub package](https://img.shields.io/pub/v/firebase_ui_oauth_apple.svg)](https://pub.dev/packages/firebase_ui_oauth_apple)       |
| [`firebase_ui_oauth_facebook`](./packages/firebase_ui_oauth_facebook/) | [![pub package](https://img.shields.io/pub/v/firebase_ui_oauth_facebook.svg)](https://pub.dev/packages/firebase_ui_oauth_facebook) |
| [`firebase_ui_oauth_google`](./packages/firebase_ui_oauth_google/)     | [![pub package](https://img.shields.io/pub/v/firebase_ui_oauth_google.svg)](https://pub.dev/packages/firebase_ui_oauth_google)     |
| [`firebase_ui_oauth_twitter`](./packages/firebase_ui_oauth_twitter/)   | [![pub package](https://img.shields.io/pub/v/firebase_ui_oauth_twitter.svg)](https://pub.dev/packages/firebase_ui_oauth_twitter)   |
| [`firebase_ui_shared`](./packages/firebase_ui_shared/)                 | [![pub package](https://img.shields.io/pub/v/firebase_ui_shared.svg)](https://pub.dev/packages/firebase_ui_shared)                 |
| [`firebase_ui_storage`](./packages/firebase_ui_storage/)               | [![pub package](https://img.shields.io/pub/v/firebase_ui_storage.svg)](https://pub.dev/packages/firebase_ui_storage)               |

## Quick start

```sh
flutter pub add forui firebase_core firebase_auth firebase_ui_auth
```

```dart
import 'package:forui/forui.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';

MaterialApp(
  builder: (context, child) => FTheme(
    data: FTheme.neutral.light.touch,
    child: child!,
  ),
  home: SignInScreen(providers: [EmailAuthProvider()]),
);
```

See the [docs](./docs/README.md) for auth providers, storage, Firestore/Database, theming, and migration notes.

## Issues

Please file Firebase UI specific issues, bugs, or feature requests in our [issue tracker](https://github.com/firebase/FirebaseUI-Flutter/issues/new/choose).

## Contributing

If you wish to contribute a change to any of the existing plugins in this repo, please review our [contribution guide](./CONTRIBUTING.md) and open a [pull request](https://github.com/firebase/FirebaseUI-Flutter/pulls).
