// Copyright (c) 2020, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/file_system/memory_file_system.dart';
import 'package:dartdoc/src/model/model.dart';
import 'package:test/test.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

import 'dartdoc_test_base.dart';
import 'src/test_descriptor_utils.dart' as d;
import 'src/utils.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(LibrariesTest);
  });

  // TODO(srawlins): Migrate to test_reflective_loader tests.

  test('A named library', () async {
    var packageMetaProvider = testPackageMetaProvider;

    var packagePath = await d.createPackage(
      'test_package',
      libFiles: [
        d.file('lib.dart', '''
/// A doc comment.
///
/// **Details**.
library name.and.dots;
'''),
      ],
      resourceProvider:
          packageMetaProvider.resourceProvider as MemoryResourceProvider,
    );
    final packageConfigProvider =
        getTestPackageConfigProvider(packageMetaProvider.defaultSdkDir.path);
    packageConfigProvider.addPackageToConfigFor(
        packagePath, 'library_test', Uri.file('$packagePath/'));

    final packageGraph = await bootBasicPackage(
      packagePath,
      packageMetaProvider,
      packageConfigProvider,
    );
    final library = packageGraph.libraries.named('name.and.dots');
    expect(library.name, 'name.and.dots');
    expect(library.fullyQualifiedName, 'name.and.dots');
    expect(library.packageName, 'test_package');
    expect(library.documentationComment, '''
/// A doc comment.
///
/// **Details**.''');
    expect(library.documentation, '''
A doc comment.

**Details**.''');
    expect(library.oneLineDoc, 'A doc comment.');
  });

  test('An unnamed library', () async {
    var packageMetaProvider = testPackageMetaProvider;

    var packagePath = await d.createPackage(
      'test_package',
      libFiles: [
        d.file('lib.dart', '''
/// A doc comment.
///
/// **Details**.
library;
'''),
      ],
      resourceProvider:
          packageMetaProvider.resourceProvider as MemoryResourceProvider,
    );
    final packageConfigProvider =
        getTestPackageConfigProvider(packageMetaProvider.defaultSdkDir.path);
    packageConfigProvider.addPackageToConfigFor(
        packagePath, 'library_test', Uri.file('$packagePath/'));

    final packageGraph = await bootBasicPackage(
      packagePath,
      packageMetaProvider,
      packageConfigProvider,
    );
    final library = packageGraph.libraries.named('lib');
    expect(library.name, 'lib');
    expect(library.fullyQualifiedName, 'lib');
    expect(library.packageName, 'test_package');
    expect(library.documentationComment, '''
/// A doc comment.
///
/// **Details**.''');
    expect(library.documentation, '''
A doc comment.

**Details**.''');
    expect(library.oneLineDoc, 'A doc comment.');
  });

  test('Libraries are sorted properly', () async {
    var packageMetaProvider = testPackageMetaProvider;
    var resourceProvider =
        packageMetaProvider.resourceProvider as MemoryResourceProvider;

    var packagePath = await d.createPackage(
      'test_package',
      libFiles: [
        d.dir('d', [d.file('a.dart', '')]),
        d.dir('e', [d.file('a.dart', '')]),
        // Unnamed library with library directive.
        d.file('b.dart', 'library;'),
        // Unnamed library without library directives.
        d.file('c.dart', ''),
        d.file('d.dart', 'library;'),
        d.file('e.dart', ''),
      ],
      resourceProvider: resourceProvider,
    );
    final packageConfigProvider =
        getTestPackageConfigProvider(packageMetaProvider.defaultSdkDir.path);
    packageConfigProvider.addPackageToConfigFor(
        packagePath, 'library_test', Uri.file('$packagePath/'));

    final packageGraph = await bootBasicPackage(
      packagePath,
      packageMetaProvider,
      packageConfigProvider,
    );
    final daName = resourceProvider.convertPath('d/a');
    final eaName = resourceProvider.convertPath('e/a');
    final daLibrary = packageGraph.libraries.displayNamed(daName);
    final eaLibrary = packageGraph.libraries.displayNamed(eaName);
    final bLibrary = packageGraph.libraries.displayNamed('b');
    final cLibrary = packageGraph.libraries.displayNamed('c');
    final dLibrary = packageGraph.libraries.displayNamed('d');
    final eLibrary = packageGraph.libraries.displayNamed('e');
    var libraries = [
      daLibrary,
      eaLibrary,
      bLibrary,
      cLibrary,
      dLibrary,
      eLibrary,
    ]..sort(byName);
    expect(
      libraries.map((l) => l.displayName),
      containsAllInOrder(['b', 'c', 'd', daName, 'e', eaName]),
    );
  });

  test('libraries in SDK package have appropriate data', () async {
    var packageMetaProvider = testPackageMetaProvider;
    var sdkFolder = packageMetaProvider.defaultSdkDir;
    var packageConfigProvider = getTestPackageConfigProvider(sdkFolder.path);

    var packageGraph = await bootBasicPackage(
        sdkFolder.path, packageMetaProvider, packageConfigProvider,
        additionalArguments: [
          '--input',
          packageMetaProvider.defaultSdkDir.path,
        ]);

    var localPackages = packageGraph.localPackages;
    expect(localPackages, hasLength(1));
    var sdkPackage = localPackages.single;
    expect(sdkPackage.name, equals('Dart'));

    var dartAsyncLib = sdkPackage.libraries.named('dart:async');
    expect(dartAsyncLib.name, 'dart:async');
    expect(dartAsyncLib.dirName, 'dart-async');
    expect(dartAsyncLib.href,
        '${htmlBasePlaceholder}dart-async/dart-async-library.html');
  }, onPlatform: {'windows': Skip('Test does not work on Windows (#2446)')});
}

@reflectiveTest
class LibrariesTest extends DartdocTestBase {
  @override
  String get libraryName => 'libraries';

  void test_publicLibrary() async {
    var library = await bootPackageWithLibrary(
      'var x = 1;',
      libraryFilePath: 'lib/library.dart',
    );

    expect(library.qualifiedName, 'libraries');
    expect(library.href, '${placeholder}libraries/libraries-library.html');
  }

  void test_exportedLibrary() async {
    var library = await bootPackageWithLibrary(
      'var x = 1;',
      libraryFilePath: 'lib/src/library.dart',
      extraFiles: [
        d.dir('lib', [
          d.file('public.dart', '''
export 'src/library.dart';
''')
        ]),
      ],
    );
    expect(library.qualifiedName, 'libraries');
    expect(library.href, '${placeholder}public/public-library.html');
  }
}
