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
}
