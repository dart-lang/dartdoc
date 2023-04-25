// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:test/test.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

import '../dartdoc_test_base.dart';
import '../src/utils.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(HideConstantImplementationsTest);
  });
}

@reflectiveTest
class HideConstantImplementationsTest extends DartdocTestBase {
  @override
  String get libraryName => 'hide_constant_implementations';
  @override
  String get sdkConstraint => '>=2.18.0 <4.0.0';

  void test_noDirectiveAllows() async {
    var library = await bootPackageWithLibrary('''
class A {
  static const int aConst = 12;
}
''');
    var aConst = library.classes.named('A').constantFields.named('aConst');
    expect(aConst.hasConstantValueForDisplay, isTrue);
  }

  void test_directiveDenies() async {
    var library = await bootPackageWithLibrary('''
/// Some documentation.
/// {@hideConstantImplementations}
class A {
  static const int aConst = 12;
}
''');
    var aClass = library.classes.named('A');
    var aConst = aClass.constantFields.named('aConst');
    expect(aConst.hasConstantValueForDisplay, isFalse);
    expect(aClass.documentation, equals('Some documentation.\n'));
  }

  void test_libraryDirectiveImpactsTopLevelOnly() async {
    var library = await bootPackageWithLibrary('''
class A {
  static const int aConst = 12;
}

static const aTopLevelConst = 37;
''', libraryPreamble: '''
/// Some documentation.
/// {@hideConstantImplementations}
''');
    var aConst = library.classes.named('A').constantFields.named('aConst');
    expect(aConst.hasConstantValueForDisplay, isTrue);
    var aTopLevelConst = library.constants.named('aTopLevelConst');
    expect(aTopLevelConst.hasConstantValueForDisplay, isFalse);
    expect(library.documentation, equals('Some documentation.\n'));
  }
}