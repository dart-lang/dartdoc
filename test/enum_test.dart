// Copyright (c) 2022, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:dartdoc/src/model/model.dart';
import 'package:dartdoc/src/render/enum_field_renderer.dart';
import 'package:test/test.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

import 'dartdoc_test_base.dart';
import 'src/utils.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(EnumTest);
    defineReflectiveTests(EnhancedEnumTest);
  });
}

// TODO(srawlins): Sort members after a code review for the
// test_reflective_loader migration.

@reflectiveTest
class EnumTest extends DartdocTestBase {
  @override
  String get libraryName => 'enums';

  void test_publicEnums() async {
    var library = await bootPackageWithLibrary('enum E { one, two, three }');
    expect(library.publicEnums, isNotEmpty);
  }

  void test_fullyQualifiedName() async {
    var library = await bootPackageWithLibrary('enum E { one, two, three }');
    var eEnum = library.enums.named('E');

    expect(eEnum.fullyQualifiedName, equals('enums.E'));
  }

  void test_linkedName() async {
    var library = await bootPackageWithLibrary('enum E { one, two, three }');
    var eEnum = library.enums.named('E');

    expect(eEnum.linkedName, equals('<a href="$linkPrefix/E.html">E</a>'));
  }

  void test_enclosingElement() async {
    var library = await bootPackageWithLibrary('enum E { one, two, three }');
    var eEnum = library.enums.named('E');

    expect(eEnum.enclosingElement.name, 'enums');
  }

  void test_publicEnumValues() async {
    var library = await bootPackageWithLibrary('enum E { one, two, three }');
    var eEnum = library.enums.named('E');

    expect(eEnum.publicEnumValues, hasLength(3));
  }

  void test_valuesConstant() async {
    var library = await bootPackageWithLibrary('enum E { one, two, three }');
    var valuesField = library.enums.named('E').constantFields.named('values');
    expect(valuesField.documentation, startsWith('A constant List'));
  }

  void test_valuesConstant_canBeReferenced() async {
    var library = await bootPackageWithLibrary('''
enum E { one, two, three }

/// Reference to [E.values].
class C {}
''');
    var cClass = library.classes.named('C');
    expect(
      cClass.documentationAsHtml,
      '<p>Reference to '
      '<a href="$linkPrefix/E/values-constant.html">E.values</a>.</p>',
    );
  }

  void test_annotatedValue() async {
    var library = await bootPackageWithLibrary('''
enum E {
  @deprecated
  one,
  two, three
}

''');
    var one = library.enums.named('E').publicEnumValues.named('one');
    expect(one.hasAnnotations, true);
    expect(one.annotations, hasLength(1));
    expect(one.isDeprecated, true);
  }

  void test_value_canBeReferenced() async {
    var library = await bootPackageWithLibrary('''
enum E { one, two, three }

/// Reference to [E.one].
class C {}
''');
    var cClass = library.classes.named('C');
    expect(cClass.documentationAsHtml,
        '<p>Reference to <a href="$linkPrefix/E.html">E.one</a>.</p>');
  }

  void test_index_canBeReferenced() async {
    var library = await bootPackageWithLibrary('''
enum E { one, two, three }

/// Reference to [E.index].
class C {}
''');
    var cClass = library.classes.named('C');
    expect(
      cClass.documentationAsHtml,
      '<p>Reference to '
      '<a href="https://api.dart.dev/stable/2.16.0/dart-core/Enum/index.html">E.index</a>.</p>',
    );
  }

  void test_index_isLinked() async {
    var library = await bootPackageWithLibrary('enum E { one, two, three }');
    var eEnum = library.enums.named('E');

    expect(eEnum.instanceFields.map((f) => f.name), contains('index'));
    expect(
      eEnum.instanceFields.named('index').linkedName,
      '<a href="https://api.dart.dev/stable/2.16.0/dart-core/Enum/index.html">index</a>',
    );
  }

  void test_toString() async {
    var library = await bootPackageWithLibrary('enum E { one, two, three }');
    var eEnum = library.enums.named('E');
    var toStringMethod = eEnum.instanceMethods.named('toString');
    expect(toStringMethod.characterLocation, isNotNull);
    expect(toStringMethod.characterLocation.toString(),
        equals(eEnum.characterLocation.toString()));
  }

  void test_value_linksToItsAnchor() async {
    var library = await bootPackageWithLibrary('enum E { one, two, three }');
    var oneValue =
        library.enums.named('E').publicEnumValues.named('one') as EnumField;
    expect(oneValue.linkedName, '<a href="$linkPrefix/E.html#one">one</a>');
    expect(oneValue.constantValue,
        equals(EnumFieldRendererHtml().renderValue(oneValue)));
  }

