# Forui patterns (this repo)

Cheatsheet for agents editing Firebase UI packages. Prefer looking up current Forui APIs under `package:forui` when unsure.

## Theme

Every app (and test harness) that hosts Firebase UI needs an `FTheme` ancestor:

```dart
MaterialApp(
  builder: (context, child) => FTheme(
    data: FTheme.neutral.light.touch,
    child: child!,
  ),
  // ...
);
```

Read colors/typography via `context.theme` (Forui), not `Theme.of`, except in DataTable `table_builder.dart` files.

## Typography

| Use | Token |
| --- | --- |
| Screen titles | `theme.typography.display.md` (or `titleStyle` override) |
| Body / hints | `theme.typography.body.sm` / `.md` |

Avoid obsolete tokens like `typography.xl`.

## Icons

Use `FLucideIcons.*`, not Material `Icons.*`.

## Text fields

- Prefer `FTextFormField` / `UniversalTextFormField`.
- Custom `prefixBuilder` / `prefix` widgets need start padding (Forui’s own prefix icon uses start 12 / end 4):

```dart
prefix: const Padding(
  padding: EdgeInsetsDirectional.only(start: 12, end: 4),
  child: Text('+'),
),
```

## Select

Use the generic on the type, then `.search`:

```dart
FSelect<String>.search(
  items: countryItems,
  control: .lifted(value: code, onChange: ...),
  filter: (query) => ...,
);
```

Not `FSelect.search<String>(...)`.

## OTP / SMS

Wire **one** submit path. Use `onSubmit` only — do not also auto-submit from `onChange` when length hits 6 (double verification).

```dart
FOtpField(
  control: .managed(controller: controller),
  onSubmit: (v) {
    if (v.length < 6) return;
    onSubmit(v);
  },
);
```

## Navigation

`createPageRoute` must return `CupertinoPageRoute` or `MaterialPageRoute`. Do not replace with a custom `PageRouteBuilder` fade — that drops iOS interactive swipe-back.

## Loading

Use `LoadingIndicator` (`forui_firebase_ui_shared`) or `FCircularProgress` / `FDeterminateProgress`, not `CircularProgressIndicator` / `CupertinoActivityIndicator`.

## DataTables (exception)

`FirestoreDataTable` / `FirebaseDatabaseDataTable` stay Material. Leave `Theme.of` and Material icons in those `table_builder.dart` files alone.
