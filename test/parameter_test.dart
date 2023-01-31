// Copyright (c) 2022, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:dartdoc/src/model/model.dart';
import 'package:test/test.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

import 'dartdoc_test_base.dart';
import 'src/utils.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(ParameterTest);
  });
}

@reflectiveTest
class ParameterTest extends DartdocTestBase {
  @override
  String get libraryName => 'parameters';
  @override
  String get sdkConstraint => '>=2.17.0 <3.0.0';

  void test_requiredPositionalFieldFormalParameter() async {
    var library = await bootPackageWithLibrary('''
class A {
  int? f;
  A.requiredPositional(this.f);
}
''');
    var requiredPositional = library.constructor('A.requiredPositional');

    expect(requiredPositional.linkedParams, matchesCompressed(r'''
        <span class="parameter" id="requiredPositional-param-f">
          <span class="type-annotation">
            <a href=".*/dart-core/int-class\.html">int</a>\?
          </span>
          <span class="parameter-name">f</span>
        </span>
      '''));
  }

  void test_optionalPositionalFieldFormalParameter() async {
    var library = await bootPackageWithLibrary('''
class A {
  int? f;
  A.optionalPositional([this.f]);
}
''');
    var optionalPositional = library.constructor('A.optionalPositional');

    expect(optionalPositional.linkedParams, matchesCompressed(r'''
        <span class="parameter" id="optionalPositional-param-f">
          \[
          <span class="type-annotation">
            <a href=".*/dart-core/int-class\.html">int</a>\?
          </span>
          <span class="parameter-name">f</span>
          \]
        </span>
      '''));
  }

  void test_optionalPositionalFieldFormalParameterWithDefaultValue() async {
    var library = await bootPackageWithLibrary('''
class A {
  int? f;
  A.defaultValue([this.f = 0]);
}
''');
    var defaultValue = library.constructor('A.defaultValue');

    expect(defaultValue.linkedParams, matchesCompressed(r'''
        <span class="parameter" id="defaultValue-param-f">
          \[
          <span class="type-annotation">
            <a href=".*/dart-core/int-class\.html">int</a>\?
          </span>
          <span class="parameter-name">f</span>
          =
          <span class="default-value">0</span>
          \]
        </span>
      '''));
  }

  void test_requiredNamedFieldFormalParameter() async {
    var library = await bootPackageWithLibrary('''
class A {
  int? f;
  A.requiredNamed({required this.f});
}
''');
    var requiredNamed = library.constructor('A.requiredNamed');

    expect(requiredNamed.linkedParams, matchesCompressed(r'''
        <span class="parameter" id="requiredNamed-param-f">
          \{
          <span>required</span>
          <span class="type-annotation">
            <a href=".*/dart-core/int-class\.html">int</a>\?
          </span>
          <span class="parameter-name">f</span>
          \}
        </span>
      '''));
  }

  void test_namedFieldFormalParameter() async {
    var library = await bootPackageWithLibrary('''
class A {
  int? f;
  A.named({this.f});
}
''');
    var named = library.constructor('A.named');

    expect(named.linkedParams, matchesCompressed(r'''
        <span class="parameter" id="named-param-f">
          \{
          <span class="type-annotation">
            <a href=".*/dart-core/int-class\.html">int</a>\?
          </span>
          <span class="parameter-name">f</span>
          \}
        </span>
      '''));
  }

  void test_namedFieldFormalParameterWithDefaultValue() async {
    var library = await bootPackageWithLibrary('''
class A {
  int? f;
  A.namedWithDefault({this.f = 0});
}
''');
    var namedWithDefault = library.constructor('A.namedWithDefault');

    expect(namedWithDefault.linkedParams, matchesCompressed(r'''
        <span class="parameter" id="namedWithDefault-param-f">
          \{
          <span class="type-annotation">
            <a href=".*/dart-core/int-class\.html">int</a>\?
          </span>
          <span class="parameter-name">f</span>
          =
          <span class="default-value">0</span>
          \}
        </span>
      '''));
  }

  void test_requiredPositionalSuperParameter() async {
    var library = await bootPackageWithLibrary('''
class C {
  C.requiredPositional(int a);
}
class D extends C {
  D.requiredPositional(super.a) : super.requiredPositional();
}
''');
    var requiredPositional = library.constructor('D.requiredPositional');

    expect(requiredPositional.linkedParams, matchesCompressed(r'''
        <span class="parameter" id="requiredPositional-param-a">
          <span class="type-annotation">
            <a href=".*/dart-core/int-class\.html">int</a>
          </span>
          <span class="parameter-name">a</span>
        </span>
      '''));
  }

  void test_optionalPositionalSuperParameter() async {
    var library = await bootPackageWithLibrary('''
class C {
  C.optionalPositional([int? a]);
}
class D extends C {
  D.optionalPositional([super.a]) : super.optionalPositional();
}
''');
    var optionalPositional = library.constructor('D.optionalPositional');

    expect(optionalPositional.linkedParams, matchesCompressed(r'''
        <span class="parameter" id="optionalPositional-param-a">
          \[
          <span class="type-annotation">
            <a href=".*/dart-core/int-class\.html">int</a>\?
          </span>
          <span class="parameter-name">a</span>
          \]
        </span>
      '''));
  }

