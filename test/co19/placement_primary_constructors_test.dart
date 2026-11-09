// Copyright (c) 2026, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// @assertion Doc comments are associated with the declaration that immediately
/// follows them. They are only considered valid when placed directly before the
/// following types of declarations:
/// ...
/// - Constructors (including factory and named constructors)
/// @author sgrekhov22@gmail.com
library;

import 'package:test/test.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

import '../src/utils.dart';
import 'co19_test_base.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(PlacementPrimaryConstructorsTest);
  });
}

@reflectiveTest
class PlacementPrimaryConstructorsTest extends Co19TestBase {
  /// Check that doc comments placed before a class with a primary constructor
  /// are associated with the class and not with the constructor.
  void test_beforeClassWithPrimaryConstructor1() async {
    var library = await bootPackageWithLibrary('''
/// Line 1
class C1(int x);

/// Line 2
class const C2(final int x);

/// Line 3
class C3.named(int x);

/// Line 4
class C4<T>(T x);

/// Line 5
abstract class C5();
''');
    var c1 = library.classes.named('C1');
    expect(c1.documentation, 'Line 1');
    var c1c = c1.constructors.named('C1.new');
    expect(c1c.documentation, isEmpty);
    var c2 = library.classes.named('C2');
    expect(c2.documentation, 'Line 2');
    var c2c = c2.constructors.named('C2.new');
    expect(c2c.documentation, isEmpty);
    var c3 = library.classes.named('C3');
    expect(c3.documentation, 'Line 3');
    var c3c = c3.constructors.named('C3.named');
    expect(c3c.documentation, isEmpty);
    var c4 = library.classes.named('C4');
    expect(c4.documentation, 'Line 4');
    var c4c = c4.constructors.named('C4.new');
    expect(c4c.documentation, isEmpty);
    var c5 = library.classes.named('C5');
    expect(c5.documentation, 'Line 5');
    var c5c = c5.constructors.named('C5.new');
    expect(c5c.documentation, isEmpty);
  }

  /// Check that doc comments placed inside a header of a class with a primary
  /// constructor are not associated with the class or with the constructor.
  void test_insideClassPrimaryConstructorHeader1() async {
    var library = await bootPackageWithLibrary('''
class /// Line 1
  C1(int x);

class /// Line 2
  const C2(final int x);

class const /// Line 3
  C3(final int x);

class C4 /// Line 4
  (int x);

class C5<T> /// Line 5
  (T x);

class C6 /// Line 6
  .named(int x);

class C7. /// Line 7
  named(int x);

abstract class /// Line 8
  C8();

abstract /// Line 9
  class C9();
''');
    var c1 = library.classes.named('C1');
    expect(c1.documentation, isEmpty);
    var c1c = c1.constructors.named('C1.new');
    expect(c1c.documentation, isEmpty);
    var c2 = library.classes.named('C2');
    expect(c2.documentation, isEmpty);
    var c2c = c2.constructors.named('C2.new');
    expect(c2c.documentation, isEmpty);
    var c3 = library.classes.named('C3');
    expect(c3.documentation, isEmpty);
    var c3c = c3.constructors.named('C3.new');
    expect(c3c.documentation, isEmpty);
    var c4 = library.classes.named('C4');
    expect(c4.documentation, isEmpty);
    var c4c = c4.constructors.named('C4.new');
    expect(c4c.documentation, isEmpty);
    var c5 = library.classes.named('C5');
    expect(c5.documentation, isEmpty);
    var c5c = c5.constructors.named('C5.new');
    expect(c5c.documentation, isEmpty);
    var c6 = library.classes.named('C6');
    expect(c6.documentation, isEmpty);
    var c6c = c6.constructors.named('C6.named');
    expect(c6c.documentation, isEmpty);
    var c7 = library.classes.named('C7');
    expect(c7.documentation, isEmpty);
    var c7c = c7.constructors.named('C7.named');
    expect(c7c.documentation, isEmpty);
    var c8 = library.classes.named('C8');
    expect(c8.documentation, isEmpty);
    var c8c = c8.constructors.named('C8.new');
    expect(c8c.documentation, isEmpty);
    var c9 = library.classes.named('C9');
    expect(c9.documentation, isEmpty);
    var c9c = c9.constructors.named('C9.new');
    expect(c9c.documentation, isEmpty);
  }

  /// Check that doc comments placed before a body of a primary constructor of
  /// a class are associated with the constructor and not with the class.
  void test_beforeClassPrimaryConstructorBody1() async {
    var library = await bootPackageWithLibrary('''
class C1(int x) {
  /// Line 1
  this; /// Line 2
  /// Line 3

  /// Line 4
  void foo() {}
}

class C2(int x) {
  /// Line 1
  this { /// Line 2
  /// Line 3
  }
  /// Line 4

  /// Line 5
  void foo() {}
}

class C3(int x) {
  /// Line 1
  this : assert(x > 0);
}

class C4.named(int x) {
  /// Line 1
  this;
}

class const C5(final int x) {
  /// Line 1
  this;
}

/// Line 1
class C6(int x) {
  /// Line 2
  this;
}

class /// Line 1
  C7(int x) {
  /// Line 2
  this;
}
''');
    var c1 = library.classes.named('C1');
    expect(c1.documentation, isEmpty);
    var c1c = c1.constructors.named('C1.new');
    expect(c1c.documentation, 'Line 1');
    var c2 = library.classes.named('C2');
    expect(c2.documentation, isEmpty);
    var c2c = c2.constructors.named('C2.new');
    expect(c2c.documentation, 'Line 1');
    var c3 = library.classes.named('C3');
    expect(c3.documentation, isEmpty);
    var c3c = c3.constructors.named('C3.new');
    expect(c3c.documentation, 'Line 1');
    var c4 = library.classes.named('C4');
    expect(c4.documentation, isEmpty);
    var c4c = c4.constructors.named('C4.named');
    expect(c4c.documentation, 'Line 1');
    var c5 = library.classes.named('C5');
    expect(c5.documentation, isEmpty);
    var c5c = c5.constructors.named('C5.new');
    expect(c5c.documentation, 'Line 1');
    var c6 = library.classes.named('C6');
    expect(c6.documentation, 'Line 1');
    var c6c = c6.constructors.named('C6.new');
    expect(c6c.documentation, 'Line 2');
    var c7 = library.classes.named('C7');
    expect(c7.documentation, isEmpty);
    var c7c = c7.constructors.named('C7.new');
    expect(c7c.documentation, 'Line 2');
    var c1foo = c1.instanceMethods.named('foo');
    expect(c1foo.documentation, '''
Line 2
Line 3
Line 4''');
    var c2foo = c2.instanceMethods.named('foo');
    expect(c2foo.documentation, '''
Line 4
Line 5''');
  }

