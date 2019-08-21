// Copyright (c) 2018, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// Unit tests for lib/src/warnings.dart.
library dartdoc.warnings_test;

import 'dart:io';

import 'package:dartdoc/src/dartdoc_options.dart';
import 'package:dartdoc/src/warnings.dart';
import 'package:path/path.dart' as path;
import 'package:test/test.dart';

void main() {
  Directory tempDir, testPackageOne, testPackageTwo, testPackageThree;
  File pubspecYamlOne, pubspecYamlTwo, pubspecYamlThree, dartdocYamlThree;
  DartdocOptionSet optionSet;

  setUpAll(() {
    tempDir = Directory.systemTemp.createTempSync('warnings_test');
    testPackageOne = Directory(path.join(tempDir.path, 'test_package_one'))
      ..createSync();
    testPackageTwo = Directory(path.join(tempDir.path, 'test_package_two'))
      ..createSync();
    testPackageThree = Directory(path.join(tempDir.path, 'test_package_three'))
      ..createSync();
    pubspecYamlOne = File(path.join(testPackageOne.path, 'pubspec.yaml'));
    pubspecYamlOne.writeAsStringSync('name: test_package_one');
    pubspecYamlTwo = File(path.join(testPackageTwo.path, 'pubspec.yaml'));
    pubspecYamlTwo.writeAsStringSync('name: test_package_two');
    dartdocYamlThree =
        File(path.join(testPackageThree.path, 'dartdoc_options.yaml'));
    dartdocYamlThree.writeAsStringSync('''
dartdoc:
  warnings:
    - type-as-html
    - unresolved-export
  errors:
    - unresolved-doc-reference
  ignore:
    - ambiguous-reexport  
    ''');
    pubspecYamlThree = File(path.join(testPackageThree.path, 'pubspec.yaml'));
    pubspecYamlThree.writeAsStringSync('name: test_package_three');
  });

  setUp(() async {
    optionSet = await DartdocOptionSet.fromOptionGenerators(
        'dartdoc', [createDartdocOptions]);
  });

  test('Verify that options for enabling/disabling packages work', () {
    optionSet.parseArguments([
      '--allow-warnings-in-packages',
      'test_package_two,test_package_three',
      '--allow-errors-in-packages',
      'test_package_two,test_package_three',
      '--ignore-warnings-in-packages',
      'test_package_three',
      '--ignore-errors-in-packages',
      'test_package_three',
    ]);
    PackageWarningOptions optionsOne =
        optionSet['packageWarningOptions'].valueAt(testPackageOne);
    PackageWarningOptions optionsTwo =
        optionSet['packageWarningOptions'].valueAt(testPackageTwo);
    PackageWarningOptions optionsThree =
        optionSet['packageWarningOptions'].valueAt(testPackageThree);

    expect(optionsOne.warningModes.values,
        everyElement(equals(PackageWarningMode.ignore)));
    expect(optionsOne.warningModes.values,
        everyElement(equals(PackageWarningMode.ignore)));
    expect(optionsTwo.warningModes.values, contains(PackageWarningMode.warn));
    expect(optionsTwo.warningModes.values, contains(PackageWarningMode.error));
    expect(optionsThree.warningModes.values,
        everyElement(equals(PackageWarningMode.ignore)));
    expect(optionsThree.warningModes.values,
        everyElement(equals(PackageWarningMode.ignore)));
  });

  test('Verify that loading warning options from files works', () {
    optionSet.parseArguments([]);
    PackageWarningOptions optionsThree =
        optionSet['packageWarningOptions'].valueAt(testPackageThree);

    expect(optionsThree.warningModes[PackageWarning.typeAsHtml],
        equals(PackageWarningMode.warn));
    expect(optionsThree.warningModes[PackageWarning.unresolvedExport],
        equals(PackageWarningMode.warn));
    expect(optionsThree.warningModes[PackageWarning.unresolvedDocReference],
        equals(PackageWarningMode.error));
    expect(optionsThree.warningModes[PackageWarning.ambiguousReexport],
        equals(PackageWarningMode.ignore));
  });

  test('Verify that args override warning options from files', () {
    optionSet.parseArguments([
      '--warnings',
      'ambiguous-reexport',
      '--errors',
      'type-as-html',
      '--ignore',
      'unresolved-export',
    ]);
    PackageWarningOptions optionsThree =
        optionSet['packageWarningOptions'].valueAt(testPackageThree);
    expect(optionsThree.warningModes[PackageWarning.typeAsHtml],
        equals(PackageWarningMode.error));
    expect(optionsThree.warningModes[PackageWarning.unresolvedExport],
        equals(PackageWarningMode.ignore));
    // unresolved-doc-reference is not mentioned in command line, so it reverts to default
    expect(optionsThree.warningModes[PackageWarning.unresolvedDocReference],
        equals(PackageWarningMode.warn));
    expect(optionsThree.warningModes[PackageWarning.ambiguousReexport],
        equals(PackageWarningMode.warn));
  });

  test(
      'Verify that null values for warnings, ignore, and errors reset to defaults',
      () {
    optionSet.parseArguments([
      '--warnings',
      '',
      '--errors',
      '',
      '--ignore',
      '',
    ]);
    PackageWarningOptions optionsThree =
        optionSet['packageWarningOptions'].valueAt(testPackageThree);

    expect(optionsThree.warningModes[PackageWarning.typeAsHtml],
        equals(PackageWarningMode.ignore));
    expect(optionsThree.warningModes[PackageWarning.unresolvedExport],
        equals(PackageWarningMode.error));
    expect(optionsThree.warningModes[PackageWarning.unresolvedDocReference],
        equals(PackageWarningMode.warn));
    expect(optionsThree.warningModes[PackageWarning.ambiguousReexport],
        equals(PackageWarningMode.warn));
  });
}
