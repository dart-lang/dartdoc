// Copyright (c) 2018, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library dartdoc.model_test;

import 'dart:io';

import 'package:dartdoc/src/dartdoc_options.dart';
import 'package:dartdoc/src/tool_runner.dart';
import 'package:path/path.dart' as path;
import 'package:test/test.dart';
import 'package:yaml/yaml.dart';

import 'src/utils.dart' as utils;

void main() {
  var toolMap;
  Directory tempDir;
  File setupFile;

  ToolRunner runner;
  ToolTempFileTracker tracker;
  ToolErrorCallback errorCallback;
  final errors = <String>[];

  setUpAll(() async {
    ProcessResult result;
    tempDir = Directory.systemTemp.createTempSync('tool_runner_test_');
    var snapshotFile = path.join(tempDir.path, 'drill.snapshot');
    try {
      result = Process.runSync(
          Platform.resolvedExecutable,
          [
            '--snapshot=${snapshotFile}',
            '--snapshot-kind=app-jit',
            'bin/drill.dart'
          ],
          workingDirectory: utils.testPackageDir.absolute.path);
    } on ProcessException catch (exception) {
      stderr.writeln('Unable to make snapshot of tool: $exception');
      expect(result?.exitCode, equals(0));
    }
    if (result != null && result.exitCode != 0) {
      stdout.writeln(result.stdout);
      stderr.writeln(result.stderr);
    }
    expect(result?.exitCode, equals(0));
    setupFile = File(path.join(tempDir.path, 'setup.stamp'));
    // We use the Dart executable for our "non-dart" tool
    // test, because it's the only executable that we know the
    // exact location of that works on all platforms.
    var nonDartExecutable = Platform.resolvedExecutable;
    // Have to replace backslashes on Windows with double-backslashes, to
    // escape them for YAML parser.
    var yamlMap = '''
drill:
  command: ["bin/drill.dart"]
  description: "Puts holes in things."
snapshot_drill:
  command: ["${snapshotFile.replaceAll(r'\', r'\\')}"]
  description: "Puts holes in things, but faster."
setup_drill:
  command: ["bin/drill.dart"]
  setup_command: ["bin/setup.dart", "${setupFile.absolute.path.replaceAll(r'\', r'\\')}"]
  description: "Puts holes in things, with setup."
non_dart:
  command: ["${nonDartExecutable.replaceAll(r'\', r'\\')}"]
  description: "A non-dart tool"
echo:
  macos: ['/bin/sh', '-c', 'echo']
  linux: ['/bin/sh', '-c', 'echo']
  windows: ['C:\\Windows\\System32\\cmd.exe', '/c', 'echo']
  description: 'Works on everything'
''';
    var pathContext = path.Context(current: utils.testPackageDir.absolute.path);
    toolMap = ToolConfiguration.fromYamlMap(loadYaml(yamlMap), pathContext);
    // This shouldn't really happen, but if you didn't load the config from a
    // yaml map (which would fail on a missing executable), or a file is deleted
    // during execution,it might, so we test it.
    toolMap.tools.addAll({
      'missing': ToolDefinition(['/a/missing/executable'], null, 'missing'),
    });

    runner = ToolRunner(toolMap);
    errorCallback = (String message) => errors.add(message);
  });
  tearDownAll(() {
    tempDir?.deleteSync(recursive: true);
    tracker?.dispose();
    SnapshotCache.instance.dispose();
    setupFile = null;
    tempDir = null;
  });

  group('ToolRunner', () {
    setUp(() {
      errors.clear();
    });
    // This test must come first, to verify that the first run creates
    // a snapshot.
    test('can invoke a Dart tool, and second run is a snapshot.', () async {
      var result = await runner.run(
        ['drill', r'--file=$INPUT'],
        errorCallback,
        content: 'TEST INPUT',
      );
      expect(errors, isEmpty);
      expect(result, contains('--file=<INPUT_FILE>'));
      expect(result, contains('## `TEST INPUT`'));
      expect(result, contains('Script location is in dartdoc tree.'));
      expect(setupFile.existsSync(), isFalse);
      result = await runner.run(
        ['drill', r'--file=$INPUT'],
        errorCallback,
        content: 'TEST INPUT 2',
      );
      expect(errors, isEmpty);
      expect(result, contains('--file=<INPUT_FILE>'));
      expect(result, contains('## `TEST INPUT 2`'));
      expect(result, contains('Script location is in snapshot cache.'));
      expect(setupFile.existsSync(), isFalse);
    });
    test('can invoke a Dart tool', () async {
      var result = await runner.run(
        ['drill', r'--file=$INPUT'],
        errorCallback,
        content: 'TEST INPUT',
      );
      expect(errors, isEmpty);
      expect(result, contains('Script location is in snapshot cache.'));
      expect(result, contains('--file=<INPUT_FILE>'));
      expect(result, contains('## `TEST INPUT`'));
      expect(setupFile.existsSync(), isFalse);
    });
    test('can invoke a non-Dart tool', () async {
      var result = await runner.run(
        ['non_dart', '--version'],
        errorCallback,
        content: 'TEST INPUT',
      );
      expect(errors, isEmpty);
      expect(result, isEmpty); // Output is on stderr.
    });
    test('can invoke a pre-snapshotted tool', () async {
      var result = await runner.run(
        ['snapshot_drill', r'--file=$INPUT'],
        errorCallback,
        content: 'TEST INPUT',
      );
      expect(errors, isEmpty);
      expect(result, contains('--file=<INPUT_FILE>'));
      expect(result, contains('## `TEST INPUT`'));
    });
    test('can invoke a tool with a setup action', () async {
      var result = await runner.run(
        ['setup_drill', r'--file=$INPUT'],
        errorCallback,
        content: 'TEST INPUT',
      );
      expect(errors, isEmpty);
      expect(result, contains('--file=<INPUT_FILE>'));
      expect(result, contains('## `TEST INPUT`'));
      expect(setupFile.existsSync(), isTrue);
    });
    test('fails if tool not in tool map', () async {
      var result = await runner.run(
        ['hammer', r'--file=$INPUT'],
        errorCallback,
        content: 'TEST INPUT',
      );
      expect(errors, isNotEmpty);
      expect(
          errors[0], contains('Unable to find definition for tool "hammer"'));
      expect(result, isEmpty);
    });
    test('fails if tool returns non-zero status', () async {
      var result = await runner.run(
        ['drill', r'--file=/a/missing/file'],
        errorCallback,
        content: 'TEST INPUT',
      );
      expect(errors, isNotEmpty);
      expect(errors[0], contains('Tool "drill" returned non-zero exit code'));
      expect(result, isEmpty);
    });
    test("fails if tool in tool map doesn't exist", () async {
      var result = await runner.run(
        ['missing'],
        errorCallback,
        content: 'TEST INPUT',
      );
      expect(errors, isNotEmpty);
      expect(errors[0],
          contains('Failed to run tool "missing" as "/a/missing/executable"'));
      expect(result, isEmpty);
    });
  });
}