  /// Check that block-based doc comments placed before a class with a primary
  /// constructor are associated with the class and not with the constructor.
  void test_beforeClassWithPrimaryConstructor2() async {
    var library = await bootPackageWithLibrary('''
/** Line 1
 */
class C1(int x);

/** Line 2
 */
class const C2(final int x);

/** Line 3
 */
class C3.named(int x);

/** Line 4
 */
class C4<T>(T x);

/** Line 5
 */
abstract class C5();
''');
    var c1 = library.classes.named('C1');
    expect(c1.documentation, 'Line 1');
    var c1c = c1.constructors.named('C1.new');
    expect(c1c.documentation, isEmpty);
    var c2 = library.classes.named('C2');
    expect(c2.documentation, 'Line 2');
    var c2c = c2.constructors.named('C2.new');
    expect(c2c.documentation, isEmpty);
    var c3 = library.classes.named('C3');
    expect(c3.documentation, 'Line 3');
    var c3c = c3.constructors.named('C3.named');
    expect(c3c.documentation, isEmpty);
    var c4 = library.classes.named('C4');
    expect(c4.documentation, 'Line 4');
    var c4c = c4.constructors.named('C4.new');
    expect(c4c.documentation, isEmpty);
    var c5 = library.classes.named('C5');
    expect(c5.documentation, 'Line 5');
    var c5c = c5.constructors.named('C5.new');
    expect(c5c.documentation, isEmpty);
  }

  /// Check that block-based doc comments placed inside a header of a class
  /// with a primary constructor are not associated with the class or with the
  /// constructor.
  void test_insideClassPrimaryConstructorHeader2() async {
    var library = await bootPackageWithLibrary('''
class /** Line 1 */
  C1(int x);

class /** Line 2 */
  const C2(final int x);

class const /** Line 3 */
  C3(final int x);

class C4 /** Line 4 */
  (int x);

class C5<T> /** Line 5 */
  (T x);

class C6 /** Line 6 */
  .named(int x);

class C7. /** Line 7 */
  named(int x);

abstract class /** Line 8 */
  C8();

abstract /** Line 9 */
  class C9();
''');
    var c1 = library.classes.named('C1');
    expect(c1.documentation, isEmpty);
    var c1c = c1.constructors.named('C1.new');
    expect(c1c.documentation, isEmpty);
    var c2 = library.classes.named('C2');
    expect(c2.documentation, isEmpty);
    var c2c = c2.constructors.named('C2.new');
    expect(c2c.documentation, isEmpty);
    var c3 = library.classes.named('C3');
    expect(c3.documentation, isEmpty);
    var c3c = c3.constructors.named('C3.new');
    expect(c3c.documentation, isEmpty);
    var c4 = library.classes.named('C4');
    expect(c4.documentation, isEmpty);
    var c4c = c4.constructors.named('C4.new');
    expect(c4c.documentation, isEmpty);
    var c5 = library.classes.named('C5');
    expect(c5.documentation, isEmpty);
    var c5c = c5.constructors.named('C5.new');
    expect(c5c.documentation, isEmpty);
    var c6 = library.classes.named('C6');
    expect(c6.documentation, isEmpty);
    var c6c = c6.constructors.named('C6.named');
    expect(c6c.documentation, isEmpty);
    var c7 = library.classes.named('C7');
    expect(c7.documentation, isEmpty);
    var c7c = c7.constructors.named('C7.named');
    expect(c7c.documentation, isEmpty);
    var c8 = library.classes.named('C8');
    expect(c8.documentation, isEmpty);
    var c8c = c8.constructors.named('C8.new');
    expect(c8c.documentation, isEmpty);
    var c9 = library.classes.named('C9');
    expect(c9.documentation, isEmpty);
    var c9c = c9.constructors.named('C9.new');
    expect(c9c.documentation, isEmpty);
  }

  /// Check that block-based doc comments placed before a body of a primary
  /// constructor of a class are associated with the constructor and not with
  /// the class.
  void test_beforeClassPrimaryConstructorBody2() async {
    var library = await bootPackageWithLibrary('''
class C1(int x) {
  /** Line 1
   */
  this; /** Line 2 */
  /** Line 3
   */

  /** Line 4
   */
  void foo() {}
}

class C2(int x) {
  /** Line 1
   */
  this { /** Line 2 */
  /** Line 3
   */
  }
  /** Line 4
   */

  /** Line 5
   */
  void foo() {}
}

class C3(int x) {
  /** Line 1
   */
  this : assert(x > 0);
}

class C4.named(int x) {
  /** Line 1
   */
  this;
}

class const C5(final int x) {
  /** Line 1
   */
  this;
}

/** Line 1
 */
class C6(int x) {
  /** Line 2
   */
  this;
}

class /** Line 1 */
  C7(int x) {
  /** Line 2
   */
  this;
}
''');
    var c1 = library.classes.named('C1');
    expect(c1.documentation, isEmpty);
    var c1c = c1.constructors.named('C1.new');
    expect(c1c.documentation, 'Line 1');
    var c2 = library.classes.named('C2');
    expect(c2.documentation, isEmpty);
    var c2c = c2.constructors.named('C2.new');
    expect(c2c.documentation, 'Line 1');
    var c3 = library.classes.named('C3');
    expect(c3.documentation, isEmpty);
    var c3c = c3.constructors.named('C3.new');
    expect(c3c.documentation, 'Line 1');
    var c4 = library.classes.named('C4');
    expect(c4.documentation, isEmpty);
    var c4c = c4.constructors.named('C4.named');
    expect(c4c.documentation, 'Line 1');
    var c5 = library.classes.named('C5');
    expect(c5.documentation, isEmpty);
    var c5c = c5.constructors.named('C5.new');
    expect(c5c.documentation, 'Line 1');
    var c6 = library.classes.named('C6');
    expect(c6.documentation, 'Line 1');
    var c6c = c6.constructors.named('C6.new');
    expect(c6c.documentation, 'Line 2');
    var c7 = library.classes.named('C7');
    expect(c7.documentation, isEmpty);
    var c7c = c7.constructors.named('C7.new');
    expect(c7c.documentation, 'Line 2');
    var c1foo = c1.instanceMethods.named('foo');
    expect(c1foo.documentation, 'Line 4');
    var c2foo = c2.instanceMethods.named('foo');
    expect(c2foo.documentation, 'Line 5');
  }

