// Copyright (c) 2026, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// @assertion Doc comments are associated with the declaration that immediately
/// follows them. They are only considered valid when placed directly before the
/// following types of declarations:
/// ...
/// - Constructors (including factory and named constructors)
/// - Methods (instance, static)
/// - Operators
/// - Fields (instance, static)
/// - Getters or setters
/// @author sgrekhov22@gmail.com
library;

import 'package:test/test.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

import '../src/utils.dart';
import 'co19_test_base.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(PlacementTest);
  });
}

@reflectiveTest
class PlacementTest extends Co19TestBase {
  /// Check that doc comments in a class can be recognized before user-defined
  /// operators.
  void test_beforeClassOperator1() async {
    var library = await bootPackageWithLibrary('''
class C {
  /// Line 1
  int operator +(Object? other) => 1; /// Line 2
  /// Line 3

  /// Line 1
  int operator -(Object? other) { /// Line 2
    /// Line 3
    return -1;
  }
  /// Line 4
}
''');
    var c = library.classes.named('C');
    var op1 = c.instanceOperators.named('operator +');
    expect(op1.documentation, 'Line 1');
    var op2 = c.instanceOperators.named('operator -');
    expect(op2.documentation, '''
Line 2
Line 3
Line 1''');
  }

  /// Check that block-based doc comments in a class can be recognized before
  /// user-defined operators.
  void test_beforeClassOperator2() async {
    var library = await bootPackageWithLibrary('''
class C {
  /** Line 1
   */
  int operator +(Object? other) => 1; /** Line 2 */
  /** Line 3
   */

  /** Line 1
   */
  int operator -(Object? other) { /** Line 2 */
  /** Line 3
   */
    return -1;
  }
  /** Line 4
   */
}
''');
    var c = library.classes.named('C');
    var op1 = c.instanceOperators.named('operator +');
    expect(op1.documentation, 'Line 1');
    var op2 = c.instanceOperators.named('operator -');
    expect(op2.documentation, 'Line 1');
  }

  /// Check that doc comments in a mixin can be recognized before user-defined
  /// operators.
  void test_beforeMixinOperator1() async {
    var library = await bootPackageWithLibrary('''
mixin M {
  /// Line 1
  int operator +(Object? other) => 1; /// Line 2
  /// Line 3

  /// Line 1
  int operator -(Object? other) { /// Line 2
    /// Line 3
    return -1;
  }
  /// Line 4
}
''');
    var m = library.mixins.named('M');
    var op1 = m.instanceOperators.named('operator +');
    expect(op1.documentation, 'Line 1');
    var op2 = m.instanceOperators.named('operator -');
    expect(op2.documentation, '''
Line 2
Line 3
Line 1''');
  }

  /// Check that block-based doc comments in a mixin can be recognized before
  /// user-defined operators.
  void test_beforeMixinOperator2() async {
    var library = await bootPackageWithLibrary('''
mixin M {
  /** Line 1
   */
  int operator +(Object? other) => 1; /** Line 2 */
  /** Line 3
   */

  /** Line 1
   */
  int operator -(Object? other) { /** Line 2 */
  /** Line 3
   */
    return -1;
  }
  /** Line 4
   */
}
''');
    var m = library.mixins.named('M');
    var op1 = m.instanceOperators.named('operator +');
    expect(op1.documentation, 'Line 1');
    var op2 = m.instanceOperators.named('operator -');
    expect(op2.documentation, 'Line 1');
  }

  /// Check that doc comments in an enum can be recognized before user-defined
  /// operators.
  void test_beforeEnumOperator1() async {
    var library = await bootPackageWithLibrary('''
enum E {
  e0;
  /// Line 1
  int operator +(Object? other) => 1; /// Line 2
  /// Line 3

  /// Line 1
  int operator -(Object? other) { /// Line 2
    /// Line 3
    return -1;
  }
  /// Line 4
}
''');
    var e = library.enums.named('E');
    var op1 = e.instanceOperators.named('operator +');
    expect(op1.documentation, 'Line 1');
    var op2 = e.instanceOperators.named('operator -');
    expect(op2.documentation, '''
Line 2
Line 3
Line 1''');
  }

