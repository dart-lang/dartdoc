// Copyright (c) 2020, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:analyzer/file_system/file_system.dart';
import 'package:path/path.dart' as p;

/// Keeps track of coverage data automatically for any processes run by this
/// [CoverageSubprocessLauncher].  Requires that these be dart processes.
class CoverageSubprocessLauncher extends SubprocessLauncher {
  CoverageSubprocessLauncher(String context, [Map<String, String>? environment])
      : super(
            context, {...?environment, 'DARTDOC_COVERAGE_DATA': tempDir.path});

  static int nextRun = 0;

  /// Set this to true to enable coverage runs.
  static bool get coverageEnabled =>
      Platform.environment.containsKey('COVERAGE_TOKEN');

  /// A list of all coverage results picked up by all launchers.
  // TODO(srawlins): Refactor this to one or more type aliases once the feature
  // is enabled.
  static List<Future<Iterable<Map<Object, Object?>>>> coverageResults = [];

  static Directory tempDir = () {
    var coverageData = Platform.environment['DARTDOC_COVERAGE_DATA'];
    if (coverageData != null) {
      return Directory(coverageData);
    }
    return Directory.systemTemp.createTempSync('dartdoc_coverage_data');
  }();

  static String buildNextCoverageFilename() =>
      p.join(tempDir.path, 'dart-cov-$pid-${nextRun++}.json');

  /// Call once all coverage runs have been generated by calling runStreamed
  /// on all [CoverageSubprocessLaunchers].
  static Future<dynamic> generateCoverageToFile(
      File outputFile, ResourceProvider resourceProvider) async {
    if (!coverageEnabled) return Future.value(null);
    var currentCoverageResults = coverageResults;
    coverageResults = [];
    var launcher = SubprocessLauncher('format_coverage');

    /// Wait for all coverage runs to finish.
    await Future.wait(currentCoverageResults);

    return launcher.runStreamed('pub', [
      'run',
      'coverage:format_coverage',
      '--lcov',
      '-v',
      '-b',
      '.',
      '--packages=.packages',
      '--sdk-root=${p.canonicalize(p.join(p.dirname(Platform.executable), '..'))}',
      '--out=${p.canonicalize(outputFile.path)}',
      '--report-on=bin,lib',
      '-i',
      tempDir.path,
    ]);
  }

  @override
  Future<Iterable<Map<String, Object?>>> runStreamed(
      String executable, List<String> arguments,
      {String? workingDirectory,
      Map<String, String>? environment,
      bool includeParentEnvironment = true,
      void Function(String)? perLine}) async {
    environment ??= {};
    assert(
        executable == Platform.executable ||
            executable == Platform.resolvedExecutable,
        'Must use dart executable for tracking coverage');

    var portAsString = Completer<String>();
    void parsePortAsString(String line) {
      if (!portAsString.isCompleted && coverageEnabled) {
        var m = _vmServicePortRegexp.matchAsPrefix(line);
        if (m != null) {
          if (m.group(1) != null) portAsString.complete(m.group(1));
        }
      } else {
        if (perLine != null) perLine(line);
      }
    }

    var coverageResult = Completer<Iterable<Map<Object, Object?>>>();

    if (coverageEnabled) {
      // This must be added before awaiting in this method.
      coverageResults.add(coverageResult.future);
      arguments = [
        '--disable-service-auth-codes',
        '--enable-vm-service=0',
        '--pause-isolates-on-exit',
        ...arguments
      ];
      if (!environment.containsKey('DARTDOC_COVERAGE_DATA')) {
        environment['DARTDOC_COVERAGE_DATA'] = tempDir.path;
      }
    }

    var results = super.runStreamed(executable, arguments,
        environment: environment,
        includeParentEnvironment: includeParentEnvironment,
        workingDirectory: workingDirectory,
        perLine: parsePortAsString);

    if (coverageEnabled) {
      await super.runStreamed('pub', [
        'run',
        'coverage:collect_coverage',
        '--wait-paused',
        '--resume-isolates',
        '--port=${await portAsString.future}',
        '--out=${buildNextCoverageFilename()}',
      ]).then((r) => coverageResult.complete(r));
    }
    return results;
  }

