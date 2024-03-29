// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:test/test.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

import '../src/utils.dart';
import 'template_test_base.dart';

void main() async {
  defineReflectiveSuite(() {
    defineReflectiveTests(ClassTest);
  });
}

@reflectiveTest
class ClassTest extends TemplateTestBase {
  @override
  String get packageName => 'class_test';

  @override
  String get libraryName => 'class';

  void test_implementers_class_extends() async {
    await createPackageWithLibrary('''
class Base {}
class Foo extends Base {}
''');
    var baseLines = readLines(['lib', 'Base-class.html']);

    baseLines.expectMainContentContainsAllInOrder([
      matches('<dt>Implementers</dt>'),
      matches('<dd><ul class="comma-separated clazz-relationships">'),
      matches('<li><a href="../lib/Foo-class.html">Foo</a></li>'),
      matches('</ul></dd>'),
    ]);
  }

  void test_implementers_class_implements() async {
    await createPackageWithLibrary('''
class Base {}
class Foo implements Base {}
''');
    var baseLines = readLines(['lib', 'Base-class.html']);

    baseLines.expectMainContentContainsAllInOrder([
      matches('<dt>Implementers</dt>'),
      matches('<dd><ul class="comma-separated clazz-relationships">'),
      matches('<li><a href="../lib/Foo-class.html">Foo</a></li>'),
      matches('</ul></dd>'),
    ]);
  }

  void test_implementers_class_implements_withGenericType() async {
    await createPackageWithLibrary('''
class Base<E> {}
class Foo<E> implements Base<E> {}
''');
    var baseLines = readLines(['lib', 'Base-class.html']);

    baseLines.expectMainContentContainsAllInOrder([
      matches('<dt>Implementers</dt>'),
      matches('<dd><ul class="comma-separated clazz-relationships">'),
      matches('<li><a href="../lib/Foo-class.html">Foo</a></li>'),
      matches('</ul></dd>'),
    ]);
  }

  void test_implementers_class_implements_withInstantiatedType() async {
    await createPackageWithLibrary('''
class Base<E> {}
class Foo implements Base<int> {}
''');
    var baseLines = readLines(['lib', 'Base-class.html']);

    baseLines.expectMainContentContainsAllInOrder([
      matches('<dt>Implementers</dt>'),
      matches('<dd><ul class="comma-separated clazz-relationships">'),
      matches('<li><a href="../lib/Foo-class.html">Foo</a></li>'),
      matches('</ul></dd>'),
    ]);
  }

  void test_implementers_extensionType_implements() async {
    await createPackageWithLibrary('''
class Base1 {}
class Base2 extends Base1 {}
extension type ET(Base2 base) implements Base1 {}
''');
    var base1Lines = readLines(['lib', 'Base1-class.html']);

    base1Lines.expectMainContentContainsAllInOrder([
      matches('<dt>Implementers</dt>'),
      matches('<dd><ul class="comma-separated clazz-relationships">'),
      matches('<li><a href="../lib/Base2-class.html">Base2</a></li>'),
      matches('<li><a href="../lib/ET-extension-type.html">ET</a></li>'),
      matches('</ul></dd>'),
    ]);
  }

  void test_implementers_mixin_implements() async {
    await createPackageWithLibrary('''
class Base {}
mixin M implements Base {}
''');
    var baseLines = readLines(['lib', 'Base-class.html']);

    baseLines.expectMainContentContainsAllInOrder([
      matches('<dt>Implementers</dt>'),
      matches('<dd><ul class="comma-separated clazz-relationships">'),
      matches('<li><a href="../lib/M-mixin.html">M</a></li>'),
      matches('</ul></dd>'),
    ]);
  }

  @FailingTest(reason: 'Not implemented yet; should be?')
  void test_implementers_mixin_superclassConstraint() async {
    await createPackageWithLibrary('''
class Base {}
mixin M on Base {}
''');
    var baseLines = readLines(['lib', 'Base-class.html']);

    baseLines.expectMainContentContainsAllInOrder([
      matches('<dt>Implementers</dt>'),
      matches('<dd><ul class="comma-separated clazz-relationships">'),
      matches('<li><a href="../lib/M-mixin.html">M</a></li>'),
      matches('</ul></dd>'),
    ]);
  }

  void test_constructor_named() async {
    await createPackageWithLibrary('''
class C {
  /// A named constructor.
  C.named();
}
''');
    var htmlLines = readLines(['lib', 'C-class.html']);

    htmlLines.expectMainContentContainsAllInOrder([
      matches('<h2>Constructors</h2>'),
      matches('<a href="../lib/C/C.named.html">C.named</a>'),
      matches('A named constructor.'),
    ]);
  }

  void test_constructor_unnamed() async {
    await createPackageWithLibrary('''
class C {
  /// An unnamed constructor.
  C();
}
''');
    var htmlLines = readLines(['lib', 'C-class.html']);

    htmlLines.expectMainContentContainsAllInOrder([
      matches('<h2>Constructors</h2>'),
      matches('<a href="../lib/C/C.html">C</a>'),
      matches('An unnamed constructor.'),
    ]);
  }

  void test_instanceMethod() async {
    await createPackageWithLibrary('''
class C {
  /// An instance method.
  void m1() {}
}
''');
    var htmlLines = readLines(['lib', 'C-class.html']);

    htmlLines.expectMainContentContainsAllInOrder([
      matches('<h2>Methods</h2>'),
      matches('<dt id="m1" class="callable">'),
      matches('<a href="../lib/C/m1.html">m1</a>'),
      matches('An instance method.'),
    ]);
  }

  void test_instanceMethod_generic() async {
    await createPackageWithLibrary('''
abstract class C {
  /// An instance method.
  T m1<T extends num>(T a);
}
''');
    var htmlLines = readLines(['lib', 'C-class.html']);

    htmlLines.expectMainContentContainsAllInOrder([
      matches('<h2>Methods</h2>'),
      matches('<dt id="m1" class="callable">'),
      matches('<a href="../lib/C/m1.html">m1</a>'),
      matches('An instance method.'),
    ]);
  }
}
