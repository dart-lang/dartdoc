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
  }

  void test_abstractSealed() async {
    var library = await bootPackageWithLibrary('''
abstract class A {}
sealed class B extends A {}
''');
    var Bclass = library.classes.named('B');
    expect(Bclass.fullkind, equals('sealed class')); // *not* sealed abstract
  }

  void test_inferredModifiers() async {
    var library = await bootPackageWithLibrary('''
base class A {}
sealed class B extends A {}
base class C extends B {}

interface class D {}
sealed class E extends D {}
interface class F extends E {}

final class G {}
sealed class H extends G {}
final class I extends H {}

class J {}
base mixin K on J {}
sealed class L extends J with K {}
base class M extends L {}
''');
    var Bclass = library.classes.named('B');
    var Cclass = library.classes.named('C');
    var Eclass = library.classes.named('E');
    var Fclass = library.classes.named('F');
    var Hclass = library.classes.named('H');
    var Iclass = library.classes.named('I');
    var Lclass = library.classes.named('L');
    var Mclass = library.classes.named('M');
    expect(Bclass.fullkind, equals('sealed class')); // *not* sealed base
    expect(Cclass.fullkind, equals('base class'));
    expect(Eclass.fullkind, equals('sealed class'));
    expect(Fclass.fullkind, equals('interface class'));
    expect(Hclass.fullkind, equals('sealed class'));
    expect(Iclass.fullkind, equals('final class'));
    expect(Lclass.fullkind, equals('sealed class'));
    expect(Mclass.fullkind, equals('base class'));
  }
}
