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
    defineReflectiveTests(InvalidPlacementTest);
  });
}

@reflectiveTest
class InvalidPlacementTest extends Co19TestBase {
  /// Check that doc comments placed before `import` and `export` directives
  /// are ignored.
  void test_beforeDirectives1() async {
    var library = await bootPackageWithLibrary('''
/// Line 1
import 'dart:core';
/// Line 2
export 'dart:core' show int;

class C {}
''');
    expect(library.documentation, isEmpty);
    var c = library.classes.named('C');
    expect(c.documentation, isEmpty);
  }

  /// Check that block-based doc comments placed before `import` and `export`
  /// directives are ignored.
  void test_blockBeforeDirectives1() async {
    var library = await bootPackageWithLibrary('''
/** Line 1
 */
import 'dart:core';
/** Line 2 */
export 'dart:core' show int;

class C {}
''');
    expect(library.documentation, isEmpty);
    var c = library.classes.named('C');
    expect(c.documentation, isEmpty);
  }

  /// Check that doc comments placed before `import` and `export` directives
  /// are ignored. Test the case when there is no 'library' directive.
  @FailingTest(
      reason: 'The first doc comment is treated as a library doc comment.')
  void test_beforeDirectives2() async {
    var library = await bootLibrary('''
/// Line 1
import 'dart:core';
/// Line 2
export 'dart:core' show int;

class C {}
''');
    expect(library.documentation, isEmpty);
    var c = library.classes.named('C');
    expect(c.documentation, isEmpty);
  }

  /// Check that block-based doc comments placed before `import` and `export`
  /// directives are ignored. Test the case when there is no 'library' directive.
  @FailingTest(
      reason: 'The first doc comment is treated as a library doc comment.')
  void test_blockBeforeDirectives2() async {
    var library = await bootLibrary('''
/** Line 1
 */
import 'dart:core';
/** Line 2 */
export 'dart:core' show int;

class C {}
''');
    expect(library.documentation, isEmpty);
    var c = library.classes.named('C');
    expect(c.documentation, isEmpty);
  }

  /// Check that doc comments placed inside a top-level function body are
  /// ignored.
  void test_insideFunctionBody() async {
    var library = await bootPackageWithLibrary('''
void foo() {
  /// Line 1
  var x = 0;
  /// Line 2
  void bar() {}
  /// Line 3
  print(x);
  /// Line 4
  if (x > 0) {
    /// Line 5
    bar();
  }
  /// Line 6
}

void baz() {}
''');
    var foo = library.functions.named('foo');
    expect(foo.documentation, isEmpty);
    var baz = library.functions.named('baz');
    expect(baz.documentation, isEmpty);
  }

  /// Check that block-based doc comments placed inside a top-level function
  /// body are ignored.
  void test_blockInsideFunctionBody() async {
    var library = await bootPackageWithLibrary('''
void foo() {
  /** Line 1
   */
  var x = 0;
  /** Line 2 */
  void bar() {}
  /** Line 3
   */
  print(x);
  /** Line 4 */
  if (x > 0) {
    /** Line 5
     */
    bar();
  }
  /** Line 6 */
}

void baz() {}
''');
    var foo = library.functions.named('foo');
    expect(foo.documentation, isEmpty);
    var baz = library.functions.named('baz');
    expect(baz.documentation, isEmpty);
  }

  /// Check that doc comments placed inside a method body are ignored.
  void test_insideMethodBody() async {
    var library = await bootPackageWithLibrary('''
class C {
  void foo() {
    /// Line 1
    var x = 0;
    /// Line 2
    void bar() {}
    /// Line 3
    print(x);
  /// Line 4
  }

  void baz() {}
}
''');
    var c = library.classes.named('C');
    var foo = c.instanceMethods.named('foo');
    expect(foo.documentation, isEmpty);
    var baz = c.instanceMethods.named('baz');
    expect(baz.documentation, isEmpty);
  }

  /// Check that block-based doc comments placed inside a method body are
  /// ignored.
  void test_blockInsideMethodBody() async {
    var library = await bootPackageWithLibrary('''
class C {
  void foo() {
    /** Line 1
     */
    var x = 0;
    /** Line 2 */
    void bar() {}
    /** Line 3
     */
    print(x);
  /** Line 4 */
  }

  void baz() {}
}
''');
    var c = library.classes.named('C');
    var foo = c.instanceMethods.named('foo');
    expect(foo.documentation, isEmpty);
    var baz = c.instanceMethods.named('baz');
    expect(baz.documentation, isEmpty);
  }

