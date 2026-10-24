# Agent notes

Forui port of Firebase UI for Flutter. Pub package names are `forui_firebase_ui_*`; directories under `packages/` keep the upstream `firebase_ui_*` names.

## When to open

| Open | When |
| --- | --- |
| [docs/forui-patterns.md](docs/forui-patterns.md) | Editing Forui widgets (theme, typography, OTP, select, prefixes, icons) |
| [docs/firebase-ui-auth/theming.md](docs/firebase-ui-auth/theming.md) | App must wrap UI in `FTheme` |
| [docs/firebase-ui-auth/migration.md](docs/firebase-ui-auth/migration.md) | Material/Cupertino → Forui API deltas |
| [docs/README.md](docs/README.md) | User-facing docs index |
| `packages/*/lib/src/table_builder.dart` | DataTables — **Material exception** (`Theme.of` allowed); edit-modal buttons use `UniversalButton` |
| `packages/firebase_ui_auth/lib/src/widgets/internal/universal_page_route.dart` | Navigation routes — keep `CupertinoPageRoute` / `MaterialPageRoute` (iOS swipe-back) |
| [`.github/workflows/e2e.yml`](.github/workflows/e2e.yml) | Android/iOS/macOS/web e2e; NDK, AVD, emulator, Flutter pin |

## Constraints

- Dart `^3.13`, Flutter **3.47+**, Forui **0.27.x**
- Prefer `dart run melos run analyze` / package `flutter test` over inventing new check scripts
- Do not migrate DataTables unless the user asks

## CI

- Pin every third-party Action by **commit SHA** with a `# version` comment (match existing workflows).
- Android e2e runs on host `ubuntu-latest` + `reactivecircus/android-emulator-runner` (KVM). Do **not** switch that job to a `flutter-android` container — nested virt breaks the emulator path. (`ghcr.io/gmeligio/flutter-web` is fine for the web job only.)
- Flutter pins `ndkVersion` to **r28c** (`28.2.13676358`). Install via `nttld/setup-ndk` with `ndk-version: r28c`, `link-to-sdk: true`, `local-cache: true`.
- iOS/macOS e2e runners: **`macos-26`**. Simulator model must exist on that image (currently `iPhone 17`).

### When upgrading Flutter

Update these together (same version string unless noted):

| Where | What |
| --- | --- |
| [`.github/workflows/e2e.yml`](.github/workflows/e2e.yml) | every `flutter-version:` |
| [`.github/workflows/e2e.yml`](.github/workflows/e2e.yml) web job | `ghcr.io/gmeligio/flutter-web:<version>` |
| [`.github/workflows/e2e.yml`](.github/workflows/e2e.yml) Android | `nttld/setup-ndk` `ndk-version` if `flutter.ndkVersion` changed |
| [`unit_tests.yml`](.github/workflows/unit_tests.yml) / [`code_health.yml`](.github/workflows/code_health.yml) | usually `channel: stable` only; pin `flutter-version` if e2e is pinned and analyze must match |
| [AGENTS.md](AGENTS.md) Constraints | Flutter **x.y+** line |
| Runner OS / simulators | only if the image or Xcode set forces it (e.g. `macos-*`, simulator model) |