  /// Check that doc comments placed before a mixin class with a primary
  /// constructor are associated with the mixin class and not with the
  /// constructor.
  void test_beforeMixinClassWithPrimaryConstructor1() async {
    var library = await bootPackageWithLibrary('''
/// Line 1
mixin class M1();

/// Line 2
mixin class const M2();

/// Line 3
mixin class M3.named();

/// Line 4
mixin class M4<T>();

/// Line 5
abstract mixin class M5();

/// Line 6
base mixin class M6();
''');
    var m1 = library.classes.named('M1');
    expect(m1.documentation, 'Line 1');
    var m1c = m1.constructors.named('M1.new');
    expect(m1c.documentation, isEmpty);
    var m2 = library.classes.named('M2');
    expect(m2.documentation, 'Line 2');
    var m2c = m2.constructors.named('M2.new');
    expect(m2c.documentation, isEmpty);
    var m3 = library.classes.named('M3');
    expect(m3.documentation, 'Line 3');
    var m3c = m3.constructors.named('M3.named');
    expect(m3c.documentation, isEmpty);
    var m4 = library.classes.named('M4');
    expect(m4.documentation, 'Line 4');
    var m4c = m4.constructors.named('M4.new');
    expect(m4c.documentation, isEmpty);
    var m5 = library.classes.named('M5');
    expect(m5.documentation, 'Line 5');
    var m5c = m5.constructors.named('M5.new');
    expect(m5c.documentation, isEmpty);
    var m6 = library.classes.named('M6');
    expect(m6.documentation, 'Line 6');
    var m6c = m6.constructors.named('M6.new');
    expect(m6c.documentation, isEmpty);
  }

  /// Check that doc comments placed inside a header of a mixin class with a
  /// primary constructor are not associated with the mixin class or with the
  /// constructor.
  void test_insideMixinClassPrimaryConstructorHeader1() async {
    var library = await bootPackageWithLibrary('''
mixin /// Line 1
  class M1();

mixin class /// Line 2
  M2();

mixin class /// Line 3
  const M3();

mixin class const /// Line 4
  M4();

mixin class M5 /// Line 5
  ();

mixin class M6<T> /// Line 6
  ();

mixin class M7 /// Line 7
  .named();

mixin class M8. /// Line 8
  named();

abstract /// Line 9
  mixin class M9();

abstract mixin class /// Line 10
  M10();

base /// Line 11
  mixin class M11();
''');
    var m1 = library.classes.named('M1');
    expect(m1.documentation, isEmpty);
    var m1c = m1.constructors.named('M1.new');
    expect(m1c.documentation, isEmpty);
    var m2 = library.classes.named('M2');
    expect(m2.documentation, isEmpty);
    var m2c = m2.constructors.named('M2.new');
    expect(m2c.documentation, isEmpty);
    var m3 = library.classes.named('M3');
    expect(m3.documentation, isEmpty);
    var m3c = m3.constructors.named('M3.new');
    expect(m3c.documentation, isEmpty);
    var m4 = library.classes.named('M4');
    expect(m4.documentation, isEmpty);
    var m4c = m4.constructors.named('M4.new');
    expect(m4c.documentation, isEmpty);
    var m5 = library.classes.named('M5');
    expect(m5.documentation, isEmpty);
    var m5c = m5.constructors.named('M5.new');
    expect(m5c.documentation, isEmpty);
    var m6 = library.classes.named('M6');
    expect(m6.documentation, isEmpty);
    var m6c = m6.constructors.named('M6.new');
    expect(m6c.documentation, isEmpty);
    var m7 = library.classes.named('M7');
    expect(m7.documentation, isEmpty);
    var m7c = m7.constructors.named('M7.named');
    expect(m7c.documentation, isEmpty);
    var m8 = library.classes.named('M8');
    expect(m8.documentation, isEmpty);
    var m8c = m8.constructors.named('M8.named');
    expect(m8c.documentation, isEmpty);
    var m9 = library.classes.named('M9');
    expect(m9.documentation, isEmpty);
    var m9c = m9.constructors.named('M9.new');
    expect(m9c.documentation, isEmpty);
    var m10 = library.classes.named('M10');
    expect(m10.documentation, isEmpty);
    var m10c = m10.constructors.named('M10.new');
    expect(m10c.documentation, isEmpty);
    var m11 = library.classes.named('M11');
    expect(m11.documentation, isEmpty);
    var m11c = m11.constructors.named('M11.new');
    expect(m11c.documentation, isEmpty);
  }