  void test_values_haveIndices() async {
    var library = await bootPackageWithLibrary('enum E { one, two, three }');
    var oneValue =
        library.enums.named('E').publicEnumValues.named('one') as EnumField;
    var twoValue =
        library.enums.named('E').publicEnumValues.named('two') as EnumField;
    var threeValue =
        library.enums.named('E').publicEnumValues.named('three') as EnumField;

    expect(oneValue.constantValue, equals('const E(0)'));
    expect(twoValue.constantValue, equals('const E(1)'));
    expect(threeValue.constantValue, equals('const E(2)'));
  }

  void test_hasAnnotations() async {
    var library = await bootPackageWithLibrary('''
class C {
  const C();
}

@C()
enum E { one, two, three }
''');
    var eEnum = library.enums.named('E');

    expect(eEnum.hasAnnotations, true);
    expect(eEnum.annotations, hasLength(1));
    expect(eEnum.annotations.single.linkedName,
        '<a href="$linkPrefix/C-class.html">C</a>');
  }

  void test_hasDocComment() async {
    var library = await bootPackageWithLibrary('''
/// Doc comment for [E].
enum E { one, two, three }
''');
    var eEnum = library.enums.named('E');

    expect(eEnum.hasDocumentationComment, true);
    expect(eEnum.documentationComment, '/// Doc comment for [E].');
  }

  void test_value_hasDocComment() async {
    var library = await bootPackageWithLibrary('''
enum E {
  /// Doc comment for [E.one].
  one,
  two,
  three
}
''');
    var one = library.enums.named('E').publicEnumValues.named('one');

    expect(one.hasDocumentationComment, true);
    expect(one.documentationComment, '/// Doc comment for [E.one].');
  }
}

@reflectiveTest
class EnhancedEnumTest extends DartdocTestBase {
  @override
  String get libraryName => 'enums';

  @override
  String get sdkConstraint => '>=2.17.0 <3.0.0';

  void test_linkedGenericParameters() async {
    var library = await bootPackageWithLibrary('''
class C<T> {}

enum E<T> implements C<T> { one, two, three; }
''');
    var eEnum = library.enums.named('E');

    expect(
      eEnum.linkedGenericParameters,
      '<span class="signature">&lt;<wbr><span class="type-parameter">T</span>&gt;</span>',
    );
  }

  void test_methodsAreDocumented() async {
    // TODO(srawlins): As all supported Dart is >=2.15.0, this test can just
    // be a "method" test rather than an "enum" test.
    var library = await bootPackageWithLibrary('''
enum E {
  one, two, three;

  /// Doc comment.
  int method1(String p) => 7;
}
''');
    var method1 = library.enums.named('E').instanceMethods.named('method1');

    expect(method1.isInherited, false);
    expect(method1.isOperator, false);
    expect(method1.isStatic, false);
    expect(method1.isCallable, true);
    expect(method1.isDocumented, true);
    expect(
      method1.linkedName,
      '<a href="$linkPrefix/E/method1.html">method1</a>',
    );
    expect(method1.documentationComment, '/// Doc comment.');
  }

  void test_operatorsAreDocumented() async {
    // TODO(srawlins): As all supported Dart is >=2.15.0, this test can just
    // be an "operator" test rather than an "enum" test.
    var library = await bootPackageWithLibrary('''
enum E {
  one, two, three;

  /// Greater than.
  bool operator >(E other) => index > other.index;

  /// Less than.
  bool operator <(E other) => index < other.index;
}
''');
    var greaterThan =
        library.enums.named('E').instanceOperators.named('operator >');

    expect(greaterThan.isInherited, false);
    expect(greaterThan.isOperator, true);
    expect(greaterThan.isStatic, false);
    expect(greaterThan.isCallable, true);
    expect(greaterThan.isDocumented, true);
    expect(
      greaterThan.linkedName,
      '<a href="$linkPrefix/E/operator_greater.html">operator ></a>',
    );
    expect(greaterThan.documentationComment, '/// Greater than.');

    var lessThan =
        library.enums.named('E').instanceOperators.named('operator <');

    expect(lessThan.isInherited, false);
    expect(lessThan.isOperator, true);
    expect(lessThan.isStatic, false);
    expect(lessThan.isCallable, true);
    expect(lessThan.isDocumented, true);
    expect(
      lessThan.linkedName,
      // TODO(srawlins): I think this smells... escape HTML.
      '<a href="$linkPrefix/E/operator_less.html">operator <</a>',
    );
    expect(lessThan.documentationComment, '/// Less than.');
  }

