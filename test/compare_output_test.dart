// Copyright (c) 2015, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library dartdoc.compare_output_test;

import 'dart:convert';
import 'dart:io';
import 'dart:mirrors';

import 'package:path/path.dart' as path;
import 'package:test/test.dart';

const List<String> _filesToIgnore = const <String>['.DS_Store'];

const String gitBinName = 'git';

final _nameStatusLineRegexp = new RegExp(r'(\w)\t(.+)');

Uri get _currentFileUri =>
    (reflect(main) as ClosureMirror).function.location.sourceUri;

String get _testPackageDocsPath =>
    path.fromUri(_currentFileUri.resolve('../testing/test_package_docs'));

String get _testPackagePath =>
    path.fromUri(_currentFileUri.resolve('../testing/test_package'));

void main() {
  group('compare outputs', () {
    Directory tempDir;

    var dartdocBin =
        path.fromUri(_currentFileUri.resolve('../bin/dartdoc.dart'));

    setUp(() {
      tempDir = Directory.systemTemp.createTempSync('dartdoc.test.');
    });

    tearDown(() {
      if (tempDir != null) {
        tempDir.deleteSync(recursive: true);
      }
    });

    test("Validate html output of test_package", () async {
      if (Platform.isWindows) {
        print("Skipping on Windows");
        return;
      }
      // This must be synced with ../tool/grind.dart's updateTestPackageDocs().
      var args = <String>[
        dartdocBin,
        '--auto-include-dependencies',
        '--example-path-prefix',
        'examples',
        '--exclude',
        'dart.async,dart.collection,dart.convert,dart.core,dart.math,dart.typed_data,meta',
        '--no-include-source',
        '--pretty-index-json',
        '--output',
        tempDir.path
      ];

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
            path.join(_testPackageDocsPath, k),
            path.join(tempDir.path, k)
          ];
          result = Process.runSync(gitBinName, args);
          assert(result.exitCode != 0);
          message.add(result.stdout);
        }
      });

      if (message.length == 1) return;

      message.addAll([
        '',
        "If there have been changes to generation"
            " you may need to run `grind update-test-package-docs` again."
      ]);

      fail(message.join('\n'));
    });

    test('Check for sample code in examples', () {
      var args = <String>[
        dartdocBin,
        '--include',
        'ex',
        '--no-include-source',
        '--output',
        tempDir.path
      ];

      var result = Process.runSync(Platform.resolvedExecutable, args,
          workingDirectory: _testPackagePath);

      if (result.exitCode != 0) {
        print(result.exitCode);
        print(result.stdout);
        print(result.stderr);
        fail('dartdoc failed');
      }

      // Examples are reported as unfound because we (purposefully)
      // did not use --example-path-prefix above.
      final sep = '.'; // We don't care what the path separator character is
      final firstUnfoundExample = new RegExp('warning: lib${sep}example.dart: '
          '@example file not found.*test_package${sep}dog${sep}food.md');
      if (!result.stderr.contains(firstUnfoundExample)) {
        fail('Should warn about unfound @example files: \n'
            'stdout:\n${result.stdout}\nstderr:\n${result.stderr}');
      }
    });

    test('--footer-text includes text', () {
      String footerTextPath =
          path.join(Directory.systemTemp.path, 'footer.txt');
      new File(footerTextPath).writeAsStringSync(' footer text include ');

      var args = <String>[
        dartdocBin,
        '--footer-text=${footerTextPath}',
        '--include',
        'ex',
        '--output',
        tempDir.path
      ];

      var result = Process.runSync(Platform.resolvedExecutable, args,
          workingDirectory: _testPackagePath);

      if (result.exitCode != 0) {
        print(result.exitCode);
        print(result.stdout);
        print(result.stderr);
        fail('dartdoc failed');
      }

      File outFile = new File(path.join(tempDir.path, 'index.html'));
      expect(outFile.readAsStringSync(), contains('footer text include'));
    });

    test('Check dartdoc generation with crossdart', () {
      var args = <String>[
        dartdocBin,
        '--add-crossdart',
        '--output',
        tempDir.path
      ];

      var result = Process.runSync(Platform.resolvedExecutable, args,
          workingDirectory: _testPackagePath);

      if (result.exitCode != 0) {
        print(result.exitCode);
        print(result.stdout);
        print(result.stderr);
        fail('dartdoc failed');
      }
    });
  }, onPlatform: {'windows': new Skip('Avoiding parsing git output')});
}

Map<String, String> _parseOutput(
    String input, String sourcePath, String tempPath) {
  var values = <String, String>{};
  for (var line in LineSplitter.split(input)) {
    Match match = _nameStatusLineRegexp.firstMatch(line);

    var type = match[1];
    var p = match[2];

    if (_filesToIgnore.any((i) => path.basename(p) == i)) {
      continue;
    }

    if (type == 'A') {
      expect(path.isWithin(tempPath, p), isTrue,
          reason: '`$p` should be within $tempPath');
      p = path.relative(p, from: tempPath);
    } else {
      expect(path.isWithin(sourcePath, p), isTrue,
          reason: '`$p` should be within $sourcePath');
      p = path.relative(p, from: sourcePath);
    }

    values[p] = type;
  }

  return values;
}
