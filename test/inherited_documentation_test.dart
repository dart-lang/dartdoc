// Copyright (c) 2026, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:test/test.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

import 'dartdoc_test_base.dart';
import 'src/utils.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(InheritedDocumentationTest);
  });
}

/// Tests for the "Documentation inherited from" note that appears in the HTML
/// for members that override a member with documentation and do not have their
/// own documentation.
@reflectiveTest
class InheritedDocumentationTest extends DartdocTestBase {
  @override
  String get libraryName => 'inherited';

  void test_ownDocumentation_isNotInherited() async {
    var library = await bootPackageWithLibrary('''
class A {
  /// Docs on A.m.
  void m() {}
}
''');
    var aM = library.classes.named('A').instanceMethods.named('m');
    expect(aM.hasInheritedDocumentation, isFalse);
    expect(aM.inheritedDocumentationFrom, isEmpty);
  }

  void test_overrideWithoutDocumentation_isInheritedFromBase() async {
    var library = await bootPackageWithLibrary('''
class A {
  /// Docs on A.m.
  void m() {}
}

class B extends A {
  @override
  void m() {}
}
''');
    var bM = library.classes.named('B').instanceMethods.named('m');
    expect(bM.documentationAsHtml, contains('Docs on A.m.'));
    expect(bM.hasInheritedDocumentation, isTrue);
    var aM = library.classes.named('A').instanceMethods.named('m');
    expect(bM.inheritedDocumentationFrom, [aM]);
    expect(aM.linkedQualifiedName, '<a href="$linkPrefix/A/m.html">A.m</a>');
  }

  void test_overrideWithDocumentation_isNotInherited() async {
    var library = await bootPackageWithLibrary('''
class A {
  /// Docs on A.m.
  void m() {}
}

class B extends A {
  /// Docs on B.m.
  @override
  void m() {}
}
''');
    var bM = library.classes.named('B').instanceMethods.named('m');
    expect(bM.hasInheritedDocumentation, isFalse);
  }

  void test_overrideTwoLevelsDown_isInheritedFromDefiningClass() async {
    var library = await bootPackageWithLibrary('''
class A {
  /// Docs on A.m.
  void m() {}
}

class B extends A {
  @override
  void m() {}
}

class C extends B {
  @override
  void m() {}
}
''');
    var cM = library.classes.named('C').instanceMethods.named('m');
    expect(cM.hasInheritedDocumentation, isTrue);
    expect(cM.inheritedDocumentationFrom.map((e) => e.qualifiedDisplayName),
        ['A.m']);
  }

  void test_fieldWithOwnAccessorDocumentation_isNotInherited() async {
    var library = await bootPackageWithLibrary('''
class A {
  /// Docs on the getter.
  int get x => 0;

  /// Docs on the setter.
  set x(int value) {}
}
''');
    var x = library.classes.named('A').instanceFields.named('x');
    expect(x.documentationAsHtml, contains('Docs on the getter.'));
    expect(x.hasInheritedDocumentation, isFalse);
  }

  void test_overriddenGetter_isInheritedFromBaseGetter() async {
    var library = await bootPackageWithLibrary('''
class A {
  /// Docs on A.x.
  int get x => 0;
}

class B extends A {
  @override
  int get x => 1;
}
''');
    var bX = library.classes.named('B').instanceFields.named('x');
    expect(bX.documentationAsHtml, contains('Docs on A.x.'));
    expect(bX.hasInheritedDocumentation, isTrue);
    var source = bX.inheritedDocumentationFrom.single;
    expect(source.qualifiedDisplayName, 'A.x');
    expect(
        source.linkedQualifiedName, '<a href="$linkPrefix/A/x.html">A.x</a>');
  }

  void test_implementedInterfaceMember_isInheritedFromInterface() async {
    var library = await bootPackageWithLibrary('''
abstract class I {
  /// Docs on I.m.
  void m();
}

class A implements I {
  @override
  void m() {}
}
''');
    var aM = library.classes.named('A').instanceMethods.named('m');
    expect(aM.documentationAsHtml, contains('Docs on I.m.'));
    expect(aM.hasInheritedDocumentation, isTrue);
    expect(aM.inheritedDocumentationFrom.map((e) => e.qualifiedDisplayName),
        ['I.m']);
  }

  void test_noDocumentationAnywhere_isNotInherited() async {
    var library = await bootPackageWithLibrary('''
class A {
  void m() {}
}

class B extends A {
  @override
  void m() {}
}
''');
    var bM = library.classes.named('B').instanceMethods.named('m');
    expect(bM.hasDocumentation, isFalse);
    expect(bM.hasInheritedDocumentation, isFalse);
  }
}
