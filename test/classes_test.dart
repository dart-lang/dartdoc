// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:dartdoc/src/special_elements.dart';
import 'package:test/test.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

import 'dartdoc_test_base.dart';
import 'src/utils.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(ClassesTest);
  });
}

@reflectiveTest
class ClassesTest extends DartdocTestBase {
  @override
  String get libraryName => 'classes';

  void test_availableExtensions_onClass() async {
    var library = await bootPackageWithLibrary('''
class C {}
extension Ex on C {}
''');

    var c = library.classes.named('C');
    expect(
      c.potentiallyApplicableExtensionsSorted,
      contains(library.extensions.named('Ex')),
    );
  }

  void test_availableExtensions_onClassWithInstantiatedType() async {
    var library = await bootPackageWithLibrary('''
class C<T> {}
extension Ex on C<int> {}
''');

    var c = library.classes.named('C');
    expect(
      c.potentiallyApplicableExtensionsSorted,
      contains(library.extensions.named('Ex')),
    );
  }

  void test_availableExtensions_onSubtypeOfClass() async {
    var library = await bootPackageWithLibrary('''
class C {}
class D extends C {}
extension Ex on C {}
''');

    var d = library.classes.named('D');
    expect(
      d.potentiallyApplicableExtensionsSorted,
      contains(library.extensions.named('Ex')),
    );
  }

  void test_availableExtensions_onInstantiatedSubtypeOfClass() async {
    var library = await bootPackageWithLibrary('''
class C<T> {}
class D<T> extends C<T> {}
extension Ex on C<int> {}
''');

    var d = library.classes.named('D');
    expect(
      d.potentiallyApplicableExtensionsSorted,
      contains(library.extensions.named('Ex')),
    );
  }

  void test_publicInterfaces_direct() async {
    var library = await bootPackageWithLibrary('''
class A {}
class B implements A {}
''');

    var b = library.classes.named('B');
    expect(b.publicInterfaces, hasLength(1));
    expect(b.publicInterfaces.first.modelElement, library.classes.named('A'));
  }

  void test_publicInterfaces_indirect() async {
    var library = await bootPackageWithLibrary('''
class A {}
class B implements A {}
class C implements B {}
''');

    var c = library.classes.named('C');
    // Only `B` is shown, not indirect-through-public like `A`.
    expect(c.publicInterfaces, hasLength(1));
    expect(c.publicInterfaces.first.modelElement, library.classes.named('B'));
  }

  void test_publicInterfaces_indirectViaPrivate() async {
    var library = await bootPackageWithLibrary('''
class A {}
class _B implements A {}
class C implements _B {}
''');

    var c = library.classes.named('C');
    expect(c.publicInterfaces, hasLength(1));
    expect(c.publicInterfaces.first.modelElement, library.classes.named('A'));
  }

  void test_publicInterfaces_indirectViaPrivate2() async {
    var library = await bootPackageWithLibrary('''
class A {}
class _B implements A {}
class _C implements _B {}
class D implements _C {}
''');

    var d = library.classes.named('D');
    expect(d.publicInterfaces, hasLength(1));
    expect(d.publicInterfaces.first.modelElement, library.classes.named('A'));
  }

  void test_publicInterfaces_indirectViaPrivateExtendedClass() async {
    var library = await bootPackageWithLibrary('''
class A {}
class _B implements A {}
class C extends _B {}
''');

    var c = library.classes.named('C');
    expect(c.publicInterfaces, hasLength(1));
    expect(c.publicInterfaces.first.modelElement, library.classes.named('A'));
  }

  void test_publicInterfaces_indirectViaPrivateExtendedClass2() async {
    var library = await bootPackageWithLibrary('''
class A {}
class _B implements A {}
class _C extends _B {}
class D extends _C {}
''');

    var c = library.classes.named('D');
    expect(c.publicInterfaces, hasLength(1));
    expect(c.publicInterfaces.first.modelElement, library.classes.named('A'));
  }

  void test_publicInterfaces_onlyExtendedClasses() async {
    var library = await bootPackageWithLibrary('''
class A {}
class B extends A {}
class _C extends B {}
class D extends _C {}
''');

    expect(library.classes.named('D').publicInterfaces, isEmpty);
  }

  void test_publicInterfaces_indirectViaPrivateMixedInMixin() async {
    var library = await bootPackageWithLibrary('''
class A {}
mixin _M implements A {}
class C with _M {}
''');

    var c = library.classes.named('C');
    expect(c.publicInterfaces, hasLength(1));
    expect(c.publicInterfaces.first.modelElement, library.classes.named('A'));
  }

  void test_publicInterfaces_indirectViaPrivate_multiply() async {
    var library = await bootPackageWithLibrary('''
class A<T> {}
class _B<U> implements A<U> {}
class C<T> implements A<T>, _B<T> {}
''');

    var c = library.classes.named('C');
    expect(c.publicInterfaces, hasLength(1));
    expect(c.publicInterfaces.first.modelElement, library.classes.named('A'));
  }

  void test_inheritanceOfObjectInstanceMethod() async {
    // This code is written such that `Inheritable._inheritance` for
    // `A.toString()` includes two copies of Object; one from walking up B's
    // chain, and then the second from walking up C's chain.
    var library = await bootPackageWithLibrary('''
class A implements B, C {}
class B implements C {}
class C implements D {}
class D implements Object {}
''');

    var object = library.packageGraph.specialClasses[SpecialClass.object]!;
    var toString = library.classes.named('A').instanceMethods.named('toString');
    expect(toString.canonicalEnclosingContainer, object);
  }

  // TODO(srawlins): Test everything else about classes.
}
