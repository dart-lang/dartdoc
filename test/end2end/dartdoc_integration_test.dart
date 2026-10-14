// Copyright (c) 2019, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

@Timeout.factor(3)
library;

import 'dart:async';
import 'dart:io';

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

  test('AOT compiled dartdoc generates docs and static assets', () async {
    var tempDir =
        Directory.systemTemp.createTempSync('dartdoc_aot_test.').absolute;
    addTearDown(() => tempDir.deleteSync(recursive: true));

    var buildDir = path.join(tempDir.path, 'build');
    var compileResult = await Process.run(
      Platform.resolvedExecutable,
      ['build', 'cli', '--target=$_dartdocPath', '--output=$buildDir'],
    );
    expect(
      compileResult.exitCode,
      0,
      reason: 'Failed to build dartdoc CLI: ${compileResult.stderr}',
    );
    expect(
      compileResult.stderr.toString(),
      isNot(contains('File modified during build')),
    );

    var aotExe = path.join(
      buildDir,
      'bundle',
      'bin',
      Platform.isWindows ? 'dartdoc.exe' : 'dartdoc',
    );
    var packagePath = await d.createPackage(
      'aot_test_pkg',
      libFiles: [
        d.file('lib.dart', '/// A documented class.\nclass Foo {}\n'),
      ],
    );
    var outDir = path.join(tempDir.path, 'doc');
    var process = await TestProcess.start(
      aotExe,
      ['--input=$packagePath', '--output=$outDir'],
      workingDirectory: tempDir.path,
    );
    await process.shouldExit(0);
    expect(File(path.join(outDir, 'index.html')).existsSync(), isTrue);
    expect(
      File(path.join(outDir, 'static-assets', 'docs.dart.js')).existsSync(),
      isTrue,
    );
  });
}
