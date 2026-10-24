# Firebase UI Phone provider

## Configuration

To support Phone Numbers as a provider, first ensure that the "Phone" provider is
enabled in the [Firebase Console](https://console.firebase.google.com/project/_/authentication/providers):

![Enable Phone Provider](../images/ui-phone-provider.jpg)

Next, follow the [Setup Instructions](https://firebase.google.com/docs/auth/flutter/phone-auth) to configure Phone Authentication for your
platforms.

Configure phone provider:

```dart
import 'package:firebase_core/firebase_core.dart';
import 'package:forui_firebase_ui_auth/forui_firebase_ui_auth.dart';

// If you need to use FirebaseAuth directly, make sure to hide PhoneAuthProvider:
// import 'package:firebase_auth/firebase_auth.dart' hide PhoneAuthProvider;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  FirebaseUIAuth.configureProviders([
    PhoneAuthProvider(),
    // ... other providers
  ]);
}
```

## Using screen

After adding `PhoneAuthProvider` to the `FirebaseUIAuth.configureProviders`, a button will be added to the `SignInScreen` and `RegisterScreen`.

```dart
SignInScreen(
  actions: [
    VerifyPhoneAction((context, _) {
      Navigator.pushNamed(context, '/phone');
    }),
  ],
);
```

> Notes:
>
> - see [navigation guide](../navigation.md) to learn how navigation works with Firebase UI.
> - explore [FirebaseUIActions API docs](https://pub.dev/documentation/forui_firebase_ui_auth/latest/forui_firebase_ui_auth/FirebaseUIAction-class.html).

Configure a `'/phone'` route to render `PhoneInputScreen`. Apps must wrap Firebase UI in [`FTheme`](../theming.md) (typically via `MaterialApp.builder`):

```dart
import 'package:forui/forui.dart';

MaterialApp(
  builder: (context, child) => FTheme(
    data: FTheme.neutral.light.touch,
    child: child!,
  ),
  routes: {
    // ...other routes
    '/phone': (context) => PhoneInputScreen(
      actions: [
        SMSCodeRequestedAction((context, action, flowKey, phoneNumber) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => SMSCodeInputScreen(
                flowKey: flowKey,
              ),
            ),
          );
        }),
      ],
    ),
  },
)
```

## Using view

If the pre-built screens don't suit the app's needs, you could use a `PhoneInputView` to build your custom screen (ensure an `FTheme` ancestor, e.g. from `MaterialApp.builder` above):

```dart
final _flowKey = Object();

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
                SMSCodeRequestedAction((context, action, flowKey, phoneNumber) {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => SMSCodeInputScreen(
                        flowKey: flowKey,
                      ),
                    ),
                  );
                }),
              ],
              child: PhoneInputView(flowKey: _flowKey),
            ),
          ),
        ],
      ),
    );
  }
}
```

## Using widget

If a view is also not flexible enough, use `PhoneInput` and `SMSCodeInput` inside an `AuthFlowBuilder` (unlike `EmailForm`, these widgets do not create a flow themselves):

```dart
class MyCustomWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AuthFlowBuilder<PhoneAuthController>(
      builder: (context, state, ctrl, child) {
        if (state is AwaitingPhoneNumber || state is SMSCodeRequested) {
          return PhoneInput(
            initialCountryCode: 'US',
            onSubmit: ctrl.acceptPhoneNumber,
          );
        } else if (state is SMSCodeSent) {
          return SMSCodeInput(
            onSubmit: (smsCode) {
              ctrl.verifySMSCode(
                smsCode,
                verificationId: state.verificationId,
                confirmationResult: state.confirmationResult,
              );
            },
          );
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

## Building a custom widget with `AuthFlowBuilder`

You could also use `AuthFlowBuilder` to facilitate the functionality of the `PhoneAuthFlow`:

```dart
class MyCustomWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AuthFlowBuilder<PhoneAuthController>(
      listener: (oldState, newState, controller) {
        if (newState is PhoneVerified) {
          Navigator.of(context).pushReplacementNamed('/profile');
        }
      },
      builder: (context, state, ctrl, child) {
        if (state is AwaitingPhoneNumber || state is SMSCodeRequested) {
          return PhoneInput(
            initialCountryCode: 'US',
            onSubmit: (phoneNumber) {
              ctrl.acceptPhoneNumber(phoneNumber);
            },
          );
        } else if (state is SMSCodeSent) {
          return SMSCodeInput(onSubmit: (smsCode) {
            ctrl.verifySMSCode(
              smsCode,
              verificationId: state.verificationId,
              confirmationResult: state.confirmationResult,
            );
          });
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

For full control over every phase of the authentication lifecycle you could build a stateful widget that implements `PhoneAuthListener`. Ensure an [`FTheme`](../theming.md) ancestor.

```dart
class CustomPhoneVerification extends StatefulWidget {
  const CustomPhoneVerification({super.key});

  @override
  State<CustomPhoneVerification> createState() =>
      _CustomPhoneVerificationState();
}

class _CustomPhoneVerificationState extends State<CustomPhoneVerification>
    implements PhoneAuthListener {
  @override
  final auth = FirebaseAuth.instance;

  late final PhoneAuthProvider _provider = PhoneAuthProvider()
    ..auth = auth
    ..authListener = this;

  @override
  AuthProvider get provider => _provider;

  String? verificationId;
  ConfirmationResult? confirmationResult;

  late Widget child = PhoneInput(
    initialCountryCode: 'US',
    onSubmit: (phoneNumber) {
      _provider.sendVerificationCode(
        phoneNumber: phoneNumber,
        action: AuthAction.signIn,
      );
    },
  );

  @override
  void onCodeSent(String verificationId, [int? forceResendToken]) {
    this.verificationId = verificationId;
  }

  @override
  void onConfirmationRequested(ConfirmationResult result) {
    confirmationResult = result;
  }

  @override
  void onSMSCodeRequested(String phoneNumber) {
    setState(() {
      child = SMSCodeInput(
        onSubmit: (smsCode) {
          _provider.verifySMSCode(
            action: AuthAction.signIn,
            code: smsCode,
            verificationId: verificationId,
            confirmationResult: confirmationResult,
          );
        },
      );
    });
  }

  @override
  void onVerificationCompleted(PhoneAuthCredential credential) {
    _provider.onCredentialReceived(credential, AuthAction.signIn);
  }

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
      child = const Text('Phone verification cancelled');
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
