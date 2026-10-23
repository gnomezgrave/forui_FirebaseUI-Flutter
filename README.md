# Firebase UI for Flutter (Forui)

Firebase UI is a set of Flutter packages that connect common UI flows to Firebase APIs. This repository is a **Forui** port of the original [Firebase UI for Flutter](https://github.com/firebase/FirebaseUI-Flutter) libraries — widgets are built with [Forui](https://forui.dev) instead of Material/Cupertino dual paths.

Migrating from upstream `firebase_ui_*` packages to `forui_firebase_ui_*` can be found in the [Migrating from upstream Firebase UI](#migrating-from-upstream-firebase-ui) section.

**Requirements:** Dart `^3.13.0`, Flutter **3.47+**, and an [`FTheme`](https://forui.dev/docs) ancestor around Firebase UI widgets.

## Why this repo exists?

Upstream [Firebase UI for Flutter](https://github.com/firebase/FirebaseUI-Flutter) builds screens with Material and Cupertino dual paths. Apps that use [Forui](https://forui.dev) — a minimalistic, platform-agnostic UI library inspired by [shadcn/ui](https://ui.shadcn.com) — end up mixing design languages: Firebase UI looks Material while the rest of the app follows Forui’s touch-first, cohesive styling.

This fork exists so Firebase UI flows (sign-in, OAuth, storage browsers, and so on) use Forui widgets (`FScaffold`, `FButton`, `FTextFormField`, Lucide icons, …) and theme through [`FTheme`](https://forui.dev/docs). You keep the same Firebase UI APIs and behaviors, with a UI that matches a Forui app instead of Material/Cupertino.

## Available packages

| package                                                                | pub                                                                                                                                |
| ---------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------- |
| [`forui_firebase_ui_auth`](./packages/firebase_ui_auth/)                     | [![pub package](https://img.shields.io/pub/v/forui_firebase_ui_auth.svg)](https://pub.dev/packages/forui_firebase_ui_auth)                     |
| [`forui_firebase_ui_database`](./packages/firebase_ui_database/)             | [![pub package](https://img.shields.io/pub/v/forui_firebase_ui_database.svg)](https://pub.dev/packages/forui_firebase_ui_database)             |
| [`forui_firebase_ui_firestore`](./packages/firebase_ui_firestore/)           | [![pub package](https://img.shields.io/pub/v/forui_firebase_ui_firestore.svg)](https://pub.dev/packages/forui_firebase_ui_firestore)           |
| [`forui_firebase_ui_localizations`](./packages/firebase_ui_localizations/)   | [![pub package](https://img.shields.io/pub/v/forui_firebase_ui_localizations.svg)](https://pub.dev/packages/forui_firebase_ui_localizations)   |
| [`forui_firebase_ui_oauth`](./packages/firebase_ui_oauth/)                   | [![pub package](https://img.shields.io/pub/v/forui_firebase_ui_oauth.svg)](https://pub.dev/packages/forui_firebase_ui_oauth)                   |
| [`forui_firebase_ui_oauth_apple`](./packages/firebase_ui_oauth_apple/)       | [![pub package](https://img.shields.io/pub/v/forui_firebase_ui_oauth_apple.svg)](https://pub.dev/packages/forui_firebase_ui_oauth_apple)       |
| [`forui_firebase_ui_oauth_facebook`](./packages/firebase_ui_oauth_facebook/) | [![pub package](https://img.shields.io/pub/v/forui_firebase_ui_oauth_facebook.svg)](https://pub.dev/packages/forui_firebase_ui_oauth_facebook) |
| [`forui_firebase_ui_oauth_google`](./packages/firebase_ui_oauth_google/)     | [![pub package](https://img.shields.io/pub/v/forui_firebase_ui_oauth_google.svg)](https://pub.dev/packages/forui_firebase_ui_oauth_google)     |
| [`forui_firebase_ui_oauth_twitter`](./packages/firebase_ui_oauth_twitter/)   | [![pub package](https://img.shields.io/pub/v/forui_firebase_ui_oauth_twitter.svg)](https://pub.dev/packages/forui_firebase_ui_oauth_twitter)   |
| [`forui_firebase_ui_shared`](./packages/firebase_ui_shared/)                 | [![pub package](https://img.shields.io/pub/v/forui_firebase_ui_shared.svg)](https://pub.dev/packages/forui_firebase_ui_shared)                 |
| [`forui_firebase_ui_storage`](./packages/firebase_ui_storage/)               | [![pub package](https://img.shields.io/pub/v/forui_firebase_ui_storage.svg)](https://pub.dev/packages/forui_firebase_ui_storage)               |

## Quick start

```sh
flutter pub add forui firebase_core firebase_auth forui_firebase_ui_auth
```

```dart
import 'package:forui/forui.dart';
import 'package:forui_firebase_ui_auth/firebase_ui_auth.dart';

MaterialApp(
  builder: (context, child) => FTheme(
    data: FTheme.neutral.light.touch,
    child: child!,
  ),
  home: SignInScreen(providers: [EmailAuthProvider()]),
);
```

See the [docs](./docs/README.md) for auth providers, storage, Firestore/Database, theming, and migration notes.

## Migrating from upstream Firebase UI

Package names are prefixed with `forui_` (for example `firebase_ui_auth` → `forui_firebase_ui_auth`). Library file paths are unchanged (`firebase_ui_auth.dart`).

1. Depend on the `forui_firebase_ui_*` packages you need (and [`forui`](https://pub.dev/packages/forui)).
2. Rewrite old imports and pubspec dependency keys:

```sh
# From your app (after: dart pub add forui_firebase_ui_shared)
dart run forui_firebase_ui_shared:migrate_imports

# Preview only:
dart run forui_firebase_ui_shared:migrate_imports --dry-run
```

That rewrites:

```dart
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
```

to:

```dart
import 'package:forui_firebase_ui_auth/firebase_ui_auth.dart';
```

and renames matching keys in `pubspec.yaml`. Then run `dart pub get`.

From this repo you can run `dart run melos run fix`. (Official `dart fix` data-driven library moves require deprecations in the *old* packages, which we do not publish.)

## Issues

Please file Firebase UI specific issues, bugs, or feature requests in our [issue tracker](https://github.com/gnomezgrave/forui_FirebaseUI-Flutter/issues/new/choose).

## Contributing

If you wish to contribute a change to any of the existing plugins in this repo, please review our [contribution guide](./CONTRIBUTING.md) and open a [pull request](https://github.com/gnomezgrave/forui_FirebaseUI-Flutter/pulls).
