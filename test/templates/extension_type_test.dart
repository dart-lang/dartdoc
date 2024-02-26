// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
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
    defineReflectiveTests(ExtensionTypeTest);
  });
}

@reflectiveTest
class ExtensionTypeTest extends DartdocTestBase {
  static const packageName = 'extension_type_test';

  @override
  String get libraryName => 'class';

  /// Creates a package on disk with the given singular library [content], and
  /// generates the docs.
  Future<void> createPackageWithLibrary(String content) async {
    packagePath = await d.createPackage(
      packageName,
      pubspec: '''
name: extension_type_test
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
      libFiles: [
        d.file('lib.dart', content),
      ],
      resourceProvider: resourceProvider,
    );
    await writeDartdocResources(resourceProvider);
    packageConfigProvider.addPackageToConfigFor(
        packagePath, packageName, Uri.file('$packagePath/'));

    await (await buildDartdoc()).generateDocs();
  }

  List<String> readLines(List<String> filePath) =>
      resourceProvider.readLines([packagePath, 'doc', ...filePath]);

  void test_extensionNameWithGenerics() async {
    await createPackageWithLibrary('''
extension type One<E>(List<E> it) {}
''');
    var htmlLines = readLines(['lib', 'One-extension-type.html']);

    htmlLines.expectMainContentContainsAllInOrder([
      matches(
        '<span class="kind-class">One&lt;<wbr>'
        '<span class="type-parameter">E</span>&gt;</span>',
      )
    ]);
  }

  void test_primaryConstructorPage() async {
    await createPackageWithLibrary('''
extension type One<E>(List<E> it) {}
''');
    var htmlLines = readLines(['lib', 'One', 'One.html']);

    htmlLines.expectMainContentContainsAllInOrder([
      matches(
        '<span class="kind-constructor">One&lt;<wbr>'
        '<span class="type-parameter">E</span>&gt;</span> constructor',
      )
    ]);
  }

  void test_namedConstructorPage() async {
    await createPackageWithLibrary('''
extension type One<E>(List<E> it) {
  One.named(this.e);
}
''');
    var htmlLines = readLines(['lib', 'One', 'One.named.html']);

    htmlLines.expectMainContentContainsAllInOrder([
      matches(
        '<span class="kind-constructor">One&lt;<wbr>'
        '<span class="type-parameter">E</span>&gt;.named</span> constructor',
      )
    ]);
  }

  void test_representationType() async {
    await createPackageWithLibrary('''
class Foo<E> {}
extension type One<E>(Foo<E> it) {}
''');
    var htmlLines = readLines(['lib', 'One-extension-type.html']);

    htmlLines.expectMainContentContainsAllInOrder([
      matches('<dt>on</dt>'),
      matches('<a href="../lib/Foo-class.html">Foo</a>'
          '<span class="signature">&lt;<wbr>'
          '<span class="type-parameter">E</span>&gt;</span>'),
    ]);
  }

  void test_classInterfaces() async {
    await createPackageWithLibrary('''
class Base<E> {}
class Foo<E> implements Base<E> {}
extension type One<E>(Foo<E> it) implements Base<E> {}
''');
    var htmlLines = readLines(['lib', 'One-extension-type.html']);

    htmlLines.expectMainContentContainsAllInOrder([
      matches('<dt>Implemented types</dt>'),
      matches('<a href="../lib/Base-class.html">Base</a>'
          '<span class="signature">&lt;<wbr>'
          '<span class="type-parameter">E</span>&gt;</span>'),
    ]);
  }

  void test_extensionTypeInterfaces() async {
    await createPackageWithLibrary('''
extension type One<E>(List<E> it) {}
extension type Two(List<int> it) implements One<int> {}
''');
    var htmlLines = readLines(['lib', 'Two-extension-type.html']);

    htmlLines.expectMainContentContainsAllInOrder([
      matches('<dt>Implemented types</dt>'),
      matches('<a href="../lib/One-extension-type.html">One</a>'
          '<span class="signature">&lt;<wbr>'
          '<span class="type-parameter">int</span>&gt;</span>'),
    ]);
  }

  void test_implementers() async {
    await createPackageWithLibrary('''
extension type One<E>(List<E> it) {}
extension type Two(List<int> it) implements One<int> {}
''');
    var htmlLines = readLines(['lib', 'One-extension-type.html']);

    htmlLines.expectMainContentContainsAllInOrder([
      matches('<dt>Implementers</dt>'),
      matches('<dd><ul class="comma-separated clazz-relationships">'),
      matches('<li><a href="../lib/Two-extension-type.html">Two</a></li>'),
      matches('</ul></dd>'),
    ]);
  }

  void test_constructors() async {
    await createPackageWithLibrary('''
extension type One(int it) {
  /// A named constructor.
  One.named(this.it);
}
''');
    var htmlLines = readLines(['lib', 'One-extension-type.html']);

    htmlLines.expectMainContentContainsAllInOrder([
      matches('<h2>Constructors</h2>'),
      matches('<a href="../lib/One/One.html">One</a>'),
      matches('<a href="../lib/One/One.named.html">'
          'One.named</a>'),
      matches('A named constructor.'),
    ]);
  }

  void test_staticMethods() async {
    await createPackageWithLibrary('''
extension type One(int it) {
  /// A static method.
  static void s1() {}
}
''');
    var htmlLines = readLines(['lib', 'One-extension-type.html']);

    htmlLines.expectMainContentContainsAllInOrder([
      matches('<h2>Static Methods</h2>'),
      matches('<a href="../lib/One/s1.html">s1</a>'),
      matches('A static method.'),
    ]);
  }

  void test_staticFields() async {
    await createPackageWithLibrary('''
extension type One(int it) {
  /// A static field.
  static final int sf1 = 2;
}
''');
    var htmlLines = readLines(['lib', 'One-extension-type.html']);

    htmlLines.expectMainContentContainsAllInOrder([
      matches('<h2>Static Properties</h2>'),
      matches('<a href="../lib/One/sf1.html">sf1</a>'),
      matches('A static field.'),
    ]);
  }

  void test_staticGetterSetterPairs() async {
    await createPackageWithLibrary('''
extension type One(int it) {
  /// A static getter.
  static int get gs1 => 3;

  /// A static setter.
  static void set gs1(int value) {}
}
''');
    var htmlLines = readLines(['lib', 'One-extension-type.html']);

    htmlLines.expectMainContentContainsAllInOrder([
      matches('<h2>Static Properties</h2>'),
      matches('<a href="../lib/One/gs1.html">gs1</a>'),
      matches('A static getter.'),
    ]);
  }

  void test_constants() async {
    await createPackageWithLibrary('''
extension type One(int it) {
  /// A constant.
  static const c1 = 1;
}
''');
    var htmlLines = readLines(['lib', 'One-extension-type.html']);

    htmlLines.expectMainContentContainsAllInOrder([
      matches('<h2>Constants</h2>'),
      matches('<a href="../lib/One/c1-constant.html">c1</a>'),
      matches('A constant.'),
    ]);
  }

  void test_representationField() async {
    await createPackageWithLibrary('''
extension type One(int it) {}
''');
    var htmlLines = readLines(['lib', 'One-extension-type.html']);

    htmlLines.expectMainContentContainsAllInOrder([
      matches('<h2>Properties</h2>'),
      matches('<a href="../lib/One/it.html">it</a>'),
    ]);
  }

  void test_inheritedRepresentationField() async {
    await createPackageWithLibrary('''
extension type One(int one) {}
extension type Two(int two) implements One {}
''');
    var htmlLines = readLines(['lib', 'Two-extension-type.html']);

    htmlLines.expectMainContentContainsAllInOrder([
      matches('<h2>Properties</h2>'),
      matches('<a href="../lib/One/one.html">one</a>'),
    ]);
  }

  void test_inheritedGetters() async {
    await createPackageWithLibrary('''
class Base {
  int get field1 => 1;
}
class Foo extends Base {}
extension type One(int one) implements Base {}
''');
    var htmlLines = readLines(['lib', 'One-extension-type.html']);

    htmlLines.expectMainContentContainsAllInOrder([
      matches('<h2>Properties</h2>'),
      matches('<a href="../lib/Base/field1.html">field1</a>'),
    ]);
  }

  void test_instanceMethods() async {
    await createPackageWithLibrary('''
extension type One(int it) {
  /// An instance method.
  void m1() {}
}
''');
    var htmlLines = readLines(['lib', 'One-extension-type.html']);

    htmlLines.expectMainContentContainsAllInOrder([
      matches('<h2>Methods</h2>'),
      matches('<dt id="m1" class="callable">'),
      matches('<a href="../lib/One/m1.html">m1</a>'),
      matches('An instance method.'),
    ]);
  }

  void test_methodsInheritedFromClassSuperInterface() async {
    await createPackageWithLibrary('''
class Base {
  void m2() {}
}
class Foo extends Base {}
extension type One(int it) implements Base {}
''');
    var htmlLines = readLines(['lib', 'One-extension-type.html']);

    htmlLines.expectMainContentContainsAllInOrder([
      matches('<h2>Methods</h2>'),
      matches('<dt id="m2" class="callable inherited">'),
      matches('<a href="../lib/Base/m2.html">m2</a>'),
    ]);
  }

  void test_methodsInheritedFromAnExtensionTypeSuperInterface() async {
    await createPackageWithLibrary('''
extension type One(int one) {
  void m1() {}
}
extension type Two(int two) implements One {}
''');
    var htmlLines = readLines(['lib', 'Two-extension-type.html']);

    htmlLines.expectMainContentContainsAllInOrder([
      matches('<h2>Methods</h2>'),
      matches('<dt id="m1" class="callable inherited">'),
      matches('<a href="../lib/One/m1.html">m1</a>'),
    ]);
  }

  void test_operators() async {
    await createPackageWithLibrary('''
extension type One(int one) {
  /// An operator.
  bool operator >(E other) => false;
}
''');
    var htmlLines = readLines(['lib', 'One-extension-type.html']);

    htmlLines.expectMainContentContainsAllInOrder([
      matches('<h2>Operators</h2>'),
      matches('<a href="../lib/One/operator_greater.html">operator ></a>'),
      matches('An operator.'),
    ]);
  }

  void test_inheritedOperators() async {
    await createPackageWithLibrary('''
extension type One(int one) {
  /// An operator.
  bool operator >(E other) => false;
}
extension type Two(int two) implements One {}
''');
    var htmlLines = readLines(['lib', 'Two-extension-type.html']);

    htmlLines.expectMainContentContainsAllInOrder([
      matches('<h2>Operators</h2>'),
      matches('<a href="../lib/One/operator_greater.html">operator ></a>'),
      matches('An operator.'),
    ]);
  }

  void test_sidebar_methods() async {
    await createPackageWithLibrary('''
extension type One(int it) {
  void m1() {}
}
''');
    var htmlLines = readLines(['lib', 'One-extension-type-sidebar.html']);

    expect(
      htmlLines,
      containsAllInOrder([
        matches(
          '<a href="../lib/One-extension-type.html#instance-methods">'
          'Methods</a>',
        ),
        matches('<a href="../lib/One/m1.html">m1</a>'),
      ]),
    );
  }

  void test_sidebar_operators() async {
    await createPackageWithLibrary('''
extension type One(int it) {
  bool operator >(E other) => false;
}
''');
    var htmlLines = readLines(['lib', 'One-extension-type-sidebar.html']);

    expect(
      htmlLines,
      containsAllInOrder([
        matches(
            '<a href="../lib/One-extension-type.html#operators">Operators</a>'),
        matches('<a href="../lib/One/operator_greater.html">operator ></a>'),
      ]),
    );
  }

  void test_sidebar_staticProperties() async {
    await createPackageWithLibrary('''
extension type One(int it) {
  static final int sf1 = 2;

  static int get gs1 => 3;

  static void set gs1(int value) {}
}
''');
    var htmlLines = readLines(['lib', 'One-extension-type-sidebar.html']);

    expect(
      htmlLines,
      containsAllInOrder([
        matches('<a href="../lib/One-extension-type.html#static-properties">'
            'Static properties</a>'),
        matches('<a href="../lib/One/gs1.html">gs1</a>'),
        matches('<a href="../lib/One/sf1.html">sf1</a>'),
      ]),
    );
  }

  void test_sidebar_staticMethods() async {
    await createPackageWithLibrary('''
extension type One(int it) {
  static void s1() {}
}
''');
    var htmlLines = readLines(['lib', 'One-extension-type-sidebar.html']);

    expect(
      htmlLines,
      containsAllInOrder([
        matches('<a href="../lib/One-extension-type.html#static-methods">'
            'Static methods</a>'),
        matches('<a href="../lib/One/s1.html">s1</a>'),
      ]),
    );
  }
}

extension on MemoryResourceProvider {
  List<String> readLines(List<String> pathParts) =>
      getFile(path.joinAll(pathParts)).readAsStringSync().split('\n');
}
