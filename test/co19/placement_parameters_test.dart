// Copyright (c) 2026, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// @assertion While not strictly disallowed by the language, any other
/// placement of a comment with the `///` syntax, is not considered a doc
/// comment, and hence should be ignored by documentation tools.
/// @author sgrekhov22@gmail.com
library;

import 'package:test/test.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

import '../src/utils.dart';
import 'co19_test_base.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(PlacementParametersTest);
  });
}

@reflectiveTest
class PlacementParametersTest extends Co19TestBase {
  /// Check that doc comments placed inside a parameter list of a top-level
  /// function are not associated with the function.
  void test_functionParameters1() async {
    var library = await bootPackageWithLibrary('''
void foo(/// Line 1
  int x, [
  /// Line 2
  int y = 0]) {}

void bar({
  /// Line 3
  int x = 0,
  /// Line 4
  required int y}) {}
''');
    var foo = library.functions.named('foo');
    expect(foo.documentation, isEmpty);
    var bar = library.functions.named('bar');
    expect(bar.documentation, isEmpty);
  }

  /// Check that doc comments placed inside a parameter list of a top-level
  /// function are ignored.
  @FailingTest(reason: 'https://github.com/dart-lang/dartdoc/issues/1259')
  void test_functionParameters2() async {
    var library = await bootPackageWithLibrary('''
void foo(/// Line 1
  int x, [
  /// Line 2
  int y = 0]) {}

void bar({
  /// Line 3
  int x = 0,
  /// Line 4
  required int y}) {}
''');
    var foo = library.functions.named('foo');
    expect(foo.parameters.named('x').documentation, isEmpty);
    expect(foo.parameters.named('y').documentation, isEmpty);
    var bar = library.functions.named('bar');
    expect(bar.parameters.named('x').documentation, isEmpty);
    expect(bar.parameters.named('y').documentation, isEmpty);
  }

  /// Check that block-based doc comments placed inside a parameter list of a
  /// top-level function are not associated with the function.
  void test_blockFunctionParameters1() async {
    var library = await bootPackageWithLibrary('''
void foo(/** Line 1 */ int x, [
  /** Line 2
   */
  int y = 0]) {}

void bar({
  /** Line 3 */
  int x = 0,
  /** Line 4
   */
  required int y}) {}
''');
    var foo = library.functions.named('foo');
    expect(foo.documentation, isEmpty);
    var bar = library.functions.named('bar');
    expect(bar.documentation, isEmpty);
  }

  /// Check that block-based doc comments placed inside a parameter list of a
  /// top-level function are ignored.
  @FailingTest(reason: 'https://github.com/dart-lang/dartdoc/issues/1259')
  void test_blockFunctionParameters2() async {
    var library = await bootPackageWithLibrary('''
void foo(/** Line 1 */ int x, [
  /** Line 2
   */
  int y = 0]) {}

void bar({
  /** Line 3 */
  int x = 0,
  /** Line 4
   */
  required int y}) {}
''');
    var foo = library.functions.named('foo');
    expect(foo.parameters.named('x').documentation, isEmpty);
    expect(foo.parameters.named('y').documentation, isEmpty);
    var bar = library.functions.named('bar');
    expect(bar.parameters.named('x').documentation, isEmpty);
    expect(bar.parameters.named('y').documentation, isEmpty);
  }

  /// Check that doc comments placed inside a parameter list of a constructor
  /// are not associated with the constructor.
  void test_constructorParameters1() async {
    var library = await bootPackageWithLibrary('''
class C {
  int z;

  C(/// Line 1
    int x, [
    /// Line 2
    this.z = 0]);

  C.named({
    /// Line 3
    int x = 0,
    /// Line 4
    required this.z});

  factory C.factory(/// Line 5
    int x) => C(x);
}
''');
    var c = library.classes.named('C');
    var c1 = c.constructors.named('C.new');
    expect(c1.documentation, isEmpty);
    var c2 = c.constructors.named('C.named');
    expect(c2.documentation, isEmpty);
    var c3 = c.constructors.named('C.factory');
    expect(c3.documentation, isEmpty);
  }

