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
class _Foo extends Base {}
class Foo extends _Foo {}
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
class _Foo implements Base {}
class Foo implements _Foo {}
''');
    var baseLines = readLines(['lib', 'Base-class.html']);

    expect(
      baseLines.join('\n'),
      matchesCompressed('''
        <dt>Implementers</dt>
        <dd><ul class="comma-separated clazz-relationships">
            <li><a href="../lib/Foo-class.html">Foo</a></li>
        </ul></dd>
'''),
    );
  }

  void test_implementers_class_extends2() async {
    await createPackageWithLibrary('''
abstract class A {}
abstract class B extends A {}
class _C extends B {}
class D extends _C {}
''');
    var baseLines = readLines(['lib', 'A-class.html']);

    expect(
      baseLines.join('\n'),
      // D should not be found; it is indirect via B.
      matchesCompressed('''
        <dt>Implementers</dt>
        <dd><ul class="comma-separated clazz-relationships">
            <li><a href="../lib/B-class.html">B</a></li>
        </ul></dd>
'''),
    );
  }

  void test_implementers_class_implements_withGenericType() async {
    await createPackageWithLibrary('''
class Base<E> {}
class Foo<E> implements Base<E> {}
''');
    var baseLines = readLines(['lib', 'Base-class.html']);

    expect(
      baseLines.join('\n'),
      matchesCompressed(r'''
        <dt>Implementers</dt>
        <dd><ul class="comma-separated clazz-relationships">
          <li><a href="../lib/Foo-class.html">Foo</a></li>
        </ul></dd>
'''),
    );
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

  void test_implementers_class_mixesIn() async {
    await createPackageWithLibrary('''
class Base {}
class _Foo with Base {}
class Foo with _Foo {}
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
mixin _M implements Base {}
mixin M implements _M {}
''');
    var baseLines = readLines(['lib', 'Base-class.html']);

    baseLines.expectMainContentContainsAllInOrder([
      matches('<dt>Implementers</dt>'),
      matches('<dd><ul class="comma-separated clazz-relationships">'),
      matches('<li><a href="../lib/M-mixin.html">M</a></li>'),
      matches('</ul></dd>'),
    ]);
  }

  void test_implementers_mixin_superclassConstraint() async {
    await createPackageWithLibrary('''
class Base {}
mixin _M on Base {}
mixin M on _M {}
''');
    var baseLines = readLines(['lib', 'Base-class.html']);

    baseLines.expectMainContentContainsAllInOrder([
      matches('<dt>Implementers</dt>'),
      matches('<dd><ul class="comma-separated clazz-relationships">'),
      matches('<li><a href="../lib/M-mixin.html">M</a></li>'),
      matches('</ul></dd>'),
    ]);
  }

  void test_availableExtensions_direct() async {
    await createPackageWithLibrary('''
class C {}
extension E on C {}
''');
    var baseLines = readLines(['lib', 'C-class.html']);

    baseLines.expectMainContentContainsAllInOrder([
      matches('<dt>Available extensions</dt>'),
      matches('<dd><ul class="comma-separated clazz-relationships">'),
      matches('<li><a href="../lib/E.html">E</a></li>'),
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

  void test_instanceMethod_fromExtension() async {
    await createPackageWithLibrary('''
class C {}

extension E on C {
  /// An instance method.
  void m() {}
}
''');
    var htmlLines = readLines(['lib', 'C-class.html']);

    htmlLines.expectMainContentContainsAllInOrder([
      matches('<h2>Methods</h2>'),
      matches('<dt id="m" class="callable">'),
      matches('<a href="../lib/E/m.html">m</a>'),
      matches('An instance method.'),
    ]);
  }

  void test_operator_fromExtension() async {
    await createPackageWithLibrary('''
class C {}

extension E on C {
  /// An operator.
  int operator +(int other) => 7;
}
''');
    var htmlLines = readLines(['lib', 'C-class.html']);

    htmlLines.expectMainContentContainsAllInOrder([
      matches('<h2>Operators</h2>'),
      matches('<dt id="operator \\+" class="callable">'),
      matches('<a href="../lib/E/operator_plus.html">operator \\+</a>'),
      matches('An operator.'),
    ]);
  }

  void test_instancePropertyAccessor_fromExtension() async {
    await createPackageWithLibrary('''
class C {}

extension E on C {
  /// An instance getter.
  int get f => 1;
}
''');
    var htmlLines = readLines(['lib', 'C-class.html']);

    htmlLines.expectMainContentContainsAllInOrder([
      matches('<h2>Properties</h2>'),
      matches('<dt id="f" class="property">'),
      matches('<a href="../lib/E/f.html">f</a>'),
      matches('An instance getter.'),
    ]);
  }

  void test_instancePropertyAccessor_fromExtension_onNullableType() async {
    await createPackageWithLibrary('''
class C {}

extension E on C? {
  /// An instance getter.
  int get f => 1;
}
''');
    var htmlLines = readLines(['lib', 'C-class.html']);

    htmlLines.expectMainContentContainsAllInOrder([
      matches('<h2>Properties</h2>'),
      matches('<dt id="f" class="property">'),
      matches('<a href="../lib/E/f.html">f</a>'),
      matches('An instance getter.'),
    ]);
  }

  void test_instancePropertyAccessor_fromExtensionOfSupertype() async {
    await createPackageWithLibrary('''
class C<T> {}

class D<T> extends C<T> {}

extension E on C<int> {
  /// An instance getter.
  int get f => 1;
}
''');
    var htmlLines = readLines(['lib', 'D-class.html']);

    htmlLines.expectMainContentContainsAllInOrder([
      matches('<h2>Properties</h2>'),
      matches('<dt id="f" class="property">'),
      matches('<a href="../lib/E/f.html">f</a>'),
      matches('An instance getter.'),
    ]);
  }

  void test_sidebar_method_providedByExtension() async {
    await createPackageWithLibrary('''
class C {}

extension E on C {
  /// An instance method.
  void m() {}
}
''');
    var htmlLines = readLines(['lib', 'C-class-sidebar.html']);

    htmlLines.expectContentContainsAllInOrder([
      matches('<a href="lib/C-class.html#instance-methods">Methods</a>'),
      matches('<a href="lib/E/m.html">m</a>'),
      matches('<sup'),
      matches('    class="muted"'),
      matches('    title="Available on C">\\(ext\\)</sup>'),
    ]);
  }

  void test_sidebar_operator_providedByExtension() async {
    await createPackageWithLibrary('''
class C {}

extension E on C {
  /// An operator.
  int operator +(int other) => 7;
}
''');
    var htmlLines = readLines(['lib', 'C-class-sidebar.html']);

    htmlLines.expectContentContainsAllInOrder([
      matches('<a href="lib/C-class.html#operators">Operators</a>'),
      matches('<a href="lib/E/operator_plus.html">operator \\+</a>'),
      matches('<sup'),
      matches('    class="muted"'),
      matches('    title="Available on C">\\(ext\\)</sup>'),
    ]);
  }

  void test_sidebar_propertyAccessor_providedByExtension() async {
    await createPackageWithLibrary('''
class C {}

extension E on C {
  /// An instance getter.
  int get f => 1;
}
''');
    var htmlLines = readLines(['lib', 'C-class-sidebar.html']);

    htmlLines.expectContentContainsAllInOrder([
      matches('<a href="lib/C-class.html#instance-properties">Properties</a>'),
      matches('<a href="lib/E/f.html">f</a>'),
      matches('<sup'),
      matches('    class="muted"'),
      matches('    title="Available on C">\\(ext\\)</sup>'),
    ]);
  }
}
