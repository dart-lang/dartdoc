// Copyright (c) 2022, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:test/test.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

import 'dartdoc_test_base.dart';
import 'src/utils.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(ConstantValuesWithConstructorTearoffsTest);
    if (namedArgumentsAnywhereAllowed) {
      defineReflectiveTests(ConstantValuesWithNamedArgumentsAnywhereTest);
    }
  });
}

// TODO(srawlins): Sort members after a code review for the
// test_reflective_loader migration.

@reflectiveTest
class ConstantValuesWithConstructorTearoffsTest extends DartdocTestBase {
  @override
  String get libraryName => 'constructor_tearoffs';

  void test_nonGenericFunctionReference() async {
    var library = await bootPackageWithLibrary('''
void func() {}
const aFunc = func;
''');
    var aFuncConstant = library.constants.named('aFunc');
    expect(aFuncConstant.constantValue, equals('func'));
  }

  void test_genericFunctionReference() async {
    var library = await bootPackageWithLibrary('''
void funcTypeParams<T extends String, U extends num>(
    T something, U different) {}
const aFuncParams = funcTypeParams;
''');
    var aFuncParamsConstant = library.constants.named('aFuncParams');
    expect(aFuncParamsConstant.constantValue, equals('funcTypeParams'));
  }

  void test_genericFunctionReferenceWithTypeArgs() async {
    var library = await bootPackageWithLibrary('''
void funcTypeParams<T extends String, U extends num>(
    T something, U different) {}
const aFuncWithArgs = funcTypeParams<String, int>;
''');
    var aFuncWithArgs = library.constants.named('aFuncWithArgs');
    expect(aFuncWithArgs.constantValue,
        equals('funcTypeParams&lt;String, int&gt;'));
  }

  void test_namedConstructorReference() async {
    var library = await bootPackageWithLibrary('''
class F<T> {
  F.alternative();
}
const aTearOffNamedConstructor = F.alternative;
''');
    var aTearOffNamedConstructor =
        library.constants.named('aTearOffNamedConstructor');
    expect(aTearOffNamedConstructor.constantValue, equals('F.alternative'));
  }

  void test_namedConstructorReferenceWithTypeArgs() async {
    var library = await bootPackageWithLibrary('''
class F<T> {
  F.alternative();
}
const aTearOffNamedConstructorArgs = F<int>.alternative;
''');
    var aTearOffNamedConstructorArgs =
        library.constants.named('aTearOffNamedConstructorArgs');
    expect(aTearOffNamedConstructorArgs.constantValue,
        equals('F&lt;int&gt;.alternative'));
  }

  void test_unnamedConstructorReference() async {
    var library = await bootPackageWithLibrary('''
class F<T> {
  F();
}
const aTearOffUnnamedConstructor = F.new;
''');
    var aTearOffUnnamedConstructor =
        library.constants.named('aTearOffUnnamedConstructor');
    expect(aTearOffUnnamedConstructor.constantValue, equals('F.new'));
  }

  void test_unnamedConstructorReferenceWithTypeArgs() async {
    var library = await bootPackageWithLibrary('''
class F<T> {
  F();
}
const aTearOffUnnamedConstructorArgs = F<String>.new;
''');
    var aTearOffUnnamedConstructorArgs =
        library.constants.named('aTearOffUnnamedConstructorArgs');
    expect(aTearOffUnnamedConstructorArgs.constantValue,
        equals('F&lt;String&gt;.new'));
  }

  void test_unnamedTypedefConstructorReference() async {
    var library = await bootPackageWithLibrary('''
class F<T> {
  F();
}
const aTearOffUnnamedConstructorTypedef = Fstring.new;
''');
    var aTearOffUnnamedConstructorTypedef =
        library.constants.named('aTearOffUnnamedConstructorTypedef');
    expect(
        aTearOffUnnamedConstructorTypedef.constantValue, equals('Fstring.new'));
  }

  void test_unnamedTypedefConstructorReferenceWithTypeArgs() async {
    var library = await bootPackageWithLibrary('''
class F<T> {
  F();
}
const aTearOffUnnamedConstructorArgsTypedef = Ft<String>.new;
''');
    var aTearOffUnnamedConstructorArgsTypedef =
        library.constants.named('aTearOffUnnamedConstructorArgsTypedef');
    expect(aTearOffUnnamedConstructorArgsTypedef.constantValue,
        equals('Ft&lt;String&gt;.new'));
  }
}

@reflectiveTest
class ConstantValuesWithNamedArgumentsAnywhereTest extends DartdocTestBase {
  @override
  String get libraryName => 'constant_values';

  @override
  String get sdkConstraint => '>=2.17.0 <3.0.0';

  void test_namedParametersInConstInvocationValue_specifiedLast() async {
    var library = await bootPackageWithLibrary('''
class C {
  const C(int a, int b, {required int c, required int d});
}
const p = C(1, 2, c: 3, d: 4);
''');
    var pConst = library.constants.named('p');

    expect(pConst.constantValue,
        equals('<a href="$linkPrefix/C/C.html">C</a>(1, 2, c: 3, d: 4)'));
  }

  void test_namedParametersInConstInvocationValue_specifiedAnywhere() async {
    var library = await bootPackageWithLibrary('''
class C {
  const C(int a, int b, {required int c, required int d});
}
const q = C(1, c: 2, 3, d: 4);
''');
    var qConst = library.constants.named('q');

    expect(qConst.constantValue,
        equals('<a href="$linkPrefix/C/C.html">C</a>(1, c: 2, 3, d: 4)'));
  }

  void test_namedParametersInConstInvocationValue_specifiedFirst() async {
    var library = await bootPackageWithLibrary('''
class C {
  const C(int a, int b, {required int c, required int d});
}
const r = C(c: 1, d: 2, 3, 4);
''');
    var rConst = library.constants.named('r');

    expect(rConst.constantValue,
        equals('<a href="$linkPrefix/C/C.html">C</a>(c: 1, d: 2, 3, 4)'));
  }
}
