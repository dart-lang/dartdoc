// Copyright (c) 2026, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.
import 'package:analyzer/dart/analysis/features.dart';
import 'package:test/test.dart';

import 'dartdoc_test_base.dart';
import 'src/test_descriptor_utils.dart' as d;

void main() {
  group('Experiment flags', () {
    final testBase = _ExperimentsTest();

    setUpAll(() async {
      await testBase.setUp();
    });

    test('are disabled by default', () async {
      var library = await testBase.bootPackageWithLibrary(
        'void f() {}',
      );
      // Verify that 'macros' and 'augmentations' are actually disabled by
      // default so our other tests are meaningful.
      expect(library.element.featureSet.isEnabled(Feature.macros), isFalse);
      expect(
          library.element.featureSet.isEnabled(Feature.augmentations), isFalse);
    });

    test('are picked up from command-line', () async {
      var library = await testBase.bootPackageWithLibrary(
        'void f() {}',
        additionalArguments: ['--enable-experiment=macros'],
      );

      expect(library.element.featureSet.isEnabled(Feature.macros), isTrue);
    });

    test('are picked up from dartdoc_options.yaml', () async {
      var library = await testBase.bootPackageWithLibrary(
        'void f() {}',
        extraFiles: [
          d.file('dartdoc_options.yaml', '''
dartdoc:
  enable-experiment:
    - macros
'''),
        ],
      );

      expect(library.element.featureSet.isEnabled(Feature.macros), isTrue);
    });

    test('are picked up from analysis_options.yaml', () async {
      var library = await testBase.bootPackageWithLibrary(
        'void f() {}',
        extraFiles: [
          d.file('analysis_options.yaml', '''
analyzer:
  enable-experiment:
    - macros
'''),
        ],
      );

      expect(library.element.featureSet.isEnabled(Feature.macros), isTrue);
    });

    test('command-line overrides dartdoc_options.yaml', () async {
      var library = await testBase.bootPackageWithLibrary(
        'void f() {}',
        additionalArguments: ['--enable-experiment=macros'],
        extraFiles: [
          d.file('dartdoc_options.yaml', '''
dartdoc:
  enable-experiment:
    - augmentations
'''),
        ],
      );

      // CLI should win.
      expect(library.element.featureSet.isEnabled(Feature.macros), isTrue);
      expect(
          library.element.featureSet.isEnabled(Feature.augmentations), isFalse);
    });

    test('dartdoc_options.yaml overrides analysis_options.yaml', () async {
      var library = await testBase.bootPackageWithLibrary(
        'void f() {}',
        extraFiles: [
          d.file('dartdoc_options.yaml', '''
dartdoc:
  enable-experiment:
    - macros
'''),
          d.file('analysis_options.yaml', '''
analyzer:
  enable-experiment:
    - augmentations
'''),
        ],
      );

      // dartdoc_options.yaml should win over analysis_options.yaml.
      expect(library.element.featureSet.isEnabled(Feature.macros), isTrue);
      expect(
          library.element.featureSet.isEnabled(Feature.augmentations), isFalse);
    });
  });
}

class _ExperimentsTest extends DartdocTestBase {
  @override
  String get libraryName => 'experiments_test';

  @override
  List<String> get experiments => const [];
}
