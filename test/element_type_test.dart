// Copyright (c) 2022, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/file_system/memory_file_system.dart';
import 'package:dartdoc/src/model/model.dart';
import 'package:dartdoc/src/package_config_provider.dart';
import 'package:test/test.dart';

import 'src/test_descriptor_utils.dart' as d;
import 'src/utils.dart';

// TODO(srawlins): Migrate to test_reflective_loader tests.

void main() async {
  const libraryName = 'element_types';
  const placeholder = '%%__HTMLBASE_dartdoc_internal__%%';
  const linkPrefix = '$placeholder$libraryName';

  const intLink =
      '<a href="https://api.dart.dev/stable/2.16.0/dart-core/int-class.html">int</a>';
  const stringLink =
      '<a href="https://api.dart.dev/stable/2.16.0/dart-core/String-class.html">String</a>';

  final packageMetaProvider = testPackageMetaProvider;
  final resourceProvider =
      packageMetaProvider.resourceProvider as MemoryResourceProvider;
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

    final packageGraph = await bootBasicPackage(
      packagePath,
      packageMetaProvider,
      packageConfigProvider,
    );
    return packageGraph.libraries.named(libraryName);
  }

  await setUpPackage(libraryName);

  group('interface type', () {
    test('simple class has rendered names', () async {
      final library = await bootPackageWithLibrary('''
class C {}
void f(C p) {}
''');
      final fFunction = library.functions.named('f');
      final parameterType = fFunction.parameters.single.modelType;

      expect(parameterType.linkedName,
          equals('<a href="$linkPrefix/C-class.html">C</a>'));
      expect(parameterType.nameWithGenerics, equals('C'));
    });

    test('simple nullable class has rendered names', () async {
      final library = await bootPackageWithLibrary('''
class C {}
void f(C? p) {}
''');
      final fFunction = library.functions.named('f');
      final parameterType = fFunction.parameters.single.modelType;

      expect(parameterType.linkedName,
          equals('<a href="$linkPrefix/C-class.html">C</a>?'));
      expect(parameterType.nameWithGenerics, equals('C?'));
    });

    test('generic class, instantiated with a simple type, has rendered names',
        () async {
      final library = await bootPackageWithLibrary('''
class C<T> {}
void f(C<int> p) {}
''');
      final fFunction = library.functions.named('f');
      final parameterType = fFunction.parameters.single.modelType;

      expect(
        parameterType.linkedName,
        '<a href="$linkPrefix/C-class.html">C</a>'
        '<span class="signature">&lt;<wbr>'
        '<span class="type-parameter">$intLink</span>&gt;</span>',
      );
      expect(
        parameterType.nameWithGenerics,
        equals('C&lt;<wbr><span class="type-parameter">int</span>&gt;'),
      );
    });

    test(
        'generic class, instantiated with a simple nullable type, has a linked '
        'name', () async {
      final library = await bootPackageWithLibrary('''
class C<T> {}
void f(C<int?> p) {}
''');
      final fFunction = library.functions.named('f');
      final parameterType = fFunction.parameters.single.modelType;

      expect(
        parameterType.linkedName,
        '<a href="$linkPrefix/C-class.html">C</a>'
        '<span class="signature">&lt;<wbr>'
        '<span class="type-parameter">$intLink?</span>&gt;</span>',
      );
    });

    test('generic class, instantiated with a type variable, has a linked name',
        () async {
      final library = await bootPackageWithLibrary('''
class C<T> {}
void f<T>(C<T> p) {}
''');
      final fFunction = library.functions.named('f');
      final parameterType = fFunction.parameters.single.modelType;

      expect(
        parameterType.linkedName,
        '<a href="$linkPrefix/C-class.html">C</a>'
        '<span class="signature">&lt;<wbr>'
        '<span class="type-parameter">T</span>&gt;</span>',
      );
    });
  });

  group('function type', () {
    test('simple function type has rendered names', () async {
      final library = await bootPackageWithLibrary('''
void f(int Function(String) p) {}
''');
      final fFunction = library.functions.named('f');
      final parameterType = fFunction.parameters.single.modelType;

      expect(
        parameterType.linkedName,
        '$intLink Function'
        '<span class="signature">'
        '(<span class="parameter" id="param-">'
        '<span class="type-annotation">$stringLink</span>'
        '</span>)</span>',
      );
      expect(parameterType.nameWithGenerics, equals('Function'));
    });

    test('nullable function type has rendered names', () async {
      final library = await bootPackageWithLibrary('''
void f(int Function(String)? p) {}
''');
      final fFunction = library.functions.named('f');
      final parameterType = fFunction.parameters.single.modelType;

      expect(
        parameterType.linkedName,
        // TODO(https://github.com/dart-lang/dartdoc/issues/2381): Fix.
        '($intLink Function'
        '<span class="signature">'
        '(<span class="parameter" id="param-">'
        '<span class="type-annotation">$stringLink</span>'
        '</span>)</span>?)',
      );
      expect(parameterType.nameWithGenerics, equals('Function'));
    });

    test('generic function type has rendered names', () async {
      final library = await bootPackageWithLibrary('''
void f(int Function<T>(T)? p) {}
''');
      final fFunction = library.functions.named('f');
      final parameterType = fFunction.parameters.single.modelType;

      expect(
        parameterType.linkedName,
        '($intLink Function'
        '&lt;<wbr><span class="type-parameter">T</span>&gt;'
        '<span class="signature">'
        '(<span class="parameter" id="param-">'
        '<span class="type-annotation">T</span></span>)</span>?)',
      );
      expect(
        parameterType.nameWithGenerics,
        'Function&lt;<wbr><span class="type-parameter">T</span>&gt;',
      );
    });
  });

  group('other types', () {
    test('"dynamic" type has rendered names', () async {
      final library = await bootPackageWithLibrary('''
void f(dynamic p) {}
''');
      final fFunction = library.functions.named('f');
      final parameterType = fFunction.parameters.single.modelType;

      expect(parameterType.linkedName, equals('dynamic'));
      expect(parameterType.nameWithGenerics, equals('dynamic'));
    });

    test('"Never" type has rendered names', () async {
      final library = await bootPackageWithLibrary('''
void f(Never p) {}
''');
      final fFunction = library.functions.named('f');
      final parameterType = fFunction.parameters.single.modelType;

      expect(parameterType.linkedName, equals('Never'));
      expect(parameterType.nameWithGenerics, equals('Never'));
    });

    test('"void" type has rendered names', () async {
      final library = await bootPackageWithLibrary('''
void f(void p) {}
''');
      final fFunction = library.functions.named('f');
      final parameterType = fFunction.parameters.single.modelType;

      expect(parameterType.linkedName, equals('void'));
      expect(parameterType.nameWithGenerics, equals('void'));
    });
  });
}
