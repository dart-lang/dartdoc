// Copyright (c) 2020, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'dart:convert';
import 'dart:io';

class SubprocessLauncher {
  final String context;
  final Map<String, String> defaultEnvironment;

  String get prefix => context.isNotEmpty ? '$context: ' : '';

  /// Listen to [stream] as a stream of lines of text, writing them to both
  /// [output] and a returned String.
  ///
  /// This is borrowed from flutter:dev/tools/dartdoc.dart; modified.
  static Future<String> _printStream(Stream<List<int>> stream, Stdout output,
          {required Iterable<String> Function(String line) filter,
          String prefix = ''}) =>
      stream
          .transform(utf8.decoder)
          .transform(const LineSplitter())
          .expand(filter)
          .map(
        (String line) {
          final value = '${'$prefix$line'.trim()}\n';
          output.write(value);
          return value;
        },
      ).join();

  SubprocessLauncher(this.context, [this.defaultEnvironment = const {}]);

  /// A wrapper around start/await `process.exitCode` that displays the output
  /// of [executable] with [arguments] continuously and throws on non-zero exit
  /// codes.
  ///
  /// It will also parse any valid JSON objects (one per line) it encounters
  /// on stdout/stderr, and return them. Returns null if no JSON objects
  /// were encountered, or if DRY_RUN is set to 1 in the execution environment.
  // TODO(jcollins-g): refactor to return a stream of stderr/stdout lines and
  // their associated JSON objects.
  Future<Iterable<Map<String, Object?>>> runStreamed(
    String executable,
    List<String> arguments, {
    String? workingDirectory,
    Map<String, String>? environment,
    bool includeParentEnvironment = true,
    bool withStats = false,
  }) async {
    environment = {...defaultEnvironment, ...?environment};
    var jsonObjects = <Map<String, Object?>>[];

    /// Allow us to pretend we didn't pass the JSON flag in to dartdoc by
    /// printing what dartdoc would have printed without it, yet storing
    /// json objects into [jsonObjects].
    Iterable<String> jsonCallback(String line) {
      Map<String, Object?>? result;
      try {
        result = json.decoder.convert(line) as Map<String, dynamic>?;
      } on FormatException {
        // Assume invalid JSON is actually a line of normal text.
        // ignore: avoid_catching_errors
      } on TypeError catch (e, st) {
        // The convert function returns a String if there is no JSON in the
        // line.  Just ignore it and leave result null.
        print(e);
        print(st);
      }
      if (result != null) {
        jsonObjects.add(result);
        if (result.containsKey('message')) {
          line = result['message'] as String;
        } else if (result.containsKey('data')) {
          var data = result['data'] as Map;
          line = data['text'] as String;
        }
      }
      return line.split('\n');
    }

    stderr.write('$prefix+ ');
    if (workingDirectory != null) stderr.write('(cd "$workingDirectory" && ');
    if (environment.isNotEmpty) {
      stderr.write(environment.entries.map((MapEntry<String, String> entry) {
        if (entry.key.contains(_quotables)) {
          return "${entry.key}='${entry.value}'";
        } else {
          return '${entry.key}=${entry.value}';
        }
      }).join(' '));
      stderr.write(' ');
    }
    stderr.write(executable);
    if (arguments.isNotEmpty) {
      for (var arg in arguments) {
        if (arg.contains(_quotables)) {
          stderr.write(" '$arg'");
        } else {
          stderr.write(' $arg');
        }
      }
    }
    if (workingDirectory != null) stderr.write(')');
    stderr.write('\n');

    if (Platform.environment.containsKey('DRY_RUN')) return {};

    if (withStats) {
      (executable, arguments) = wrapWithTime(executable, arguments);
    }
    if (Platform.isLinux) {
      (executable, arguments) = _wrapWithStdbuf(executable, arguments);
    }

    var process = await Process.start(executable, arguments,
        workingDirectory: workingDirectory,
        environment: environment,
        includeParentEnvironment: includeParentEnvironment);
    // Stream stdout and stderr to _this_ process's stdout and stderr.
    var stdoutFuture = _printStream(process.stdout, stdout,
        prefix: prefix, filter: jsonCallback);
    var stderrFuture = _printStream(process.stderr, stderr,
        prefix: prefix, filter: jsonCallback);
    var (_, _, exitCode) =
        await (stdoutFuture, stderrFuture, process.exitCode).wait;

    if (exitCode != 0) {
      print('${await stdoutFuture} ${await stderrFuture}');
      throw SubprocessException(
        command: [executable, ...arguments].join(' '),
        workingDirectory: workingDirectory,
        exitCode: exitCode,
        environment: environment,
      );
    }
    return jsonObjects;
  }

  /// Wraps [command] and [args] with a call to `stdbuf`.
  (String, List<String>) _wrapWithStdbuf(String command, List<String> args) =>
      // Use GNU coreutils to force line buffering.  This makes sure that
      // subprocesses that die due to fatal signals do not chop off the last few
      // lines of their output.
      //
      // Dart does not actually do this (seems to flush manually) unless the VM
      // crashes.
      (
        'stdbuf',
        [
          ...['-o', 'L', '-e', 'L'],
          command,
          ...args,
        ],
      );

  /// Wraps [command] and [args] with a command to `time`.
  static (String, List<String>) wrapWithTime(
          String command, List<String> args) =>
      ('/usr/bin/time', ['-l', command, ...args]);

  Future<Iterable<Map<String, Object?>>> runStreamedDartCommand(
    List<String> arguments, {
    String? workingDirectory,
    Map<String, String>? environment,
    bool includeParentEnvironment = true,
    bool withStats = false,
  }) async =>
      await runStreamed(
        Platform.executable,
        arguments,
        workingDirectory: workingDirectory,
        environment: environment,
        includeParentEnvironment: includeParentEnvironment,
        withStats: withStats,
      );

  static final _quotables = RegExp(r'[ "\r\n\$]');
}

/// An exception that represents an issue during subprocess execution.
class SubprocessException implements Exception {
  final String command;
  final String? workingDirectory;
  final int exitCode;
  final Map<String, String> environment;

  SubprocessException({
    required this.command,
    required this.workingDirectory,
    required this.environment,
    required this.exitCode,
  });

  @override
  String toString() => 'SubprocessException['
      'command: "$command", '
      'workingDirectory: "${workingDirectory ?? '(null)'}", '
      'exitCode: $exitCode, '
      'environment: $environment]';
}
