// Copyright 2023, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:forui_firebase_ui_storage/firebase_ui_storage.dart';
import 'package:forui_firebase_ui_storage_example/firebase_options.dart';
import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await FirebaseStorage.instance.useStorageEmulator('localhost', 9199);

  final storage = FirebaseStorage.instance;

  final config = FirebaseUIStorageConfiguration(storage: storage);

  await FirebaseUIStorage.configure(config);

  runApp(const FirebaseUIStorageExample());
}

class FirebaseUIStorageExample extends StatelessWidget {
  const FirebaseUIStorageExample({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FirebaseUI Storage Example',
      builder: (context, child) => FTheme(
        data: FTheme.neutral.light.touch,
        child: FToaster(child: child!),
      ),
      home: const Home(),
    );
  }
}

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _selectedIndex = 0;
  GlobalKey key = GlobalKey();

  Widget buildList() {
    return StorageListView(
      key: key,
      ref: FirebaseStorage.instance.ref('/'),
      itemBuilder: (context, ref) {
        return AspectRatio(
          aspectRatio: 1,
          child: StorageImage(ref: ref, fit: BoxFit.cover),
        );
      },
    );
  }

  Widget buildGrid() {
    return StorageGridView(
      key: key,
      ref: FirebaseStorage.instance.ref('/'),
      itemBuilder: (context, ref) {
        return AspectRatio(
          aspectRatio: 1,
          child: StorageImage(ref: ref, fit: BoxFit.cover),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return FScaffold(
      header: FHeader(
        title: const Text('FirebaseUI Storage Example'),
        suffixes: [
          FHeaderAction(
            icon: Icon(FLucideIcons.refreshCw),
            onPress: () {
              setState(() {
                key = GlobalKey();
              });
            },
          ),
        ],
      ),
      footer: FBottomNavigationBar(
        index: _selectedIndex,
        onChange: (index) => setState(() => _selectedIndex = index),
        children: [
          FBottomNavigationBarItem(
            icon: Icon(FLucideIcons.list),
            label: const Text('List'),
          ),
          FBottomNavigationBarItem(
            icon: Icon(FLucideIcons.layoutGrid),
            label: const Text('Grid'),
          ),
        ],
      ),
      child: Column(
        children: [
          Expanded(
            child: switch (_selectedIndex) {
              0 => buildList(),
              1 => buildGrid(),
              _ => throw UnimplementedError(),
            },
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Builder(
              builder: (context) {
                return UploadButton(
                  onError: (error, _) {
                    showFToast(context: context, title: Text(error.toString()));
                  },
                  onUploadComplete: (ref) {
                    showFToast(
                      context: context,
                      title: const Text('Upload complete'),
                    );

                    setState(() {
                      key = GlobalKey();
                    });
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
