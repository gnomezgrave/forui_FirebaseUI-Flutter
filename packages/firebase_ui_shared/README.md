## Firebase UI Shared

Shared Forui-based building blocks used across Firebase UI packages.


## Migrating from `firebase_ui_shared`

See [Migrating from upstream Firebase UI](https://github.com/gnomezgrave/forui_FirebaseUI-Flutter#migrating-from-upstream-firebase-ui) in the repository README (`firebase_ui_*` → `forui_firebase_ui_*`).

## Getting started

```sh
flutter pub add forui_firebase_ui_shared
```

Apps must wrap Firebase UI widgets in an [FTheme](https://forui.dev/docs) ancestor:

```dart
import 'package:forui/forui.dart';

MaterialApp(
  builder: (context, child) => FTheme(
    data: FTheme.neutral.light.touch,
    child: child!,
  ),
  // ...
);
```

Requires Flutter **3.47+** and Forui **0.27.x**.

## Usage

See [API docs](https://pub.dev/documentation/forui_firebase_ui_shared/latest/).

## License

MIT
