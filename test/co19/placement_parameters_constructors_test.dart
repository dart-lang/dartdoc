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
    defineReflectiveTests(PlacementParametersConstructorsTest);
  });
}

@reflectiveTest
class PlacementParametersConstructorsTest extends Co19TestBase {
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
}