  void test_optionalPositionalSuperParameterWithDefault() async {
    var library = await bootPackageWithLibrary('''
class C {
  C.defaultValue([int a = 0]);
}
class D extends C {
  D.defaultValue([super.a = 0]) : super.defaultValue();
}
''');
    var defaultValue = library.constructor('D.defaultValue');

    expect(defaultValue.linkedParams, matchesCompressed(r'''
        <span class="parameter" id="defaultValue-param-a">
          \[
          <span class="type-annotation">
            <a href=".*/dart-core/int-class\.html">int</a>
          </span>
          <span class="parameter-name">a</span>
          =
          <span class="default-value">0</span>
          \]
        </span>
      '''));
  }

  void test_requiredNamedSuperParameters() async {
    var library = await bootPackageWithLibrary('''
class C {
  C.requiredNamed({required int a});
}
class D extends C {
  D.requiredNamed({required super.a}) : super.requiredNamed();
}
''');
    var requiredNamed = library.constructor('D.requiredNamed');

    expect(requiredNamed.linkedParams, matchesCompressed(r'''
        <span class="parameter" id="requiredNamed-param-a">
          \{
          <span>required</span>
          <span class="type-annotation">
            <a href=".*/dart-core/int-class\.html">int</a>
          </span>
          <span class="parameter-name">a</span>
          \}
        </span>
      '''));
  }

  void test_namedSuperParameter() async {
    var library = await bootPackageWithLibrary('''
class C {
  C.named({int? a});
}
class D extends C {
  D.named({super.a}) : super.named();
}
''');
    var named = library.constructor('D.named');

    expect(named.linkedParams, matchesCompressed(r'''
        <span class="parameter" id="named-param-a">
          \{
          <span class="type-annotation">
            <a href=".*/dart-core/int-class\.html">int</a>\?
          </span>
          <span class="parameter-name">a</span>
          \}
        </span>
      '''));
  }

  void test_namedSuperParameterWithDefault() async {
    var library = await bootPackageWithLibrary('''
class C {
  C.namedWithDefault({int a = 0});
}
class D extends C {
  D.namedWithDefault({int a = 0}) : super.namedWithDefault();
}
''');
    var namedWithDefault = library.constructor('D.namedWithDefault');

    expect(namedWithDefault.linkedParams, matchesCompressed(r'''
        <span class="parameter" id="namedWithDefault-param-a">
          \{
          <span class="type-annotation">
            <a href=".*/dart-core/int-class\.html">int</a>
          </span>
          <span class="parameter-name">a</span>
          =
          <span class="default-value">0</span>
          \}
        </span>
      '''));
  }

  void test_superConstructorParameterIsFieldFormal() async {
    var library = await bootPackageWithLibrary('''
class C {
  int f;
  C.fieldFormal(this.f);
}
class D extends C {
  D.fieldFormal(super.f) : super.fieldFormal();
}
''');
    var fieldFormal = library.constructor('D.fieldFormal');

    expect(fieldFormal.linkedParams, matchesCompressed(r'''
        <span class="parameter" id="fieldFormal-param-f">
          <span class="type-annotation">
            <a href=".*/dart-core/int-class\.html">int</a>
          </span>
          <span class="parameter-name">f</span>
        </span>
      '''));
  }

  void test_superConstructorParameterIsSuperParameter() async {
    var library = await bootPackageWithLibrary('''
class C {
  C.requiredPositional(int a);
}
class D extends C {
  D.requiredPositional(super.a) : super.requiredPositional();
}
class E extends D {
  E.superIsSuper(super.a) : super.requiredPositional();
}
''');
    var superIsSuper = library.constructor('E.superIsSuper');

    expect(superIsSuper.linkedParams, matchesCompressed(r'''
        <span class="parameter" id="superIsSuper-param-a">
          <span class="type-annotation">
            <a href=".*/dart-core/int-class\.html">int</a>
          </span>
          <span class="parameter-name">a</span>
        </span>
      '''));
  }

  void testParameterIsSubtypeOfSuperConstructorParameter() async {
    var library = await bootPackageWithLibrary('''
class C {
  C.positionalNum(num g);
}
class D extends C {
  D.positionalNum(int super.g) : super.positionalNum();
}
''');
    var positionalNum = library.constructor('D.positionalNum');

    expect(positionalNum.linkedParams, matchesCompressed(r'''
        <span class="parameter" id="positionalNum-param-g">
          <span class="type-annotation">
            <a href=".*/dart-core/int-class\.html">int</a>
          </span>
          <span class="parameter-name">g</span>
        </span>
      '''));
  }
}

extension on Library {
  Constructor constructor(String name) {
    var className = name.split('.').first;
    return classes
        .firstWhere((c) => c.name == className)
        .constructors
        .firstWhere((c) => c.name == name);
  }
}
