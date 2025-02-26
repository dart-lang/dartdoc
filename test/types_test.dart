// Copyright (c) 2025, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:dartdoc/src/model/model.dart';
import 'package:dartdoc/src/render/parameter_renderer.dart';
import 'package:test/test.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

import 'dartdoc_test_base.dart';
import 'src/utils.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(TypesTest);
  });
}

@reflectiveTest
class TypesTest extends DartdocTestBase {
  @override
  String get libraryName => 'types';

  void test_setter_functionTypedParameter() async {
    var library = await bootPackageWithLibrary('''
class C {
  set f(p(int a, List<int> b)) {}
}
''');
    var f = library.field('C', 'f');
    expect(f.modelType.linkedName, matchesCompressed('''
        dynamic Function
        <span class="signature">\\(
          <span class="parameter" id="p-param-a">
            <span class="type-annotation">
              <a href="$dartCoreUrlPrefix/int-class.html">int</a>
            </span>
            <span class="parameter-name">a</span>,
          </span>
          <span class="parameter" id="p-param-b">
            <span class="type-annotation">
              <a href="$dartCoreUrlPrefix/List-class.html">List</a>
              <span class="signature">&lt;<wbr>
                <span class="type-parameter">
                  <a href="$dartCoreUrlPrefix/int-class.html">int</a>
                </span>&gt;
              </span>
            </span>
            <span class="parameter-name">b</span>
          </span>\\)
        </span>
      '''));
  }

  void test_field_substitutedTypes() async {
    var library = await bootPackageWithLibrary('''
class C<T> {
  List<T>? f;
}
class D extends C<int> {}
''');
    var f = library.field('D', 'f');
    expect(f.modelType.linkedName, matchesCompressed('''
        <a href="$dartCoreUrlPrefix/List-class.html">List</a>
        <span class="signature">&lt;<wbr>
          <span class="type-parameter">
            <a href="$dartCoreUrlPrefix/int-class.html">int</a>
          </span>&gt;
        </span>
      '''));
  }

  void test_getter_substitutedTypes() async {
    var library = await bootPackageWithLibrary('''
class C<T> {
  List<T> get f => [];
}
class D extends C<int> {}
''');
    var f = library.field('D', 'f').getter!;
    expect(f.modelType.returnType.linkedName, matchesCompressed('''
        <a href="$dartCoreUrlPrefix/List-class.html">List</a>
        <span class="signature">&lt;<wbr>
          <span class="type-parameter">
            <a href="$dartCoreUrlPrefix/int-class.html">int</a>
          </span>&gt;
        </span>
      '''));
  }

  void test_setterParameter_substitutedTypes() async {
    var library = await bootPackageWithLibrary('''
class C<T> {
  set f(List<T> p) {}
}
class D extends C<int> {}
''');
    var f = library.field('D', 'f').setter!;
    expect(f.parameters.first.modelType.linkedName, matchesCompressed('''
        <a href="$dartCoreUrlPrefix/List-class.html">List</a>
        <span class="signature">&lt;<wbr>
          <span class="type-parameter">
            <a href="$dartCoreUrlPrefix/int-class.html">int</a>
          </span>&gt;
        </span>
      '''));
  }

  void test_methodReturnType() async {
    var library = await bootPackageWithLibrary('''
abstract class C {
  List<int> m();
}
''');
    var m = library.method('C', 'm');
    expect(m.modelType.returnType.linkedName, matchesCompressed('''
        <a href="$dartCoreUrlPrefix/List-class.html">List</a>
        <span class="signature">&lt;<wbr>
          <span class="type-parameter">
            <a href="$dartCoreUrlPrefix/int-class.html">int</a>
          </span>&gt;
        </span>
      '''));
  }

  void test_methodReturnType_substitutedTypes() async {
    var library = await bootPackageWithLibrary('''
abstract class C<T> {
  List<T> m();
}
class D extends C<int> {}
''');
    var m = library.method('D', 'm');
    expect(m.modelType.returnType.linkedName, matchesCompressed('''
        <a href="$dartCoreUrlPrefix/List-class.html">List</a>
        <span class="signature">&lt;<wbr>
          <span class="type-parameter">
            <a href="$dartCoreUrlPrefix/int-class.html">int</a>
          </span>&gt;
        </span>
      '''));
  }

  void test_methodReturnType_parameterizedTypedef() async {
    var library = await bootPackageWithLibrary('''
typedef String TD<T>(T p);
abstract class C {
  TD<int> m();
}
''');
    var m = library.method('C', 'm');
    expect(m.modelType.returnType.linkedName, matchesCompressed('''
        <a href="${htmlBasePlaceholder}types/TD.html">TD</a>
        <span class="signature">&lt;<wbr>
          <span class="type-parameter">
            <a href="$dartCoreUrlPrefix/int-class.html">int</a>
          </span>&gt;
        </span>
      '''));
  }

  void test_methodReturnType_substitutedTypes_parameterizedTypedef() async {
    var library = await bootPackageWithLibrary('''
typedef String TD<T>(T p);
abstract class C<T> {
  TD<T> m();
}
class D extends C<int> {}
''');
    var m = library.method('D', 'm');
    expect(m.modelType.returnType.linkedName, matchesCompressed('''
        <a href="${htmlBasePlaceholder}types/TD.html">TD</a>
        <span class="signature">&lt;<wbr>
          <span class="type-parameter">
            <a href="$dartCoreUrlPrefix/int-class.html">int</a>
          </span>&gt;
        </span>
      '''));
  }

  void test_operatorTypes_substitutedTypes() async {
    var library = await bootPackageWithLibrary('''
abstract class C<T> {
  List<T> operator +(List<T> p);
}
class D extends C<int> {}
''');
    var plus = library.operator('D', 'operator +');
    expect(plus.modelType.returnType.linkedName, matchesCompressed('''
        <a href="$dartCoreUrlPrefix/List-class.html">List</a>
        <span class="signature">&lt;<wbr>
          <span class="type-parameter">
            <a href="$dartCoreUrlPrefix/int-class.html">int</a>
          </span>&gt;
        </span>
      '''));
    var renderedParameter =
        ParameterRendererHtml().renderLinkedParams(plus.parameters);
    expect(renderedParameter, matchesCompressed('''
        <a href="$dartCoreUrlPrefix/List-class.html">List</a>
        <span class="signature">&lt;<wbr>
          <span class="type-parameter">
            <a href="$dartCoreUrlPrefix/int-class.html">int</a>
          </span>&gt;
        </span>
      '''));
  }
}

extension on Library {
  Field field(String className, String methodName) => classes
      .firstWhere((c) => c.name == className)
      .instanceFields
      .firstWhere((field) => field.name == methodName);

  Method method(String className, String methodName) => classes
      .firstWhere((clas) => clas.name == className)
      .instanceMethods
      .firstWhere((method) => method.name == methodName);

  Operator operator(String className, String methodName) => classes
      .firstWhere((clas) => clas.name == className)
      .instanceOperators
      .firstWhere((method) => method.name == methodName);
}
