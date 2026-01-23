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

  /// Check that doc comments can be placed before class constructors.
  void test_beforeClassConstructor1() async {
    var library = await bootPackageWithLibrary('''
class C {
  /// Line 1
  C(); /// Line 2
  /// Line 3

  /// Line 1
  C.named() { /// Line 2
  /// Line 3
  }
  /// Line 4
  
  /// Line 1
  C.redirecting() : this(); /// Line 2
  /// Line 3
  
  /// Line 1
  factory C.factory() { /// Line 2
  /// Line 3
    return C();
  }
  /// Line 4
  
  /// Line 1
  factory C.redirectingFactory() = C.named; /// Line 2
  /// Line 3
  
  /// Line 1
  C._private() { /// Line 2
  /// Line 3
  }
  /// Line 4
}
''');
    var c = library.classes.named('C');
    var c1 = c.constructors.named('C.new');
    expect(c1.documentation, 'Line 1');
    var c2 = c.constructors.named('C.named');
    expect(c2.documentation, '''
Line 2
Line 3
Line 1''');
    var c3 = c.constructors.named('C.redirecting');
    expect(c3.documentation, '''
Line 4
Line 1''');
    var c4 = c.constructors.named('C.factory');
    expect(c4.documentation, '''
Line 2
Line 3
Line 1''');
    var c5 = c.constructors.named('C.redirectingFactory');
    expect(c5.documentation, '''
Line 4
Line 1''');
    var c6 = c.constructors.named('C._private');
    expect(c6.documentation, '''
Line 2
Line 3
Line 1''');
  }

  /// Check that block-based doc comments can be placed before class
  /// constructors.
  void test_beforeClassConstructor2() async {
    var library = await bootPackageWithLibrary('''
class C {
  /** Line 1
   */
  C(); /** Line 2 */
  /** Line 3
   */

  /** Line 1
   */
  C.named() { /** Line 2 */
  /** Line 3
   */
  }
  /** Line 4
   */
  
  /** Line 1
   */
  C.redirecting() : this(); /** Line 2 */
  /** Line 3
   */
  
  /** Line 1
   */
  factory C.factory() { /** Line 2 */
  /** Line 3
   */
     return C();
  }
  /** Line 4
   */
  
  /** Line 1
   */
  factory C.redirectingFactory() = C.named; /** Line 2 */
  /** Line 3
   */
   
  /** Line 1
   */
  C._private() { /** Line 2 */
  /** Line 3
   */
  }
  /** Line 4
   */
}
''');
    var c = library.classes.named('C');
    var c1 = c.constructors.named('C.new');
    expect(c1.documentation, 'Line 1');
    var c2 = c.constructors.named('C.named');
    expect(c2.documentation, 'Line 1');
    var c3 = c.constructors.named('C.redirecting');
    expect(c3.documentation, 'Line 1');
    var c4 = c.constructors.named('C.factory');
    expect(c4.documentation, 'Line 1');
    var c5 = c.constructors.named('C.redirectingFactory');
    expect(c5.documentation, 'Line 1');
    var c6 = c.constructors.named('C._private');
    expect(c6.documentation, 'Line 1');
  }

  /// Check that doc comments can be placed before enum constructors.
  void test_beforeEnumConstructor1() async {
    var library = await bootPackageWithLibrary('''
enum E {
  e0;
  /// Line 1
  const E(); /// Line 2
  /// Line 3

  /// Line 1
  const E.named(); /// Line 2
  /// Line 3

  /// Line 1
  const E.redirecting() : this(); /// Line 2
  /// Line 3

  /// Line 1
  factory E.factory() { /// Line 2
    /// Line 3
    return E.e0;
  }
  /// Line 4
  
  /// Line 1
  const E._private(); /// Line 2
  /// Line 3
}
''');
    var e = library.enums.named('E');
    var c1 = e.constructors.named('E.new');
    expect(c1.documentation, 'Line 1');
    var c2 = e.constructors.named('E.named');
    expect(c2.documentation, '''
Line 2
Line 3
Line 1''');
    var c3 = e.constructors.named('E.redirecting');
    expect(c3.documentation, '''
Line 2
Line 3
Line 1''');
    var c4 = e.constructors.named('E.factory');
    expect(c4.documentation, '''
Line 2
Line 3
Line 1''');
    var c5 = e.constructors.named('E._private');
    expect(c5.documentation, '''
Line 4
Line 1''');
  }

  /// Check that block-based doc comments can be placed before enum constructors.
  void test_beforeEnumConstructor2() async {
    var library = await bootPackageWithLibrary('''
enum E {
  e0;
  /** Line 1
   */
  const E(); /** Line 2 */
  /** Line 3
   */

  /** Line 1
   */
  const E.named(); /** Line 2 */
  /** Line 3
   */

  /** Line 1
   */
  const E.redirecting() : this(); /** Line 2 */
  /** Line 3
   */

  /** Line 1
   */
  factory E.factory() { /** Line 2 */
    /** Line 3
     */
    return E.e0;
  }
  /** Line 4
   */
   
  /** Line 1
   */
  const E._private(); /** Line 2 */
  /** Line 3
   */
}
''');
    var e = library.enums.named('E');
    var c1 = e.constructors.named('E.new');
    expect(c1.documentation, 'Line 1');
    var c2 = e.constructors.named('E.named');
    expect(c2.documentation, 'Line 1');
    var c3 = e.constructors.named('E.redirecting');
    expect(c3.documentation, 'Line 1');
    var c4 = e.constructors.named('E.factory');
    expect(c4.documentation, 'Line 1');
    var c5 = e.constructors.named('E._private');
    expect(c5.documentation, 'Line 1');
  }

  /// Check that doc comments can be placed before class constructors.
  void test_beforeExtensionTypeConstructor1() async {
    var library = await bootPackageWithLibrary('''
extension type ET._(int v) {
  /// Line 1
  ET(this.v); /// Line 2
  /// Line 3

  /// Line 1
  ET.named(this.v) { /// Line 2
  /// Line 3
  }
  /// Line 4
  
  /// Line 1
  ET.redirecting(int v) : this(v); /// Line 2
  /// Line 3
  
  /// Line 1
  factory ET.factory() { /// Line 2
  /// Line 3
    return ET(0);
  }
  /// Line 4
  
  /// Line 1
  factory ET.redirectingFactory(int _) = ET.named; /// Line 2
  /// Line 3
  
  /// Line 1
  ET._private(this.v) { /// Line 2
  /// Line 3
  }
  /// Line 4
}
''');
    var et = library.extensionTypes.named('ET');
    var c1 = et.constructors.named('ET.new');
    expect(c1.documentation, 'Line 1');
    var c2 = et.constructors.named('ET.named');
    expect(c2.documentation, '''
Line 2
Line 3
Line 1''');
    var c3 = et.constructors.named('ET.redirecting');
    expect(c3.documentation, '''
Line 4
Line 1''');
    var c4 = et.constructors.named('ET.factory');
    expect(c4.documentation, '''
Line 2
Line 3
Line 1''');
    var c5 = et.constructors.named('ET.redirectingFactory');
    expect(c5.documentation, '''
Line 4
Line 1''');
    var c6 = et.constructors.named('ET._private');
    expect(c6.documentation, '''
Line 2
Line 3
Line 1''');
  }

  /// Check that block-based doc comments can be placed before class
  /// constructors.
  void test_beforeExtensionTypeConstructor2() async {
    var library = await bootPackageWithLibrary('''
extension type ET._(int v) {
  /** Line 1
   */
  ET(this.v); /** Line 2 */
  /** Line 3
   */

  /** Line 1
   */
  ET.named(this.v) { /** Line 2 */
  /** Line 3
   */
  }
  /** Line 4
   */
  
  /** Line 1
   */
  ET.redirecting(int v) : this(v); /** Line 2 */
  /** Line 3
   */
  
  /** Line 1
   */
  factory ET.factory() { /** Line 2 */
  /** Line 3
   */
     return ET(0);
  }
  /** Line 4
   */
  
  /** Line 1
   */
  factory ET.redirectingFactory() = ET.named; /** Line 2 */
  /** Line 3
   */
   
  /** Line 1
   */ 
  ET._private(this.v) { /** Line 2 */
  /** Line 3
   */
  }
  /** Line 4
   */
}
''');
    var et = library.extensionTypes.named('ET');
    var c1 = et.constructors.named('ET.new');
    expect(c1.documentation, 'Line 1');
    var c2 = et.constructors.named('ET.named');
    expect(c2.documentation, 'Line 1');
    var c3 = et.constructors.named('ET.redirecting');
    expect(c3.documentation, 'Line 1');
    var c4 = et.constructors.named('ET.factory');
    expect(c4.documentation, 'Line 1');
    var c5 = et.constructors.named('ET.redirectingFactory');
    expect(c5.documentation, 'Line 1');
    var c6 = et.constructors.named('ET._private');
    expect(c6.documentation, 'Line 1');
  }
}
