# Firebase UI Localizations

Localization labels for Firebase UI packages (`^0.1.0`).


## Migrating from `firebase_ui_localizations`

See [Migrating from upstream Firebase UI](https://github.com/gnomezgrave/forui_FirebaseUI-Flutter#migrating-from-upstream-firebase-ui) in the repository README (`firebase_ui_*` → `forui_firebase_ui_*`).

## Getting Started

See the [documentation](../../docs/firebase-ui-localizations.md).

## Issues and feedback

Please file Firebase UI specific issues, bugs, or feature requests in our [issue tracker](https://github.com/gnomezgrave/forui_FirebaseUI-Flutter/issues).

## Contributing

To contribute a change to this plugin, please review our [contributing guide](https://github.com/gnomezgrave/forui_FirebaseUI-Flutter/blob/main/CONTRIBUTING.md).

### Adding a new language

If you want to add a new language, make sure to add a relevant `.arb` file into `lib/i10n`.

- copy `lib/i10n/forui_firebase_ui_en.arb` to `lib/i10n/forui_firebase_ui_<your-language-code>.arb`
- translate labels
- run `dart run forui_firebase_ui_localizations:gen_l10n`
- commit the `.arb` and generated `.dart` file
- submit a PR

### Adding a new label to existing languages

If you want to add new labels to existing languages,

- Execute `dart run forui_firebase_ui_localizations:add_label`:

```bash
dart run forui_firebase_ui_localizations:add_label
Label name?: someNewLabel
Label description?: This will go to the doc comment of the label
English translation?: Some new label
Done!
```

- Execute `dart run forui_firebase_ui_localizations:gen_l10n`
- Commit the changes
- Submit a PR
