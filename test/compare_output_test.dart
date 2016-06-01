// Copyright (c) 2015, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library dartdoc.compare_output_test;

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:mirrors';

import 'package:path/path.dart' as p;
import 'package:test/test.dart';
import 'package:which/which.dart';

const List<String> _filesToIgnore = const <String>['.DS_Store'];

const _gitBinName = 'git';

String _gitCache;

final _nameStatusLineRegexp = new RegExp(r'(\w)\t(.+)');

Uri get _currentFileUri =>
    (reflect(main) as ClosureMirror).function.location.sourceUri;

String get _testPackageDocsPath =>
    p.fromUri(_currentFileUri.resolve('../testing/test_package_docs'));

String get _testPackagePath =>
    p.fromUri(_currentFileUri.resolve('../testing/test_package'));

void main() {
  group('compare outputs', () {
    Directory tempDir;

    var dartdocBin = p.fromUri(_currentFileUri.resolve('../bin/dartdoc.dart'));

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
        print("Tests are being run via `all.dart`, which means onPlatform "
            "argument is ignored. Skipping on Windows to avoid parsing git output");
        return;
      }

      var args = <String>[
        dartdocBin,
        '--no-include-source',
        '--output',
        tempDir.path
      ];

      var result =
          Process.runSync('dart', args, workingDirectory: _testPackagePath);

      if (result.exitCode != 0) {
        print(result.stdout);
        print(result.stderr);
        fail('dartdoc failed: ${result.exitCode}');
      }

      var gitPath = await _gitBinPath();

      args = <String>[
        'diff',
        '--no-index',
        '--name-status',
        '--no-color',
        _testPackageDocsPath,
        tempDir.path
      ];

      result = Process.runSync(gitPath, args);

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
            p.join(_testPackageDocsPath, k),
            p.join(tempDir.path, k)
          ];
          result = Process.runSync(gitPath, args);
          assert(result.exitCode != 0);
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

      var result =
          Process.runSync('dart', args, workingDirectory: _testPackagePath);

      if (result.exitCode != 0) {
        print(result.stdout);
        print(result.stderr);
        fail('dartdoc failed: ${result.exitCode}');
      }

      expect(result.stdout,
          contains('core/pipes/ts/slice_pipe/slice_pipe_example.ts'));
    });
  }, onPlatform: {'windows': new Skip('Avoiding parsing git output')});
}

Future<String> _gitBinPath() async {
  if (_gitCache == null) {
    _gitCache = await which(_gitBinName);
  }
  return _gitCache;
}

Map<String, String> _parseOutput(
    String input, String sourcePath, String tempPath) {
  var values = <String, String>{};
  for (var line in LineSplitter.split(input)) {
    Match match = _nameStatusLineRegexp.firstMatch(line);

    var type = match[1];
    var path = match[2];

    if (_filesToIgnore.any((i) => p.basename(path) == i)) {
      continue;
    }

    if (type == 'A') {
      expect(p.isWithin(tempPath, path), isTrue,
          reason: '`${path}` should be within ${tempPath}');
      path = p.relative(path, from: tempPath);
    } else {
      expect(p.isWithin(sourcePath, path), isTrue,
          reason: '`${path}` should be within ${sourcePath}');
      path = p.relative(path, from: sourcePath);
    }

    values[path] = type;
  }

  return values;
}