  /// Check that doc comments placed inside a parameter list of a constructor
  /// are ignored.
  @FailingTest(reason: 'https://github.com/dart-lang/dartdoc/issues/1259')
  void test_constructorParameters2() async {
    var library = await bootPackageWithLibrary('''
class C {
  int z;

  C(/// Line 1
    int x, [
    /// Line 2
    this.z = 0]);

  C.named({
    /// Line 3
    int x = 0,
    /// Line 4
    required this.z});

  factory C.factory(/// Line 5
    int x) => C(x);
}
''');
    var c = library.classes.named('C');
    var c1 = c.constructors.named('C.new');
    expect(c1.parameters.named('x').documentation, isEmpty);
    expect(c1.parameters.named('z').documentation, isEmpty);
    var c2 = c.constructors.named('C.named');
    expect(c2.parameters.named('x').documentation, isEmpty);
    expect(c2.parameters.named('z').documentation, isEmpty);
    var c3 = c.constructors.named('C.factory');
    expect(c3.parameters.named('x').documentation, isEmpty);
  }

  /// Check that block-based doc comments placed inside a parameter list of a
  /// constructor are not associated with the constructor.
  void test_blockConstructorParameters1() async {
    var library = await bootPackageWithLibrary('''
class C {
  int z;

  C(/** Line 1 */ int x, [
    /** Line 2
     */
    this.z = 0]);

  C.named({
    /** Line 3 */
    int x = 0,
    /** Line 4
     */
    required this.z});

  factory C.factory(/** Line 5 */ int x) => C(x);
}
''');
    var c = library.classes.named('C');
    var c1 = c.constructors.named('C.new');
    expect(c1.documentation, isEmpty);
    var c2 = c.constructors.named('C.named');
    expect(c2.documentation, isEmpty);
    var c3 = c.constructors.named('C.factory');
    expect(c3.documentation, isEmpty);
  }

  /// Check that block-based doc comments placed inside a parameter list of a
  /// constructor are ignored.
  @FailingTest(reason: 'https://github.com/dart-lang/dartdoc/issues/1259')
  void test_blockConstructorParameters2() async {
    var library = await bootPackageWithLibrary('''
class C {
  int z;

  C(/** Line 1 */ int x, [
    /** Line 2
     */
    this.z = 0]);

  C.named({
    /** Line 3 */
    int x = 0,
    /** Line 4
     */
    required this.z});

  factory C.factory(/** Line 5 */ int x) => C(x);
}
''');
    var c = library.classes.named('C');
    var c1 = c.constructors.named('C.new');
    expect(c1.parameters.named('x').documentation, isEmpty);
    expect(c1.parameters.named('z').documentation, isEmpty);
    var c2 = c.constructors.named('C.named');
    expect(c2.parameters.named('x').documentation, isEmpty);
    expect(c2.parameters.named('z').documentation, isEmpty);
    var c3 = c.constructors.named('C.factory');
    expect(c3.parameters.named('x').documentation, isEmpty);
  }

  /// Check that doc comments placed inside a parameter list of a static method
  /// are not associated with the method.
  void test_staticMethodParameters1() async {
    var library = await bootPackageWithLibrary('''
class C {
  static void foo(/// Line 1
    int x, [
    /// Line 2
    int y = 0]) {}

  static void bar({
    /// Line 3
    int x = 0,
    /// Line 4
    required int y}) {}
}
''');
    var c = library.classes.named('C');
    var foo = c.staticMethods.named('foo');
    expect(foo.documentation, isEmpty);
    var bar = c.staticMethods.named('bar');
    expect(bar.documentation, isEmpty);
  }

