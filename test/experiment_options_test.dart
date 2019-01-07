// Copyright (c) 2018, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// Unit tests for lib/src/experiment_options.dart.
library dartdoc.experiment_options_test;

import 'dart:io';

import 'package:dartdoc/src/dartdoc_options.dart';
import 'package:dartdoc/src/experiment_options.dart';
import 'package:path/path.dart' as pathLib;
import 'package:test/test.dart';

class DartdocExperimentOptionContextTester extends DartdocOptionContext {
  DartdocExperimentOptionContextTester(
      DartdocOptionSet optionSet, FileSystemEntity entity)
      : super(optionSet, entity);
}

void main() {
  DartdocOptionSet experimentOptions;
  Directory tempDir;
  File optionsFile;

  setUp(() async {
    experimentOptions = await DartdocOptionSet.fromOptionGenerators(
        'dartdoc', [createExperimentOptions]);
  });

  setUpAll(() {
    tempDir = Directory.systemTemp.createTempSync('experiment_options_test');
    optionsFile = new File(pathLib.join(tempDir.path, 'dartdoc_options.yaml'))
      ..createSync();
    optionsFile.writeAsStringSync('''
dartdoc:
  enable-experiment:
    - constant-update-2018
    - fake-experiment
    - no-fake-experiment-on
''');
  });

  tearDownAll(() {
    tempDir.deleteSync(recursive: true);
  });

  group('Experimental options test', () {
    test('Defaults work for all options', () {
      experimentOptions.parseArguments([]);
      DartdocExperimentOptionContextTester tester =
          new DartdocExperimentOptionContextTester(
              experimentOptions, Directory.current);
      expect(tester.experimentStatus.constant_update_2018, isFalse);
      expect(tester.experimentStatus.set_literals, isFalse);
    });

    test('Overriding defaults works via args', () {
      experimentOptions.parseArguments(
          ['--enable-experiment', 'constant-update-2018,set-literals']);
      DartdocExperimentOptionContextTester tester =
          new DartdocExperimentOptionContextTester(
              experimentOptions, Directory.current);
      expect(tester.experimentStatus.constant_update_2018, isTrue);
      expect(tester.experimentStatus.set_literals, isTrue);
    });
  });
}
