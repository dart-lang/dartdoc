// Copyright (c) 2018, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library dartdoc.model_test;

import 'dart:io';

import 'package:dartdoc/src/dartdoc_options.dart';
import 'package:dartdoc/src/tool_runner.dart';
import 'package:path/path.dart' as pathLib;
import 'package:test/test.dart';
import 'package:yaml/yaml.dart';

import 'src/utils.dart' as utils;

void main() {
  var toolMap;
  Directory tempDir;

  ToolRunner runner;
  final errors = <String>[];

  setUpAll(() async {
    ProcessResult result;
    tempDir = Directory.systemTemp.createTempSync('tool_runner_test_');
    var snapshotFile = pathLib.join(tempDir.path, 'drill.snapshot');
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
    // We use the Dart executable for our "non-dart" tool
    // test, because it's the only executable that we know the
    // exact location of that works on all platforms.
    var nonDartExecutable = Platform.resolvedExecutable;
    var yamlMap = '''
drill:
  command: ["bin/drill.dart"]
  description: "Puts holes in things."
snapshot_drill:
  command: ["${snapshotFile}"]
  description: "Puts holes in things, but faster."
non_dart:
  command: ["$nonDartExecutable"]
  description: "A non-dart tool"
echo:
  macos: ['/bin/sh', '-c', 'echo']
  linux: ['/bin/sh', '-c', 'echo']
  windows: ['C:\\Windows\\System32\\cmd.exe', '/c', 'echo']
  description: 'Works on everything'
''';
    var pathContext =
        pathLib.Context(current: utils.testPackageDir.absolute.path);
    toolMap = ToolConfiguration.fromYamlMap(loadYaml(yamlMap), pathContext);
    // This shouldn't really happen, but if you didn't load the config from a
    // yaml map (which would fail on a missing executable), or a file is deleted
    // during execution,it might, so we test it.
    toolMap.tools.addAll({
      'missing': new ToolDefinition(['/a/missing/executable'], "missing"),
    });

    runner = new ToolRunner(toolMap, (String message) => errors.add(message));
  });
  tearDownAll(() {
    tempDir?.deleteSync(recursive: true);
    runner?.dispose();
  });

  group('ToolRunner', () {
    setUp(() {
      errors.clear();
    });
    test('can invoke a Dart tool', () {
      var result = runner.run(
        ['drill', r'--file=$INPUT'],
        content: 'TEST INPUT',
      );
      expect(errors, isEmpty);
      expect(result, contains('--file=<INPUT_FILE>'));
      expect(result, contains('## `TEST INPUT`'));
    });
    test('can invoke a non-Dart tool', () {
      String result = runner.run(
        ['non_dart', '--version'],
        content: 'TEST INPUT',
      );
      expect(errors, isEmpty);
      expect(result, isEmpty); // Output is on stderr.
    });
    test('can invoke a snapshotted tool', () {
      var result = runner.run(
        ['snapshot_drill', r'--file=$INPUT'],
        content: 'TEST INPUT',
      );
      expect(errors, isEmpty);
      expect(result, contains('--file=<INPUT_FILE>'));
      expect(result, contains('## `TEST INPUT`'));
    });
    test('fails if tool not in tool map', () {
      String result = runner.run(
        ['hammer', r'--file=$INPUT'],
        content: 'TEST INPUT',
      );
      expect(errors, isNotEmpty);
      expect(
          errors[0], contains('Unable to find definition for tool "hammer"'));
      expect(result, isEmpty);
    });
    test('fails if tool returns non-zero status', () {
      String result = runner.run(
        ['drill', r'--file=/a/missing/file'],
        content: 'TEST INPUT',
      );
      expect(errors, isNotEmpty);
      expect(errors[0], contains('Tool "drill" returned non-zero exit code'));
      expect(result, isEmpty);
    });
    test("fails if tool in tool map doesn't exist", () {
      String result = runner.run(
        ['missing'],
        content: 'TEST INPUT',
      );
      expect(errors, isNotEmpty);
      expect(errors[0],
          contains('Failed to run tool "missing" as "/a/missing/executable"'));
      expect(result, isEmpty);
    });
  });
}
