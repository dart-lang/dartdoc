// Copyright (c) 2015, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library dartdoc.compare_output_test;

import 'dart:convert';
import 'dart:io';
import 'dart:mirrors';

import 'package:dartdoc/src/package_meta.dart';
import 'package:path/path.dart' as pathLib;
import 'package:test/test.dart';

import 'src/utils.dart';

const List<String> _filesToIgnore = const <String>['.DS_Store'];

const String gitBinName = 'git';

final _nameStatusLineRegexp = new RegExp(r'(\w)\t(.+)');

Uri get _currentFileUri =>
    (reflect(main) as ClosureMirror).function.location.sourceUri;

String get _testPackageDocsPath {
  if (Platform.version.split(' ').first.contains('-')) {
    return pathLib
        .fromUri(_currentFileUri.resolve('../testing/test_package_docs_dev'));
  } else {
    return pathLib
        .fromUri(_currentFileUri.resolve('../testing/test_package_docs'));
  }
}

String get _testPackagePath =>
    pathLib.fromUri(_currentFileUri.resolve('../testing/test_package'));

String get _testPackageFlutterPluginPath => pathLib
    .fromUri(_currentFileUri.resolve('../testing/test_package_flutter_plugin'));

void main() {
  group('compare outputs', () {
    Directory tempDir;
    CoverageSubprocessLauncher subprocessLauncher;

    var dartdocBin =
        pathLib.fromUri(_currentFileUri.resolve('../bin/dartdoc.dart'));

    setUpAll(() {
      subprocessLauncher =
          new CoverageSubprocessLauncher('compare_output_test-subprocesses');
    });

    tearDownAll(() async {
      await Future.wait(CoverageSubprocessLauncher.coverageResults);
    });

    setUp(() {
      tempDir = Directory.systemTemp.createTempSync('dartdoc.test.');
    });

    tearDown(() {
      if (tempDir != null) {
        tempDir.deleteSync(recursive: true);
      }
    });

    test('Validate missing FLUTTER_ROOT exception is clean', () async {
      StringBuffer output = new StringBuffer();
      var args = <String>[dartdocBin];
      Future run = subprocessLauncher.runStreamed(
          Platform.resolvedExecutable, args,
          environment: new Map.from(Platform.environment)
            ..remove('FLUTTER_ROOT'),
          includeParentEnvironment: false,
          workingDirectory: _testPackageFlutterPluginPath, perLine: (s) {
        output.writeln(s);
      });
      // Asynchronous exception, but we still need the output, too.
      expect(run, throwsA(new TypeMatcher<ProcessException>()));
      try {
        await run;
      } on ProcessException catch (_) {}

      expect(
          output.toString(),
          contains(new RegExp(
              'Top level package requires Flutter but FLUTTER_ROOT environment variable not set|test_package_flutter_plugin requires the Flutter SDK, version solving failed')));
      expect(output.toString(), isNot(contains('asynchronous gap')));
    });

    test("Validate --version works", () async {
      StringBuffer output = new StringBuffer();
      var args = <String>[dartdocBin, '--version'];
      await subprocessLauncher.runStreamed(Platform.resolvedExecutable, args,
          workingDirectory: _testPackagePath,
          perLine: (s) => output.writeln(s));
      PackageMeta dartdocMeta = new PackageMeta.fromFilename(dartdocBin);
      expect(output.toString(),
          endsWith('dartdoc version: ${dartdocMeta.version}\n'));
    });

    test("Validate html output of test_package", () async {
      if (Platform.isWindows) {
        print("Skipping on Windows");
        return;
      }
      // This must be synced with ../tool/grind.dart's updateTestPackageDocs().
      var args = <String>[
        '--enable-asserts',
        dartdocBin,
        '--no-allow-tools',
        '--auto-include-dependencies',
        '--example-path-prefix',
        'examples',
        '--exclude-packages',
        'Dart,args,matcher,meta,path,stack_trace,quiver',
        '--hide-sdk-text',
        '--no-include-source',
        '--output',
        tempDir.path,
        '--pretty-index-json',
      ];

      // Deliberately use runSync here to avoid counting this test as
      // "test coverage".
      var result = Process.runSync(Platform.resolvedExecutable, args,
          workingDirectory: _testPackagePath);

      if (result.exitCode != 0) {
        print(result.exitCode);
        print(result.stdout);
        print(result.stderr);
        fail('dartdoc failed');
      }

      args = <String>[
        'diff',
        '--no-index',
        '--name-status',
        '--no-color',
        _testPackageDocsPath,
        tempDir.path
      ];

      result = Process.runSync(gitBinName, args);

      if (result.exitCode == 0) return;

      var things =
          _parseOutput(result.stdout, _testPackageDocsPath, tempDir.path);

      if (things.isEmpty) return;

      var message = <String>["There were differences:"];

      things.forEach((k, v) {
        if (v == 'M') {
          // If the discovered diff is a modification of a file, then
          // run `git diff` and add the output to the fail message.
          args = <String>[
            'diff',
            '--no-index',
            '--no-color',
            pathLib.join(_testPackageDocsPath, k),
            pathLib.join(tempDir.path, k)
          ];
          result = Process.runSync(gitBinName, args);
          assert(result.exitCode != 0);
          message.add(result.stdout);
        }
      });

      if (message.length == 1) return;

      message.addAll([
        '',
        'If there have been changes to generation you may need to run `grind update-test-package-docs` again.'
      ]);

      fail(message.join('\n'));
    });

    test('Check for sample code in examples', () async {
      StringBuffer output = new StringBuffer();
      var args = <String>[
        dartdocBin,
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
      final firstUnfoundExample = new RegExp('warning: lib${sep}example.dart: '
          '@example file not found.*test_package${sep}dog${sep}food.md');
      if (!output.toString().contains(firstUnfoundExample)) {
        fail('Should warn about unfound @example files');
      }
    });

    test('Validate JSON output', () async {
      var args = <String>[
        dartdocBin,
        '--include',
        'ex',
        '--no-include-source',
        '--output',
        tempDir.path,
        '--json'
      ];

      Iterable<Map> jsonValues = await subprocessLauncher.runStreamed(
          Platform.resolvedExecutable, args,
          workingDirectory: _testPackagePath);

      expect(jsonValues, isNotEmpty,
          reason: 'All STDOUT lines should be JSON-encoded maps.');
    }, timeout: new Timeout.factor(2));

    test('--footer-text includes text', () async {
      String footerTextPath =
          pathLib.join(Directory.systemTemp.path, 'footer.txt');
      new File(footerTextPath).writeAsStringSync(' footer text include ');

      var args = <String>[
        dartdocBin,
        '--footer-text=${footerTextPath}',
        '--include',
        'ex',
        '--output',
        tempDir.path
      ];

      await subprocessLauncher.runStreamed(Platform.resolvedExecutable, args,
          workingDirectory: _testPackagePath);

      File outFile = new File(pathLib.join(tempDir.path, 'index.html'));
      expect(outFile.readAsStringSync(), contains('footer text include'));
    });
  },
      onPlatform: {'windows': new Skip('Avoiding parsing git output')},
      timeout: new Timeout.factor(3));
}

Map<String, String> _parseOutput(
    String input, String sourcePath, String tempPath) {
  var values = <String, String>{};
  for (var line in LineSplitter.split(input)) {
    Match match = _nameStatusLineRegexp.firstMatch(line);

    var type = match[1];
    var p = match[2];

    if (_filesToIgnore.any((i) => pathLib.basename(p) == i)) {
      continue;
    }

    if (type == 'A') {
      expect(pathLib.isWithin(tempPath, p), isTrue,
          reason: '`$p` should be within $tempPath');
      p = pathLib.relative(p, from: tempPath);
    } else {
      expect(pathLib.isWithin(sourcePath, p), isTrue,
          reason: '`$p` should be within $sourcePath');
      p = pathLib.relative(p, from: sourcePath);
    }

    values[p] = type;
  }

  return values;
}