  void test_interfacesAreLinked() async {
    var library = await bootPackageWithLibrary('''
class C<T> {}
class D {}

enum E<T> implements C<T>, D { one, two, three; }
''');
    var eEnum = library.enums.named('E');

    expect(eEnum.interfaces, hasLength(2));
    expect(eEnum.interfaces.map((i) => i.name), equals(['C', 'D']));
  }

  void test_mixedInTypesAreLinked() async {
    var library = await bootPackageWithLibrary('''
mixin M<T> {}
mixin N {}

enum E<T> with M<T>, N { one, two, three; }
''');
    var eEnum = library.enums.named('E');

    expect(eEnum.mixedInTypes, hasLength(2));
    expect(eEnum.mixedInTypes.map((i) => i.name), equals(['M', 'N']));
  }

  void test_staticMethodsAreDocumented() async {
    // TODO(srawlins): As all supported Dart is >=2.15.0, this test can just
    // be a "static method" test rather than an "enum" test.
    var library = await bootPackageWithLibrary('''
enum E {
  one, two, three;

  /// Doc comment.
  static int method1(String p) => 7;
}
''');
    var method1 = library.enums.named('E').staticMethods.named('method1');

    expect(method1.isInherited, false);
    expect(method1.isOperator, false);
    expect(method1.isStatic, true);
    expect(method1.isCallable, true);
    expect(method1.isDocumented, true);
    expect(
      method1.linkedName,
      '<a href="$linkPrefix/E/method1.html">method1</a>',
    );
    expect(method1.documentationComment, '/// Doc comment.');
  }

  void test_staticFieldsAreDocumented() async {
    // TODO(srawlins): As all supported Dart is >=2.15.0, this test can just
    // be a "static field" test rather than an "enum" test.
    var library = await bootPackageWithLibrary('''
enum E {
  one, two, three;

  /// Doc comment.
  static int field1 = 1;
}
''');
    var method1 = library.enums.named('E').staticFields.named('field1');

    expect(method1.isInherited, false);
    expect(method1.isStatic, true);
    expect(method1.isDocumented, true);
    expect(
      method1.linkedName,
      '<a href="$linkPrefix/E/field1.html">field1</a>',
    );
    expect(method1.documentationComment, '/// Doc comment.');
  }

  void test_staticGettersAreDocumented() async {
    // TODO(srawlins): As all supported Dart is >=2.15.0, this test can just
    // be a "static getter" test rather than an "enum" test.
    var library = await bootPackageWithLibrary('''
enum E {
  one, two, three;

  /// Doc comment.
  static int get getter1 => 1;
}
''');
    var method1 = library.enums.named('E').staticFields.named('getter1');

    expect(method1.isInherited, false);
    expect(method1.isStatic, true);
    expect(method1.isDocumented, true);
    expect(
      method1.linkedName,
      '<a href="$linkPrefix/E/getter1.html">getter1</a>',
    );
    expect(method1.documentationComment, 'Doc comment.');
  }

  void test_instanceFieldsAreDocumented() async {
    // TODO(srawlins): As all supported Dart is >=2.15.0, this test can just
    // be a "fields" test rather than an "enum" test.
    var library = await bootPackageWithLibrary('''
enum E {
  one, two, three;

  /// Doc comment.
  final int field1 = 1;
}
''');
    var field1 = library.enums.named('E').instanceFields.named('field1');

    expect(field1.isInherited, false);
    expect(field1.isStatic, false);
    expect(field1.isDocumented, true);
    expect(
      field1.linkedName,
      '<a href="$linkPrefix/E/field1.html">field1</a>',
    );
    expect(field1.documentationComment, '/// Doc comment.');
  }

  void test_instanceSettersAreDocumented() async {
    // TODO(srawlins): As all supported Dart is >=2.15.0, this test can just
    // be a "setters" test rather than an "enum" test.
    var library = await bootPackageWithLibrary('''
enum E {
  one, two;

  /// A setter.
  set x(int value) {}
}
''');
    var xSetter = library.enums.named('E').instanceAccessors.named('x=');

    expect(xSetter.isGetter, false);
    expect(xSetter.isSetter, true);
    expect(xSetter.isPublic, true);
    expect(xSetter.documentationComment, 'A setter.');
  }

