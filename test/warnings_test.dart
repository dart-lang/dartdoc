// Copyright (c) 2018, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// Unit tests for lib/src/warnings.dart.
library dartdoc.warnings_test;

import 'package:analyzer/file_system/physical_file_system.dart';
import 'package:dartdoc/options.dart';
import 'package:dartdoc/src/dartdoc_options.dart';
import 'package:dartdoc/src/generator/generator.dart';
import 'package:dartdoc/src/io_utils.dart';
import 'package:dartdoc/src/model/package_builder.dart';
import 'package:dartdoc/src/package_config_provider.dart';
import 'package:dartdoc/src/package_meta.dart';
import 'package:dartdoc/src/warnings.dart';
import 'package:test/test.dart';

import 'src/test_descriptor_utils.dart' as d;

void main() async {
  var resourceProvider = PhysicalResourceProvider.INSTANCE;
  var optionSet = DartdocOptionRoot.fromOptionGenerators(
      'dartdoc', [createDartdocOptions], pubPackageMetaProvider);

  test('excluding package from "allowed warnings" list ignores all', () async {
    await d.createPackage('test_package');
    var testPackage = resourceProvider.getFolder(d.dir('test_package').io.path);

    optionSet.parseArguments([
      '--allow-warnings-in-packages',
      'some_other_package',
    ]);
    PackageWarningOptions options =
        optionSet['packageWarningOptions'].valueAt(testPackage);

    expect(options.warningModes.values,
        everyElement(equals(PackageWarningMode.ignore)));
  });

  test('warnings and errors are allowed at the commandline', () async {
    await d.createPackage('test_package');
    var testPackage = resourceProvider.getFolder(d.dir('test_package').io.path);

    optionSet.parseArguments([
      '--allow-warnings-in-packages',
      'test_package',
      '--allow-errors-in-packages',
      'test_package',
    ]);
    PackageWarningOptions options =
        optionSet['packageWarningOptions'].valueAt(testPackage);

    expect(options.warningModes.values, contains(PackageWarningMode.warn));
    expect(options.warningModes.values, contains(PackageWarningMode.error));
  });

  test('allowing and ignoring warnings from a package ignores all', () async {
    await d.createPackage('test_package', dartdocOptions: '''
dartdoc:
  warnings:
    - type-as-html
    - unresolved-export
  errors:
    - unresolved-doc-reference
  ignore:
    - ambiguous-reexport
''');
    var testPackage = resourceProvider.getFolder(d.dir('test_package').io.path);

    optionSet.parseArguments([
      '--allow-warnings-in-packages',
      'test_package',
      '--allow-errors-in-packages',
      'test_package',
      '--ignore-warnings-in-packages',
      'test_package',
      '--ignore-errors-in-packages',
      'test_package',
    ]);
    PackageWarningOptions options =
        optionSet['packageWarningOptions'].valueAt(testPackage);

    expect(options.warningModes.values,
        everyElement(equals(PackageWarningMode.ignore)));
  });

  test('loading warning options from files works', () async {
    await d.createPackage('test_package', dartdocOptions: '''
dartdoc:
  warnings:
    - type-as-html
    - unresolved-export
  errors:
    - unresolved-doc-reference
  ignore:
    - ambiguous-reexport
''');

    optionSet.parseArguments([]);
    PackageWarningOptions options = optionSet['packageWarningOptions']
        .valueAt(resourceProvider.getFolder(d.dir('test_package').io.path));

    expect(options.warningModes[PackageWarning.typeAsHtml],
        equals(PackageWarningMode.warn));
    expect(options.warningModes[PackageWarning.unresolvedExport],
        equals(PackageWarningMode.warn));
    expect(options.warningModes[PackageWarning.unresolvedDocReference],
        equals(PackageWarningMode.error));
    expect(options.warningModes[PackageWarning.ambiguousReexport],
        equals(PackageWarningMode.ignore));
  });

  test('args override warning options from files', () async {
    await d.createPackage('test_package', dartdocOptions: '''
dartdoc:
  warnings:
    - type-as-html
    - unresolved-export
  errors:
    - unresolved-doc-reference
  ignore:
    - ambiguous-reexport
''');
    optionSet.parseArguments([
      '--warnings',
      'ambiguous-reexport',
      '--errors',
      'type-as-html',
      '--ignore',
      'unresolved-export',
    ]);
    PackageWarningOptions options = optionSet['packageWarningOptions']
        .valueAt(resourceProvider.getFolder(d.dir('test_package').io.path));
    expect(options.warningModes[PackageWarning.typeAsHtml],
        equals(PackageWarningMode.error));
    expect(options.warningModes[PackageWarning.unresolvedExport],
        equals(PackageWarningMode.ignore));
    // `unresolved-doc-reference` is not mentioned in command line, so it
    // reverts to default.
    expect(options.warningModes[PackageWarning.unresolvedDocReference],
        equals(PackageWarningMode.warn));
    expect(options.warningModes[PackageWarning.ambiguousReexport],
        equals(PackageWarningMode.warn));
  });

  test('null values for warnings, ignore, and errors reset to defaults',
      () async {
    await d.createPackage('test_package', dartdocOptions: '''
dartdoc:
  warnings:
    - type-as-html
    - unresolved-export
  errors:
    - unresolved-doc-reference
  ignore:
    - ambiguous-reexport
''');
    optionSet.parseArguments([
      '--warnings',
      '',
      '--errors',
      '',
      '--ignore',
      '',
    ]);
    PackageWarningOptions options = optionSet['packageWarningOptions']
        .valueAt(resourceProvider.getFolder(d.dir('test_package').io.path));

    expect(options.warningModes[PackageWarning.typeAsHtml],
        equals(PackageWarningMode.ignore));
    expect(options.warningModes[PackageWarning.unresolvedExport],
        equals(PackageWarningMode.error));
    expect(options.warningModes[PackageWarning.unresolvedDocReference],
        equals(PackageWarningMode.warn));
    expect(options.warningModes[PackageWarning.ambiguousReexport],
        equals(PackageWarningMode.warn));
  });

  test('warns of a broken re-export chain', () async {
    await d.createPackage(
      'test_package',
      pubspec: '''
name: test_package
version: 0.0.1
environment:
    sdk: '>=2.12.0 <3.0.0'
dependencies:
  test_package_export_error:
    path: ../test_package_export_error
''',
      libFiles: [
        d.file('lib.dart', '''
export 'package:test_package_export_error/library2.dart';

/// This is an important class.
class BugFreeClass {}
'''),
      ],
    );
    await d.createPackage(
      'test_package_export_error',
      pubspec: '''
name: test_package_export_error
version: 0.0.1
environment:
    sdk: '>=2.12.0 <3.0.0'
''',
      libFiles: [
        d.file('library1.dart', '''
/// An export of a non-existent library.
export 'package:not_referenced_in_pubspec/library3.dart' show Lib3Class;
'''),
        d.file('library2.dart', '''
export 'package:test_package_export_error/library1.dart';

class Lib2Class {}
'''),
      ],
    );

    var tempDir = resourceProvider.createSystemTemp('dartdoc.test.');

    var optionSet = DartdocOptionRoot.fromOptionGenerators(
        'dartdoc',
        [
          createDartdocOptions,
          createGeneratorOptions,
        ],
        pubPackageMetaProvider);
    optionSet.parseArguments(
        ['--input', d.dir('test_package').io.path, '--output', tempDir.path]);
    var context = DartdocGeneratorOptionContext.fromDefaultContextLocation(
        optionSet, pubPackageMetaProvider.resourceProvider);

    var packageGraph = await PubPackageBuilder(
            context, pubPackageMetaProvider, PhysicalPackageConfigProvider(),
            skipUnreachableSdkLibraries: true)
        .buildPackageGraph();

    var unresolvedExportWarnings = packageGraph
        .packageWarningCounter.countedWarnings.values
        .map((e) => e[PackageWarning.unresolvedExport] ?? {})
        .expand((element) => element);

    expect(unresolvedExportWarnings, hasLength(1));
    expect(unresolvedExportWarnings.first,
        equals('"package:not_referenced_in_pubspec/library3.dart"'));
  });
}