  /// Check that block-based doc comments in an enum can be recognized before
  /// user-defined operators.
  void test_beforeEnumOperator2() async {
    var library = await bootPackageWithLibrary('''
enum E {
  e0;
  /** Line 1
   */
  int operator +(Object? other) => 1; /** Line 2 */
  /** Line 3
   */

  /** Line 1
   */
  int operator -(Object? other) { /** Line 2 */
  /** Line 3
   */
    return -1;
  }
  /** Line 4
   */
}
''');
    var e = library.enums.named('E');
    var op1 = e.instanceOperators.named('operator +');
    expect(op1.documentation, 'Line 1');
    var op2 = e.instanceOperators.named('operator -');
    expect(op2.documentation, 'Line 1');
  }

  /// Check that doc comments in an extension can be recognized before
  /// user-defined operators.
  void test_beforeExtensionOperator1() async {
    var library = await bootPackageWithLibrary('''
class A {}

extension Ext on A {
  /// Line 1
  int operator +(Object? other) => 1; /// Line 2
  /// Line 3

  /// Line 1
  int operator -(Object? other) { /// Line 2
    /// Line 3
    return -1;
  }
  /// Line 4
}
''');
    var ext = library.extensions.named('Ext');
    var op1 = ext.instanceOperators.named('operator +');
    expect(op1.documentation, 'Line 1');
    var op2 = ext.instanceOperators.named('operator -');
    expect(op2.documentation, '''
Line 2
Line 3
Line 1''');
  }

  /// Check that block-based doc comments in an extension can be recognized
  /// before user-defined operators.
  void test_beforeExtensionOperator2() async {
    var library = await bootPackageWithLibrary('''
class A {}

extension Ext on A {
  /** Line 1
   */
  int operator +(Object? other) => 1; /** Line 2 */
  /** Line 3
   */

  /** Line 1
   */
  int operator -(Object? other) { /** Line 2 */
  /** Line 3
   */
    return -1;
  }
  /** Line 4
   */
}
''');
    var ext = library.extensions.named('Ext');
    var op1 = ext.instanceOperators.named('operator +');
    expect(op1.documentation, 'Line 1');
    var op2 = ext.instanceOperators.named('operator -');
    expect(op2.documentation, 'Line 1');
  }

  /// Check that doc comments in an extension type can be recognized before
  /// user-defined operators.
  void test_beforeExtensionTypeOperator1() async {
    var library = await bootPackageWithLibrary('''
extension type ET(int v) {
  /// Line 1
  int operator +(Object? other) => 1; /// Line 2
  /// Line 3

  /// Line 1
  int operator -(Object? other) { /// Line 2
    /// Line 3
    return -1;
  }
  /// Line 4
}
''');
    var et = library.extensionTypes.named('ET');
    var op1 = et.instanceOperators.named('operator +');
    expect(op1.documentation, 'Line 1');
    var op2 = et.instanceOperators.named('operator -');
    expect(op2.documentation, '''
Line 2
Line 3
Line 1''');
  }

  /// Check that block-based doc comments in an extension type can be recognized
  /// before user-defined operators.
  void test_beforeExtensionTypeOperator2() async {
    var library = await bootPackageWithLibrary('''
extension type ET(int v) {
  /** Line 1
   */
  int operator +(Object? other) => 1; /** Line 2 */
  /** Line 3
   */

  /** Line 1
   */
  int operator -(Object? other) { /** Line 2 */
  /** Line 3
   */
    return -1;
  }
  /** Line 4
   */
}
''');
    var et = library.extensionTypes.named('ET');
    var op1 = et.instanceOperators.named('operator +');
    expect(op1.documentation, 'Line 1');
    var op2 = et.instanceOperators.named('operator -');
    expect(op2.documentation, 'Line 1');
  }
}