  /// Check that doc comments placed before a body of a primary constructor of
  /// a mixin class are associated with the constructor and not with the mixin
  /// class.
  void test_beforeMixinClassPrimaryConstructorBody1() async {
    var library = await bootPackageWithLibrary('''
mixin class M1() {
  /// Line 1
  this; /// Line 2
  /// Line 3

  /// Line 4
  void foo() {}
}

mixin class M2.named() {
  /// Line 1
  this;
}

mixin class const M3() {
  /// Line 1
  this;
}

/// Line 1
mixin class M4() {
  /// Line 2
  this;
}

mixin class /// Line 1
  M5() {
  /// Line 2
  this;
}
''');
    var m1 = library.classes.named('M1');
    expect(m1.documentation, isEmpty);
    var m1c = m1.constructors.named('M1.new');
    expect(m1c.documentation, 'Line 1');
    var m2 = library.classes.named('M2');
    expect(m2.documentation, isEmpty);
    var m2c = m2.constructors.named('M2.named');
    expect(m2c.documentation, 'Line 1');
    var m3 = library.classes.named('M3');
    expect(m3.documentation, isEmpty);
    var m3c = m3.constructors.named('M3.new');
    expect(m3c.documentation, 'Line 1');
    var m4 = library.classes.named('M4');
    expect(m4.documentation, 'Line 1');
    var m4c = m4.constructors.named('M4.new');
    expect(m4c.documentation, 'Line 2');
    var m5 = library.classes.named('M5');
    expect(m5.documentation, isEmpty);
    var m5c = m5.constructors.named('M5.new');
    expect(m5c.documentation, 'Line 2');
    var m1foo = m1.instanceMethods.named('foo');
    expect(m1foo.documentation, '''
Line 2
Line 3
Line 4''');
  }

  /// Check that block-based doc comments placed before a mixin class with a
  /// primary constructor are associated with the mixin class and not with the
  /// constructor.
  void test_beforeMixinClassWithPrimaryConstructor2() async {
    var library = await bootPackageWithLibrary('''
/** Line 1
 */
mixin class M1();

/** Line 2
 */
mixin class const M2();

/** Line 3
 */
mixin class M3.named();

/** Line 4
 */
mixin class M4<T>();

/** Line 5
 */
abstract mixin class M5();

/** Line 6
 */
base mixin class M6();
''');
    var m1 = library.classes.named('M1');
    expect(m1.documentation, 'Line 1');
    var m1c = m1.constructors.named('M1.new');
    expect(m1c.documentation, isEmpty);
    var m2 = library.classes.named('M2');
    expect(m2.documentation, 'Line 2');
    var m2c = m2.constructors.named('M2.new');
    expect(m2c.documentation, isEmpty);
    var m3 = library.classes.named('M3');
    expect(m3.documentation, 'Line 3');
    var m3c = m3.constructors.named('M3.named');
    expect(m3c.documentation, isEmpty);
    var m4 = library.classes.named('M4');
    expect(m4.documentation, 'Line 4');
    var m4c = m4.constructors.named('M4.new');
    expect(m4c.documentation, isEmpty);
    var m5 = library.classes.named('M5');
    expect(m5.documentation, 'Line 5');
    var m5c = m5.constructors.named('M5.new');
    expect(m5c.documentation, isEmpty);
    var m6 = library.classes.named('M6');
    expect(m6.documentation, 'Line 6');
    var m6c = m6.constructors.named('M6.new');
    expect(m6c.documentation, isEmpty);
  }

  /// Check that block-based doc comments placed inside a header of a mixin
  /// class with a primary constructor are not associated with the mixin class
  /// or with the constructor.
  void test_insideMixinClassPrimaryConstructorHeader2() async {
    var library = await bootPackageWithLibrary('''
mixin /** Line 1 */
  class M1();

mixin class /** Line 2 */
  M2();

mixin class /** Line 3 */
  const M3();

mixin class const /** Line 4 */
  M4();

mixin class M5 /** Line 5 */
  ();

mixin class M6<T> /** Line 6 */
  ();

mixin class M7 /** Line 7 */
  .named();

mixin class M8. /** Line 8 */
  named();

abstract /** Line 9 */
  mixin class M9();

abstract mixin class /** Line 10 */
  M10();

base /** Line 11 */
  mixin class M11();
''');
    var m1 = library.classes.named('M1');
    expect(m1.documentation, isEmpty);
    var m1c = m1.constructors.named('M1.new');
    expect(m1c.documentation, isEmpty);
    var m2 = library.classes.named('M2');
    expect(m2.documentation, isEmpty);
    var m2c = m2.constructors.named('M2.new');
    expect(m2c.documentation, isEmpty);
    var m3 = library.classes.named('M3');
    expect(m3.documentation, isEmpty);
    var m3c = m3.constructors.named('M3.new');
    expect(m3c.documentation, isEmpty);
    var m4 = library.classes.named('M4');
    expect(m4.documentation, isEmpty);
    var m4c = m4.constructors.named('M4.new');
    expect(m4c.documentation, isEmpty);
    var m5 = library.classes.named('M5');
    expect(m5.documentation, isEmpty);
    var m5c = m5.constructors.named('M5.new');
    expect(m5c.documentation, isEmpty);
    var m6 = library.classes.named('M6');
    expect(m6.documentation, isEmpty);
    var m6c = m6.constructors.named('M6.new');
    expect(m6c.documentation, isEmpty);
    var m7 = library.classes.named('M7');
    expect(m7.documentation, isEmpty);
    var m7c = m7.constructors.named('M7.named');
    expect(m7c.documentation, isEmpty);
    var m8 = library.classes.named('M8');
    expect(m8.documentation, isEmpty);
    var m8c = m8.constructors.named('M8.named');
    expect(m8c.documentation, isEmpty);
    var m9 = library.classes.named('M9');
    expect(m9.documentation, isEmpty);
    var m9c = m9.constructors.named('M9.new');
    expect(m9c.documentation, isEmpty);
    var m10 = library.classes.named('M10');
    expect(m10.documentation, isEmpty);
    var m10c = m10.constructors.named('M10.new');
    expect(m10c.documentation, isEmpty);
    var m11 = library.classes.named('M11');
    expect(m11.documentation, isEmpty);
    var m11c = m11.constructors.named('M11.new');
    expect(m11c.documentation, isEmpty);
  }

