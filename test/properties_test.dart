// Copyright (c) 2026, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:dartdoc/src/model/accessor.dart';
import 'package:dartdoc/src/model/attribute.dart';
import 'package:dartdoc/src/model/field.dart';
import 'package:dartdoc/src/model/library.dart';
import 'package:test/test.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

import 'dartdoc_test_base.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(PropertiesTest);
  });
}

@reflectiveTest
class PropertiesTest extends DartdocTestBase {
  @override
  final libraryName = 'properties';

  void test_field() async {
    var library = await bootPackageWithLibrary('''
class C {
  /// Comment.
  int x = 0;
}
''');
    var x = library.instanceField('C', 'x');
    expect(x.name, equals('x'));
    expect(x.fullyQualifiedName, 'properties.C.x');
    expect(x.isPublic, isTrue);
    expect(x.documentationAsHtml, '<p>Comment.</p>');
  }

  void test_field_nodoc() async {
    var library = await bootPackageWithLibrary('''
class C {
  /// @nodoc Comment.
  int x = 0;
}
''');
    var x = library.instanceField('C', 'x');
    expect(x.name, equals('x'));
    expect(x.fullyQualifiedName, 'properties.C.x');
    expect(x.isPublic, isFalse);
  }

  void test_field_overridesField() async {
    var library = await bootPackageWithLibrary('''
class C {
  /// Comment.
  int x = 0;
}

class D extends C {
  @override
  /// Comment 2.
  int x = 1;
}
''');
    var x = library.instanceField('D', 'x');
    expect(x.fullyQualifiedName, 'properties.D.x');
    expect(x.documentationAsHtml, '<p>Comment 2.</p>');
  }

  void test_field_overridesField_inheritedDocComment() async {
    var library = await bootPackageWithLibrary('''
class C {
  /// Comment.
  int x = 0;
}

class D extends C {
  @override
  int x = 1;
}
''');
    var x = library.instanceField('D', 'x');
    expect(x.documentationAsHtml, '<p>Comment.</p>');
  }

  void test_field_overridesGetter_withDocComment() async {
    var library = await bootPackageWithLibrary('''
class C {
  /// Comment.
  int get x => 0;
}

class D extends C {
  @override
  int x = 1;
}
''');
    var x = library.instanceField('D', 'x');
    expect(x.documentationAsHtml, '<p>Comment.</p>');
  }

  void test_field_overridesSetter_withDocComment() async {
    var library = await bootPackageWithLibrary('''
class C {
  /// Comment.
  set x(int value) {}
}

class D extends C {
  @override
  int x = 1;
}
''');
    var x = library.instanceField('D', 'x');
    // TODO(srawlins): This doesn't seem right.
    expect(x.documentationAsHtml, '');
  }

  void test_field_overridesField_inheritedImplementation() async {
    var library = await bootPackageWithLibrary('''
class C {
  /// Comment.
  int x = 0;
}

class D extends C {}
''');
    var x = library.instanceField('D', 'x');
    expect(x.documentationAsHtml, '<p>Comment.</p>');
  }

  void test_field_overridesGetterSetterPair() async {
    var library = await bootPackageWithLibrary('''
class C {
  /// Comment.
  int get x => 0;

  /// Comment 2.
  set x(int value) {}
}

class D extends C {
  @override
  int x = 1;
}
''');
    var x = library.instanceField('D', 'x');
    expect(x.documentationAsHtml, '<p>Comment.</p>');
  }

  void test_getter() async {
    var library = await bootPackageWithLibrary('''
class C {
  /// Comment.
  int get x => 0;
}
''');
    var x = library.instanceGetter('C', 'x');
    expect(x.name, equals('x'));
    expect(x.fullyQualifiedName, 'properties.C.x');
    expect(x.isPublic, isTrue);
    expect(x.documentationAsHtml, '<p>Comment.</p>');
  }

  void test_getter_nodoc_preservedOnSyntheticField() async {
    var library = await bootPackageWithLibrary('''
class C {
  /// @nodoc Comment.
  int get x => 0;
}
''');
    var x = library.instanceField('C', 'x');
    expect(x.fullyQualifiedName, 'properties.C.x');
    expect(x.isPublic, isFalse);
    expect(x.documentationAsHtml, '');
  }

  void test_getter_overridesGetter() async {
    var library = await bootPackageWithLibrary('''
class C {
  /// Comment.
  int get x => 0;
}

class D extends C {
  /// Comment 2.
  int get x => 0;
}
''');
    var x = library.instanceGetter('D', 'x');
    expect(x.fullyQualifiedName, 'properties.D.x');
    expect(x.documentationAsHtml, '<p>Comment 2.</p>');
  }

  void test_getter_overridesGetter_withNoDoc() async {
    var library = await bootPackageWithLibrary('''
class C {
  /// @nodoc Comment.
  int get x => 0;
}

class D extends C {
  /// Comment 2.
  int get x => 0;
}
''');
    var x = library.instanceField('D', 'x');
    expect(x.fullyQualifiedName, 'properties.D.x');
    expect(x.isPublic, true);
    expect(x.hasPublicGetter, true);
    expect(x.readOnly, true);
    expect(x.documentationAsHtml, '<p>Comment 2.</p>');
  }

