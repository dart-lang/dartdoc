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
    defineReflectiveTests(PlacementParametersTopLevelTest);
  });
}

@reflectiveTest
class PlacementParametersTopLevelTest extends Co19TestBase {
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
}