  /// Check that block-based doc comments placed before a body of a primary
  /// constructor of a mixin class are associated with the constructor and not
  /// with the mixin class.
  void test_beforeMixinClassPrimaryConstructorBody2() async {
    var library = await bootPackageWithLibrary('''
mixin class M1() {
  /** Line 1
   */
  this; /** Line 2 */
  /** Line 3
   */

  /** Line 4
   */
  void foo() {}
}

mixin class M2.named() {
  /** Line 1
   */
  this;
}

mixin class const M3() {
  /** Line 1
   */
  this;
}

/** Line 1
 */
mixin class M4() {
  /** Line 2
   */
  this;
}

mixin class /** Line 1 */
  M5() {
  /** Line 2
   */
  this;
}
''');
    var m1 = library.classes.named('M1');
    expect(m1.documentation, isEmpty);
    var m1c = m1.constructors.named('M1.new');
    expect(m1c.documentation, 'Line 1');
    var m2 = library.classes.named('M2');
    expect(m2.documentation, isEmpty);
    var m2c = m2.constructors.named('M2.named');
    expect(m2c.documentation, 'Line 1');
    var m3 = library.classes.named('M3');
    expect(m3.documentation, isEmpty);
    var m3c = m3.constructors.named('M3.new');
    expect(m3c.documentation, 'Line 1');
    var m4 = library.classes.named('M4');
    expect(m4.documentation, 'Line 1');
    var m4c = m4.constructors.named('M4.new');
    expect(m4c.documentation, 'Line 2');
    var m5 = library.classes.named('M5');
    expect(m5.documentation, isEmpty);
    var m5c = m5.constructors.named('M5.new');
    expect(m5c.documentation, 'Line 2');
    var m1foo = m1.instanceMethods.named('foo');
    expect(m1foo.documentation, 'Line 4');
  }

  /// Check that doc comments placed before an enum with a primary constructor
  /// are associated with the enum and not with the constructor.
  void test_beforeEnumWithPrimaryConstructor1() async {
    var library = await bootPackageWithLibrary('''
/// Line 1
enum E1(final int x) {
  e0(1);
}

/// Line 2
enum const E2(final int x) {
  e0(1);
}

/// Line 3
enum E3.named(final int x) {
  e0.named(1);
}

/// Line 4
enum E4<T>(final T x) {
  e0<int>(1);
}
''');
    var e1 = library.enums.named('E1');
    expect(e1.documentation, 'Line 1');
    var e1c = e1.constructors.named('E1.new');
    expect(e1c.documentation, isEmpty);
    var e2 = library.enums.named('E2');
    expect(e2.documentation, 'Line 2');
    var e2c = e2.constructors.named('E2.new');
    expect(e2c.documentation, isEmpty);
    var e3 = library.enums.named('E3');
    expect(e3.documentation, 'Line 3');
    var e3c = e3.constructors.named('E3.named');
    expect(e3c.documentation, isEmpty);
    var e4 = library.enums.named('E4');
    expect(e4.documentation, 'Line 4');
    var e4c = e4.constructors.named('E4.new');
    expect(e4c.documentation, isEmpty);
  }

  /// Check that doc comments placed inside a header of an enum with a primary
  /// constructor are not associated with the enum or with the constructor.
  void test_insideEnumPrimaryConstructorHeader1() async {
    var library = await bootPackageWithLibrary('''
enum /// Line 1
  E1(final int x) {
  e0(1);
}

enum /// Line 2
  const E2(final int x) {
  e0(1);
}

enum const /// Line 3
  E3(final int x) {
  e0(1);
}

enum E4 /// Line 4
  (final int x) {
  e0(1);
}

enum E5<T> /// Line 5
  (final T x) {
  e0<int>(1);
}

enum E6 /// Line 6
  .named(final int x) {
  e0.named(1);
}

enum E7. /// Line 7
  named(final int x) {
  e0.named(1);
}
''');
    var e1 = library.enums.named('E1');
    expect(e1.documentation, isEmpty);
    var e1c = e1.constructors.named('E1.new');
    expect(e1c.documentation, isEmpty);
    var e2 = library.enums.named('E2');
    expect(e2.documentation, isEmpty);
    var e2c = e2.constructors.named('E2.new');
    expect(e2c.documentation, isEmpty);
    var e3 = library.enums.named('E3');
    expect(e3.documentation, isEmpty);
    var e3c = e3.constructors.named('E3.new');
    expect(e3c.documentation, isEmpty);
    var e4 = library.enums.named('E4');
    expect(e4.documentation, isEmpty);
    var e4c = e4.constructors.named('E4.new');
    expect(e4c.documentation, isEmpty);
    var e5 = library.enums.named('E5');
    expect(e5.documentation, isEmpty);
    var e5c = e5.constructors.named('E5.new');
    expect(e5c.documentation, isEmpty);
    var e6 = library.enums.named('E6');
    expect(e6.documentation, isEmpty);
    var e6c = e6.constructors.named('E6.named');
    expect(e6c.documentation, isEmpty);
    var e7 = library.enums.named('E7');
    expect(e7.documentation, isEmpty);
    var e7c = e7.constructors.named('E7.named');
    expect(e7c.documentation, isEmpty);
  }

  /// Check that doc comments placed before a body of a primary constructor of
  /// an enum are associated with the constructor and not with the enum.
  void test_beforeEnumPrimaryConstructorBody1() async {
    var library = await bootPackageWithLibrary('''
enum E1(final int x) {
  e0(1);
  /// Line 1
  this; /// Line 2
  /// Line 3

  /// Line 4
  void foo() {}
}

enum E2(final int x) {
  e0(1);
  /// Line 1
  this : assert(x > 0);
}

enum E3.named(final int x) {
  e0.named(1);
  /// Line 1
  this;
}

/// Line 1
enum E4(final int x) {
  e0(1);
  /// Line 2
  this;
}

enum /// Line 1
  E5(final int x) {
  e0(1);
  /// Line 2
  this;
}
''');
    var e1 = library.enums.named('E1');
    expect(e1.documentation, isEmpty);
    var e1c = e1.constructors.named('E1.new');
    expect(e1c.documentation, 'Line 1');
    var e2 = library.enums.named('E2');
    expect(e2.documentation, isEmpty);
    var e2c = e2.constructors.named('E2.new');
    expect(e2c.documentation, 'Line 1');
    var e3 = library.enums.named('E3');
    expect(e3.documentation, isEmpty);
    var e3c = e3.constructors.named('E3.named');
    expect(e3c.documentation, 'Line 1');
    var e4 = library.enums.named('E4');
    expect(e4.documentation, 'Line 1');
    var e4c = e4.constructors.named('E4.new');
    expect(e4c.documentation, 'Line 2');
    var e5 = library.enums.named('E5');
    expect(e5.documentation, isEmpty);
    var e5c = e5.constructors.named('E5.new');
    expect(e5c.documentation, 'Line 2');
    var e1foo = e1.instanceMethods.named('foo');
    expect(e1foo.documentation, '''
Line 2
Line 3
Line 4''');
  }

