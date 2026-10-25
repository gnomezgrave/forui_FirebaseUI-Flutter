# Migrating to the Forui Firebase UI packages

This guide covers moving from the original Material/Cupertino **Firebase UI for Flutter** packages to this **Forui** port (version `0.1.0`).

## What changed

- UI is built with [Forui](https://forui.dev) instead of dual Material/Cupertino widgets.
- Apps **must** provide an `FTheme` ancestor (usually via `MaterialApp.builder`).
- Requires Dart `^3.13.0` and Flutter **3.47+**.
- `PlatformWidget` and dual `materialIcon` / `cupertinoIcon` APIs are removed.
- `ProfileScreen.appBar` / `cupertinoNavigationBar` are replaced by a single `header`.
- Firestore/Database **DataTables** remain Material-based; list/grid query loading uses Forui indicators.

Package APIs (`SignInScreen`, providers, actions, etc.) stay largely the same; the main integration change is theming.

## OAuth package layout

Unlike a cyclic auth↔oauth graph, this port keeps a **one-way** dependency chain so packages can publish to pub.dev:

`shared` / `localizations` → **`auth`** → **`oauth`** → `oauth_*`

| Lives in | Types / responsibility |
| --- | --- |
| `forui_firebase_ui_auth` | `OAuthProvider`, `OAuthListener`, button styles, `OAuthProviderButton`, `OAuthProviderButtonBase`, `OAuthFlow` |
| `forui_firebase_ui_oauth` | `PlatformSignInMixin`, desktop/web OAuth helpers; **re-exports** the auth OAuth types |
| `forui_firebase_ui_oauth_*` | Concrete providers (`GoogleProvider`, …) — `extends OAuthProvider with PlatformSignInMixin` |

App code can keep importing OAuth types from either `forui_firebase_ui_auth` or `forui_firebase_ui_oauth` (re-export). Prefer auth for screens/widgets; use oauth / oauth_* when implementing a custom provider.

## Dependencies

```yaml
dependencies:
  forui: ^0.27.0
  forui_firebase_ui_auth: ^0.1.0
  # as needed:
  forui_firebase_ui_oauth: ^0.1.0
  forui_firebase_ui_oauth_google: ^0.1.0
  forui_firebase_ui_oauth_apple: ^0.1.0
  forui_firebase_ui_oauth_facebook: ^0.1.0
  forui_firebase_ui_oauth_twitter: ^0.1.0
  forui_firebase_ui_firestore: ^0.1.0
  forui_firebase_ui_database: ^0.1.0
  forui_firebase_ui_storage: ^0.1.0
  forui_firebase_ui_localizations: ^0.1.0
```

Imports use the Forui package and matching library name (`package:forui_firebase_ui_auth/forui_firebase_ui_auth.dart`, etc.).

## Wrap your app in `FTheme`

```diff
 import 'package:flutter/material.dart';
+import 'package:forui/forui.dart';
 import 'package:forui_firebase_ui_auth/forui_firebase_ui_auth.dart';

 MaterialApp(
+  builder: (context, child) => FTheme(
+    data: FTheme.neutral.light.touch,
+    child: child!,
+  ),
   home: SignInScreen(
     providers: [EmailAuthProvider()],
   ),
 );
```

See [Theming](./theming.md) for more options.

## Profile screen header

```diff
 ProfileScreen(
-  appBar: AppBar(title: Text('Profile')),
+  header: FHeader(title: Text('Profile')),
 );
```

## Loading indicators

Replace Material/Cupertino progress widgets in custom builders with Forui equivalents:

```diff
- return const CircularProgressIndicator();
+ return const LoadingIndicator(size: 32, borderWidth: 2);
 // or
+ return const FCircularProgress();
```

## Historical note

The archived upstream changelogs (pre-Forui) live in each package as `CHANGELOG.md.org`. Version `0.1.0` is the first public Forui release of this package set.