  void test_constructorsAreDocumented() async {
    // TODO(srawlins): As all supported Dart is >=2.15.0, this test can just
    // be a "constructors" test rather than an "enum" test.
    var library = await bootPackageWithLibrary('''
enum E {
  one.named(1),
  two.named(2);

  final int x;

  /// A named constructor.
  const E.named(this.x);
}
''');
    var namedConstructor =
        library.enums.named('E').constructors.named('E.named');

    expect(namedConstructor.isFactory, false);
    expect(namedConstructor.fullyQualifiedName, 'enums.E.named');
    expect(namedConstructor.nameWithGenerics, 'E.named');
    expect(namedConstructor.documentationComment, '/// A named constructor.');
  }

  void test_valuesHaveAConstantValueImplementation() async {
    var library = await bootPackageWithLibrary('''
enum E {
  one.named(1),
  two.named(2);

  final int x;

  /// A named constructor.
  const E.named(this.x);
}

enum F { one, two }
''');
    var eOneValue = library.enums.named('E').publicEnumValues.named('one');
    expect(eOneValue.constantValueTruncated, 'E.named(1)');

    var eTwoValue = library.enums.named('E').publicEnumValues.named('two');
    expect(eTwoValue.constantValueTruncated, 'E.named(2)');

    var fOneValue = library.enums.named('F').publicEnumValues.named('one');
    expect(fOneValue.constantValueTruncated, 'F()');

    var fTwoValue = library.enums.named('F').publicEnumValues.named('two');
    expect(fTwoValue.constantValueTruncated, 'F()');
  }

  void test_namedConstructorCanBeReferenced() async {
    // TODO(srawlins): As all supported Dart is >=2.15.0, this test can just
    // be a "constructors" test rather than an "enum" test.
    var library = await bootPackageWithLibrary('''
enum E {
  one.named(1),
  two.named(2);

  const E.named(int x);
}

/// Reference to [E.named].
class C {}
''');
    var cClass = library.classes.named('C');
    expect(
      cClass.documentationAsHtml,
      '<p>Reference to <a href="$linkPrefix/E/E.named.html">E.named</a>.</p>',
    );
  }

  void test_instanceMethodsCanBeReferenced() async {
    // TODO(srawlins): As all supported Dart is >=2.15.0, this test can just
    // be a "methods" test rather than an "enum" test.
    var library = await bootPackageWithLibrary('''
enum E {
  one, two;

  /// Doc comment.
  static int method1(String p) => 7;
}

/// Reference to [E.method1].
class C {}
''');
    var cClass = library.classes.named('C');
    expect(
      cClass.documentationAsHtml,
      '<p>Reference to <a href="$linkPrefix/E/method1.html">E.method1</a>.</p>',
    );
  }

  void test_instanceGettersCanBeReferenced() async {
    // TODO(srawlins): As all supported Dart is >=2.15.0, this test can just
    // be a "getters" test rather than an "enum" test.
    var library = await bootPackageWithLibrary('''
enum E {
  one, two;

  /// A getter.
  int get x => 1;
}

/// Reference to [E.x].
class C {}
''');
    var cClass = library.classes.named('C');
    expect(
      cClass.documentationAsHtml,
      '<p>Reference to <a href="$linkPrefix/E/x.html">E.x</a>.</p>',
    );
  }

  void test_instanceSettersCanBeReferenced() async {
    // TODO(srawlins): As all supported Dart is >=2.15.0, this test can just
    // be a "setters" test rather than an "enum" test.
    var library = await bootPackageWithLibrary('''
enum E {
  one, two;

  /// A setter.
  set x(int value) {}
}

/// Reference to [E.x].
class C {}
''');
    var cClass = library.classes.named('C');
    expect(
      cClass.documentationAsHtml,
      '<p>Reference to <a href="$linkPrefix/E/x.html">E.x</a>.</p>',
    );
  }

  void test_staticMethodsCanBeReferenced() async {
    // TODO(srawlins): As all supported Dart is >=2.15.0, this test can just
    // be a "static methods" test rather than an "enum" test.
    var library = await bootPackageWithLibrary('''
enum E {
  one, two;

  static void m() {}
}

/// Reference to [E.m].
class C {}
''');
    var cClass = library.classes.named('C');
    expect(
      cClass.documentationAsHtml,
      '<p>Reference to <a href="$linkPrefix/E/m.html">E.m</a>.</p>',
    );
  }

  void test_staticFieldsCanBeReferenced() async {
    // TODO(srawlins): As all supported Dart is >=2.15.0, this test can just
    // be a "static fields" test rather than an "enum" test.
    var library = await bootPackageWithLibrary('''
enum E {
  one, two;

  static int f = 1;
}

/// Reference to [E.f].
class C {}
''');
    var cClass = library.classes.named('C');
    expect(
      cClass.documentationAsHtml,
      '<p>Reference to <a href="$linkPrefix/E/f.html">E.f</a>.</p>',
    );
  }
}