  /// Check that block-based doc comments placed before an enum with a primary
  /// constructor are associated with the enum and not with the constructor.
  void test_beforeEnumWithPrimaryConstructor2() async {
    var library = await bootPackageWithLibrary('''
/** Line 1
 */
enum E1(final int x) {
  e0(1);
}

/** Line 2
 */
enum const E2(final int x) {
  e0(1);
}

/** Line 3
 */
enum E3.named(final int x) {
  e0.named(1);
}

/** Line 4
 */
enum E4<T>(final T x) {
  e0<int>(1);
}
''');
    var e1 = library.enums.named('E1');
    expect(e1.documentation, 'Line 1');
    var e1c = e1.constructors.named('E1.new');
    expect(e1c.documentation, isEmpty);
    var e2 = library.enums.named('E2');
    expect(e2.documentation, 'Line 2');
    var e2c = e2.constructors.named('E2.new');
    expect(e2c.documentation, isEmpty);
    var e3 = library.enums.named('E3');
    expect(e3.documentation, 'Line 3');
    var e3c = e3.constructors.named('E3.named');
    expect(e3c.documentation, isEmpty);
    var e4 = library.enums.named('E4');
    expect(e4.documentation, 'Line 4');
    var e4c = e4.constructors.named('E4.new');
    expect(e4c.documentation, isEmpty);
  }

  /// Check that block-based doc comments placed inside a header of an enum
  /// with a primary constructor are not associated with the enum or with the
  /// constructor.
  void test_insideEnumPrimaryConstructorHeader2() async {
    var library = await bootPackageWithLibrary('''
enum /** Line 1 */
  E1(final int x) {
  e0(1);
}

enum /** Line 2 */
  const E2(final int x) {
  e0(1);
}

enum const /** Line 3 */
  E3(final int x) {
  e0(1);
}

enum E4 /** Line 4 */
  (final int x) {
  e0(1);
}

enum E5<T> /** Line 5 */
  (final T x) {
  e0<int>(1);
}

enum E6 /** Line 6 */
  .named(final int x) {
  e0.named(1);
}

enum E7. /** Line 7 */
  named(final int x) {
  e0.named(1);
}
''');
    var e1 = library.enums.named('E1');
    expect(e1.documentation, isEmpty);
    var e1c = e1.constructors.named('E1.new');
    expect(e1c.documentation, isEmpty);
    var e2 = library.enums.named('E2');
    expect(e2.documentation, isEmpty);
    var e2c = e2.constructors.named('E2.new');
    expect(e2c.documentation, isEmpty);
    var e3 = library.enums.named('E3');
    expect(e3.documentation, isEmpty);
    var e3c = e3.constructors.named('E3.new');
    expect(e3c.documentation, isEmpty);
    var e4 = library.enums.named('E4');
    expect(e4.documentation, isEmpty);
    var e4c = e4.constructors.named('E4.new');
    expect(e4c.documentation, isEmpty);
    var e5 = library.enums.named('E5');
    expect(e5.documentation, isEmpty);
    var e5c = e5.constructors.named('E5.new');
    expect(e5c.documentation, isEmpty);
    var e6 = library.enums.named('E6');
    expect(e6.documentation, isEmpty);
    var e6c = e6.constructors.named('E6.named');
    expect(e6c.documentation, isEmpty);
    var e7 = library.enums.named('E7');
    expect(e7.documentation, isEmpty);
    var e7c = e7.constructors.named('E7.named');
    expect(e7c.documentation, isEmpty);
  }

  /// Check that block-based doc comments placed before a body of a primary
  /// constructor of an enum are associated with the constructor and not with
  /// the enum.
  void test_beforeEnumPrimaryConstructorBody2() async {
    var library = await bootPackageWithLibrary('''
enum E1(final int x) {
  e0(1);
  /** Line 1
   */
  this; /** Line 2 */
  /** Line 3
   */

  /** Line 4
   */
  void foo() {}
}

enum E2(final int x) {
  e0(1);
  /** Line 1
   */
  this : assert(x > 0);
}

enum E3.named(final int x) {
  e0.named(1);
  /** Line 1
   */
  this;
}

/** Line 1
 */
enum E4(final int x) {
  e0(1);
  /** Line 2
   */
  this;
}

enum /** Line 1 */
  E5(final int x) {
  e0(1);
  /** Line 2
   */
  this;
}
''');
    var e1 = library.enums.named('E1');
    expect(e1.documentation, isEmpty);
    var e1c = e1.constructors.named('E1.new');
    expect(e1c.documentation, 'Line 1');
    var e2 = library.enums.named('E2');
    expect(e2.documentation, isEmpty);
    var e2c = e2.constructors.named('E2.new');
    expect(e2c.documentation, 'Line 1');
    var e3 = library.enums.named('E3');
    expect(e3.documentation, isEmpty);
    var e3c = e3.constructors.named('E3.named');
    expect(e3c.documentation, 'Line 1');
    var e4 = library.enums.named('E4');
    expect(e4.documentation, 'Line 1');
    var e4c = e4.constructors.named('E4.new');
    expect(e4c.documentation, 'Line 2');
    var e5 = library.enums.named('E5');
    expect(e5.documentation, isEmpty);
    var e5c = e5.constructors.named('E5.new');
    expect(e5c.documentation, 'Line 2');
    var e1foo = e1.instanceMethods.named('foo');
    expect(e1foo.documentation, 'Line 4');
  }

