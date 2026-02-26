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
  /// Check that doc comments can be recognized before class getters and
  /// setters (instance and static).
  void test_beforeClassGetterSetter1() async {
    var library = await bootPackageWithLibrary('''
class C {
  /// Line 1
  static int get staticGetter => 0; /// Line 2
  /// Line 3
  
  /// Line 1
  static void set staticSetter(int _) { /// Line 2
    /// Line 3
  }
  /// Line 4
  
  /// Line 1
  static int get staticGetterWithBody { /// Line 2
    /// Line 3
    return 0;
  }
  /// Line 4

  /// Line 1
  int get instanceGetter => 0; /// Line 2
  /// Line 3
  
  /// Line 1
  void set instanceSetter(int _) { /// Line 2
    /// Line 3
  }
  /// Line 4
  
  /// Line 1
  int get instanceGetterWithBody { /// Line 2
    /// Line 3
    return 0;
  }
  /// Line 4
}
''');
    var c = library.classes.named('C');
    var sg1 = c.staticFields.named('staticGetter');
    expect(sg1.documentation, 'Line 1');
    var ss1 = c.staticFields.named('staticSetter');
    expect(ss1.documentation, '''
Line 2
Line 3
Line 1''');
    var sg2 = c.staticFields.named('staticGetterWithBody');
    expect(sg2.documentation, '''
Line 4
Line 1''');

    var ig1 = c.instanceFields.named('instanceGetter');
    expect(ig1.documentation, '''
Line 4
Line 1''');
    var is1 = c.instanceFields.named('instanceSetter');
    expect(is1.documentation, '''
Line 2
Line 3
Line 1''');
    var ig2 = c.instanceFields.named('instanceGetterWithBody');
    expect(ig2.documentation, '''
Line 4
Line 1''');
  }

  /// Check that block-based doc comments can be recognized before class getters
  /// and setters (instance and static).
  void test_beforeClassGetterSetter2() async {
    var library = await bootPackageWithLibrary('''
class C {
  /** Line 1
   */
  static int get staticGetter => 0; /** Line 2 */
  /** Line 3
   */
  
  /** Line 1
   */
  static void set staticSetter(int _) { /** Line 2 */
  /** Line 3
   */
  }
  /** Line 4
   */
   
  /** Line 1
   */
  static int get staticGetterWithBody { /** Line 2 */
  /** Line 3
   */
    return 0;
  }
  /** Line 4
   */
   
  /** Line 1
   */
  int get instanceGetter => 0; /** Line 2 */
  /** Line 3
   */
  
  /** Line 1
   */
  void set instanceSetter(int _) { /** Line 2 */
  /** Line 3
   */
  }
  /** Line 4
   */
   
  /** Line 1
   */
  int get instanceGetterWithBody { /** Line 2 */
  /** Line 3
   */
    return 0;
  }
  /** Line 4
   */   
}
''');
    var c = library.classes.named('C');
    var sg1 = c.staticFields.named('staticGetter');
    expect(sg1.documentation, 'Line 1');
    var ss1 = c.staticFields.named('staticSetter');
    expect(ss1.documentation, 'Line 1');
    var sg2 = c.staticFields.named('staticGetterWithBody');
    expect(sg2.documentation, 'Line 1');
    var ig1 = c.instanceFields.named('instanceGetter');
    expect(ig1.documentation, 'Line 1');
    var is1 = c.instanceFields.named('instanceSetter');
    expect(is1.documentation, 'Line 1');
    var ig2 = c.instanceFields.named('instanceGetterWithBody');
    expect(ig2.documentation, 'Line 1');
  }

  /// Check that doc comments can be recognized before mixin getters and setters
  /// (instance and static).
  void test_beforeMixinGetterSetter1() async {
    var library = await bootPackageWithLibrary('''
mixin M {
  /// Line 1
  static int get staticGetter => 0; /// Line 2
  /// Line 3
  
  /// Line 1
  static void set staticSetter(int _) { /// Line 2
    /// Line 3
  }
  /// Line 4
  
  /// Line 1
  static int get staticGetterWithBody { /// Line 2
    /// Line 3
    return 0;
  }
  /// Line 4

  /// Line 1
  int get instanceGetter => 0; /// Line 2
  /// Line 3
  
  /// Line 1
  void set instanceSetter(int _) { /// Line 2
    /// Line 3
  }
  /// Line 4
  
  /// Line 1
  int get instanceGetterWithBody { /// Line 2
    /// Line 3
    return 0;
  }
  /// Line 4
}
''');
    var mixinM = library.mixins.named('M');
    var sg1 = mixinM.staticFields.named('staticGetter');
    expect(sg1.documentation, 'Line 1');
    var ss1 = mixinM.staticFields.named('staticSetter');
    expect(ss1.documentation, '''
Line 2
Line 3
Line 1''');
    var sg2 = mixinM.staticFields.named('staticGetterWithBody');
    expect(sg2.documentation, '''
Line 4
Line 1''');

    var ig1 = mixinM.instanceFields.named('instanceGetter');
    expect(ig1.documentation, '''
Line 4
Line 1''');
    var is1 = mixinM.instanceFields.named('instanceSetter');
    expect(is1.documentation, '''
Line 2
Line 3
Line 1''');
    var ig2 = mixinM.instanceFields.named('instanceGetterWithBody');
    expect(ig2.documentation, '''
Line 4
Line 1''');
  }

  /// Check that block-based doc comments can be recognized before mixin getters
  /// and setters (instance and static).
  void test_beforeMixinGetterSetter2() async {
    var library = await bootPackageWithLibrary('''
mixin M {
  /** Line 1
   */
  static int get staticGetter => 0; /** Line 2 */
  /** Line 3
   */
  
  /** Line 1
   */
  static void set staticSetter(int _) { /** Line 2 */
  /** Line 3
   */
  }
  /** Line 4
   */
   
  /** Line 1
   */
  static int get staticGetterWithBody { /** Line 2 */
  /** Line 3
   */
    return 0;
  }
  /** Line 4
   */
   
  /** Line 1
   */
  int get instanceGetter => 0; /** Line 2 */
  /** Line 3
   */
  
  /** Line 1
   */
  void set instanceSetter(int _) { /** Line 2 */
  /** Line 3
   */
  }
  /** Line 4
   */
   
  /** Line 1
   */
  int get instanceGetterWithBody { /** Line 2 */
  /** Line 3
   */
    return 0;
  }
  /** Line 4
   */   
}
''');
    var mixinM = library.mixins.named('M');
    var sg1 = mixinM.staticFields.named('staticGetter');
    expect(sg1.documentation, 'Line 1');
    var ss1 = mixinM.staticFields.named('staticSetter');
    expect(ss1.documentation, 'Line 1');
    var sg2 = mixinM.staticFields.named('staticGetterWithBody');
    expect(sg2.documentation, 'Line 1');
    var ig1 = mixinM.instanceFields.named('instanceGetter');
    expect(ig1.documentation, 'Line 1');
    var is1 = mixinM.instanceFields.named('instanceSetter');
    expect(is1.documentation, 'Line 1');
    var ig2 = mixinM.instanceFields.named('instanceGetterWithBody');
    expect(ig2.documentation, 'Line 1');
  }

  /// Check that doc comments can be recognized before enum getters and setters
  /// (instance and static).
  void test_beforeEnumGetterSetter1() async {
    var library = await bootPackageWithLibrary('''
enum E {
  e0;
  /// Line 1
  static int get staticGetter => 0; /// Line 2
  /// Line 3
  
  /// Line 1
  static void set staticSetter(int _) { /// Line 2
    /// Line 3
  }
  /// Line 4
  
  /// Line 1
  static int get staticGetterWithBody { /// Line 2
    /// Line 3
    return 0;
  }
  /// Line 4

  /// Line 1
  int get instanceGetter => 0; /// Line 2
  /// Line 3
  
  /// Line 1
  void set instanceSetter(int _) { /// Line 2
    /// Line 3
  }
  /// Line 4
  
  /// Line 1
  int get instanceGetterWithBody { /// Line 2
    /// Line 3
    return 0;
  }
  /// Line 4
}
''');
    var e = library.enums.named('E');
    var sg1 = e.staticFields.named('staticGetter');
    expect(sg1.documentation, 'Line 1');
    var ss1 = e.staticFields.named('staticSetter');
    expect(ss1.documentation, '''
Line 2
Line 3
Line 1''');
    var sg2 = e.staticFields.named('staticGetterWithBody');
    expect(sg2.documentation, '''
Line 4
Line 1''');

    var ig1 = e.instanceFields.named('instanceGetter');
    expect(ig1.documentation, '''
Line 4
Line 1''');
    var is1 = e.instanceFields.named('instanceSetter');
    expect(is1.documentation, '''
Line 2
Line 3
Line 1''');
    var ig2 = e.instanceFields.named('instanceGetterWithBody');
    expect(ig2.documentation, '''
Line 4
Line 1''');
  }

  /// Check that block-based doc comments can be recognized before enum getters
  /// and setters (instance and static).
  void test_beforeEnumGetterSetter2() async {
    var library = await bootPackageWithLibrary('''
enum E {
  e0;
  /** Line 1
   */
  static int get staticGetter => 0; /** Line 2 */
  /** Line 3
   */
  
  /** Line 1
   */
  static void set staticSetter(int _) { /** Line 2 */
  /** Line 3
   */
  }
  /** Line 4
   */
   
  /** Line 1
   */
  static int get staticGetterWithBody { /** Line 2 */
  /** Line 3
   */
    return 0;
  }
  /** Line 4
   */
   
  /** Line 1
   */
  int get instanceGetter => 0; /** Line 2 */
  /** Line 3
   */
  
  /** Line 1
   */
  void set instanceSetter(int _) { /** Line 2 */
  /** Line 3
   */
  }
  /** Line 4
   */
   
  /** Line 1
   */
  int get instanceGetterWithBody { /** Line 2 */
  /** Line 3
   */
    return 0;
  }
  /** Line 4
   */   
}
''');
    var e = library.enums.named('E');
    var sg1 = e.staticFields.named('staticGetter');
    expect(sg1.documentation, 'Line 1');
    var ss1 = e.staticFields.named('staticSetter');
    expect(ss1.documentation, 'Line 1');
    var sg2 = e.staticFields.named('staticGetterWithBody');
    expect(sg2.documentation, 'Line 1');
    var ig1 = e.instanceFields.named('instanceGetter');
    expect(ig1.documentation, 'Line 1');
    var is1 = e.instanceFields.named('instanceSetter');
    expect(is1.documentation, 'Line 1');
    var ig2 = e.instanceFields.named('instanceGetterWithBody');
    expect(ig2.documentation, 'Line 1');
  }

  /// Check that doc comments can be recognized before extension getters and
  /// setters (instance and static).
  void test_beforeExtensionGetterSetter1() async {
    var library = await bootPackageWithLibrary('''
class A {}

extension Ext on A {
  /// Line 1
  static int get staticGetter => 0; /// Line 2
  /// Line 3
  
  /// Line 1
  static void set staticSetter(int _) { /// Line 2
    /// Line 3
  }
  /// Line 4
  
  /// Line 1
  static int get staticGetterWithBody { /// Line 2
    /// Line 3
    return 0;
  }
  /// Line 4

  /// Line 1
  int get instanceGetter => 0; /// Line 2
  /// Line 3
  
  /// Line 1
  void set instanceSetter(int _) { /// Line 2
    /// Line 3
  }
  /// Line 4
  
  /// Line 1
  int get instanceGetterWithBody { /// Line 2
    /// Line 3
    return 0;
  }
  /// Line 4
}
''');
    var ext = library.extensions.named('Ext');
    var sg1 = ext.staticFields.named('staticGetter');
    expect(sg1.documentation, 'Line 1');
    var ss1 = ext.staticFields.named('staticSetter');
    expect(ss1.documentation, '''
Line 2
Line 3
Line 1''');
    var sg2 = ext.staticFields.named('staticGetterWithBody');
    expect(sg2.documentation, '''
Line 4
Line 1''');

    var ig1 = ext.instanceFields.named('instanceGetter');
    expect(ig1.documentation, '''
Line 4
Line 1''');
    var is1 = ext.instanceFields.named('instanceSetter');
    expect(is1.documentation, '''
Line 2
Line 3
Line 1''');
    var ig2 = ext.instanceFields.named('instanceGetterWithBody');
    expect(ig2.documentation, '''
Line 4
Line 1''');
  }

  /// Check that block-based doc comments can be recognized before extension
  /// getters and setters (instance and static).
  void test_beforeExtensionGetterSetter2() async {
    var library = await bootPackageWithLibrary('''
class A {}

extension Ext on A {
  /** Line 1
   */
  static int get staticGetter => 0; /** Line 2 */
  /** Line 3
   */
  
  /** Line 1
   */
  static void set staticSetter(int _) { /** Line 2 */
  /** Line 3
   */
  }
  /** Line 4
   */
   
  /** Line 1
   */
  static int get staticGetterWithBody { /** Line 2 */
  /** Line 3
   */
    return 0;
  }
  /** Line 4
   */
   
  /** Line 1
   */
  int get instanceGetter => 0; /** Line 2 */
  /** Line 3
   */
  
  /** Line 1
   */
  void set instanceSetter(int _) { /** Line 2 */
  /** Line 3
   */
  }
  /** Line 4
   */
   
  /** Line 1
   */
  int get instanceGetterWithBody { /** Line 2 */
  /** Line 3
   */
    return 0;
  }
  /** Line 4
   */   
}
''');
    var ext = library.extensions.named('Ext');
    var sg1 = ext.staticFields.named('staticGetter');
    expect(sg1.documentation, 'Line 1');
    var ss1 = ext.staticFields.named('staticSetter');
    expect(ss1.documentation, 'Line 1');
    var sg2 = ext.staticFields.named('staticGetterWithBody');
    expect(sg2.documentation, 'Line 1');
    var ig1 = ext.instanceFields.named('instanceGetter');
    expect(ig1.documentation, 'Line 1');
    var is1 = ext.instanceFields.named('instanceSetter');
    expect(is1.documentation, 'Line 1');
    var ig2 = ext.instanceFields.named('instanceGetterWithBody');
    expect(ig2.documentation, 'Line 1');
  }

  /// Check that doc comments can be recognized before extension type getters
  /// and setters (instance and static).
  void test_beforeExtensionTypeGetterSetter1() async {
    var library = await bootPackageWithLibrary('''
extension type ET(int _) {
  /// Line 1
  static int get staticGetter => 0; /// Line 2
  /// Line 3
  
  /// Line 1
  static void set staticSetter(int _) { /// Line 2
    /// Line 3
  }
  /// Line 4
  
  /// Line 1
  static int get staticGetterWithBody { /// Line 2
    /// Line 3
    return 0;
  }
  /// Line 4

  /// Line 1
  int get instanceGetter => 0; /// Line 2
  /// Line 3
  
  /// Line 1
  void set instanceSetter(int _) { /// Line 2
    /// Line 3
  }
  /// Line 4
  
  /// Line 1
  int get instanceGetterWithBody { /// Line 2
    /// Line 3
    return 0;
  }
  /// Line 4
}
''');
    var et = library.extensionTypes.named('ET');
    var sg1 = et.staticFields.named('staticGetter');
    expect(sg1.documentation, 'Line 1');
    var ss1 = et.staticFields.named('staticSetter');
    expect(ss1.documentation, '''
Line 2
Line 3
Line 1''');
    var sg2 = et.staticFields.named('staticGetterWithBody');
    expect(sg2.documentation, '''
Line 4
Line 1''');

    var ig1 = et.instanceFields.named('instanceGetter');
    expect(ig1.documentation, '''
Line 4
Line 1''');
    var is1 = et.instanceFields.named('instanceSetter');
    expect(is1.documentation, '''
Line 2
Line 3
Line 1''');
    var ig2 = et.instanceFields.named('instanceGetterWithBody');
    expect(ig2.documentation, '''
Line 4
Line 1''');
  }

  /// Check that block-based doc comments can be recognized before extension
  /// type getters and setters (instance and static).
  void test_beforeExtensionTypeGetterSetter2() async {
    var library = await bootPackageWithLibrary('''
extension type ET(int _) {
  /** Line 1
   */
  static int get staticGetter => 0; /** Line 2 */
  /** Line 3
   */
  
  /** Line 1
   */
  static void set staticSetter(int _) { /** Line 2 */
  /** Line 3
   */
  }
  /** Line 4
   */
   
  /** Line 1
   */
  static int get staticGetterWithBody { /** Line 2 */
  /** Line 3
   */
    return 0;
  }
  /** Line 4
   */
   
  /** Line 1
   */
  int get instanceGetter => 0; /** Line 2 */
  /** Line 3
   */
  
  /** Line 1
   */
  void set instanceSetter(int _) { /** Line 2 */
  /** Line 3
   */
  }
  /** Line 4
   */
   
  /** Line 1
   */
  int get instanceGetterWithBody { /** Line 2 */
  /** Line 3
   */
    return 0;
  }
  /** Line 4
   */   
}
''');
    var et = library.extensionTypes.named('ET');
    var sg1 = et.staticFields.named('staticGetter');
    expect(sg1.documentation, 'Line 1');
    var ss1 = et.staticFields.named('staticSetter');
    expect(ss1.documentation, 'Line 1');
    var sg2 = et.staticFields.named('staticGetterWithBody');
    expect(sg2.documentation, 'Line 1');
    var ig1 = et.instanceFields.named('instanceGetter');
    expect(ig1.documentation, 'Line 1');
    var is1 = et.instanceFields.named('instanceSetter');
    expect(is1.documentation, 'Line 1');
    var ig2 = et.instanceFields.named('instanceGetterWithBody');
    expect(ig2.documentation, 'Line 1');
  }
}
