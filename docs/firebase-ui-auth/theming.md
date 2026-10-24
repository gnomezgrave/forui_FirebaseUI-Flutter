# Theming

Firebase UI widgets are built on [Forui](https://forui.dev). Apps must provide an [`FTheme`](https://forui.dev/docs) ancestor (typically via `MaterialApp.builder`).

```dart
import 'package:forui/forui.dart';

class FirebaseAuthUIExample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      builder: (context, child) => FTheme(
        data: FTheme.neutral.light.touch,
        child: child!,
      ),
      home: const SignInScreen(
        providers: [
          EmailAuthProvider(),
        ],
      ),
    );
  }
}
```

Customize appearance by choosing a Forui theme (or generating a custom style with the Forui CLI). Widget-specific options such as `EmailFormStyle` and `titleStyle` can further tune individual screens.

See [Forui theming docs](https://forui.dev/docs) for available themes and style customization.