  /// Check that doc comments placed before an extension type with a primary
  /// constructor are associated with the extension type and not with the
  /// constructor.
  void test_beforeExtensionTypeWithPrimaryConstructor1() async {
    var library = await bootPackageWithLibrary('''
/// Line 1
extension type ET1(int v) {}

/// Line 2
extension type const ET2(int v) {}

/// Line 3
extension type ET3.named(int v) {}

/// Line 4
extension type ET4<T>(T v) {}
''');
    var et1 = library.extensionTypes.named('ET1');
    expect(et1.documentation, 'Line 1');
    var et1c = et1.constructors.named('ET1.new');
    expect(et1c.documentation, isEmpty);
    var et2 = library.extensionTypes.named('ET2');
    expect(et2.documentation, 'Line 2');
    var et2c = et2.constructors.named('ET2.new');
    expect(et2c.documentation, isEmpty);
    var et3 = library.extensionTypes.named('ET3');
    expect(et3.documentation, 'Line 3');
    var et3c = et3.constructors.named('ET3.named');
    expect(et3c.documentation, isEmpty);
    var et4 = library.extensionTypes.named('ET4');
    expect(et4.documentation, 'Line 4');
    var et4c = et4.constructors.named('ET4.new');
    expect(et4c.documentation, isEmpty);
  }

  /// Check that doc comments placed inside a header of an extension type with
  /// a primary constructor are not associated with the extension type or with
  /// the constructor.
  void test_insideExtensionTypePrimaryConstructorHeader1() async {
    var library = await bootPackageWithLibrary('''
extension /// Line 1
  type ET1(int v) {}

extension type /// Line 2
  ET2(int v) {}

extension type /// Line 3
  const ET3(int v) {}

extension type const /// Line 4
  ET4(int v) {}

extension type ET5 /// Line 5
  (int v) {}

extension type ET6<T> /// Line 6
  (T v) {}

extension type ET7 /// Line 7
  .named(int v) {}

extension type ET8. /// Line 8
  named(int v) {}
''');
    var et1 = library.extensionTypes.named('ET1');
    expect(et1.documentation, isEmpty);
    var et1c = et1.constructors.named('ET1.new');
    expect(et1c.documentation, isEmpty);
    var et2 = library.extensionTypes.named('ET2');
    expect(et2.documentation, isEmpty);
    var et2c = et2.constructors.named('ET2.new');
    expect(et2c.documentation, isEmpty);
    var et3 = library.extensionTypes.named('ET3');
    expect(et3.documentation, isEmpty);
    var et3c = et3.constructors.named('ET3.new');
    expect(et3c.documentation, isEmpty);
    var et4 = library.extensionTypes.named('ET4');
    expect(et4.documentation, isEmpty);
    var et4c = et4.constructors.named('ET4.new');
    expect(et4c.documentation, isEmpty);
    var et5 = library.extensionTypes.named('ET5');
    expect(et5.documentation, isEmpty);
    var et5c = et5.constructors.named('ET5.new');
    expect(et5c.documentation, isEmpty);
    var et6 = library.extensionTypes.named('ET6');
    expect(et6.documentation, isEmpty);
    var et6c = et6.constructors.named('ET6.new');
    expect(et6c.documentation, isEmpty);
    var et7 = library.extensionTypes.named('ET7');
    expect(et7.documentation, isEmpty);
    var et7c = et7.constructors.named('ET7.named');
    expect(et7c.documentation, isEmpty);
    var et8 = library.extensionTypes.named('ET8');
    expect(et8.documentation, isEmpty);
    var et8c = et8.constructors.named('ET8.named');
    expect(et8c.documentation, isEmpty);
  }

  /// Check that doc comments placed before a body of a primary constructor of
  /// an extension type are associated with the constructor and not with the
  /// extension type.
  void test_beforeExtensionTypePrimaryConstructorBody1() async {
    var library = await bootPackageWithLibrary('''
extension type ET1(int v) {
  /// Line 1
  this; /// Line 2
  /// Line 3

  /// Line 4
  void foo() {}
}

extension type ET2(int v) {
  /// Line 1
  this { /// Line 2
  /// Line 3
  }
  /// Line 4

  /// Line 5
  void foo() {}
}

extension type ET3(int v) {
  /// Line 1
  this : assert(v > 0);
}

extension type ET4.named(int v) {
  /// Line 1
  this;
}

/// Line 1
extension type ET5(int v) {
  /// Line 2
  this;
}

extension type /// Line 1
  ET6(int v) {
  /// Line 2
  this;
}
''');
    var et1 = library.extensionTypes.named('ET1');
    expect(et1.documentation, isEmpty);
    var et1c = et1.constructors.named('ET1.new');
    expect(et1c.documentation, 'Line 1');
    var et2 = library.extensionTypes.named('ET2');
    expect(et2.documentation, isEmpty);
    var et2c = et2.constructors.named('ET2.new');
    expect(et2c.documentation, 'Line 1');
    var et3 = library.extensionTypes.named('ET3');
    expect(et3.documentation, isEmpty);
    var et3c = et3.constructors.named('ET3.new');
    expect(et3c.documentation, 'Line 1');
    var et4 = library.extensionTypes.named('ET4');
    expect(et4.documentation, isEmpty);
    var et4c = et4.constructors.named('ET4.named');
    expect(et4c.documentation, 'Line 1');
    var et5 = library.extensionTypes.named('ET5');
    expect(et5.documentation, 'Line 1');
    var et5c = et5.constructors.named('ET5.new');
    expect(et5c.documentation, 'Line 2');
    var et6 = library.extensionTypes.named('ET6');
    expect(et6.documentation, isEmpty);
    var et6c = et6.constructors.named('ET6.new');
    expect(et6c.documentation, 'Line 2');
    var et1foo = et1.instanceMethods.named('foo');
    expect(et1foo.documentation, '''
Line 2
Line 3
Line 4''');
    var et2foo = et2.instanceMethods.named('foo');
    expect(et2foo.documentation, '''
Line 4
Line 5''');
  }