  void test_getter_overridesField_withDocComment() async {
    var library = await bootPackageWithLibrary('''
class C {
  /// Comment.
  int x = 0;
}

class D extends C {
  int get x => 0;
}
''');
    var x = library.instanceGetter('D', 'x');
    expect(x.fullyQualifiedName, 'properties.D.x');
    expect(x.documentationAsHtml, '<p>Comment.</p>');
  }

  void test_getter_overridesField_withNodoc() async {
    var library = await bootPackageWithLibrary('''
class C {
  /// @nodoc Comment.
  int x = 0;
}

class D extends C {
  /// Comment 2.
  int get x => 0;
}
''');
    var x = library.instanceField('D', 'x');
    expect(x.fullyQualifiedName, 'properties.D.x');
    expect(x.isPublic, true);
    expect(x.readOnly, true);
    expect(x.documentationAsHtml, '<p>Comment 2.</p>');
    expect(x.annotations, isNot(contains(Attribute.inheritedSetter)));
  }

  void test_setter() async {
    var library = await bootPackageWithLibrary('''
class C {
  /// Comment.
  set x(int value) {}
}
''');
    var x = library.instanceSetter('C', 'x=');
    expect(x.name, equals('x='));
    expect(x.fullyQualifiedName, 'properties.C.x=');
    expect(x.isPublic, isTrue);
    expect(x.documentationAsHtml, '<p>Comment.</p>');
  }

  void test_setter_nodoc_preservedOnSyntheticField() async {
    var library = await bootPackageWithLibrary('''
class C {
  /// @nodoc Comment.
  set x(int value) {}
}
''');
    var x = library.instanceField('C', 'x');
    expect(x.fullyQualifiedName, 'properties.C.x');
    expect(x.isPublic, isFalse);
    expect(x.documentationAsHtml, '');
  }

  void test_setter_overridesSetter() async {
    var library = await bootPackageWithLibrary('''
class C {
  /// Comment.
  set x(int value) {}
}

class D extends C {
  /// Comment 2.
  set x(int value) {}
}
''');
    var x = library.instanceSetter('D', 'x=');
    expect(x.fullyQualifiedName, 'properties.D.x=');
    expect(x.documentationAsHtml, '<p>Comment 2.</p>');
  }

  void test_setter_overridesField() async {
    var library = await bootPackageWithLibrary('''
class C {
  /// Comment.
  int x = 0;
}

class D extends C {
  /// Comment 2.
  set x(int value) {}
}
''');
    var x = library.instanceSetter('D', 'x=');
    expect(x.fullyQualifiedName, 'properties.D.x=');
    // TODO(srawlins): Should this include the getter part from the super-field?
    expect(x.documentationAsHtml, '<p>Comment 2.</p>');
  }

  void test_getterSetterPair() async {
    var library = await bootPackageWithLibrary('''
class C {
  /// Comment.
  int get x => 0;

  /// Comment 2.
  set x(int value) {}
}
''');
    // We can access the synthetic field created by the getter/setter pair.
    var x = library.instanceField('C', 'x');
    expect(x.fullyQualifiedName, 'properties.C.x');
    // Only the comment from the getter is used.
    expect(x.documentationAsHtml, '<p>Comment.</p>');
  }

  void test_getterSetterPair_getterHasNoDocComment() async {
    var library = await bootPackageWithLibrary('''
class C {
  int get x => 0;

  /// Comment 2.
  set x(int value) {}
}
''');
    var x = library.instanceField('C', 'x');
    expect(x.fullyQualifiedName, 'properties.C.x');
    // TODO(srawlins): Should this include the getter part from the super-field?
    expect(x.documentationAsHtml, '<p>Comment 2.</p>');
  }

  void test_getterSetterPair_overridesField() async {
    var library = await bootPackageWithLibrary('''
class C {
  /// Comment.
  int x = 0;
}

class D extends C {
  @override
  int get x => 0;

  @override
  set x(int value) {}
}
''');
    var x = library.instanceField('D', 'x');
    expect(x.fullyQualifiedName, 'properties.D.x');
    expect(x.documentationAsHtml, '<p>Comment.</p>');
  }

  // TODO(srawlins): Test split inheritance.
  // TODO(srawlins): Test top-level fields, getters, setters.
}

extension on Library {
  Field instanceField(String className, String fieldName) => classes
      .firstWhere((c) => c.name == className)
      .instanceFields
      .firstWhere((field) => field.name == fieldName);

  Accessor instanceGetter(String className, String getterName) => classes
      .firstWhere((c) => c.name == className)
      .instanceAccessors
      .firstWhere((getter) => getter.name == getterName);

  Accessor instanceSetter(String className, String setterName) => classes
      .firstWhere((c) => c.name == className)
      .instanceAccessors
      .firstWhere((setter) => setter.name == setterName);
}
