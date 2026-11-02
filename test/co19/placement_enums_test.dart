// Copyright (c) 2026, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// @assertion Doc comments are associated with the declaration that immediately
/// follows them. They are only considered valid when placed directly before the
/// following types of declarations:
/// ...
/// - A doc comment can be placed before an individual enum value.
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
  /// Check that doc comments in an enum can be recognized before enum values.
  void test_beforeEnumValue1() async {
    var library = await bootPackageWithLibrary('''
enum E {
  /// Line 1
  e0, /// Line 2
  /// Line 3

  /// Line 1
  e1(), /// Line 2
  /// Line 3
  
  /// Line 1
  e2.foo(/** Some comment */) /// Line 2
  /// Line 3
  ;
  const E();
  const E.foo();
}
''');
    var e = library.enums.named('E');
    var e0 = e.publicEnumValues.named('e0');
    expect(e0.documentation, 'Line 1');
    var e1 = e.publicEnumValues.named('e1');
    expect(e1.documentation, '''
Line 2
Line 3
Line 1''');
    var e2 = e.publicEnumValues.named('e2');
    expect(e2.documentation, '''
Line 2
Line 3
Line 1''');
  }

  /// Check that block-based doc comments in an enum can be recognized before
  /// enum values.
  void test_beforeEnumValue2() async {
    var library = await bootPackageWithLibrary('''
enum E {
  /** Line 1 */
  e0, /** Line 2 */
  /** Line 3 
   */

  /** Line 1 */
  e1(), /** Line 2 */
  /** Line 3 
   */
   
  /** Line 1 */
  e2.foo(/** Some comment */) /** Line 2 */
  /** Line 3 
   */
  ;
  const E();
  const E.foo();
}
''');
    var e = library.enums.named('E');
    var e0 = e.publicEnumValues.named('e0');
    expect(e0.documentation, 'Line 1');
    var e1 = e.publicEnumValues.named('e1');
    expect(e1.documentation, 'Line 1');
    var e2 = e.publicEnumValues.named('e2');
    expect(e2.documentation, 'Line 1');
  }
}
