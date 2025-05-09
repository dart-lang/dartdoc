// Copyright (c) 2022, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:dartdoc/src/model/model.dart';
import 'package:dartdoc/src/model_utils.dart';
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

  void test_formalParameter_referenced() async {
    var library = await bootPackageWithLibrary('''
/// Text [p].
void f(int p) {}
''');
    var f = library.functions.named('f');
    // There is no link, but also no wrong link or crash.
    expect(f.documentationAsHtml, '<p>Text <code>p</code>.</p>');
  }

  void test_formalParameter_referenced_notShadowedElement() async {
    var library = await bootPackageWithLibrary('''
/// Text [p].
void f(int p) {}
var p = 0;
''');
    var f = library.functions.named('f');
    // There is no link, but also no wrong link or crash.
    expect(f.documentationAsHtml, '<p>Text <code>p</code>.</p>');
  }

  void test_formalParameter_referenced_notShadowedPrefix() async {
    var library = await bootPackageWithLibrary('''
import 'dart:async' as p;
/// Text [p].
void f(int p) {}
''');
    var f = library.functions.named('f');
    // There is no link, but also no wrong link or crash.
    expect(f.documentationAsHtml, '<p>Text <code>p</code>.</p>');
  }

  void test_formalParameter_referenced_wildcard() async {
    var library = await bootPackageWithLibrary('''
/// Text [_].
void f(int _) {}
''');
    var f = library.functions.named('f');
    // There is no link, but also no wrong link or crash.
    expect(f.documentationAsHtml, '<p>Text <code>_</code>.</p>');
  }

  void test_formalParameter_generic_method() async {
    var library = await bootPackageWithLibrary('''
class C {
  int one(int Function<T>(T)? f) {
    return 1;
  }
}
''');
    var one = library.method('C', 'one');
    expect(one.linkedParams, matchesCompressed(r'''
        <span class="parameter" id="one-param-f">
          <span class="type-annotation">
            <a href=".*/dart-core/int-class\.html">int</a>
          </span>
          <span class="parameter-name">f</span>
          &lt;<wbr>
          <span class="type-parameter">T</span>
          &gt;\(
          <span class="parameter" id="param-">
            <span class="type-annotation">T</span>
          </span>
          \)\?
        </span>
      '''));
  }

  void test_formalParameter_generic_topLevelFunction() async {
    var library = await bootPackageWithLibrary('''
int one(int Function<T>(T)? f) {
  return 1;
}
''');
    var one = library.functions.wherePublic.firstWhere((c) => c.name == 'one');
    expect(one.linkedParams, matchesCompressed(r'''
        <span class="parameter" id="one-param-f">
          <span class="type-annotation">
            <a href=".*/dart-core/int-class\.html">int</a>
          </span>
          <span class="parameter-name">f</span>
          &lt;<wbr>
          <span class="type-parameter">T</span>
          &gt;\(
          <span class="parameter" id="param-">
            <span class="type-annotation">T</span>
          </span>
          \)\?
        </span>
      '''));
  }

  void test_formalParameter_named() async {
    var library = await bootPackageWithLibrary('''
class A {
  int? f;
  A.named({this.f});
}
''');
    var named = library.constructor('A.named');

    expect(named.linkedParams, matchesCompressed(r'''
        \{
        <span class="parameter" id="named-param-f">
          <span class="type-annotation">
            <a href=".*/dart-core/int-class\.html">int</a>\?
          </span>
          <span class="parameter-name">f</span>
        </span>
        \}
      '''));
  }

  void test_formalParameter_named_defaultValue() async {
    var library = await bootPackageWithLibrary('''
class A {
  int? f;
  A.namedWithDefault({this.f = 0});
}
''');
    var namedWithDefault = library.constructor('A.namedWithDefault');

    expect(namedWithDefault.linkedParams, matchesCompressed(r'''
        \{
        <span class="parameter" id="namedWithDefault-param-f">
          <span class="type-annotation">
            <a href=".*/dart-core/int-class\.html">int</a>\?
          </span>
          <span class="parameter-name">f</span>
          =
          <span class="default-value">0</span>
        </span>
        \}
      '''));
  }

  void test_formalParameter_named_required() async {
    var library = await bootPackageWithLibrary('''
class A {
  int? f;
  A.requiredNamed({required this.f});
}
''');
    var requiredNamed = library.constructor('A.requiredNamed');

    expect(requiredNamed.linkedParams, matchesCompressed(r'''
        \{
        <span class="parameter" id="requiredNamed-param-f">
          <span>required</span>
          <span class="type-annotation">
            <a href=".*/dart-core/int-class\.html">int</a>\?
          </span>
          <span class="parameter-name">f</span>
        </span>
        \}
      '''));
  }

  void test_formalParameter_positional_optional() async {
    var library = await bootPackageWithLibrary('''
class A {
  int? f;
  A.optionalPositional([this.f]);
}
''');
    var optionalPositional = library.constructor('A.optionalPositional');

    expect(optionalPositional.linkedParams, matchesCompressed(r'''
        \[
        <span class="parameter" id="optionalPositional-param-f">
          <span class="type-annotation">
            <a href=".*/dart-core/int-class\.html">int</a>\?
          </span>
          <span class="parameter-name">f</span>
        </span>
        \]
      '''));
  }

  void test_formalParameter_positional_optional_defaultValue() async {
    var library = await bootPackageWithLibrary('''
class A {
  int? f;
  A.defaultValue([this.f = 0]);
}
''');
    var defaultValue = library.constructor('A.defaultValue');

    expect(defaultValue.linkedParams, matchesCompressed(r'''
        \[
        <span class="parameter" id="defaultValue-param-f">
          <span class="type-annotation">
            <a href=".*/dart-core/int-class\.html">int</a>\?
          </span>
          <span class="parameter-name">f</span>
          =
          <span class="default-value">0</span>
        </span>
        \]
      '''));
  }

  void test_formalParameter_positional_required() async {
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

  void test_fieldFormalParameter_referenced() async {
    var library = await bootPackageWithLibrary('''
class C {
  int p;
  /// Text [p].
  C(this.p);
}
''');
    var cConstructor = library.classes.named('C').constructors.named('C.new');
    // There is no link, but also no wrong link or crash.
    expect(cConstructor.documentationAsHtml, '<p>Text <code>p</code>.</p>');
  }

  void test_fieldFormalParameter_referenced_wildcard() async {
    var library = await bootPackageWithLibrary('''
class C {
  int _;
  /// Text [_].
  C(this._);
}
''');
    var cConstructor = library.classes.named('C').constructors.named('C.new');
    // There is no link, but also no wrong link or crash.
    expect(cConstructor.documentationAsHtml, '<p>Text <code>_</code>.</p>');
  }

  void test_superParameter_referenced_wildcard() async {
    var library = await bootPackageWithLibrary('''
class C {
  C(int _);
}
class D extends C {
  /// Text [_].
  D(super._) {}
}
''');
    var dConstructor = library.classes.named('D').constructors.named('D.new');
    // There is no link, but also no wrong link or crash.
    expect(dConstructor.documentationAsHtml, '<p>Text <code>_</code>.</p>');
  }

  void test_superParameter_fieldFormal() async {
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

  void test_superParameter_isSubtype() async {
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

  void test_superParameter_superParameter() async {
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

  void test_superParameter_named() async {
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
          <span class="type-annotation">
            <a href=".*/dart-core/int-class\.html">int</a>\?
          </span>
          <span class="parameter-name">a</span>
        </span>
        \}
      '''));
  }

  void test_superParameter_named_default() async {
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
          <span class="type-annotation">
            <a href=".*/dart-core/int-class\.html">int</a>
          </span>
          <span class="parameter-name">a</span>
          =
          <span class="default-value">0</span>
        </span>
        \}
      '''));
  }

  void test_superParameter_named_required() async {
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
          <span>required</span>
          <span class="type-annotation">
            <a href=".*/dart-core/int-class\.html">int</a>
          </span>
          <span class="parameter-name">a</span>
        </span>
        \}
      '''));
  }

  void test_superParameter_positional_optional() async {
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
          <span class="type-annotation">
            <a href=".*/dart-core/int-class\.html">int</a>\?
          </span>
          <span class="parameter-name">a</span>
        </span>
        \]
      '''));
  }

  void test_superParameter_positional_optional_default() async {
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
          <span class="type-annotation">
            <a href=".*/dart-core/int-class\.html">int</a>
          </span>
          <span class="parameter-name">a</span>
          =
          <span class="default-value">0</span>
        </span>
        \]
      '''));
  }

  void test_superParameter_positional_required() async {
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
}

extension on Library {
  Constructor constructor(String name) {
    var className = name.split('.').first;
    return classes
        .firstWhere((c) => c.name == className)
        .constructors
        .firstWhere((c) => c.name == name);
  }

  Method method(String className, String methodName) => classes
      .firstWhere((clas) => clas.name == className)
      .declaredMethods
      .firstWhere((method) => method.name == methodName);
}
