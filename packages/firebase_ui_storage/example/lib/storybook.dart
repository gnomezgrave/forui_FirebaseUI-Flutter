// Copyright 2023, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:forui_firebase_ui_storage/forui_firebase_ui_storage.dart';
import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

import 'firebase_options.dart';
import 'src/apps.dart';

final brightness = ValueNotifier(Brightness.light);
final app = ValueNotifier(apps[0]);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await FirebaseStorage.instance.useStorageEmulator('localhost', 9199);

  final storage = FirebaseStorage.instance;

  final config = FirebaseUIStorageConfiguration(
    storage: storage,
    uploadRoot: storage.ref('flutter-tests'),
  );

  await FirebaseUIStorage.configure(config);

  runApp(const FirebaseUIStorageGallery());
}

class FirebaseUIStorageGallery extends StatelessWidget {
  const FirebaseUIStorageGallery({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: brightness,
      builder: (context, currentBrightness, _) {
        final theme = currentBrightness == Brightness.dark
            ? FTheme.neutral.dark.touch
            : FTheme.neutral.light.touch;

        return MaterialApp(
          title: 'Firebase UI Storage Gallery',
          builder: (context, child) => FTheme(data: theme, child: child!),
          home: const Gallery(),
        );
      },
    );
  }
}

class Gallery extends StatelessWidget {
  const Gallery({super.key});

  @override
  Widget build(BuildContext context) {
    return FScaffold(
      child: Column(
        children: [
          const Toolbar(),
          Expanded(
            child: Row(
              children: [
                const SizedBox(width: 200, child: AppList()),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      ValueListenableBuilder(
                        valueListenable: app,
                        builder: (context, app, _) =>
                            Expanded(child: Center(child: app)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class Toolbar extends StatelessWidget {
  const Toolbar({super.key});

  @override
  Widget build(BuildContext context) {
    final currentBrightness = context.theme.colors.brightness;

    return Padding(
      padding: const EdgeInsets.all(8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          const Text('Brightness'),
          const SizedBox(width: 16),
          FButton(
            variant: currentBrightness == Brightness.light
                ? FButtonVariant.primary
                : FButtonVariant.outline,
            onPress: () => brightness.value = Brightness.light,
            child: Icon(FLucideIcons.sun),
          ),
          const SizedBox(width: 8),
          FButton(
            variant: currentBrightness == Brightness.dark
                ? FButtonVariant.primary
                : FButtonVariant.outline,
            onPress: () => brightness.value = Brightness.dark,
            child: Icon(FLucideIcons.moon),
          ),
        ],
      ),
    );
  }
}
