// Copyright (c) 2022, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/file_system/memory_file_system.dart';
import 'package:dartdoc/src/model/model.dart';
import 'package:dartdoc/src/package_config_provider.dart';
import 'package:dartdoc/src/package_meta.dart';
import 'package:test/test.dart';

import 'src/test_descriptor_utils.dart' as d;
import 'src/utils.dart';

void main() {
  const libraryName = 'element_types';

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

  Future<Library> bootPackageWithLibrary(String libraryContent) async {
    await d.dir('lib', [
      d.file('lib.dart', '''
library $libraryName;

$libraryContent
'''),
    ]).createInMemory(resourceProvider, packagePath);

    var packageGraph = await bootBasicPackage(
      packagePath,
      packageMetaProvider,
      packageConfigProvider,
    );
    return packageGraph.libraries.named(libraryName);
  }

  group('interface type', () {
    const libraryName = 'element_types';
    const placeholder = '%%__HTMLBASE_dartdoc_internal__%%';
    const linkPrefix = '$placeholder$libraryName';

    setUp(() async {
      packageMetaProvider = testPackageMetaProvider;
      resourceProvider =
          packageMetaProvider.resourceProvider as MemoryResourceProvider;
      await setUpPackage(libraryName);
    });

    test('simple class has rendered names', () async {
      var library = await bootPackageWithLibrary('''
class C {}
void f(C p) {}
''');
      var fFunction = library.functions.named('f');
      var parameterType = fFunction.allParameters.single.modelType;

      expect(parameterType.linkedName,
          equals('<a href="$linkPrefix/C-class.html">C</a>'));
      expect(parameterType.nameWithGenerics, equals('C'));
    });

    test('simple nullable class has rendered names', () async {
      var library = await bootPackageWithLibrary('''
class C {}
void f(C? p) {}
''');
      var fFunction = library.functions.named('f');
      var parameterType = fFunction.allParameters.single.modelType;

      expect(parameterType.linkedName,
          equals('<a href="$linkPrefix/C-class.html">C</a>?'));
      expect(parameterType.nameWithGenerics, equals('C?'));
    });

    test('generic class, instantiated with a simple type, has rendered names',
        () async {
      var library = await bootPackageWithLibrary('''
class C<T> {}
void f(C<int> p) {}
''');
      var fFunction = library.functions.named('f');
      var parameterType = fFunction.allParameters.single.modelType;

      expect(
        parameterType.linkedName,
        '<a href="$linkPrefix/C-class.html">C</a>'
        '<span class="signature">&lt;<wbr>'
        '<span class="type-parameter"><a href="https://api.dart.dev/stable/2.16.0/dart-core/int-class.html">int</a></span>&gt;</span>',
      );
      expect(
        parameterType.nameWithGenerics,
        equals('C&lt;<wbr><span class="type-parameter">int</span>&gt;'),
      );
    });

    test(
        'generic class, instantiated with a simple nullable type, has a linked '
        'name', () async {
      var library = await bootPackageWithLibrary('''
class C<T> {}
void f(C<int?> p) {}
''');
      var fFunction = library.functions.named('f');
      var parameterType = fFunction.allParameters.single.modelType;

      expect(
        parameterType.linkedName,
        '<a href="$linkPrefix/C-class.html">C</a>'
        '<span class="signature">&lt;<wbr>'
        '<span class="type-parameter">'
        '<a href="https://api.dart.dev/stable/2.16.0/dart-core/int-class.html">int</a>?</span>&gt;</span>',
      );
    });

    test('generic class, instantiated with a type variable, has a linked name',
        () async {
      var library = await bootPackageWithLibrary('''
class C<T> {}
void f<T>(C<T> p) {}
''');
      var fFunction = library.functions.named('f');
      var parameterType = fFunction.allParameters.single.modelType;

      expect(
        parameterType.linkedName,
        '<a href="$linkPrefix/C-class.html">C</a>'
        '<span class="signature">&lt;<wbr>'
        '<span class="type-parameter">T</span>&gt;</span>',
      );
    });

    test('"dynamic" type has rendered names', () async {
      var library = await bootPackageWithLibrary('''
void f(dynamic p) {}
''');
      var fFunction = library.functions.named('f');
      var parameterType = fFunction.allParameters.single.modelType;

      expect(parameterType.linkedName, equals('dynamic'));
      expect(parameterType.nameWithGenerics, equals('dynamic'));
    });
  });
}
