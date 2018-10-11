// Copyright (c) 2018, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library dartdoc.model_test;

import 'dart:io';

import 'package:dartdoc/src/dartdoc_options.dart';
import 'package:dartdoc/src/tool_runner.dart';
import 'package:path/path.dart' as pathLib;
import 'package:test/test.dart';

import 'src/utils.dart' as utils;

void main() {
  var toolMap = ToolConfiguration.empty;

  toolMap.tools.addAll({
    'missing': new ToolDefinition(['/a/missing/executable'], "missing"),
    'drill': new ToolDefinition(
        [pathLib.join(utils.testPackageDir.absolute.path, 'bin', 'drill.dart')],
        'Makes holes'),
    // We use the Dart executable for our "non-dart" tool
    // test, because it's the only executable that we know the
    // exact location of that works on all platforms.
    'non_dart':
        new ToolDefinition([Platform.resolvedExecutable], 'non-dart tool'),
  });
  ToolRunner runner;
  final errors = <String>[];

  setUpAll(() async {
    runner = new ToolRunner(toolMap, (String message) => errors.add(message));
  });
  tearDownAll(() {
    runner.dispose();
  });

  group('ToolRunner', () {
    setUp(() {
      errors.clear();
    });
    test('can invoke a Dart tool', () {
      var result = runner.run(
        ['drill', r'--file=$INPUT'],
        'TEST INPUT',
      );
      expect(errors, isEmpty);
      expect(result, contains(new RegExp(r'Args: \[--file=<INPUT_FILE>]')));
      expect(result, contains('## `TEST INPUT`'));
    });
    test('can invoke a non-Dart tool', () {
      String result = runner.run(
        ['non_dart', '--version'],
        'TEST INPUT',
      );
      expect(errors, isEmpty);
      expect(result, isEmpty); // Output is on stderr.
    });
    test('fails if tool not in tool map', () {
      String result = runner.run(
        ['hammer', r'--file=$INPUT'],
        'TEST INPUT',
      );
      expect(errors, isNotEmpty);
      expect(
          errors[0], contains('Unable to find definition for tool "hammer"'));
      expect(result, isEmpty);
    });
    test('fails if tool returns non-zero status', () {
      String result = runner.run(
        ['drill', r'--file=/a/missing/file'],
        'TEST INPUT',
      );
      expect(errors, isNotEmpty);
      expect(
          errors[0], contains('Tool "drill" returned non-zero exit code'));
      expect(result, isEmpty);
    });
    test("fails if tool in tool map doesn't exist", () {
      String result = runner.run(
        ['missing'],
        'TEST INPUT',
      );
      expect(errors, isNotEmpty);
      expect(errors[0],
          contains('Failed to run tool "missing" as "/a/missing/executable"'));
      expect(result, isEmpty);
    });
  });
}
