// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:test/test.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

import 'dartdoc_test_base.dart';
import 'src/utils.dart';

void main() {
  defineReflectiveSuite(() {
    if (classModifiersAllowed) {
      defineReflectiveTests(ClassModifiersTest);
    }
  });
}

@reflectiveTest
class ClassModifiersTest extends DartdocTestBase {
  @override
  String get libraryName => 'class_modifiers';

  @override
  String get sdkConstraint => '>=3.0.0-0.0-dev <4.0.0';

  @override
  List<String> get experiments => ['class-modifiers', 'sealed-class'];

  /// From the table in the class modifiers feature specification.
  void test_tableOfModifiers() async {
    var library = await bootPackageWithLibrary('''
class A {}
base class B {}
interface class C {}
final class D {}
sealed class E {}
abstract class F {}
abstract base class G {}
abstract interface class H {}
abstract final class I {}
mixin class J {}
base mixin class K {}
abstract mixin class L {}
abstract base mixin class M {}
mixin N {}
base mixin O {}
interface mixin P {}
final mixin Q {}
sealed mixin R {}
''');
  // This almost seems worth a map and loop, but leaving expanded for now for
  // test clarity.
  var Aclass = library.classes.named('A');
  var Bclass = library.classes.named('B');
  var Cclass = library.classes.named('C');
  var Dclass = library.classes.named('D');
  var Eclass = library.classes.named('E');
  var Fclass = library.classes.named('F');
  var Gclass = library.classes.named('G');
  var Hclass = library.classes.named('H');
  var Iclass = library.classes.named('I');
  var Jclass = library.classes.named('J');
  var Kclass = library.classes.named('K');
  var Lclass = library.classes.named('L');
  var Mclass = library.classes.named('M');
  var Nmixin = library.mixins.named('N');
  var Omixin = library.mixins.named('O');
  var Pmixin = library.mixins.named('P');
  var Qmixin = library.mixins.named('Q');
  var Rmixin = library.mixins.named('R');
  expect(Aclass.fullkind, equals('class'));
  expect(Bclass.fullkind, equals('base class'));
  expect(Cclass.fullkind, equals('interface class'));
  expect(Dclass.fullkind, equals('final class'));
  expect(Eclass.fullkind, equals('sealed class'));
  expect(Fclass.fullkind, equals('abstract class'));
  expect(Gclass.fullkind, equals('abstract base class'));
  expect(Hclass.fullkind, equals('abstract interface class'));
  expect(Iclass.fullkind, equals('abstract final class'));
  expect(Jclass.fullkind, equals('mixin class'));
  expect(Kclass.fullkind, equals('base mixin class'));
  expect(Lclass.fullkind, equals('abstract mixin class'));
  expect(Mclass.fullkind, equals('abstract base mixin class'));
  expect(Nmixin.fullkind, equals('mixin'));
  expect(Omixin.fullkind, equals('base mixin'));
  expect(Pmixin.fullkind, equals('interface mixin'));
  expect(Qmixin.fullkind, equals('final mixin'));
  expect(Rmixin.fullkind, equals('sealed mixin'));
  }
}