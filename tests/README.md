# tests

Integration / e2e suite for the Forui Firebase UI packages (`tests/integration_test`).

Requires the Firebase Emulator Suite. From the repo root:

```bash
dart run melos run test:e2e:macos
dart run melos run test:e2e:ios
dart run melos run test:e2e:android
dart run melos run test:e2e:web       # builds example apps (matches CI web job)
```

See [CONTRIBUTING.md](../CONTRIBUTING.md#end-to-end-e2e-tests) for emulator setup, device overrides, and CI parity notes.