  /// Check that doc comments placed inside a parameter list of a static method
  /// are ignored.
  @FailingTest(reason: 'https://github.com/dart-lang/dartdoc/issues/1259')
  void test_staticMethodParameters2() async {
    var library = await bootPackageWithLibrary('''
class C {
  static void foo(/// Line 1
    int x, [
    /// Line 2
    int y = 0]) {}

  static void bar({
    /// Line 3
    int x = 0,
    /// Line 4
    required int y}) {}
}
''');
    var c = library.classes.named('C');
    var foo = c.staticMethods.named('foo');
    expect(foo.parameters.named('x').documentation, isEmpty);
    expect(foo.parameters.named('y').documentation, isEmpty);
    var bar = c.staticMethods.named('bar');
    expect(bar.parameters.named('x').documentation, isEmpty);
    expect(bar.parameters.named('y').documentation, isEmpty);
  }

  /// Check that block-based doc comments placed inside a parameter list of a
  /// static method are not associated with the method.
  void test_blockStaticMethodParameters1() async {
    var library = await bootPackageWithLibrary('''
class C {
  static void foo(/** Line 1 */ int x, [
    /** Line 2
     */
    int y = 0]) {}

  static void bar({
    /** Line 3 */
    int x = 0,
    /** Line 4
     */
    required int y}) {}
}
''');
    var c = library.classes.named('C');
    var foo = c.staticMethods.named('foo');
    expect(foo.documentation, isEmpty);
    var bar = c.staticMethods.named('bar');
    expect(bar.documentation, isEmpty);
  }

  /// Check that block-based doc comments placed inside a parameter list of a
  /// static method are ignored.
  @FailingTest(reason: 'https://github.com/dart-lang/dartdoc/issues/1259')
  void test_blockStaticMethodParameters2() async {
    var library = await bootPackageWithLibrary('''
class C {
  static void foo(/** Line 1 */ int x, [
    /** Line 2
     */
    int y = 0]) {}

  static void bar({
    /** Line 3 */
    int x = 0,
    /** Line 4
     */
    required int y}) {}
}
''');
    var c = library.classes.named('C');
    var foo = c.staticMethods.named('foo');
    expect(foo.parameters.named('x').documentation, isEmpty);
    expect(foo.parameters.named('y').documentation, isEmpty);
    var bar = c.staticMethods.named('bar');
    expect(bar.parameters.named('x').documentation, isEmpty);
    expect(bar.parameters.named('y').documentation, isEmpty);
  }

  /// Check that doc comments placed inside a parameter list of an instance
  /// method are not associated with the method.
  void test_instanceMethodParameters1() async {
    var library = await bootPackageWithLibrary('''
class C {
  void foo(/// Line 1
    int x, [
    /// Line 2
    int y = 0]) {}

  void bar({
    /// Line 3
    int x = 0,
    /// Line 4
    required int y}) {}
}
''');
    var c = library.classes.named('C');
    var foo = c.instanceMethods.named('foo');
    expect(foo.documentation, isEmpty);
    var bar = c.instanceMethods.named('bar');
    expect(bar.documentation, isEmpty);
  }

  /// Check that doc comments placed inside a parameter list of an instance
  /// method are ignored.
  @FailingTest(reason: 'https://github.com/dart-lang/dartdoc/issues/1259')
  void test_instanceMethodParameters2() async {
    var library = await bootPackageWithLibrary('''
class C {
  void foo(/// Line 1
    int x, [
    /// Line 2
    int y = 0]) {}

  void bar({
    /// Line 3
    int x = 0,
    /// Line 4
    required int y}) {}
}
''');
    var c = library.classes.named('C');
    var foo = c.instanceMethods.named('foo');
    expect(foo.parameters.named('x').documentation, isEmpty);
    expect(foo.parameters.named('y').documentation, isEmpty);
    var bar = c.instanceMethods.named('bar');
    expect(bar.parameters.named('x').documentation, isEmpty);
    expect(bar.parameters.named('y').documentation, isEmpty);
  }

  /// Check that block-based doc comments placed inside a parameter list of an
  /// instance method are not associated with the method.
  void test_blockInstanceMethodParameters1() async {
    var library = await bootPackageWithLibrary('''
class C {
  void foo(/** Line 1 */ int x, [
    /** Line 2
     */
    int y = 0]) {}

  void bar({
    /** Line 3 */
    int x = 0,
    /** Line 4
     */
    required int y}) {}
}
''');
    var c = library.classes.named('C');
    var foo = c.instanceMethods.named('foo');
    expect(foo.documentation, isEmpty);
    var bar = c.instanceMethods.named('bar');
    expect(bar.documentation, isEmpty);
  }

