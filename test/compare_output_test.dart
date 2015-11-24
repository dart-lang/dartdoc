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

Uri get _currentFileUri =>
    (reflect(main) as ClosureMirror).function.location.sourceUri;

String get _testPackageDocsPath =>
    p.fromUri(_currentFileUri.resolve('../test_package_docs'));

String get _testPackagePath =>
    p.fromUri(_currentFileUri.resolve('../test_package'));

void main() {
  group('compare outputs', () {
    Directory tempDir;

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

      var dartdocBin =
          p.fromUri(_currentFileUri.resolve('../bin/dartdoc.dart'));

      // NOTE: excluding `fake` library because it contains exported code
      //       from the SDK that has changed between 1.12 and 1.13
      // This must match the content in `grind to update test_package_docs`

      var args = <String>[
        dartdocBin,
        '--output',
        tempDir.path,
        '--exclude',
        'fake'
      ];

      var result =
          Process.runSync('dart', args, workingDirectory: _testPackagePath);

      expect(result.exitCode, 0);

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
          // TODO(keertip): remove once 1.14 is stable; noSuchMethod documentation
          // has changed from 1.13 to 1.14.
          if (!result.stdout.contains('noSuchMethod')) {
            message.add("$v\t$k");
            message.add(result.stdout);
          }
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
  }, onPlatform: {'windows': new Skip('Avoiding parsing git output')});
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

const List<String> _filesToIgnore = const <String>['.DS_Store'];

final _nameStatusLineRegexp = new RegExp(r'(\w)\t(.+)');

const _gitBinName = 'git';

String _gitCache;

Future<String> _gitBinPath() async {
  if (_gitCache == null) {
    _gitCache = await which(_gitBinName);
  }
  return _gitCache;
}
