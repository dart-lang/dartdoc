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
    defineReflectiveTests(PlacementParametersMethodsTest);
  });
}

@reflectiveTest
class PlacementParametersMethodsTest extends Co19TestBase {
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
}
