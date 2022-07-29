// Copyright (c) 2022, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/file_system/memory_file_system.dart';
import 'package:dartdoc/src/package_config_provider.dart';
import 'package:dartdoc/src/package_meta.dart';
import 'package:test/test.dart';

import 'src/test_descriptor_utils.dart' as d;
import 'src/utils.dart';

void main() {
  const libraryName = 'multiply_defined';

  late PackageMetaProvider packageMetaProvider;
  late MemoryResourceProvider resourceProvider;
  late FakePackageConfigProvider packageConfigProvider;
  late String packagePath;

  Future<void> setUpPackage(
    String name, {
    String? pubspec,
    String? analysisOptions,
  }) async {
    packagePath = await d.createPackage(
      name,
      pubspec: pubspec,
      analysisOptions: analysisOptions,
      resourceProvider: resourceProvider,
    );

    packageConfigProvider =
        getTestPackageConfigProvider(packageMetaProvider.defaultSdkDir.path);
    packageConfigProvider.addPackageToConfigFor(
        packagePath, name, Uri.file('$packagePath/'));
  }

  group('multiply-defined elements', () {
    const placeholder = '%%__HTMLBASE_dartdoc_internal__%%';

    setUp(() async {
      packageMetaProvider = testPackageMetaProvider;
      resourceProvider =
          packageMetaProvider.resourceProvider as MemoryResourceProvider;
      await setUpPackage(
        libraryName,
        pubspec: '''
name: multiply_defined
version: 0.0.1
environment:
  sdk: '>=2.17.0-0 <3.0.0'
''',
      );
    });

    test('referencing an erroneous, multiply-defined element does not crash',
        () async {
      await d.dir('lib', [
        d.file('import1.dart', 'class C {}'),
        d.file('import2.dart', 'class C {}'),
        d.file('lib.dart', '''
library $libraryName;

import 'import1.dart';
import 'import2.dart';

/// Reference to [C].
void foo(C c) {}
'''),
      ]).createInMemory(resourceProvider, packagePath);

      var packageGraph = await bootBasicPackage(
        packagePath,
        packageMetaProvider,
        packageConfigProvider,
      );
      var library = packageGraph.libraries.named(libraryName);
      var fooFunction = library.functions.named('foo');
      expect(
        fooFunction.documentationAsHtml,
        '<p>Reference to <a href="${placeholder}import1/C-class.html">C</a>.</p>',
      );
    });
  });
}
