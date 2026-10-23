# Agent notes

Forui port of Firebase UI for Flutter. Pub package names are `forui_firebase_ui_*`; directories under `packages/` keep the upstream `firebase_ui_*` names.

## When to open

| Open | When |
| --- | --- |
| [docs/forui-patterns.md](docs/forui-patterns.md) | Editing Forui widgets (theme, typography, OTP, select, prefixes, icons) |
| [docs/firebase-ui-auth/theming.md](docs/firebase-ui-auth/theming.md) | App must wrap UI in `FTheme` |
| [docs/firebase-ui-auth/migration.md](docs/firebase-ui-auth/migration.md) | Material/Cupertino → Forui API deltas |
| [docs/README.md](docs/README.md) | User-facing docs index |
| `packages/*/lib/src/table_builder.dart` | DataTables — **Material exception** (`Theme.of` allowed) |
| `packages/firebase_ui_auth/lib/src/widgets/internal/universal_page_route.dart` | Navigation routes — keep `CupertinoPageRoute` / `MaterialPageRoute` (iOS swipe-back) |

## Constraints

- Dart `^3.13`, Flutter **3.47+**, Forui **0.27.x**
- Prefer `melos run analyze` / package `flutter test` over inventing new check scripts
- Do not migrate DataTables unless the user asks
