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
  /// Check that doc comments can be recognized before class methods (instance
  /// and static).
  void test_beforeClassMethod1() async {
    var library = await bootPackageWithLibrary('''
class C {
  /// Line 1
  static int staticMethod() => 0; /// Line 2
  /// Line 3
  
  /// Line 1
  static void staticMethodWithBody() { /// Line 2
    /// Line 3
    void foo() {}
  }
  /// Line 4
  
  /// Line 1
  static void _privateStaticMethod() => 0; /// Line 2
  /// Line 3

  /// Line 1
  int instanceMethod() => 0; /// Line 2
  /// Line 3

  /// Line 1
  void instanceMethodWithBody() { /// Line 2
    /// Line 3
    void foo() {}
  }
  /// Line 4
    
  /// Line 1
  void _privateInstanceMethod() { /// Line 2
  /// Line 3
  }
  /// Line 4
}
''');
    var c = library.classes.named('C');
    var s = c.staticMethods.named('staticMethod');
    expect(s.documentation, 'Line 1');
    var sBody = c.staticMethods.named('staticMethodWithBody');
    expect(sBody.documentation, '''
Line 2
Line 3
Line 1''');
    var s2 = c.staticMethods.named('_privateStaticMethod');
    expect(s2.documentation, '''
Line 4
Line 1''');

    var m = c.instanceMethods.named('instanceMethod');
    expect(m.documentation, '''
Line 2
Line 3
Line 1''');
    var mBody = c.instanceMethods.named('instanceMethodWithBody');
    expect(mBody.documentation, '''
Line 2
Line 3
Line 1''');
    var m2 = c.instanceMethods.named('_privateInstanceMethod');
    expect(m2.documentation, '''
Line 4
Line 1''');
  }

  /// Check that block-based doc comments can be recognized before class methods
  /// (instance and static).
  void test_beforeClassMethod2() async {
    var library = await bootPackageWithLibrary('''
class C {
  /** Line 1
   */
  static int staticMethod() => 0; /** Line 2 */
  /** Line 3
   */

  /** Line 1
   */
  static void staticMethodWithBody() { /** Line 2 */
  /** Line 3
   */
    void foo() {}
  }
  /** Line 4
   */
  
  /** Line 1
   */
  static void _privateStaticMethod() => 0; /** Line 2 */
  /** Line 3
   */

  /** Line 1
   */
  int instanceMethod() => 0; /** Line 2 */
  /** Line 3
   */

  /** Line 1
   */
  void instanceMethodWithBody() { /** Line 2 */
  /** Line 3
   */
    void foo() {}
  }
  /** Line 4
   */
   
  /** Line 1
   */
  void _privateInstanceMethod() { /** Line 2 */
  /** Line 3
   */
  }
  /** Line 4
   */
}
''');
    var c = library.classes.named('C');
    var s = c.staticMethods.named('staticMethod');
    expect(s.documentation, 'Line 1');
    var sBody = c.staticMethods.named('staticMethodWithBody');
    expect(sBody.documentation, 'Line 1');
    var s2 = c.staticMethods.named('_privateStaticMethod');
    expect(s2.documentation, 'Line 1');
    var m = c.instanceMethods.named('instanceMethod');
    expect(m.documentation, 'Line 1');
    var mBody = c.instanceMethods.named('instanceMethodWithBody');
    expect(mBody.documentation, 'Line 1');
    var m2 = c.instanceMethods.named('_privateInstanceMethod');
    expect(m2.documentation, 'Line 1');
  }

  /// Check that doc comments can be recognized before mixin methods (instance
  /// and static).
  void test_beforeMixinMethod1() async {
    var library = await bootPackageWithLibrary('''
mixin M {
  /// Line 1
  static int staticMethod() => 0; /// Line 2
  /// Line 3
  
  /// Line 1
  static void staticMethodWithBody() { /// Line 2
    /// Line 3
    void foo() {}
  }
  /// Line 4
  
  /// Line 1
  static void _privateStaticMethod() => 0; /// Line 2
  /// Line 3

  /// Line 1
  int instanceMethod() => 0; /// Line 2
  /// Line 3

  /// Line 1
  void instanceMethodWithBody() { /// Line 2
    /// Line 3
    void foo() {}
  }
  /// Line 4
    
  /// Line 1
  void _privateInstanceMethod() { /// Line 2
  /// Line 3
  }
  /// Line 4
}
''');
    var mixinM = library.mixins.named('M');
    var s = mixinM.staticMethods.named('staticMethod');
    expect(s.documentation, 'Line 1');
    var sBody = mixinM.staticMethods.named('staticMethodWithBody');
    expect(sBody.documentation, '''
Line 2
Line 3
Line 1''');
    var s2 = mixinM.staticMethods.named('_privateStaticMethod');
    expect(s2.documentation, '''
Line 4
Line 1''');

    var m = mixinM.instanceMethods.named('instanceMethod');
    expect(m.documentation, '''
Line 2
Line 3
Line 1''');
    var mBody = mixinM.instanceMethods.named('instanceMethodWithBody');
    expect(mBody.documentation, '''
Line 2
Line 3
Line 1''');
    var m2 = mixinM.instanceMethods.named('_privateInstanceMethod');
    expect(m2.documentation, '''
Line 4
Line 1''');
  }

  /// Check that block-based doc comments can be recognized before mixin methods
  /// (instance and static).
  void test_beforeMixinMethod2() async {
    var library = await bootPackageWithLibrary('''
mixin M {
  /** Line 1
   */
  static int staticMethod() => 0; /** Line 2 */
  /** Line 3
   */

  /** Line 1
   */
  static void staticMethodWithBody() { /** Line 2 */
  /** Line 3
   */
    void foo() {}
  }
  /** Line 4
   */
  
  /** Line 1
   */
  static void _privateStaticMethod() => 0; /** Line 2 */
  /** Line 3
   */

  /** Line 1
   */
  int instanceMethod() => 0; /** Line 2 */
  /** Line 3
   */

  /** Line 1
   */
  void instanceMethodWithBody() { /** Line 2 */
  /** Line 3
   */
    void foo() {}
  }
  /** Line 4
   */
   
  /** Line 1
   */
  void _privateInstanceMethod() { /** Line 2 */
  /** Line 3
   */
  }
  /** Line 4
   */
}
''');
    var mixinM = library.mixins.named('M');
    var s = mixinM.staticMethods.named('staticMethod');
    expect(s.documentation, 'Line 1');
    var sBody = mixinM.staticMethods.named('staticMethodWithBody');
    expect(sBody.documentation, 'Line 1');
    var s2 = mixinM.staticMethods.named('_privateStaticMethod');
    expect(s2.documentation, 'Line 1');
    var m = mixinM.instanceMethods.named('instanceMethod');
    expect(m.documentation, 'Line 1');
    var mBody = mixinM.instanceMethods.named('instanceMethodWithBody');
    expect(mBody.documentation, 'Line 1');
    var m2 = mixinM.instanceMethods.named('_privateInstanceMethod');
    expect(m2.documentation, 'Line 1');
  }

  /// Check that doc comments can be recognized before enum methods (instance
  /// and static).
  void test_beforeEnumMethod1() async {
    var library = await bootPackageWithLibrary('''
enum E {
  e0;
  /// Line 1
  static int staticMethod() => 0; /// Line 2
  /// Line 3
  
  /// Line 1
  static void staticMethodWithBody() { /// Line 2
    /// Line 3
    void foo() {}
  }
  /// Line 4
  
  /// Line 1
  static void _privateStaticMethod() => 0; /// Line 2
  /// Line 3

  /// Line 1
  int instanceMethod() => 0; /// Line 2
  /// Line 3

  /// Line 1
  void instanceMethodWithBody() { /// Line 2
    /// Line 3
    void foo() {}
  }
  /// Line 4
  
  /// Line 1
  void _privateInstanceMethod() { /// Line 2
  /// Line 3
  }
  /// Line 4
}
''');
    var e = library.enums.named('E');
    var s = e.staticMethods.named('staticMethod');
    expect(s.documentation, 'Line 1');
    var sBody = e.staticMethods.named('staticMethodWithBody');
    expect(sBody.documentation, '''
Line 2
Line 3
Line 1''');
    var s2 = e.staticMethods.named('_privateStaticMethod');
    expect(s2.documentation, '''
Line 4
Line 1''');
    var m = e.instanceMethods.named('instanceMethod');
    expect(m.documentation, '''
Line 2
Line 3
Line 1''');
    var mBody = e.instanceMethods.named('instanceMethodWithBody');
    expect(mBody.documentation, '''
Line 2
Line 3
Line 1''');
    var m2 = e.instanceMethods.named('_privateInstanceMethod');
    expect(m2.documentation, '''
Line 4
Line 1''');
  }

  /// Check that block-based doc comments can be recognized before enum methods
  /// (instance and static).
  void test_beforeEnumMethod2() async {
    var library = await bootPackageWithLibrary('''
enum E {
  e0;
  /** Line 1
   */
  static int staticMethod() => 0; /** Line 2 */
  /** Line 3
   */

  /** Line 1
   */
  static void staticMethodWithBody() { /** Line 2 */
  /** Line 3
   */
    void foo() {}
  }
  /** Line 4
   */
  
  /** Line 1
   */
  static void _privateStaticMethod() => 0; /** Line 2 */
  /** Line 3
   */

  /** Line 1
   */
  int instanceMethod() => 0; /** Line 2 */
  /** Line 3
   */

  /** Line 1
   */
  void instanceMethodWithBody() { /** Line 2 */
  /** Line 3
   */
    void foo() {}
  }
  /** Line 4
   */
   
  /** Line 1
   */
  void _privateInstanceMethod() { /** Line 2 */
  /** Line 3
   */
  }
  /** Line 4
   */
}
''');
    var e = library.enums.named('E');
    var s = e.staticMethods.named('staticMethod');
    expect(s.documentation, 'Line 1');
    var sBody = e.staticMethods.named('staticMethodWithBody');
    expect(sBody.documentation, 'Line 1');
    var s2 = e.staticMethods.named('_privateStaticMethod');
    expect(s2.documentation, 'Line 1');
    var m = e.instanceMethods.named('instanceMethod');
    expect(m.documentation, 'Line 1');
    var mBody = e.instanceMethods.named('instanceMethodWithBody');
    expect(mBody.documentation, 'Line 1');
    var m2 = e.instanceMethods.named('_privateInstanceMethod');
    expect(m2.documentation, 'Line 1');
  }

  /// Check that doc comments can be recognized before extension methods
  /// (instance and static).
  void test_beforeExtensionMethod1() async {
    var library = await bootPackageWithLibrary('''
class A {}

extension Ext on A {
  /// Line 1
  static int staticMethod() => 0; /// Line 2
  /// Line 3
  
  /// Line 1
  static void staticMethodWithBody() { /// Line 2
    /// Line 3
    void foo() {}
  }
  /// Line 4
  
  /// Line 1
  static void _privateStaticMethod() => 0; /// Line 2
  /// Line 3

  /// Line 1
  int instanceMethod() => 0; /// Line 2
  /// Line 3

  /// Line 1
  void instanceMethodWithBody() { /// Line 2
    /// Line 3
    void foo() {}
  }
  /// Line 4
  
  /// Line 1
  void _privateInstanceMethod() { /// Line 2
  /// Line 3
  }
  /// Line 4
}
''');
    var ext = library.extensions.named('Ext');
    var s = ext.staticMethods.named('staticMethod');
    expect(s.documentation, 'Line 1');
    var sBody = ext.staticMethods.named('staticMethodWithBody');
    expect(sBody.documentation, '''
Line 2
Line 3
Line 1''');
    var s2 = ext.staticMethods.named('_privateStaticMethod');
    expect(s2.documentation, '''
Line 4
Line 1''');
    var m = ext.instanceMethods.named('instanceMethod');
    expect(m.documentation, '''
Line 2
Line 3
Line 1''');
    var mBody = ext.instanceMethods.named('instanceMethodWithBody');
    expect(mBody.documentation, '''
Line 2
Line 3
Line 1''');
    var m2 = ext.instanceMethods.named('_privateInstanceMethod');
    expect(m2.documentation, '''
Line 4
Line 1''');
  }

  /// Check that block-based doc comments can be recognized before extension
  /// methods (instance and static).
  void test_beforeExtensionMethod2() async {
    var library = await bootPackageWithLibrary('''
class A {}

extension Ext on A {
  /** Line 1
   */
  static int staticMethod() => 0; /** Line 2 */
  /** Line 3
   */

  /** Line 1
   */
  static void staticMethodWithBody() { /** Line 2 */
  /** Line 3
   */
    void foo() {}
  }
  /** Line 4
   */
  
  /** Line 1
   */
  static void _privateStaticMethod() => 0; /** Line 2 */
  /** Line 3
   */

  /** Line 1
   */
  int instanceMethod() => 0; /** Line 2 */
  /** Line 3
   */

  /** Line 1
   */
  void instanceMethodWithBody() { /** Line 2 */
  /** Line 3
   */
    void foo() {}
  }
  /** Line 4
   */
   
  /** Line 1
   */ 
  void _privateInstanceMethod() { /** Line 2 */
  /** Line 3
   */
  }
  /** Line 4
   */
}
''');
    var ext = library.extensions.named('Ext');
    var s = ext.staticMethods.named('staticMethod');
    expect(s.documentation, 'Line 1');
    var sBody = ext.staticMethods.named('staticMethodWithBody');
    expect(sBody.documentation, 'Line 1');
    var s2 = ext.staticMethods.named('_privateStaticMethod');
    expect(s2.documentation, 'Line 1');
    var m = ext.instanceMethods.named('instanceMethod');
    expect(m.documentation, 'Line 1');
    var mBody = ext.instanceMethods.named('instanceMethodWithBody');
    expect(mBody.documentation, 'Line 1');
    var m2 = ext.instanceMethods.named('_privateInstanceMethod');
    expect(m2.documentation, 'Line 1');
  }

  /// Check that doc comments can be recognized before extension type methods
  /// (instance and static).
  void test_beforeExtensionTypeMethod1() async {
    var library = await bootPackageWithLibrary('''
extension type ET(int v) {
  /// Line 1
  static int staticMethod() => 0; /// Line 2
  /// Line 3
  
  /// Line 1
  static void staticMethodWithBody() { /// Line 2
    /// Line 3
    void foo() {}
  }
  /// Line 4
  
  /// Line 1
  static void _privateStaticMethod() => 0; /// Line 2
  /// Line 3

  /// Line 1
  int instanceMethod() => 0; /// Line 2
  /// Line 3

  /// Line 1
  void instanceMethodWithBody() { /// Line 2
    /// Line 3
    void foo() {}
  }
  /// Line 4
  
  /// Line 1
  void _privateInstanceMethod() { /// Line 2
  /// Line 3
  }
  /// Line 4
}
''');
    var et = library.extensionTypes.named('ET');
    var s = et.staticMethods.named('staticMethod');
    expect(s.documentation, 'Line 1');
    var sBody = et.staticMethods.named('staticMethodWithBody');
    expect(sBody.documentation, '''
Line 2
Line 3
Line 1''');
    var s2 = et.staticMethods.named('_privateStaticMethod');
    expect(s2.documentation, '''
Line 4
Line 1''');
    var m = et.instanceMethods.named('instanceMethod');
    expect(m.documentation, '''
Line 2
Line 3
Line 1''');
    var mBody = et.instanceMethods.named('instanceMethodWithBody');
    expect(mBody.documentation, '''
Line 2
Line 3
Line 1''');
    var m2 = et.instanceMethods.named('_privateInstanceMethod');
    expect(m2.documentation, '''
Line 4
Line 1''');
  }

  /// Check that block-based doc comments can be recognized before extension
  /// type methods (instance and static).
  void test_beforeExtensionTypeMethod2() async {
    var library = await bootPackageWithLibrary('''
extension type ET(int v) {
  /** Line 1
   */
  static int staticMethod() => 0; /** Line 2 */
  /** Line 3
   */

  /** Line 1
   */
  static void staticMethodWithBody() { /** Line 2 */
  /** Line 3
   */
    void foo() {}
  }
  /** Line 4
   */
  
  /** Line 1
   */
  static void _privateStaticMethod() => 0; /** Line 2 */
  /** Line 3
   */

  /** Line 1
   */
  int instanceMethod() => 0; /** Line 2 */
  /** Line 3
   */

  /** Line 1
   */
  void instanceMethodWithBody() { /** Line 2 */
  /** Line 3
   */
    void foo() {}
  }
  /** Line 4
   */
   
  /** Line 1
   */ 
  void _privateInstanceMethod() { /** Line 2 */
  /** Line 3
   */
  }
  /** Line 4
   */
}
''');
    var et = library.extensionTypes.named('ET');
    var s = et.staticMethods.named('staticMethod');
    expect(s.documentation, 'Line 1');
    var sBody = et.staticMethods.named('staticMethodWithBody');
    expect(sBody.documentation, 'Line 1');
    var s2 = et.staticMethods.named('_privateStaticMethod');
    expect(s2.documentation, 'Line 1');
    var m = et.instanceMethods.named('instanceMethod');
    expect(m.documentation, 'Line 1');
    var mBody = et.instanceMethods.named('instanceMethodWithBody');
    expect(mBody.documentation, 'Line 1');
    var m2 = et.instanceMethods.named('_privateInstanceMethod');
    expect(m2.documentation, 'Line 1');
  }
}
