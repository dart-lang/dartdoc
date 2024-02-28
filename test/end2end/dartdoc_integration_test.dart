// Copyright (c) 2019, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

@Timeout.factor(3)
library;

import 'dart:async';
import 'dart:io';

import 'package:dartdoc/src/package_meta.dart';
import 'package:path/path.dart' as path;
import 'package:test/test.dart';
import 'package:test_process/test_process.dart';

import '../src/test_descriptor_utils.dart' as d;
import '../src/utils.dart';

var _dartdocPath = path.canonicalize(path.join('bin', 'dartdoc.dart'));

/// Runs dartdoc via [TestProcess.start].
Future<TestProcess> runDartdoc(
  List<String> options, {
  required String workingDirectory,
  Map<String, String>? environment,
  bool includeParentEnvironment = true,
}) =>
    TestProcess.start(
      Platform.resolvedExecutable,
      [_dartdocPath, ...options],
      workingDirectory: workingDirectory,
      environment: environment,
      includeParentEnvironment: includeParentEnvironment,
    );

void main() {
  test('invoking dartdoc on an empty package does not crash', () async {
    var packagePath = await d.createPackage('empty');
    var process = await runDartdoc([], workingDirectory: packagePath);
    await expectLater(
      process.stderr,
      emitsThrough(
          contains('package:test_package has no documentable libraries')),
    );
    await process.shouldExit(0);
  });

  group('invoking dartdoc on a basic package', () {
    late String packagePath;

    setUp(() async {
      packagePath = await d.createPackage('test_package', libFiles: [
        d.file('lib.dart', '/// [dead] reference\nclass C {}'),
      ]);
    });

    test('with --help prints command line args', () async {
      var process = await runDartdoc(
        ['--help'],
        workingDirectory: packagePath,
      );
      await expectLater(process.stdout,
          emitsThrough('Generate HTML documentation for Dart libraries.'));
      await expectLater(process.stdout,
          emitsThrough(matches('^-h, --help[ ]+Show command help.')));
      await process.shouldExit(0);
    });

    test('Validate --version works', () async {
      var process = await runDartdoc(
        ['--version'],
        workingDirectory: packagePath,
      );
      var dartdocMeta = pubPackageMetaProvider.fromFilename(_dartdocPath)!;
      await expectLater(process.stdout,
          emitsThrough('dartdoc version: ${dartdocMeta.version}'));
      await process.shouldExit(0);
    });
  });

  test('with tool errors cause non-zero exit when warnings are off', () async {
    // TODO(srawlins): Remove test_package_tool_error and generate afresh.
    var packagePath = await d.createPackage('test_package');
    var tempDir = path.join(
        Directory.systemTemp
            .createTempSync('dartdoc_integration_test.')
            .absolute
            .path,
        'test_package_tool_error');
    var process = await runDartdoc(
      [
        '--allow-tools',
        '--input=${testPackageToolError.path}',
        '--output=$tempDir',
      ],
      workingDirectory: packagePath,
    );
    await process.shouldExit(1);
  });
}
