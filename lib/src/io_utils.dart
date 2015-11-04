// Copyright (c) 2014, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// This is a helper library to make working with io easier.
library dartdoc.io_utils;

import 'dart:io';

import 'package:path/path.dart' as path;

/// Lists the contents of [dir].
///
/// If [recursive] is `true`, lists subdirectory contents (defaults to `false`).
///
/// Excludes files and directories beginning with `.`
///
/// The returned paths are guaranteed to begin with [dir].
Iterable<String> listDir(String dir,
    {bool recursive: false,
    Iterable<FileSystemEntity> listDir(Directory dir)}) {
  if (listDir == null) listDir = (Directory dir) => dir.listSync();

  return _doList(dir, new Set<String>(), recursive, listDir);
}

Iterable<String> _doList(String dir, Set<String> listedDirectories,
    bool recurse, Iterable<FileSystemEntity> listDir(Directory dir)) sync* {
  // Avoid recursive symlinks.
  var resolvedPath = new Directory(dir).resolveSymbolicLinksSync();
  if (!listedDirectories.contains(resolvedPath)) {
    listedDirectories = new Set<String>.from(listedDirectories);
    listedDirectories.add(resolvedPath);

    for (var entity in listDir(new Directory(dir))) {
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

/// Given a package name, explore the directory and pull out all top level
/// library files in the "lib" directory to document.
Iterable<String> findFilesToDocumentInPackage(String packageDir) sync* {
  var packageLibDir = path.join(packageDir, 'lib');
  var packageLibSrcDir = path.join(packageLibDir, 'src');

  // To avoid analyzing package files twice, only files with paths not
  // containing '/packages' will be added. The only exception is if the file
  // to analyze already has a '/package' in its path.
  for (var lib
      in listDir(packageDir, recursive: true, listDir: _packageDirList)) {
    if (lib.endsWith('.dart') &&
        (!lib.contains('${path.separator}packages') ||
            packageDir.contains('${path.separator}packages'))) {
      // Only include libraries within the lib dir that are not in lib/src
      if (path.isWithin(packageLibDir, lib) &&
          !path.isWithin(packageLibSrcDir, lib)) {
        // Only add the file if it does not contain 'part of'
        var contents = new File(lib).readAsStringSync();

        if (contents.contains(_newLinePartOfRegexp) ||
            contents.startsWith(_partOfRegexp)) {
          // NOOP: it's a part file
        } else {
          yield lib;
        }
      }
    }
  }
}

/// If [dir] contains both a `lib` directory and a `pubspec.yaml` file treat
/// it like a package and only return the `lib` dir.
///
/// This ensures that packages don't have non-`lib` content documented.
Iterable<FileSystemEntity> _packageDirList(Directory dir) sync* {
  var entities = dir.listSync();

  var pubspec = entities.firstWhere(
      (e) => e is File && path.basename(e.path) == 'pubspec.yaml',
      orElse: () => null);

  var libDir = entities.firstWhere(
      (e) => e is Directory && path.basename(e.path) == 'lib',
      orElse: () => null);

  if (pubspec != null && libDir != null) {
    yield libDir;
  } else {
    yield* entities;
  }
}

/// Converts `.` and `:` into `-`, adding a ".html" extension.
///
/// For example:
///
/// * dart.dartdoc => dart_dartdoc.html
/// * dart:core => dart_core.html
String getFileNameFor(String name) =>
    '${name.replaceAll(_libraryNameRegexp, '-')}.html';

final _libraryNameRegexp = new RegExp('[.:]');
final _partOfRegexp = new RegExp('part of ');
final _newLinePartOfRegexp = new RegExp('\npart of ');
