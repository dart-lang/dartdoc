// Copyright (c) 2020, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/file_system/memory_file_system.dart';
import 'package:dartdoc/src/model/model.dart';
import 'package:test/test.dart';

import 'src/test_descriptor_utils.dart' as d;
import 'src/utils.dart';

// TODO(srawlins): Migrate to test_reflective_loader tests.

void main() {
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
