// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'dart:io';

import 'package:dartdoc/src/io_utils.dart';
import 'package:path/path.dart' as p;

import 'subprocess_launcher.dart';

/// A class representing a Flutter SDK repository.
class FlutterRepo {
  final String path;
  final Map<String, String> env;
  final String flutterCmd = p.join('bin', 'flutter');

  final String cacheDart;
  final SubprocessLauncher launcher;

  FlutterRepo._(this.path, this.env, this.cacheDart, this.launcher);

  Future<void> init() async {
    Directory(path).createSync(recursive: true);
    await launcher.runStreamed(
        'git', ['clone', 'https://github.com/flutter/flutter.git', '.'],
        workingDirectory: path);
    await launcher.runStreamed(
      flutterCmd,
      ['--version'],
      workingDirectory: path,
    );
    await launcher.runStreamed(
      flutterCmd,
      ['update-packages'],
      workingDirectory: path,
    );
  }

  factory FlutterRepo.fromPath(String flutterPath, Map<String, String> env,
      [String? label]) {
    var cacheDart =
        p.join(flutterPath, 'bin', 'cache', 'dart-sdk', 'bin', 'dart');
    var flutterBinPath = p.join(p.canonicalize(flutterPath), 'bin');
    var existingPathVariable = env['PATH'] ?? Platform.environment['PATH'];
    env['PATH'] = '$flutterBinPath:$existingPathVariable';
    env['FLUTTER_ROOT'] = flutterPath;
    var launcher =
        SubprocessLauncher('flutter${label == null ? "" : "-$label"}', env);
    return FlutterRepo._(flutterPath, env, cacheDart, launcher);
  }

  /// Copies an existing, initialized flutter repo.
  static Future<FlutterRepo> copyFromExistingFlutterRepo(
      FlutterRepo originalRepo, String flutterPath, Map<String, String> env,
      [String? label]) async {
    // Note: This is only designed to work on Unix-like systems.
    Process.runSync('cp', [originalRepo.path, flutterPath]);
    return FlutterRepo.fromPath(flutterPath, env, label);
  }

  /// Doesn't actually copy the existing repo; use for read-only operations
  /// only.
  static Future<FlutterRepo> fromExistingFlutterRepo(FlutterRepo originalRepo,
      [String? label]) async {
    return FlutterRepo.fromPath(originalRepo.path, {}, label);
  }
}

Directory cleanFlutterDir = Directory(
    p.join(p.context.resolveTildePath('~/.dartdoc_grinder'), 'cleanFlutter'));

/// Global so that the lock is retained for the life of the process.
Future<void>? _lockFuture;
Completer<FlutterRepo>? _cleanFlutterRepo;

/// Returns true if we need to replace the existing flutter.  We never release
/// this lock until the program exits to prevent edge case runs from
/// spontaneously deciding to download a new Flutter SDK in the middle of a run.
// TODO(srawlins): The above comment is outdated.
Future<FlutterRepo> get cleanFlutterRepo async {
  var repoCompleter = _cleanFlutterRepo;
  if (repoCompleter != null) {
    return repoCompleter.future;
  }

  // No await is allowed between check of `_cleanFlutterRepo` and its
  // assignment, to prevent reentering this function.
  repoCompleter = Completer();
  _cleanFlutterRepo = repoCompleter;

  // Figure out where the repository is supposed to be and lock updates for it.
  await cleanFlutterDir.parent.create(recursive: true);
  assert(_lockFuture == null);
  _lockFuture = File(p.join(cleanFlutterDir.parent.path, 'lock'))
      .openSync(mode: FileMode.write)
      .lock();
  await _lockFuture;
  var lastSynced = File(p.join(cleanFlutterDir.parent.path, 'lastSynced'));
  var newRepo = FlutterRepo.fromPath(cleanFlutterDir.path, {}, 'clean');

  // We have a repository, but is it up to date?
  DateTime? lastSyncedTime;
  if (lastSynced.existsSync()) {
    lastSyncedTime = DateTime.fromMillisecondsSinceEpoch(
        int.parse(lastSynced.readAsStringSync()));
  }
  if (lastSyncedTime == null ||
      DateTime.now().difference(lastSyncedTime) > Duration(hours: 24)) {
    // Rebuild the repository.
    if (cleanFlutterDir.existsSync()) {
      cleanFlutterDir.deleteSync(recursive: true);
    }
    cleanFlutterDir.createSync(recursive: true);
    await newRepo.init();
    await lastSynced
        .writeAsString(DateTime.now().millisecondsSinceEpoch.toString());
  }
  repoCompleter.complete(newRepo);
  _cleanFlutterRepo = repoCompleter;
  return repoCompleter.future;
}