  /// Check that doc comments placed inside a function expression body are
  /// ignored.
  void test_insideFunctionExpression() async {
    var library = await bootPackageWithLibrary('''
var f = () {
  /// Line 1
  var x = 0;
  /// Line 2
  return x;
};

void foo() {}
''');
    var f = library.properties.named('f');
    expect(f.documentation, isEmpty);
    var foo = library.functions.named('foo');
    expect(foo.documentation, isEmpty);
  }

  /// Check that block-based doc comments placed inside a function expression
  /// body are ignored.
  void test_blockInsideFunctionExpression() async {
    var library = await bootPackageWithLibrary('''
var f = () {
  /** Line 1
   */
  var x = 0;
  /** Line 2 */
  return x;
};

void foo() {}
''');
    var f = library.properties.named('f');
    expect(f.documentation, isEmpty);
    var foo = library.functions.named('foo');
    expect(foo.documentation, isEmpty);
  }

  /// Check that doc comments placed inside a declaration (between modifiers,
  /// types and names) are ignored.
  void test_insideDeclaration() async {
    var library = await bootPackageWithLibrary('''
final /// Line 1
  int x = 0;

int /// Line 2
  y = 0;

void /// Line 3
  foo() {}

abstract /// Line 4
  class C /// Line 5
  {}

class D /// Line 6
  extends C /// Line 7
  {}
''');
    var x = library.properties.named('x');
    expect(x.documentation, isEmpty);
    var y = library.properties.named('y');
    expect(y.documentation, isEmpty);
    var foo = library.functions.named('foo');
    expect(foo.documentation, isEmpty);
    var c = library.classes.named('C');
    expect(c.documentation, isEmpty);
    var d = library.classes.named('D');
    expect(d.documentation, isEmpty);
  }

  /// Check that block-based doc comments placed inside a declaration (between
  /// modifiers, types and names) are ignored.
  void test_blockInsideDeclaration() async {
    var library = await bootPackageWithLibrary('''
final /** Line 1 */ int x = 0;

int /** Line 2
 */
  y = 0;

void /** Line 3 */ foo() {}

abstract /** Line 4 */ class C /** Line 5 */ {}

class D /** Line 6
 */
  extends C /** Line 7 */ {}
''');
    var x = library.properties.named('x');
    expect(x.documentation, isEmpty);
    var y = library.properties.named('y');
    expect(y.documentation, isEmpty);
    var foo = library.functions.named('foo');
    expect(foo.documentation, isEmpty);
    var c = library.classes.named('C');
    expect(c.documentation, isEmpty);
    var d = library.classes.named('D');
    expect(d.documentation, isEmpty);
  }

  /// Check that doc comments placed inside an expression are ignored.
  void test_insideExpression() async {
    var library = await bootPackageWithLibrary('''
int x = /// Line 1
  1 + /// Line 2
  2;

const y = [
  /// Line 3
  1,
  /// Line 4
];

int foo() => /// Line 5
  42;
''');
    var x = library.properties.named('x');
    expect(x.documentation, isEmpty);
    var y = library.constants.named('y');
    expect(y.documentation, isEmpty);
    var foo = library.functions.named('foo');
    expect(foo.documentation, isEmpty);
  }

  /// Check that block-based doc comments placed inside an expression are
  /// ignored.
  void test_blockInsideExpression() async {
    var library = await bootPackageWithLibrary('''
int x = /** Line 1 */ 1 + /** Line 2
 */
  2;

const y = [
  /** Line 3 */
  1,
  /** Line 4
   */
];

int foo() => /** Line 5 */ 42;
''');
    var x = library.properties.named('x');
    expect(x.documentation, isEmpty);
    var y = library.constants.named('y');
    expect(y.documentation, isEmpty);
    var foo = library.functions.named('foo');
    expect(foo.documentation, isEmpty);
  }

  /// Check that doc comments placed at the end of a class body are ignored.
  void test_endOfClassBody() async {
    var library = await bootPackageWithLibrary('''
class C {
  int x = 0;
  /// Line 1
}

class D {}
''');
    var c = library.classes.named('C');
    expect(c.documentation, isEmpty);
    expect(c.instanceFields.named('x').documentation, isEmpty);
    var d = library.classes.named('D');
    expect(d.documentation, isEmpty);
  }

  /// Check that block-based doc comments placed at the end of a class body are
  /// ignored.
  void test_blockEndOfClassBody() async {
    var library = await bootPackageWithLibrary('''
class C {
  int x = 0;
  /** Line 1
   */
}

class D {}
''');
    var c = library.classes.named('C');
    expect(c.documentation, isEmpty);
    expect(c.instanceFields.named('x').documentation, isEmpty);
    var d = library.classes.named('D');
    expect(d.documentation, isEmpty);
  }
}
