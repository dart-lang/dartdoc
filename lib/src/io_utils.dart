// Copyright (c) 2014, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// This is a helper library to make working with io easier.
library dartdoc.io_utils;

import 'dart:async';
import 'dart:io';

import 'package:path/path.dart' as path;

/// Return a resolved path including the home directory in place of tilde
/// references.
String resolveTildePath(String originalPath) {
  if (originalPath == null || !originalPath.startsWith('~/')) {
    return originalPath;
  }

  String homeDir;

  if (Platform.isWindows) {
    homeDir = path.absolute(Platform.environment['USERPROFILE']);
  } else {
    homeDir = path.absolute(Platform.environment['HOME']);
  }

  return path.join(homeDir, originalPath.substring(2));
}

/// Lists the contents of [dir].
///
/// If [recursive] is `true`, lists subdirectory contents (defaults to `false`).
///
/// Excludes files and directories beginning with `.`
///
/// The returned paths are guaranteed to begin with [dir].
Iterable<String> listDir(String dir,
    {bool recursive = false,
    Iterable<FileSystemEntity> Function(Directory dir) listDir}) {
  listDir ??= (Directory dir) => dir.listSync();

  return _doList(dir, <String>{}, recursive, listDir);
}

Iterable<String> _doList(
    String dir,
    Set<String> listedDirectories,
    bool recurse,
    Iterable<FileSystemEntity> Function(Directory dir) listDir) sync* {
  // Avoid recursive symlinks.
  var resolvedPath = Directory(dir).resolveSymbolicLinksSync();
  if (!listedDirectories.contains(resolvedPath)) {
    listedDirectories = Set<String>.from(listedDirectories);
    listedDirectories.add(resolvedPath);

    for (var entity in listDir(Directory(dir))) {
      // Skip hidden files and directories
      if (path.basename(entity.path).startsWith('.')) {
        continue;
      }

      yield entity.path;
      if (entity is Directory) {
        if (recurse) {
          yield* _doList(entity.path, listedDirectories, recurse, listDir);
        }
      }
    }
  }
}

/// Converts `.` and `:` into `-`, adding a ".html" extension.
///
/// For example:
///
/// * dart.dartdoc => dart_dartdoc.html
/// * dart:core => dart_core.html
String getFileNameFor(String name) =>
    '${name.replaceAll(libraryNameRegexp, '-')}.html';

final libraryNameRegexp = RegExp('[.:]');
final partOfRegexp = RegExp('part of ');
final newLinePartOfRegexp = RegExp('\npart of ');

/// Best used with Future<void>.
class MultiFutureTracker<T> {
  /// Approximate maximum number of simultaneous active Futures.
  final int parallel;

  final Set<Future<T>> _trackedFutures = {};

  MultiFutureTracker(this.parallel);

  /// Wait until fewer or equal to this many Futures are outstanding.
  Future<void> _waitUntil(int max) async {
    while (_trackedFutures.length > max) {
      await Future.any(_trackedFutures);
    }
  }

  /// Generates a [Future] from the given closure and adds it to the queue,
  /// once the queue is sufficiently empty.  The returned future completes
  /// when the generated [Future] has been added to the queue.
  Future<void> addFutureFromClosure(Future<T> Function() closure) async {
    while (_trackedFutures.length > parallel - 1) {
      await Future.any(_trackedFutures);
    }
    Future future = closure();
    _trackedFutures.add(future);
    // ignore: unawaited_futures
    future.then((f) => _trackedFutures.remove(future));
  }

  /// Wait until all futures added so far have completed.
  Future<void> wait() async => await _waitUntil(0);
}
