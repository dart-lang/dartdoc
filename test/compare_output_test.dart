// Copyright (c) 2015, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library dartdoc.compare_output_test;

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:mirrors';

import 'package:cli_util/cli_util.dart';
import 'package:dartdoc/dartdoc.dart';

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
    var testPackageDir = new Directory(_testPackagePath);

    var generators = initGenerators(null, null, null, null);

    // run dartdoc over the same
    var meta = new PackageMeta.fromDir(testPackageDir);
    var dartdoc = new DartDoc(
        testPackageDir, [], getSdkDir(), generators, tempDir, meta, []);

    await dartdoc.generateDocs();

    var gitPath = await _gitBinPath();

    var args = <String>[
      'diff',
      '--no-index',
      '--name-status',
      '--no-color',
      _testPackageDocsPath,
      tempDir.path
    ];

    var result = Process.runSync(gitPath, args);

    if (result.exitCode == 0) return;

    var things = _parseOutput(result.stdout, _testPackageDocsPath, tempDir.path);

    if (things.isEmpty) return;

    var message = <String>["There were differences:"];

    things.forEach((k, v) {
      // TODO: for the modified (M) case, add the diff
      message.add("$v\t$k");
    });

    fail(message.join('\n'));
  });
}

Map<String, String> _parseOutput(String input, String sourcePath, String tempPath) {
  var values = <String, String>{};
  for (var line in LineSplitter.split(input)) {
    Match match = _nameStatusLineRegexp.firstMatch(line);

    var type = match[1];
    var path = match[2];

    if (_filesToIgnore.any((i) => p.basename(path) == i)) {
      continue;
    }

    if (type == 'A') {
      expect(p.isWithin(tempPath, path), isTrue, reason: '"${path} should be within ${tempPath}');
      path = p.relative(path, from: tempPath);
    } else {
      expect(p.isWithin(sourcePath, path), isTrue, reason: '"${path} should be within ${sourcePath}');
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
