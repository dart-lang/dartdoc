// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:dartdoc/src/model/model.dart';
import 'package:test/test.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

import 'dartdoc_test_base.dart';
import 'src/utils.dart';

extension on InheritingContainer {
  String languageFeatureChips() =>
      displayedLanguageFeatures.map((l) => l.name).join(' ');
}

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
    expect(Aclass.languageFeatureChips(), equals(''));
    expect(Bclass.languageFeatureChips(), equals('base'));
    expect(Cclass.languageFeatureChips(), equals('interface'));
    expect(Dclass.languageFeatureChips(), equals('final'));
    expect(Eclass.languageFeatureChips(), equals('sealed'));
    expect(Fclass.languageFeatureChips(), equals('abstract'));
    expect(Gclass.languageFeatureChips(), equals('abstract base'));
    expect(Hclass.languageFeatureChips(), equals('abstract interface'));
    expect(Iclass.languageFeatureChips(), equals('abstract final'));
    expect(Jclass.languageFeatureChips(), equals('mixin'));
    expect(Kclass.languageFeatureChips(), equals('base mixin'));
    expect(Lclass.languageFeatureChips(), equals('abstract mixin'));
    expect(Mclass.languageFeatureChips(), equals('abstract base mixin'));
    expect(Nmixin.languageFeatureChips(), equals(''));
    expect(Omixin.languageFeatureChips(), equals('base'));
  }

  void test_abstractSealed() async {
    var library = await bootPackageWithLibrary('''
abstract class A {}
sealed class B extends A {}
''');
    var Bclass = library.classes.named('B');
    expect(Bclass.languageFeatureChips(),
        equals('sealed')); // *not* sealed abstract
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
    expect(
        Bclass.languageFeatureChips(), equals('sealed')); // *not* sealed base
    expect(Cclass.languageFeatureChips(), equals('base'));
    expect(Eclass.languageFeatureChips(), equals('sealed'));
    expect(Fclass.languageFeatureChips(), equals('interface'));
    expect(Hclass.languageFeatureChips(), equals('sealed'));
    expect(Iclass.languageFeatureChips(), equals('final'));
    expect(Lclass.languageFeatureChips(), equals('sealed'));
    expect(Mclass.languageFeatureChips(), equals('base'));
  }
}
