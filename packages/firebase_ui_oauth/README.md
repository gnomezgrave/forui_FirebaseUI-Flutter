# Firebase UI OAuth

[![pub package](https://img.shields.io/pub/v/forui_firebase_ui_oauth.svg)](https://pub.dev/packages/forui_firebase_ui_oauth)

Base package for Firebase UI OAuth providers (Forui-backed buttons):

- [Apple Sign In](https://pub.dev/packages/forui_firebase_ui_oauth_apple)
- [Google Sign In](https://pub.dev/packages/forui_firebase_ui_oauth_google)
- [Facebook Sign In](https://pub.dev/packages/forui_firebase_ui_oauth_facebook)
- [Twitter Sign In](https://pub.dev/packages/forui_firebase_ui_oauth_twitter)

Depends on [`forui_firebase_ui_auth`](https://pub.dev/packages/forui_firebase_ui_auth). Abstract `OAuthProvider` / button widgets live there; this package provides `PlatformSignInMixin` and re-exports those types. See [OAuth package layout](../../docs/firebase-ui-auth/migration.md#oauth-package-layout).

See the [OAuth docs](../../docs/firebase-ui-auth/providers/oauth.md). Apps must wrap Firebase UI in an [`FTheme`](https://forui.dev/docs) ancestor.

## Migrating from `firebase_ui_oauth`

See [Migrating from upstream Firebase UI](https://github.com/gnomezgrave/forui_FirebaseUI-Flutter#migrating-from-upstream-firebase-ui) in the repository README (`firebase_ui_*` → `forui_firebase_ui_*`).


For issues, please create a new [issue on the repository](https://github.com/gnomezgrave/forui_FirebaseUI-Flutter/issues).

To contribute a change to this plugin, please review our [contribution guide](../../CONTRIBUTING.md) and open a [pull request](https://github.com/gnomezgrave/forui_FirebaseUI-Flutter/pulls).