  /// Check that block-based doc comments placed inside a parameter list of an
  /// instance method are ignored.
  @FailingTest(reason: 'https://github.com/dart-lang/dartdoc/issues/1259')
  void test_blockInstanceMethodParameters2() async {
    var library = await bootPackageWithLibrary('''
class C {
  void foo(/** Line 1 */ int x, [
    /** Line 2
     */
    int y = 0]) {}

  void bar({
    /** Line 3 */
    int x = 0,
    /** Line 4
     */
    required int y}) {}
}
''');
    var c = library.classes.named('C');
    var foo = c.instanceMethods.named('foo');
    expect(foo.parameters.named('x').documentation, isEmpty);
    expect(foo.parameters.named('y').documentation, isEmpty);
    var bar = c.instanceMethods.named('bar');
    expect(bar.parameters.named('x').documentation, isEmpty);
    expect(bar.parameters.named('y').documentation, isEmpty);
  }

  /// Check that doc comments placed inside a parameter list of an operator are
  /// not associated with the operator.
  void test_operatorParameters1() async {
    var library = await bootPackageWithLibrary('''
class C {
  int operator +(/// Line 1
    Object? other) => 0;

  void operator []=(
    /// Line 2
    int index,
    /// Line 3
    int value) {}
}
''');
    var c = library.classes.named('C');
    var op1 = c.instanceOperators.named('operator +');
    expect(op1.documentation, isEmpty);
    var op2 = c.instanceOperators.named('operator []=');
    expect(op2.documentation, isEmpty);
  }

  /// Check that doc comments placed inside a parameter list of an operator are
  /// ignored.
  @FailingTest(reason: 'https://github.com/dart-lang/dartdoc/issues/1259')
  void test_operatorParameters2() async {
    var library = await bootPackageWithLibrary('''
class C {
  int operator +(/// Line 1
    Object? other) => 0;

  void operator []=(
    /// Line 2
    int index,
    /// Line 3
    int value) {}
}
''');
    var c = library.classes.named('C');
    var op1 = c.instanceOperators.named('operator +');
    expect(op1.parameters.named('other').documentation, isEmpty);
    var op2 = c.instanceOperators.named('operator []=');
    expect(op2.parameters.named('index').documentation, isEmpty);
    expect(op2.parameters.named('value').documentation, isEmpty);
  }

  /// Check that block-based doc comments placed inside a parameter list of an
  /// operator are not associated with the operator.
  void test_blockOperatorParameters1() async {
    var library = await bootPackageWithLibrary('''
class C {
  int operator +(/** Line 1 */ Object? other) => 0;

  void operator []=(
    /** Line 2 */
    int index,
    /** Line 3
     */
    int value) {}
}
''');
    var c = library.classes.named('C');
    var op1 = c.instanceOperators.named('operator +');
    expect(op1.documentation, isEmpty);
    var op2 = c.instanceOperators.named('operator []=');
    expect(op2.documentation, isEmpty);
  }

  /// Check that block-based doc comments placed inside a parameter list of an
  /// operator are ignored.
  @FailingTest(reason: 'https://github.com/dart-lang/dartdoc/issues/1259')
  void test_blockOperatorParameters2() async {
    var library = await bootPackageWithLibrary('''
class C {
  int operator +(/** Line 1 */ Object? other) => 0;

  void operator []=(
    /** Line 2 */
    int index,
    /** Line 3
     */
    int value) {}
}
''');
    var c = library.classes.named('C');
    var op1 = c.instanceOperators.named('operator +');
    expect(op1.parameters.named('other').documentation, isEmpty);
    var op2 = c.instanceOperators.named('operator []=');
    expect(op2.parameters.named('index').documentation, isEmpty);
    expect(op2.parameters.named('value').documentation, isEmpty);
  }
}
