// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:test/test.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

import 'dartdoc_test_base.dart';
import 'src/utils.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(ConstructorsTest);
  });
}

@reflectiveTest
class ConstructorsTest extends DartdocTestBase {
  @override
  final libraryName = 'constructors';

  void test_classIsAbstractFinal_factory() async {
    var library = await bootPackageWithLibrary('''
abstract final class C {
  /// Constructor.
  factory C() => throw 'Nope';
}
''');
    var c = library.classes.named('C').constructors.first;
    expect(c.name, equals('C'));
    expect(c.isPublic, isTrue);
    expect(c.documentationAsHtml, '<p>Constructor.</p>');
  }

  void test_classIsAbstractFinal_unnamed() async {
    var library = await bootPackageWithLibrary('''
abstract final class C {
  /// Constructor.
  C();
}
''');
    var c = library.classes.named('C').constructors.first;
    expect(c.name, equals('C'));
    expect(c.isPublic, isFalse);
    expect(c.documentationAsHtml, '<p>Constructor.</p>');
  }

  void test_classIsAbstractInterface_unnamed() async {
    var library = await bootPackageWithLibrary('''
abstract interface class C {
  /// Constructor.
  C();
}
''');
    var c = library.classes.named('C').constructors.first;
    expect(c.name, equals('C'));
    expect(c.isPublic, isFalse);
    expect(c.documentationAsHtml, '<p>Constructor.</p>');
  }

  void test_classIsPrivate_named() async {
    var library = await bootPackageWithLibrary('''
class C {
  /// Constructor.
  C._();
}
''');
    var c = library.classes.named('C').constructors.first;
    expect(c.name, equals('C._'));
    expect(c.isPublic, isFalse);
    expect(c.documentationAsHtml, '<p>Constructor.</p>');
  }

  void test_classIsPrivate_unnamed() async {
    var library = await bootPackageWithLibrary('''
class _C {
  /// Constructor.
  _C();
}
''');
    var c = library.classes.named('_C').constructors.first;
    expect(c.name, equals('_C'));
    expect(c.isPublic, isFalse);
    expect(c.documentationAsHtml, '<p>Constructor.</p>');
  }

  void test_classIsPublic_default() async {
    var library = await bootPackageWithLibrary('''
class C {}
''');
    var c = library.classes.named('C').constructors.first;
    expect(c.name, equals('C'));
    expect(c.isPublic, isTrue);
    expect(c.documentationAsHtml, '');
  }

  void test_classIsPublic_named() async {
    var library = await bootPackageWithLibrary('''
class C {
  /// Constructor.
  C.named();
}
''');
    var c = library.classes.named('C').constructors.first;
    expect(c.name, equals('C.named'));
    expect(c.isPublic, isTrue);
    expect(c.documentationAsHtml, '<p>Constructor.</p>');
  }

  void test_classIsPublic_unnamed() async {
    var library = await bootPackageWithLibrary('''
class C {
  /// Constructor.
  C();
}
''');
    var c = library.classes.named('C').constructors.first;
    expect(c.name, equals('C'));
    expect(c.isPublic, isTrue);
    expect(c.documentationAsHtml, '<p>Constructor.</p>');
  }

  void test_classIsPublic_unnamed_explicitNew() async {
    var library = await bootPackageWithLibrary('''
class C {
  /// Constructor.
  C.new();
}
''');
    var c = library.classes.named('C').constructors.first;
    expect(c.name, equals('C'));
    expect(c.isPublic, isTrue);
    expect(c.documentationAsHtml, '<p>Constructor.</p>');
  }

  void test_classIsSealed_unnamed() async {
    var library = await bootPackageWithLibrary('''
sealed class C {
  /// Constructor.
  C();
}
''');
    var c = library.classes.named('C').constructors.first;
    expect(c.name, equals('C'));
    expect(c.isPublic, isFalse);
    expect(c.documentationAsHtml, '<p>Constructor.</p>');
  }

  void test_enum_named() async {
    var library = await bootPackageWithLibrary('''
enum E {
  one.named(), two.named();
  /// Constructor.
  const E.named();
}
''');
    var e = library.enums.named('E').constructors.first;
    expect(e.name, equals('E.named'));
    expect(e.isPublic, isFalse);
    expect(e.documentationAsHtml, '<p>Constructor.</p>');
  }

  void test_enum_unnamed() async {
    var library = await bootPackageWithLibrary('''
enum E {
  one(), two();
  /// Constructor.
  const E();
}
''');
    var e = library.enums.named('E').constructors.first;
    expect(e.name, equals('E'));
    expect(e.isPublic, isFalse);
    expect(e.documentationAsHtml, '<p>Constructor.</p>');
  }

  void test_extensionType_named() async {
    var library = await bootPackageWithLibrary('''
extension type ET(int it) {
  /// Constructor.
  ET.named(this.it);
}
''');
    var etNamed =
        library.extensionTypes.named('ET').constructors.named('ET.named');
    expect(etNamed.name, equals('ET.named'));
    expect(etNamed.isPublic, isTrue);
    expect(etNamed.documentationAsHtml, '<p>Constructor.</p>');
  }

  void test_extensionType_primaryNamed() async {
    var library = await bootPackageWithLibrary('''
extension type ET.named(int it) {}
''');
    var etNamed =
        library.extensionTypes.named('ET').constructors.named('ET.named');
    expect(etNamed.name, equals('ET.named'));
    expect(etNamed.isPublic, isTrue);
  }

  void test_extensionType_primaryUnnamed() async {
    var library = await bootPackageWithLibrary('''
extension type ET(int it) {}
''');
    var et = library.extensionTypes.named('ET').constructors.named('ET');
    expect(et.name, equals('ET'));
    expect(et.isPublic, isTrue);
  }

  void test_extensionType_unnamed() async {
    var library = await bootPackageWithLibrary('''
extension type ET.named(int it) {
  /// Constructor.
  ET(this.it);
}
''');
    var etNamed = library.extensionTypes.named('ET').constructors.named('ET');
    expect(etNamed.name, equals('ET'));
    expect(etNamed.isPublic, isTrue);
    expect(etNamed.documentationAsHtml, '<p>Constructor.</p>');
  }
}
