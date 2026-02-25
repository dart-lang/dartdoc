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
  /// Check that doc comments can be recognized before class fields (instance
  /// and static).
  void test_beforeClassField1() async {
    var library = await bootPackageWithLibrary('''
abstract class C {
  /// Line 1
  static int staticField = 0; /// Line 2
  /// Line 3
  
  /// Line 1
  static int staticFieldWithInitializer = () { /// Line 2
    /// Line 3
    return 1;
  }();
  /// Line 4
  
  /// Line 1
  external static int externalStaticField; /// Line 2
  /// Line 3

  /// Line 1
  int instanceField = 0; /// Line 2
  /// Line 3

  /// Line 1
  int instancesFieldWithInitializer = () { /// Line 2
    /// Line 3
    return 1;
  }();
  /// Line 4
    
  /// Line 1
  abstract int abstractInstanceField; /// Line 2
  /// Line 3

  /// Line 1
  external int externalInstanceField; /// Line 2
  /// Line 3
}
''');
    var c = library.classes.named('C');
    var s1 = c.staticFields.named('staticField');
    expect(s1.documentation, 'Line 1');
    var s2 = c.staticFields.named('staticFieldWithInitializer');
    expect(s2.documentation, '''
Line 2
Line 3
Line 1''');
    var s3 = c.staticFields.named('externalStaticField');
    expect(s3.documentation, '''
Line 4
Line 1''');

    var m1 = c.instanceFields.named('instanceField');
    expect(m1.documentation, '''
Line 2
Line 3
Line 1''');
    var m2 = c.instanceFields.named('instancesFieldWithInitializer');
    expect(m2.documentation, '''
Line 2
Line 3
Line 1''');
    var m3 = c.instanceFields.named('abstractInstanceField');
    expect(m3.documentation, '''
Line 4
Line 1''');
    var m4 = c.instanceFields.named('externalInstanceField');
    expect(m4.documentation, '''
Line 2
Line 3
Line 1''');
  }

  /// Check that block-based doc comments can be recognized before class fields
  /// (instance and static).
  void test_beforeClassField2() async {
    var library = await bootPackageWithLibrary('''
class C {
  /** Line 1
   */
  static int staticField = 0; /** Line 2 */
  /** Line 3
   */

  /** Line 1
   */
  static int staticFieldWithInitializer = () { /** Line 2 */
    /** Line 3 */
    return 1;
  }();
  /** Line 4
   */

  /** Line 1
   */
  external static int externalStaticField; /** Line 2 */
  /** Line 3
   */

  /** Line 1
   */
  int instanceField = 0; /** Line 2 */
  /** Line 3
   */

  /** Line 1
   */
  int instanceFieldWithInitializer = () { /** Line 2 */
    /** Line 3 */
    return 1;
  }();
  /** Line 4
   */
   
  /** Line 1
   */
  abstract int abstractInstanceField; /** Line 2 */
  /** Line 3
   */

  /** Line 1
   */
  external int externalInstanceField; /** Line 2 */
  /** Line 3
   */
}
''');
    var c = library.classes.named('C');
    var s1 = c.staticFields.named('staticField');
    expect(s1.documentation, 'Line 1');
    var s2 = c.staticFields.named('staticFieldWithInitializer');
    expect(s2.documentation, 'Line 1');
    var s3 = c.staticFields.named('externalStaticField');
    expect(s3.documentation, 'Line 1');
    var m1 = c.instanceFields.named('instanceField');
    expect(m1.documentation, 'Line 1');
    var m2 = c.instanceFields.named('instanceFieldWithInitializer');
    expect(m2.documentation, 'Line 1');
    var m3 = c.instanceFields.named('abstractInstanceField');
    expect(m3.documentation, 'Line 1');
    var m4 = c.instanceFields.named('externalInstanceField');
    expect(m4.documentation, 'Line 1');
  }

  /// Check that doc comments can be recognized before mixin fields (instance
  /// and static).
  void test_beforeMixinField1() async {
    var library = await bootPackageWithLibrary('''
mixin M {
  /// Line 1
  static int staticField = 0; /// Line 2
  /// Line 3
  
  /// Line 1
  static int staticFieldWithInitializer = () { /// Line 2
    /// Line 3
    return 1;
  }();
  /// Line 4
  
  /// Line 1
  external static int externalStaticField; /// Line 2
  /// Line 3

  /// Line 1
  int instanceField = 0; /// Line 2
  /// Line 3

  /// Line 1
  int instancesFieldWithInitializer = () { /// Line 2
    /// Line 3
    return 1;
  }();
  /// Line 4
    
  /// Line 1
  abstract int abstractInstanceField; /// Line 2
  /// Line 3

  /// Line 1
  external int externalInstanceField; /// Line 2
  /// Line 3
}
''');
    var mixinM = library.mixins.named('M');
    var s1 = mixinM.staticFields.named('staticField');
    expect(s1.documentation, 'Line 1');
    var s2 = mixinM.staticFields.named('staticFieldWithInitializer');
    expect(s2.documentation, '''
Line 2
Line 3
Line 1''');
    var s3 = mixinM.staticFields.named('externalStaticField');
    expect(s3.documentation, '''
Line 4
Line 1''');

    var m1 = mixinM.instanceFields.named('instanceField');
    expect(m1.documentation, '''
Line 2
Line 3
Line 1''');
    var m2 = mixinM.instanceFields.named('instancesFieldWithInitializer');
    expect(m2.documentation, '''
Line 2
Line 3
Line 1''');
    var m3 = mixinM.instanceFields.named('abstractInstanceField');
    expect(m3.documentation, '''
Line 4
Line 1''');
    var m4 = mixinM.instanceFields.named('externalInstanceField');
    expect(m4.documentation, '''
Line 2
Line 3
Line 1''');
  }

  /// Check that block-based doc comments can be recognized before mixin fields
  /// (instance and static).
  void test_beforeMixinField2() async {
    var library = await bootPackageWithLibrary('''
mixin M {
  /** Line 1
   */
  static int staticField = 0; /** Line 2 */
  /** Line 3
   */

  /** Line 1
   */
  static int staticFieldWithInitializer = () { /** Line 2 */
    /** Line 3 */
    return 1;
  }();
  /** Line 4
   */

  /** Line 1
   */
  external static int externalStaticField; /** Line 2 */
  /** Line 3
   */

  /** Line 1
   */
  int instanceField = 0; /** Line 2 */
  /** Line 3
   */

  /** Line 1
   */
  int instanceFieldWithInitializer = () { /** Line 2 */
    /** Line 3 */
    return 1;
  }();
  /** Line 4
   */
   
  /** Line 1
   */
  abstract int abstractInstanceField; /** Line 2 */
  /** Line 3
   */

  /** Line 1
   */
  external int externalInstanceField; /** Line 2 */
  /** Line 3
   */
}
''');
    var mixinM = library.mixins.named('M');
    var s1 = mixinM.staticFields.named('staticField');
    expect(s1.documentation, 'Line 1');
    var s2 = mixinM.staticFields.named('staticFieldWithInitializer');
    expect(s2.documentation, 'Line 1');
    var s3 = mixinM.staticFields.named('externalStaticField');
    expect(s3.documentation, 'Line 1');
    var m1 = mixinM.instanceFields.named('instanceField');
    expect(m1.documentation, 'Line 1');
    var m2 = mixinM.instanceFields.named('instanceFieldWithInitializer');
    expect(m2.documentation, 'Line 1');
    var m3 = mixinM.instanceFields.named('abstractInstanceField');
    expect(m3.documentation, 'Line 1');
    var m4 = mixinM.instanceFields.named('externalInstanceField');
    expect(m4.documentation, 'Line 1');
  }

  /// Check that doc comments can be recognized before enum fields (instance and
  /// static).
  void test_beforeEnumField1() async {
    var library = await bootPackageWithLibrary('''
enum E {
  e0;
  /// Line 1
  static int staticField = 0; /// Line 2
  /// Line 3
  
  /// Line 1
  static int staticFieldWithInitializer = () { /// Line 2
    /// Line 3
    return 1;
  }();
  /// Line 4
  
  /// Line 1
  external static int externalStaticField; /// Line 2
  /// Line 3

  /// Line 1
  final int instanceField = 0; /// Line 2
  /// Line 3

  /// Line 1
  final int instancesFieldWithInitializer = () { /// Line 2
    /// Line 3
    return 1;
  }();
  /// Line 4
    
  /// Line 1
  abstract final int abstractInstanceField; /// Line 2
  /// Line 3

  /// Line 1
  external final int externalInstanceField; /// Line 2
  /// Line 3
}
''');
    var e = library.enums.named('E');
    var s1 = e.staticFields.named('staticField');
    expect(s1.documentation, 'Line 1');
    var s2 = e.staticFields.named('staticFieldWithInitializer');
    expect(s2.documentation, '''
Line 2
Line 3
Line 1''');
    var s3 = e.staticFields.named('externalStaticField');
    expect(s3.documentation, '''
Line 4
Line 1''');
    var m1 = e.instanceFields.named('instanceField');
    expect(m1.documentation, '''
Line 2
Line 3
Line 1''');
    var m2 = e.instanceFields.named('instancesFieldWithInitializer');
    expect(m2.documentation, '''
Line 2
Line 3
Line 1''');
    var m3 = e.instanceFields.named('abstractInstanceField');
    expect(m3.documentation, '''
Line 4
Line 1''');
    var m4 = e.instanceFields.named('externalInstanceField');
    expect(m4.documentation, '''
Line 2
Line 3
Line 1''');
  }

  /// Check that block-based doc comments can be recognized before enum fields
  /// (instance and static).
  void test_beforeEnumField2() async {
    var library = await bootPackageWithLibrary('''
enum E {
  e0;
  /** Line 1
   */
  static int staticField = 0; /** Line 2 */
  /** Line 3
   */

  /** Line 1
   */
  static int staticFieldWithInitializer = () { /** Line 2 */
    /** Line 3 */
    return 1;
  }();
  /** Line 4
   */

  /** Line 1
   */
  external static int externalStaticField; /** Line 2 */
  /** Line 3
   */

  /** Line 1
   */
  final int instanceField = 0; /** Line 2 */
  /** Line 3
   */

  /** Line 1
   */
  final int instanceFieldWithInitializer = () { /** Line 2 */
    /** Line 3 */
    return 1;
  }();
  /** Line 4
   */
   
  /** Line 1
   */
  abstract final int abstractInstanceField; /** Line 2 */
  /** Line 3
   */

  /** Line 1
   */
  external final int externalInstanceField; /** Line 2 */
  /** Line 3
   */
}
''');
    var e = library.enums.named('E');
    var s1 = e.staticFields.named('staticField');
    expect(s1.documentation, 'Line 1');
    var s2 = e.staticFields.named('staticFieldWithInitializer');
    expect(s2.documentation, 'Line 1');
    var s3 = e.staticFields.named('externalStaticField');
    expect(s3.documentation, 'Line 1');
    var m1 = e.instanceFields.named('instanceField');
    expect(m1.documentation, 'Line 1');
    var m2 = e.instanceFields.named('instanceFieldWithInitializer');
    expect(m2.documentation, 'Line 1');
    var m3 = e.instanceFields.named('abstractInstanceField');
    expect(m3.documentation, 'Line 1');
    var m4 = e.instanceFields.named('externalInstanceField');
    expect(m4.documentation, 'Line 1');
  }

  /// Check that doc comments can be recognized before extension's static fields
  void test_beforeExtensionField1() async {
    var library = await bootPackageWithLibrary('''
class A {}

extension Ext on A {
  /// Line 1
  static int staticField = 0; /// Line 2
  /// Line 3
  
  /// Line 1
  static int staticFieldWithInitializer = () { /// Line 2
    /// Line 3
    return 1;
  }();
  /// Line 4
  
  /// Line 1
  external static int externalStaticField; /// Line 2
  /// Line 3
  
  /// Line 1
  external int externalInstanceField; /// Line 2
  /// Line 3

}
''');
    var ext = library.extensions.named('Ext');
    var s1 = ext.staticFields.named('staticField');
    expect(s1.documentation, 'Line 1');
    var s2 = ext.staticFields.named('staticFieldWithInitializer');
    expect(s2.documentation, '''
Line 2
Line 3
Line 1''');
    var s3 = ext.staticFields.named('externalStaticField');
    expect(s3.documentation, '''
Line 4
Line 1''');
    var m3 = ext.instanceFields.named('externalInstanceField');
    expect(m3.documentation, '''
Line 2
Line 3
Line 1''');
  }

  /// Check that block-based doc comments can be recognized before extension's
  /// static fields.
  void test_beforeExtensionField2() async {
    var library = await bootPackageWithLibrary('''
class A {}

extension Ext on A {
  /** Line 1
   */
  static int staticField = 0; /** Line 2 */
  /** Line 3
   */

  /** Line 1
   */
  static int staticFieldWithInitializer = () { /** Line 2 */
    /** Line 3 */
    return 1;
  }();
  /** Line 4
   */

  /** Line 1
   */
  external static int externalStaticField; /** Line 2 */
  /** Line 3
   */

  /** Line 1
   */
  external int externalInstanceField; /** Line 2 */
  /** Line 3
   */
}
''');
    var ext = library.extensions.named('Ext');
    var s1 = ext.staticFields.named('staticField');
    expect(s1.documentation, 'Line 1');
    var s2 = ext.staticFields.named('staticFieldWithInitializer');
    expect(s2.documentation, 'Line 1');
    var s3 = ext.staticFields.named('externalStaticField');
    expect(s3.documentation, 'Line 1');
    var m1 = ext.instanceFields.named('externalInstanceField');
    expect(m1.documentation, 'Line 1');
  }

  /// Check that doc comments can be recognized before extension type fields
  /// (instance and static).
  void test_beforeExtensionTypeField1() async {
    var library = await bootPackageWithLibrary('''
extension type ET(
  /// Line 1
  int instanceField) {
  /// Line 1
  static int staticField = 0; /// Line 2
  /// Line 3
  
  /// Line 1
  static int staticFieldWithInitializer = () { /// Line 2
    /// Line 3
    return 1;
  }();
  /// Line 4
  
  /// Line 1
  external static int externalStaticField; /// Line 2
  /// Line 3
  
  /// Line 1
  external int externalInstanceField; /// Line 2
  /// Line 3
}
''');
    var et = library.extensionTypes.named('ET');
    var s1 = et.staticFields.named('staticField');
    expect(s1.documentation, 'Line 1');
    var s2 = et.staticFields.named('staticFieldWithInitializer');
    expect(s2.documentation, '''
Line 2
Line 3
Line 1''');
    var s3 = et.staticFields.named('externalStaticField');
    expect(s3.documentation, '''
Line 4
Line 1''');
    var m1 = et.instanceFields.named('instanceField');
    expect(m1.documentation, 'Line 1');
    var m2 = et.instanceFields.named('externalInstanceField');
    expect(m2.documentation, '''
Line 2
Line 3
Line 1''');
  }

  /// Check that block-based doc comments can be recognized before extension
  /// type fields (instance and static).
  void test_beforeExtensionTypeField2() async {
    var library = await bootPackageWithLibrary('''
extension type ET(
  /** Line 1
   */
  int instanceField) {
  /** Line 1
   */
  static int staticField = 0; /** Line 2 */
  /** Line 3
   */

  /** Line 1
   */
  static int staticFieldWithInitializer = () { /** Line 2 */
    /** Line 3 */
    return 1;
  }();
  /** Line 4
   */

  /** Line 1
   */
  external static int externalStaticField; /** Line 2 */
  /** Line 3
   */
   
  /** Line 1
   */
  external int externalInstanceField; /** Line 2 */
  /** Line 3
   */
}
''');
    var et = library.extensionTypes.named('ET');
    var s1 = et.staticFields.named('staticField');
    expect(s1.documentation, 'Line 1');
    var s2 = et.staticFields.named('staticFieldWithInitializer');
    expect(s2.documentation, 'Line 1');
    var s3 = et.staticFields.named('externalStaticField');
    expect(s3.documentation, 'Line 1');
    var m1 = et.instanceFields.named('instanceField');
    expect(m1.documentation, 'Line 1');
    var m2 = et.instanceFields.named('externalInstanceField');
    expect(m2.documentation, 'Line 1');
  }
}
