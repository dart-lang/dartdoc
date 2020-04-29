// Copyright (c) 2019, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library dartdoc.dartdoc_integration_test;

import 'dart:async';
import 'dart:io';
import 'dart:mirrors';

import 'package:dartdoc/dartdoc.dart';
import 'package:path/path.dart' as path;
import 'package:test/test.dart';

import 'src/utils.dart';

Uri get _currentFileUri =>
    (reflect(main) as ClosureMirror).function.location.sourceUri;
String get _testPackagePath =>
    path.fromUri(_currentFileUri.resolve('../testing/test_package'));
String get _testPackageFlutterPluginPath => path
    .fromUri(_currentFileUri.resolve('../testing/test_package_flutter_plugin'));

void main() {
  group('Invoking command-line dartdoc', () {
    var dartdocPath = path.canonicalize(path.join('bin', 'dartdoc.dart'));
    CoverageSubprocessLauncher subprocessLauncher;
    Directory tempDir;

    setUpAll(() async {
      tempDir =
          Directory.systemTemp.createTempSync('dartdoc_integration_test.');
      subprocessLauncher =
          CoverageSubprocessLauncher('dartdoc_integration_test-subprocesses');
    });

    tearDown(() async {
      tempDir.listSync().forEach((FileSystemEntity f) {
        f.deleteSync(recursive: true);
      });
    });

    tearDownAll(() async {
      await Future.wait(CoverageSubprocessLauncher.coverageResults);
    });

    test('running --no-generate-docs is quiet and does not generate docs',
        () async {
      var outputDir =
          await Directory.systemTemp.createTemp('dartdoc.testEmpty.');
      var outputLines = <String>[];
      await subprocessLauncher.runStreamed(Platform.resolvedExecutable,
          [dartdocPath, '--output', outputDir.path, '--no-generate-docs'],
          perLine: outputLines.add, workingDirectory: _testPackagePath);
      expect(outputLines, isNot(contains(matches('^parsing'))));
      expect(outputLines, contains(matches('^  warning:')));
      expect(outputLines.last, matches(r'^found \d+ warnings and \d+ errors'));
      expect(outputDir.listSync(), isEmpty);
    }, timeout: Timeout.factor(2));

    test('running --quiet is quiet and does generate docs', () async {
      var outputDir =
          await Directory.systemTemp.createTemp('dartdoc.testEmpty.');
      var outputLines = <String>[];
      await subprocessLauncher.runStreamed(Platform.resolvedExecutable,
          [dartdocPath, '--output', outputDir.path, '--quiet'],
          perLine: outputLines.add, workingDirectory: _testPackagePath);
      expect(outputLines, isNot(contains(matches('^parsing'))));
      expect(outputLines, contains(matches('^  warning:')));
      expect(outputLines.last, matches(r'^found \d+ warnings and \d+ errors'));
      expect(outputDir.listSync(), isNotEmpty);
    }, timeout: Timeout.factor(2));

    test('invalid parameters return non-zero and print a fatal-error',
        () async {
      var outputLines = <String>[];
      await expectLater(
          () => subprocessLauncher.runStreamed(
              Platform.resolvedExecutable,
              [
                dartdocPath,
                '--nonexisting',
              ],
              perLine: outputLines.add),
          throwsA(const TypeMatcher<ProcessException>()));
      expect(
          outputLines.firstWhere((l) => l.startsWith(' fatal')),
          equals(
              ' fatal error: Could not find an option named "nonexisting".'));
    });

    test('missing a required file path prints a fatal-error', () async {
      var outputLines = [];
      var impossiblePath = path.join(dartdocPath, 'impossible');
      await expectLater(
          () => subprocessLauncher.runStreamed(
              Platform.resolvedExecutable,
              [
                dartdocPath,
                '--input',
                impossiblePath,
              ],
              perLine: outputLines.add),
          throwsA(const TypeMatcher<ProcessException>()));
      expect(
          outputLines.firstWhere((l) => l.startsWith(' fatal')),
          startsWith(
              ' fatal error: Argument --input, set to ${impossiblePath}, resolves to missing path: '));
    });

    test('errors cause non-zero exit when warnings are off', () async {
      expect(
          () => subprocessLauncher.runStreamed(Platform.resolvedExecutable, [
                dartdocPath,
                '--allow-tools',
                '--input=${testPackageToolError.path}',
                '--output=${path.join(tempDir.absolute.path, 'test_package_tool_error')}'
              ]),
          throwsA(const TypeMatcher<ProcessException>()));
    });

    test('help prints command line args', () async {
      var outputLines = <String>[];
      await subprocessLauncher.runStreamed(
          Platform.resolvedExecutable, [dartdocPath, '--help'],
          perLine: outputLines.add);
      expect(outputLines,
          contains('Generate HTML documentation for Dart libraries.'));
      expect(
          outputLines.join('\n'),
          contains(
              RegExp('^-h, --help[ ]+Show command help.', multiLine: true)));
    });

    test('Validate missing FLUTTER_ROOT exception is clean', () async {
      var output = StringBuffer();
      var args = <String>[dartdocPath];
      var dart_tool =
          Directory(path.join(_testPackageFlutterPluginPath, '.dart_tool'));
      if (dart_tool.existsSync()) dart_tool.deleteSync(recursive: true);
      Future run = subprocessLauncher.runStreamed(
          Platform.resolvedExecutable, args,
          environment: Map.from(Platform.environment)..remove('FLUTTER_ROOT'),
          includeParentEnvironment: false,
          workingDirectory: _testPackageFlutterPluginPath, perLine: (s) {
        output.writeln(s);
      });
      // Asynchronous exception, but we still need the output, too.
      expect(run, throwsA(TypeMatcher<ProcessException>()));
      try {
        await run;
      } on ProcessException catch (_) {}

      expect(
          output.toString(),
          contains(RegExp(
              'Top level package requires Flutter but FLUTTER_ROOT environment variable not set|test_package_flutter_plugin requires the Flutter SDK, version solving failed')));
      expect(output.toString(), isNot(contains('asynchronous gap')));
    });

    test('Validate --version works', () async {
      var output = StringBuffer();
      var args = <String>[dartdocPath, '--version'];
      await subprocessLauncher.runStreamed(Platform.resolvedExecutable, args,
          workingDirectory: _testPackagePath,
          perLine: (s) => output.writeln(s));
      var dartdocMeta = PackageMeta.fromFilename(dartdocPath);
      expect(output.toString(),
          endsWith('dartdoc version: ${dartdocMeta.version}\n'));
    });

    test('Check for sample code in examples', () async {
      var output = StringBuffer();
      var args = <String>[
        dartdocPath,
        '--include',
        'ex',
        '--no-include-source',
        '--output',
        tempDir.path
      ];

      await subprocessLauncher.runStreamed(Platform.resolvedExecutable, args,
          workingDirectory: _testPackagePath,
          perLine: (s) => output.writeln(s));

      // Examples are reported as unfound because we (purposefully)
      // did not use --example-path-prefix above.
      final sep = '.'; // We don't care what the path separator character is
      final firstUnfoundExample = RegExp('warning: lib${sep}example.dart: '
          '@example file not found.*test_package${sep}dog${sep}food.md');
      if (!output.toString().contains(firstUnfoundExample)) {
        fail('Should warn about unfound @example files');
      }
    });

    test('Validate JSON output', () async {
      var args = <String>[
        dartdocPath,
        '--include',
        'ex',
        '--no-include-source',
        '--output',
        tempDir.path,
        '--json'
      ];

      var jsonValues = await subprocessLauncher.runStreamed(
          Platform.resolvedExecutable, args,
          workingDirectory: _testPackagePath);

      expect(jsonValues, isNotEmpty,
          reason: 'All STDOUT lines should be JSON-encoded maps.');
    }, timeout: Timeout.factor(2));

    test('--footer-text includes text', () async {
      var footerTextPath = path.join(Directory.systemTemp.path, 'footer.txt');
      File(footerTextPath).writeAsStringSync(' footer text include ');

      var args = <String>[
        dartdocPath,
        '--footer-text=${footerTextPath}',
        '--include',
        'ex',
        '--output',
        tempDir.path
      ];

      await subprocessLauncher.runStreamed(Platform.resolvedExecutable, args,
          workingDirectory: _testPackagePath);

      var outFile = File(path.join(tempDir.path, 'index.html'));
      expect(outFile.readAsStringSync(), contains('footer text include'));
    }, timeout: Timeout.factor(2));

    test('--footer-text excludes version', () async {
      var _testPackagePath = path
          .fromUri(_currentFileUri.resolve('../testing/test_package_options'));

      var args = <String>[dartdocPath, '--output', tempDir.path];

      await subprocessLauncher.runStreamed(Platform.resolvedExecutable, args,
          workingDirectory: _testPackagePath);

      var outFile = File(path.join(tempDir.path, 'index.html'));
      var footerRegex =
          RegExp('<footer>(.*\s*?\n?)+?</footer>', multiLine: true);
      // get footer, check for version number
      var m = footerRegex.firstMatch(outFile.readAsStringSync());
      var version = RegExp(r'(\d+\.)?(\d+\.)?(\*|\d+)');
      expect(version.hasMatch(m.group(0)), false);
    });
  }, timeout: Timeout.factor(8));
}
