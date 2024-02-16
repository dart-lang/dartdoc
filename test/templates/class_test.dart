// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/file_system/memory_file_system.dart';
import 'package:path/path.dart' as path;
import 'package:test/test.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

import '../dartdoc_test_base.dart';
import '../src/test_descriptor_utils.dart' as d;
import '../src/utils.dart';

void main() async {
  defineReflectiveSuite(() {
    defineReflectiveTests(ClassTest);
  });
}

@reflectiveTest
class ClassTest extends DartdocTestBase {
  static const packageName = 'class_test';

  @override
  String get libraryName => 'class';

  Future<void> createPackage({
    List<d.Descriptor> libFiles = const [],
  }) async {
    packagePath = await d.createPackage(
      packageName,
      pubspec: '''
name: class_test
version: 0.0.1
environment:
  sdk: '>=3.3.0-0 <4.0.0'
''',
      dartdocOptions: '''
dartdoc:
  linkToSource:
    root: '.'
    uriTemplate: 'https://github.com/dart-lang/TEST_PKG/%f%#L%l%'
''',
      libFiles: libFiles,
      resourceProvider: resourceProvider,
    );
    await writeDartdocResources(resourceProvider);
    packageConfigProvider.addPackageToConfigFor(
        packagePath, packageName, Uri.file('$packagePath/'));
  }

  Future<List<String>> createPackageAndReadLines({
    required List<d.Descriptor> libFiles,
    required List<String> filePath,
  }) async {
    await createPackage(libFiles: libFiles);
    await (await buildDartdoc()).generateDocs();

    return resourceProvider.readLines([packagePath, 'doc', ...filePath]);
  }

  void test_class_extends() async {
    var baseLines = await createPackageAndReadLines(
      libFiles: [
        d.file('lib.dart', '''
class Base {}
class Foo extends Base {}
'''),
      ],
      filePath: ['lib', 'Base-class.html'],
    );

    baseLines.expectMainContentContainsAllInOrder([
      matches('<dt>Implementers</dt>'),
      matches('<dd><ul class="comma-separated clazz-relationships">'),
      matches('<li><a href="../lib/Foo-class.html">Foo</a></li>'),
      matches('</ul></dd>'),
    ]);
  }

  void test_class_implements() async {
    var baseLines = await createPackageAndReadLines(
      libFiles: [
        d.file('lib.dart', '''
class Base {}
class Foo implements Base {}
'''),
      ],
      filePath: ['lib', 'Base-class.html'],
    );

    baseLines.expectMainContentContainsAllInOrder([
      matches('<dt>Implementers</dt>'),
      matches('<dd><ul class="comma-separated clazz-relationships">'),
      matches('<li><a href="../lib/Foo-class.html">Foo</a></li>'),
      matches('</ul></dd>'),
    ]);
  }

  void test_class_implements_withGenericType() async {
    var baseLines = await createPackageAndReadLines(
      libFiles: [
        d.file('lib.dart', '''
class Base<E> {}
class Foo<E> implements Base<E> {}
'''),
      ],
      filePath: ['lib', 'Base-class.html'],
    );

    baseLines.expectMainContentContainsAllInOrder([
      matches('<dt>Implementers</dt>'),
      matches('<dd><ul class="comma-separated clazz-relationships">'),
      matches('<li><a href="../lib/Foo-class.html">Foo</a></li>'),
      matches('</ul></dd>'),
    ]);
  }

  void test_class_implements_withInstantiatedType() async {
    var baseLines = await createPackageAndReadLines(
      libFiles: [
        d.file('lib.dart', '''
class Base<E> {}
class Foo implements Base<int> {}
'''),
      ],
      filePath: ['lib', 'Base-class.html'],
    );

    baseLines.expectMainContentContainsAllInOrder([
      matches('<dt>Implementers</dt>'),
      matches('<dd><ul class="comma-separated clazz-relationships">'),
      matches('<li><a href="../lib/Foo-class.html">Foo</a></li>'),
      matches('</ul></dd>'),
    ]);
  }

  void test_extensionType_implements() async {
    var base1Lines = await createPackageAndReadLines(
      libFiles: [
        d.file('lib.dart', '''
class Base1 {}
class Base2 extends Base1 {}
extension type ET(Base2 base) implements Base1 {}
'''),
      ],
      filePath: ['lib', 'Base1-class.html'],
    );

    base1Lines.expectMainContentContainsAllInOrder([
      matches('<dt>Implementers</dt>'),
      matches('<dd><ul class="comma-separated clazz-relationships">'),
      matches('<li><a href="../lib/Base2-class.html">Base2</a></li>'),
      matches('<li><a href="../lib/ET-extension-type.html">ET</a></li>'),
      matches('</ul></dd>'),
    ]);
  }

  void test_mixin_implements() async {
    var baseLines = await createPackageAndReadLines(
      libFiles: [
        d.file('lib.dart', '''
class Base {}
mixin M implements Base {}
'''),
      ],
      filePath: ['lib', 'Base-class.html'],
    );

    baseLines.expectMainContentContainsAllInOrder([
      matches('<dt>Implementers</dt>'),
      matches('<dd><ul class="comma-separated clazz-relationships">'),
      matches('<li><a href="../lib/M-mixin.html">M</a></li>'),
      matches('</ul></dd>'),
    ]);
  }

  @FailingTest(reason: 'Not implemented yet; should be?')
  void test_mixin_superclassConstraint() async {
    var baseLines = await createPackageAndReadLines(
      libFiles: [
        d.file('lib.dart', '''
class Base {}
mixin M on Base {}
'''),
      ],
      filePath: ['lib', 'Base-class.html'],
    );

    baseLines.expectMainContentContainsAllInOrder([
      matches('<dt>Implementers</dt>'),
      matches('<dd><ul class="comma-separated clazz-relationships">'),
      matches('<li><a href="../lib/M-mixin.html">M</a></li>'),
      matches('</ul></dd>'),
    ]);
  }
}

extension on MemoryResourceProvider {
  List<String> readLines(List<String> pathParts) =>
      getFile(path.joinAll(pathParts)).readAsStringSync().split('\n');
}
