// Copyright 2026, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

/// Rewrites upstream Firebase UI package names to the Forui port names.
///
/// ```sh
/// dart run forui_firebase_ui_shared:migrate_imports
/// dart run forui_firebase_ui_shared:migrate_imports --dry-run
/// dart run forui_firebase_ui_shared:migrate_imports path/to/project
/// ```
///
/// Updates:
/// - Dart imports/exports: `package:firebase_ui_*` → `package:forui_firebase_ui_*`
/// - pubspec dependencies/dev_dependencies keys with the same rename
void main(List<String> args) {
  final dryRun = args.contains('--dry-run');
  final help = args.contains('--help') || args.contains('-h');
  if (help) {
    stdout.writeln(_usage);
    return;
  }

  final paths = args.where((a) => !a.startsWith('-')).toList();
  final roots = paths.isEmpty ? <Directory>[Directory.current] : paths.map(Directory.new);

  var filesChanged = 0;
  var replacements = 0;

  for (final root in roots) {
    if (!root.existsSync()) {
      stderr.writeln('Path not found: ${root.path}');
      exitCode = 64;
      return;
    }

    for (final entity in root.listSync(recursive: true, followLinks: false)) {
      if (entity is! File) continue;
      final path = entity.path;
      if (_shouldSkip(path)) continue;

      final lower = path.toLowerCase();
      if (lower.endsWith('.dart')) {
        final result = _rewriteDart(entity, dryRun: dryRun);
        if (result > 0) {
          filesChanged++;
          replacements += result;
          stdout.writeln('${dryRun ? 'Would update' : 'Updated'} $path ($result)');
        }
      } else if (lower.endsWith('pubspec.yaml')) {
        final result = _rewritePubspec(entity, dryRun: dryRun);
        if (result > 0) {
          filesChanged++;
          replacements += result;
          stdout.writeln('${dryRun ? 'Would update' : 'Updated'} $path ($result)');
        }
      }
    }
  }

  if (filesChanged == 0) {
    stdout.writeln('No firebase_ui_* imports or pubspec deps found.');
  } else {
    stdout.writeln(
      '${dryRun ? 'Would change' : 'Changed'} $filesChanged file(s), '
      '$replacements replacement(s).',
    );
    if (dryRun) {
      stdout.writeln('Re-run without --dry-run to apply.');
    } else {
      stdout.writeln('Next: update pubspec versions if needed, then run `dart pub get`.');
    }
  }
}

const _usage = '''
Migrates upstream Firebase UI package names to forui_firebase_ui_*.

Usage:
  dart run forui_firebase_ui_shared:migrate_imports [options] [path...]

Options:
  --dry-run    Show changes without writing files
  -h, --help   Show this help

If no path is given, the current directory is scanned recursively.
''';

const _packages = <String>[
  'firebase_ui_oauth_facebook',
  'firebase_ui_oauth_twitter',
  'firebase_ui_oauth_google',
  'firebase_ui_oauth_apple',
  'firebase_ui_localizations',
  'firebase_ui_firestore',
  'firebase_ui_database',
  'firebase_ui_storage',
  'firebase_ui_shared',
  'firebase_ui_oauth',
  'firebase_ui_auth',
];

bool _shouldSkip(String path) {
  final parts = path.split(RegExp(r'[/\\]'));
  const skip = {
    '.git',
    '.dart_tool',
    'build',
    '.idea',
    '.vscode',
    'Pods',
    'ephemeral',
  };
  return parts.any(skip.contains);
}

int _rewriteDart(File file, {required bool dryRun}) {
  final original = file.readAsStringSync();
  var updated = original;
  var count = 0;

  for (final name in _packages) {
    final from = 'package:$name/';
    final to = 'package:forui_$name/';
    if (!updated.contains(from)) continue;
    final matches = RegExp(RegExp.escape(from)).allMatches(updated).length;
    updated = updated.replaceAll(from, to);
    count += matches;
  }

  if (count > 0) {
    updated = _dedupeImportExportLines(updated);
  }

  if (count > 0 && !dryRun && updated != original) {
    file.writeAsStringSync(updated);
  }
  return count;
}

int _rewritePubspec(File file, {required bool dryRun}) {
  final original = file.readAsStringSync();
  var updated = original;
  var count = 0;

  for (final name in _packages) {
    final foruiName = 'forui_$name';
    final hasForui = RegExp(
      r'^([ \t]*)' + RegExp.escape(foruiName) + r':',
      multiLine: true,
    ).hasMatch(updated);

    // Match dependency keys like `  firebase_ui_auth:` (not already prefixed).
    final pattern = RegExp(
      r'^([ \t]*)' + RegExp.escape(name) + r':.*$',
      multiLine: true,
    );
    final matches = pattern.allMatches(updated).toList();
    if (matches.isEmpty) continue;

    if (hasForui) {
      // Drop the old key; forui_* is already declared.
      updated = updated.replaceAllMapped(pattern, (_) => '');
    } else {
      updated = updated.replaceAllMapped(
        pattern,
        (m) => m[0]!.replaceFirst('$name:', '$foruiName:'),
      );
    }
    count += matches.length;
  }

  if (count > 0) {
    // Clean blank lines left by removed dependency entries.
    updated = updated.replaceAll(RegExp(r'\n[ \t]*\n[ \t]*\n+'), '\n\n');
    updated = updated.replaceAllMapped(
      RegExp(r'((?:dependencies|dev_dependencies|dependency_overrides):\n)\n+'),
      (m) => m[1]!,
    );
  }

  if (count > 0 && !dryRun && updated != original) {
    file.writeAsStringSync(updated);
  }
  return count;
}

/// Removes duplicate identical import/export lines after URI rewrites.
String _dedupeImportExportLines(String source) {
  final seen = <String>{};
  final out = <String>[];
  for (final line in source.split('\n')) {
    final trimmed = line.trimLeft();
    final isDirective =
        trimmed.startsWith('import ') || trimmed.startsWith('export ');
    if (isDirective) {
      if (!seen.add(trimmed)) continue;
    }
    out.add(line);
  }
  return out.join('\n');
}
