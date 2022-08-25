// Copyright (c) 2019, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library dartdoc.dartdoc_integration_test;

import 'dart:async';
import 'dart:io';
import 'dart:mirrors';

import 'package:dartdoc/src/package_meta.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';
import 'package:test_process/test_process.dart';

import '../src/test_descriptor_utils.dart' as d;
import '../src/utils.dart';

Uri get _currentFileUri =>
    (reflect(main) as ClosureMirror).function.location!.sourceUri;
String get _testPackageFlutterPluginPath => p.fromUri(_currentFileUri
    .resolve('../../testing/flutter_packages/test_package_flutter_plugin'));

var _dartdocPath = p.canonicalize(p.join('bin', 'dartdoc.dart'));

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
  }, timeout: Timeout.factor(2));

  group('invoking dartdoc on a basic package', () {
    late String packagePath;

    setUp(() async {
      packagePath = await d.createPackage('test_package', libFiles: [
        d.file('lib.dart', '/// [dead] reference\nclass C {}'),
      ]);
    });

    test('with --no-generate-docs is quiet and does not generate docs',
        () async {
      var process = await runDartdoc(
        ['--no-generate-docs'],
        workingDirectory: packagePath,
      );
      await expectLater(
          process.stderr, emitsThrough('Found 1 warning and 0 errors.'));
      await process.shouldExit(0);
      var docs = Directory(p.join(packagePath, 'doc', 'api'));
      expect(docs.existsSync(), isFalse);
    }, timeout: Timeout.factor(2));

    test('with --quiet is quiet and does generate docs', () async {
      var process = await runDartdoc(
        ['--quiet'],
        workingDirectory: packagePath,
      );
      await expectLater(process.stderr, emitsThrough(matches('^  warning:')));
      await expectLater(
          process.stderr, emitsThrough('Found 1 warning and 0 errors.'));
      await process.shouldExit(0);
      var indexHtml = Directory(p.join(packagePath, 'doc', 'api'));
      expect(indexHtml.listSync(), isNotEmpty);
    }, timeout: Timeout.factor(2));

    test('with invalid options return non-zero and print a fatal-error',
        () async {
      var process = await runDartdoc(
        ['--nonexisting'],
        workingDirectory: packagePath,
      );
      await expectLater(
          process.stderr,
          emitsThrough(
              ' fatal error: Could not find an option named "nonexisting".'));
      await process.shouldExit(64);
    });

    test('missing a required file path prints a fatal error', () async {
      var process = await runDartdoc(
        ['--input', 'non-existant'],
        workingDirectory: packagePath,
      );
      var fullPath = p.canonicalize(p.join(packagePath, 'non-existant'));
      await expectLater(
        process.stderr,
        emitsThrough(
            ' fatal error: Argument --input, set to non-existant, resolves to '
            'missing path: "$fullPath"'),
      );
      await process.shouldExit(64);
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

    test('Validate JSON output', () async {
      var process = await runDartdoc(
        [
          //dartdocPath,
          '--no-include-source',
          '--json',
        ],
        workingDirectory: packagePath,
      );
      await expectLater(
          process.stdout,
          emitsThrough(
              '{"level":"WARNING","message":"Found 1 warning and 0 errors."}'));
      await process.shouldExit(0);
    }, timeout: Timeout.factor(2));
  }, timeout: Timeout.factor(8));

  test('with tool errors cause non-zero exit when warnings are off', () async {
    // TODO(srawlins): Remove test_package_tool_error and generate afresh.
    var packagePath = await d.createPackage('test_package');
    var tempDir = p.join(
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
  }, timeout: Timeout.factor(2));

  test('with missing FLUTTER_ROOT exception reports an error', () async {
    // TODO(srawlins): Remove test_package_flutter_plugin and generate afresh.
    var dartTool =
        Directory(p.join(_testPackageFlutterPluginPath, '.dart_tool'));
    if (dartTool.existsSync()) dartTool.deleteSync(recursive: true);
    var process = await runDartdoc(
      [],
      workingDirectory: _testPackageFlutterPluginPath,
      environment: {...Platform.environment}..remove('FLUTTER_ROOT'),
      includeParentEnvironment: false,
    );
    await expectLater(
        process.stderr,
        emitsThrough(matches(
            'Top level package requires Flutter but FLUTTER_ROOT environment variable not set|'
            'test_package_flutter_plugin requires the Flutter SDK, version solving failed')));
    await process.shouldExit(1);
  });
}
