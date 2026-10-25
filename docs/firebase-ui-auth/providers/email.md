# Firebase UI Email auth provider

## Configuration

To support email as a provider, first ensure that the "Email/Password" provider is
enabled in the [Firebase Console](https://console.firebase.google.com/project/_/authentication/providers):

![Enable Email/Password Provider](../images/ui-email-provider.jpg)

Configure email provider:

```dart
import 'package:firebase_core/firebase_core.dart';
import 'package:forui_firebase_ui_auth/forui_firebase_ui_auth.dart';

// If you need to use FirebaseAuth directly, make sure to hide EmailAuthProvider:
// import 'package:firebase_auth/firebase_auth.dart' hide EmailAuthProvider;

import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  FirebaseUIAuth.configureProviders([
    EmailAuthProvider(),
    // ... other providers
  ]);
}
```

## Using screen

After adding `EmailAuthProvider` to the `FirebaseUIAuth.configureProviders` email form would be displayed on the `SignInScreen` or `RegisterScreen`.

```dart
SignInScreen(
  actions: [
    AuthStateChangeAction<SignedIn>((context, state) {
      if (!state.user!.isEmailVerified) {
        Navigator.pushNamed(context, '/verify-email');
      } else {
        Navigator.pushReplacementNamed(context, '/profile');
      }
    }),
  ],
);
```

> Notes:
>
> - see [navigation guide](../navigation.md) to learn how navigation works with Firebase UI.
> - explore [FirebaseUIActions API docs](https://pub.dev/documentation/forui_firebase_ui_auth/latest/forui_firebase_ui_auth/FirebaseUIAction-class.html).

## Using view

If the pre-built screens don't suit the app's needs, you could use a `LoginView` to build your custom screen:

Apps must wrap Firebase UI in [`FTheme`](../theming.md) (typically via `MaterialApp.builder`).

```dart
class MyLoginScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          MyCustomSideBar(),
          Padding(
            padding: const EdgeInsets.all(16),
            child: FirebaseUIActions(
              actions: [
                AuthStateChangeAction<SignedIn>((context, state) {
                  if (!state.user!.isEmailVerified) {
                    Navigator.pushNamed(context, '/verify-email');
                  } else {
                    Navigator.pushReplacementNamed(context, '/profile');
                  }
                }),
              ],
              child: LoginView(
                action: AuthAction.signUp,
                providers: FirebaseUIAuth.providersFor(
                  FirebaseAuth.instance.app,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
```

## Using widget

If a view is also not flexible enough, there is an `EmailForm`:

```dart
class MyCustomWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AuthStateListener<EmailAuthController>(
      listener: (oldState, newState, controller) {
        // perform necessary actions based on previous
        // and current auth state.
      },
      child: const EmailForm(),
    );
  }
}
```

## Building a custom widget with `AuthFlowBuilder`

You could also use `AuthFlowBuilder` to facilitate the functionality of the `EmailAuthFlow`:

```dart
class MyCustomWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AuthFlowBuilder<EmailAuthController>(
      builder: (context, state, ctrl, child) {
        if (state is AwaitingEmailAndPassword) {
          return MyCustomEmailForm();
        } else if (state is SigningIn) {
          return const LoadingIndicator(size: 32, borderWidth: 2);
        } else if (state is AuthFailed) {
          return ErrorText(exception: state.exception);
        } else {
          return Text('Unknown state $state');
        }
      },
    );
  }
}
```

## Building a custom stateful widget

For full control over every phase of the authentication lifecycle, you could build a stateful widget which implements `EmailAuthListener`. Ensure an [`FTheme`](../theming.md) ancestor.

```dart
class CustomEmailSignIn extends StatefulWidget {
  const CustomEmailSignIn({super.key});

  @override
  State<CustomEmailSignIn> createState() => _CustomEmailSignInState();
}

class _CustomEmailSignInState extends State<CustomEmailSignIn>
    implements EmailAuthListener {
  @override
  final auth = FirebaseAuth.instance;

  late final EmailAuthProvider _provider = EmailAuthProvider()
    ..auth = auth
    ..authListener = this;

  @override
  AuthProvider get provider => _provider;

  late Widget child = MyCustomEmailForm(onSubmit: (email, password) {
    _provider.authenticate(email, password, AuthAction.signIn);
  });

  @override
  Widget build(BuildContext context) {
    return Center(child: child);
  }

  @override
  void onCredentialReceived(AuthCredential credential) {
    setState(() {
      child = const LoadingIndicator(size: 32, borderWidth: 2);
    });
  }

  @override
  void onBeforeSignIn() {
    setState(() {
      child = const LoadingIndicator(size: 32, borderWidth: 2);
    });
  }

  @override
  void onCanceled() {
    setState(() {
      child = MyCustomEmailForm(onSubmit: (email, password) {
        _provider.authenticate(email, password, AuthAction.signIn);
      });
    });
  }

  @override
  void onCredentialLinked(AuthCredential credential) {
    Navigator.of(context).pushReplacementNamed('/profile');
  }

  @override
  void onError(Object error) {
    try {
      defaultOnAuthError(_provider, error);
    } on Exception catch (err) {
      setState(() {
        child = ErrorText(exception: err);
      });
    }
  }

  @override
  void onSignedIn(UserCredential credential) {
    Navigator.of(context).pushReplacementNamed('/profile');
  }

  @override
  void onMFARequired(MultiFactorResolver resolver) {
    startMFAVerification(context: context, resolver: resolver, auth: auth);
  }
}
```