  /// Check that block-based doc comments placed before an extension type with
  /// a primary constructor are associated with the extension type and not with
  /// the constructor.
  void test_beforeExtensionTypeWithPrimaryConstructor2() async {
    var library = await bootPackageWithLibrary('''
/** Line 1
 */
extension type ET1(int v) {}

/** Line 2
 */
extension type const ET2(int v) {}

/** Line 3
 */
extension type ET3.named(int v) {}

/** Line 4
 */
extension type ET4<T>(T v) {}
''');
    var et1 = library.extensionTypes.named('ET1');
    expect(et1.documentation, 'Line 1');
    var et1c = et1.constructors.named('ET1.new');
    expect(et1c.documentation, isEmpty);
    var et2 = library.extensionTypes.named('ET2');
    expect(et2.documentation, 'Line 2');
    var et2c = et2.constructors.named('ET2.new');
    expect(et2c.documentation, isEmpty);
    var et3 = library.extensionTypes.named('ET3');
    expect(et3.documentation, 'Line 3');
    var et3c = et3.constructors.named('ET3.named');
    expect(et3c.documentation, isEmpty);
    var et4 = library.extensionTypes.named('ET4');
    expect(et4.documentation, 'Line 4');
    var et4c = et4.constructors.named('ET4.new');
    expect(et4c.documentation, isEmpty);
  }

  /// Check that block-based doc comments placed inside a header of an
  /// extension type with a primary constructor are not associated with the
  /// extension type or with the constructor.
  void test_insideExtensionTypePrimaryConstructorHeader2() async {
    var library = await bootPackageWithLibrary('''
extension /** Line 1 */
  type ET1(int v) {}

extension type /** Line 2 */
  ET2(int v) {}

extension type /** Line 3 */
  const ET3(int v) {}

extension type const /** Line 4 */
  ET4(int v) {}

extension type ET5 /** Line 5 */
  (int v) {}

extension type ET6<T> /** Line 6 */
  (T v) {}

extension type ET7 /** Line 7 */
  .named(int v) {}

extension type ET8. /** Line 8 */
  named(int v) {}
''');
    var et1 = library.extensionTypes.named('ET1');
    expect(et1.documentation, isEmpty);
    var et1c = et1.constructors.named('ET1.new');
    expect(et1c.documentation, isEmpty);
    var et2 = library.extensionTypes.named('ET2');
    expect(et2.documentation, isEmpty);
    var et2c = et2.constructors.named('ET2.new');
    expect(et2c.documentation, isEmpty);
    var et3 = library.extensionTypes.named('ET3');
    expect(et3.documentation, isEmpty);
    var et3c = et3.constructors.named('ET3.new');
    expect(et3c.documentation, isEmpty);
    var et4 = library.extensionTypes.named('ET4');
    expect(et4.documentation, isEmpty);
    var et4c = et4.constructors.named('ET4.new');
    expect(et4c.documentation, isEmpty);
    var et5 = library.extensionTypes.named('ET5');
    expect(et5.documentation, isEmpty);
    var et5c = et5.constructors.named('ET5.new');
    expect(et5c.documentation, isEmpty);
    var et6 = library.extensionTypes.named('ET6');
    expect(et6.documentation, isEmpty);
    var et6c = et6.constructors.named('ET6.new');
    expect(et6c.documentation, isEmpty);
    var et7 = library.extensionTypes.named('ET7');
    expect(et7.documentation, isEmpty);
    var et7c = et7.constructors.named('ET7.named');
    expect(et7c.documentation, isEmpty);
    var et8 = library.extensionTypes.named('ET8');
    expect(et8.documentation, isEmpty);
    var et8c = et8.constructors.named('ET8.named');
    expect(et8c.documentation, isEmpty);
  }

  /// Check that block-based doc comments placed before a body of a primary
  /// constructor of an extension type are associated with the constructor and
  /// not with the extension type.
  void test_beforeExtensionTypePrimaryConstructorBody2() async {
    var library = await bootPackageWithLibrary('''
extension type ET1(int v) {
  /** Line 1
   */
  this; /** Line 2 */
  /** Line 3
   */

  /** Line 4
   */
  void foo() {}
}

extension type ET2(int v) {
  /** Line 1
   */
  this { /** Line 2 */
  /** Line 3
   */
  }
  /** Line 4
   */

  /** Line 5
   */
  void foo() {}
}

extension type ET3(int v) {
  /** Line 1
   */
  this : assert(v > 0);
}

extension type ET4.named(int v) {
  /** Line 1
   */
  this;
}

/** Line 1
 */
extension type ET5(int v) {
  /** Line 2
   */
  this;
}

extension type /** Line 1 */
  ET6(int v) {
  /** Line 2
   */
  this;
}
''');
    var et1 = library.extensionTypes.named('ET1');
    expect(et1.documentation, isEmpty);
    var et1c = et1.constructors.named('ET1.new');
    expect(et1c.documentation, 'Line 1');
    var et2 = library.extensionTypes.named('ET2');
    expect(et2.documentation, isEmpty);
    var et2c = et2.constructors.named('ET2.new');
    expect(et2c.documentation, 'Line 1');
    var et3 = library.extensionTypes.named('ET3');
    expect(et3.documentation, isEmpty);
    var et3c = et3.constructors.named('ET3.new');
    expect(et3c.documentation, 'Line 1');
    var et4 = library.extensionTypes.named('ET4');
    expect(et4.documentation, isEmpty);
    var et4c = et4.constructors.named('ET4.named');
    expect(et4c.documentation, 'Line 1');
    var et5 = library.extensionTypes.named('ET5');
    expect(et5.documentation, 'Line 1');
    var et5c = et5.constructors.named('ET5.new');
    expect(et5c.documentation, 'Line 2');
    var et6 = library.extensionTypes.named('ET6');
    expect(et6.documentation, isEmpty);
    var et6c = et6.constructors.named('ET6.new');
    expect(et6c.documentation, 'Line 2');
    var et1foo = et1.instanceMethods.named('foo');
    expect(et1foo.documentation, 'Line 4');
    var et2foo = et2.instanceMethods.named('foo');
    expect(et2foo.documentation, 'Line 5');
  }
}