  static final _vmServicePortRegexp = RegExp(
      r'^(?:Observatory|The Dart VM service is) listening on http://.*:(\d+)');
}

class SubprocessLauncher {
  final String context;
  final Map<String, String> environmentDefaults = {};

  String get prefix => context.isNotEmpty ? '$context: ' : '';

  // This is borrowed from flutter:dev/tools/dartdoc.dart; modified.
  static Future<void> _printStream(Stream<List<int>> stream, StringSink output,
      {required Iterable<String> Function(String line) filter,
      String prefix = ''}) {
    return stream
        .transform(utf8.decoder)
        .transform(const LineSplitter())
        .expand(filter)
        .listen((String line) {
      output.write('$prefix$line'.trim());
      output.write('\n');
    }).asFuture();
  }

  SubprocessLauncher(this.context, [Map<String, String>? environment]) {
    environmentDefaults.addAll(environment ?? {});
  }

  /// A wrapper around start/await process.exitCode that will display the
  /// output of the executable continuously and fail on non-zero exit codes.
  /// It will also parse any valid JSON objects (one per line) it encounters
  /// on stdout/stderr, and return them.  Returns null if no JSON objects
  /// were encountered, or if DRY_RUN is set to 1 in the execution environment.
  ///
  /// Makes running programs in grinder similar to set -ex for bash, even on
  /// Windows (though some of the bashisms will no longer make sense).
  /// TODO(jcollins-g): refactor to return a stream of stderr/stdout lines
  ///                   and their associated JSON objects.
  Future<Iterable<Map<String, Object?>>> runStreamed(
      String executable, List<String> arguments,
      {String? workingDirectory,
      Map<String, String>? environment,
      bool includeParentEnvironment = true,
      void Function(String)? perLine}) async {
    environment = {}
      ..addAll(environmentDefaults)
      ..addAll(environment ?? {});
    var jsonObjects = <Map<String, Object?>>[];

    /// Allow us to pretend we didn't pass the JSON flag in to dartdoc by
    /// printing what dartdoc would have printed without it, yet storing
    /// json objects into [jsonObjects].
    Iterable<String> jsonCallback(String line) {
      if (perLine != null) perLine(line);
      Map<String, Object?>? result;
      try {
        result = json.decoder.convert(line);
      } on FormatException {
        // Assume invalid JSON is actually a line of normal text.
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
          line = data['text'];
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

    var realExecutable = executable;
    var realArguments = <String>[];
    if (Platform.isLinux) {
      // Use GNU coreutils to force line buffering.  This makes sure that
      // subprocesses that die due to fatal signals do not chop off the
      // last few lines of their output.
      //
      // Dart does not actually do this (seems to flush manually) unless
      // the VM crashes.
      realExecutable = 'stdbuf';
      realArguments.addAll(['-o', 'L', '-e', 'L']);
      realArguments.add(executable);
    }
    realArguments.addAll(arguments);

    var process = await Process.start(realExecutable, realArguments,
        workingDirectory: workingDirectory,
        environment: environment,
        includeParentEnvironment: includeParentEnvironment);
    var stdoutBuffer = StringBuffer();
    var stdoutFuture = _printStream(process.stdout, stdoutBuffer,
        prefix: prefix, filter: jsonCallback);
    var stderrBuffer = StringBuffer();
    var stderrFuture = _printStream(process.stderr, stderrBuffer,
        prefix: prefix, filter: jsonCallback);
    await Future.wait([stderrFuture, stdoutFuture, process.exitCode]);

    var exitCode = await process.exitCode;
    if (exitCode != 0) {
      throw ProcessException(
          executable,
          arguments,
          'SubprocessLauncher got non-zero exitCode: $exitCode\n\n'
          'stdout: $stdoutBuffer\n\nstderr: $stderrBuffer',
          exitCode);
    }
    return jsonObjects;
  }

  static final _quotables = RegExp(r'[ "\r\n\$]');
}
