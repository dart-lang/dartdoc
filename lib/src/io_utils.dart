// Copyright (c) 2014, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// This is a helper library to make working with io easier.
library dartdoc.io_utils;

import 'dart:async';
import 'dart:convert';
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

/// Converts `.` and `:` into `-`, adding a ".html" extension.
///
/// For example:
///
/// * dart.dartdoc => dart_dartdoc.html
/// * dart:core => dart_core.html
String getFileNameFor(String name) =>
    '${name.replaceAll(libraryNameRegexp, '-')}.html';

final libraryNameRegexp = new RegExp('[.:]');
final partOfRegexp = new RegExp('part of ');
final newLinePartOfRegexp = new RegExp('\npart of ');

final RegExp quotables = new RegExp(r'[ "\r\n\$]');

class SubprocessLauncher {
  final String context;
  final Map<String, String> environment;

  String get prefix => context.isNotEmpty ? '$context: ' : '';

  // from flutter:dev/tools/dartdoc.dart, modified
  static void _printStream(Stream<List<int>> stream, Stdout output,
      {String prefix: '', Iterable<String> Function(String line) filter}) {
    assert(prefix != null);
    if (filter == null) filter = (line) => [line];
    stream
        .transform(utf8.decoder)
        .transform(const LineSplitter())
        .expand(filter)
        .listen((String line) {
      if (line != null) {
        output.write('$prefix$line'.trim());
        output.write('\n');
      }
    });
  }

  SubprocessLauncher(this.context, [Map<String, String> environment])
      : this.environment = environment ?? <String, String>{};

  /// A wrapper around start/await process.exitCode that will display the
  /// output of the executable continuously and fail on non-zero exit codes.
  /// It will also parse any valid JSON objects (one per line) it encounters
  /// on stdout/stderr, and return them.  Returns null if no JSON objects
  /// were encountered.
  ///
  /// Makes running programs in grinder similar to set -ex for bash, even on
  /// Windows (though some of the bashisms will no longer make sense).
  /// TODO(jcollins-g): move this to grinder?
  Future<Iterable<Map>> runStreamed(String executable, List<String> arguments,
      {String workingDirectory}) async {
    List<Map> jsonObjects;

    /// Allow us to pretend we didn't pass the JSON flag in to dartdoc by
    /// printing what dartdoc would have printed without it, yet storing
    /// json objects into [jsonObjects].
    Iterable<String> jsonCallback(String line) {
      Map result;
      try {
        result = json.decoder.convert(line);
      } catch (FormatException) {}
      if (result != null) {
        if (jsonObjects == null) {
          jsonObjects = new List();
        }
        jsonObjects.add(result);
        if (result.containsKey('message')) {
          line = result['message'];
        } else if (result.containsKey('data')) {
          line = result['data']['text'];
        }
      }
      return line.split('\n');
    }

    stderr.write('$prefix+ ');
    if (workingDirectory != null) stderr.write('(cd "$workingDirectory" && ');
    if (environment != null) {
      stderr.write(environment.keys.map((String key) {
        if (environment[key].contains(quotables)) {
          return "$key='${environment[key]}'";
        } else {
          return "$key=${environment[key]}";
        }
      }).join(' '));
      stderr.write(' ');
    }
    stderr.write('$executable');
    if (arguments.isNotEmpty) {
      for (String arg in arguments) {
        if (arg.contains(quotables)) {
          stderr.write(" '$arg'");
        } else {
          stderr.write(" $arg");
        }
      }
    }
    if (workingDirectory != null) stderr.write(')');
    stderr.write('\n');
    Process process = await Process.start(executable, arguments,
        workingDirectory: workingDirectory, environment: environment);

    _printStream(process.stdout, stdout, prefix: prefix, filter: jsonCallback);
    _printStream(process.stderr, stderr, prefix: prefix, filter: jsonCallback);
    await process.exitCode;

    int exitCode = await process.exitCode;
    if (exitCode != 0) {
      throw new ProcessException(executable, arguments,
          "SubprocessLauncher got non-zero exitCode", exitCode);
    }
    return jsonObjects;
  }
}
