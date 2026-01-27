// Copyright (c) 2026, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// @assertion Doc comments are associated with the declaration that immediately
/// follows them. They are only considered valid when placed directly before the
/// following types of declarations:
/// ...
/// - `library` directives.
/// ...
/// - class
/// - mixin
/// - enum
/// - extension
/// - extension type
/// - typedef
/// - Top-level functions
/// - Top-level variables
/// - Top-level getters or setters
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
  /// Check that doc comments can be placed before `library` directive
  void test_beforeLibrary1() async {
    await writePackageWithCommentedLibrary('''
/// Line 1
library; /// Line 2
/// Line 3
''');
    expectDocComment('Line 1');
  }

  /// Check that doc comments can be placed before `library` directive
  void test_beforeLibrary2() async {
    await writePackageWithCommentedLibrary('''
/** Line 1
 */
library; /** Line 2 */
/** Line 3 */
''');
    expectDocComment('Line 1');
  }

  /// Check that doc comments can be placed before a class.
  void test_beforeClass1() async {
    var library = await bootPackageWithLibrary('''
/// Line 1
class C { /// Line 2
/// Line 3
}
/// Line 4
''');
    var c = library.classes.named('C');
    expect(c.documentation, 'Line 1');
  }

  /// Check that block-based doc comments can be placed before a class.
  void test_beforeClass2() async {
    var library = await bootPackageWithLibrary('''
/** Line 1
 */
class C { /** Line 2 */
/** Line 3
 */
}
/** Line 4
 */
''');
    var c = library.classes.named('C');
    expect(c.documentation, 'Line 1');
  }

  /// Check that doc comments can be placed before a private class.
  void test_beforeClass3() async {
    var library = await bootPackageWithLibrary('''
/// Line 1
class _C { /// Line 2
/// Line 3
}
/// Line 4
''');
    var c = library.classes.named('_C');
    expect(c.documentation, 'Line 1');
  }

  /// Check that block-based doc comments can be placed before a private class.
  void test_beforeClass4() async {
    var library = await bootPackageWithLibrary('''
/** Line 1
 */
class _C { /** Line 2 */
/** Line 3
 */
}
/** Line 4
 */
''');
    var c = library.classes.named('_C');
    expect(c.documentation, 'Line 1');
  }

  /// Check that doc comments can be placed before a mixin.
  void test_beforeMixin1() async {
    var library = await bootPackageWithLibrary('''
/// Line 1
mixin M { /// Line 2
/// Line 3
}
/// Line 4
''');
    var m = library.mixins.named('M');
    expect(m.documentation, 'Line 1');
  }

  /// Check that block-based doc comments can be placed before a mixin.
  void test_beforeMixin2() async {
    var library = await bootPackageWithLibrary('''
/** Line 1
 */
mixin M { /** Line 2 */
/** Line 3
 */
}
/** Line 4
 */
''');
    var m = library.mixins.named('M');
    expect(m.documentation, 'Line 1');
  }

  /// Check that doc comments can be placed before a private mixin.
  void test_beforeMixin3() async {
    var library = await bootPackageWithLibrary('''
/// Line 1
mixin _M { /// Line 2
/// Line 3
}
/// Line 4
''');
    var m = library.mixins.named('_M');
    expect(m.documentation, 'Line 1');
  }

  /// Check that block-based doc comments can be placed before a private mixin.
  void test_beforeMixin4() async {
    var library = await bootPackageWithLibrary('''
/** Line 1
 */
mixin _M { /** Line 2 */
/** Line 3
 */
}
/** Line 4
 */
''');
    var m = library.mixins.named('_M');
    expect(m.documentation, 'Line 1');
  }

  /// Check that doc comments can be placed before an enum.
  void test_beforeEnum1() async {
    var library = await bootPackageWithLibrary('''
/// Line 1
enum E { /// Line 2
  e0;
/// Line 3
}
/// Line 4
''');
    var e = library.enums.named('E');
    expect(e.documentation, 'Line 1');
  }

  /// Check that block-based doc comments can be placed before an enum.
  void test_beforeEnum2() async {
    var library = await bootPackageWithLibrary('''
/** Line 1
 */
enum E { /** Line 2 */
  e0;
/** Line 3
 */
}
/** Line 4
 */
''');
    var e = library.enums.named('E');
    expect(e.documentation, 'Line 1');
  }

  /// Check that doc comments can be placed before a private enum.
  void test_beforeEnum3() async {
    var library = await bootPackageWithLibrary('''
/// Line 1
enum _E { /// Line 2
  e0;
/// Line 3
}
/// Line 4
''');
    var e = library.enums.named('_E');
    expect(e.documentation, 'Line 1');
  }

  /// Check that block-based doc comments can be placed before a private enum.
  void test_beforeEnum4() async {
    var library = await bootPackageWithLibrary('''
/** Line 1
 */
enum _E { /** Line 2 */
  e0;
/** Line 3
 */
}
/** Line 4
 */
''');
    var e = library.enums.named('_E');
    expect(e.documentation, 'Line 1');
  }

  /// Check that doc comments can be placed before an extension.
  void test_beforeExtension1() async {
    var library = await bootPackageWithLibrary('''
class A {}
    
/// Line 1
extension Ext { /// Line 2
/// Line 3
}
/// Line 4
''');
    var ext = library.extensions.named('Ext');
    expect(ext.documentation, 'Line 1');
  }

  /// Check that block-based doc comments can be placed before an extension.
  void test_beforeExtension2() async {
    var library = await bootPackageWithLibrary('''
class A {}
    
/** Line 1
 */
extension Ext { /** Line 2 */
/** Line 3
 */
}
/** Line 4
 */
''');
    var ext = library.extensions.named('Ext');
    expect(ext.documentation, 'Line 1');
  }

  /// Check that doc comments can be placed before a private extension.
  void test_beforeExtension3() async {
    var library = await bootPackageWithLibrary('''
class A {}
    
/// Line 1
extension _Ext { /// Line 2
/// Line 3
}
/// Line 4
''');
    var ext = library.extensions.named('_Ext');
    expect(ext.documentation, 'Line 1');
  }

  /// Check that block-based doc comments can be placed before a private
  /// extension.
  void test_beforeExtension4() async {
    var library = await bootPackageWithLibrary('''
class A {}
    
/** Line 1
 */
extension _Ext { /** Line 2 */
/** Line 3
 */
}
/** Line 4
 */
''');
    var ext = library.extensions.named('_Ext');
    expect(ext.documentation, 'Line 1');
  }

  /// Check that doc comments can be placed before an extension type.
  void test_beforeExtensionType1() async {
    var library = await bootPackageWithLibrary('''
/// Line 1
extension type ET(int _) { /// Line 2
/// Line 3
}
/// Line 4
''');
    var et = library.extensionTypes.named('ET');
    expect(et.documentation, 'Line 1');
  }

  /// Check that block-based doc comments can be placed before an extension type.
  void test_beforeExtensionType2() async {
    var library = await bootPackageWithLibrary('''
/** Line 1
 */
extension type ET(int _) { /** Line 2 */
/** Line 3
 */
}
/** Line 4
 */
''');
    var et = library.extensionTypes.named('ET');
    expect(et.documentation, 'Line 1');
  }

  /// Check that doc comments can be placed before a private extension type.
  void test_beforeExtensionType3() async {
    var library = await bootPackageWithLibrary('''
/// Line 1
extension type _ET(int _) { /// Line 2
/// Line 3
}
/// Line 4
''');
    var et = library.extensionTypes.named('_ET');
    expect(et.documentation, 'Line 1');
  }

  /// Check that block-based doc comments can be placed before a private
  /// extension type.
  void test_beforeExtensionType4() async {
    var library = await bootPackageWithLibrary('''
/** Line 1
 */
extension type _ET(int _) { /** Line 2 */
/** Line 3
 */
}
/** Line 4
 */
''');
    var et = library.extensionTypes.named('_ET');
    expect(et.documentation, 'Line 1');
  }

  /// Check that doc comments can be placed before a typedef.
  void test_beforeTypedef1() async {
    var library = await bootPackageWithLibrary('''
/// Line 1
typedef IntAlias = int; /// Line 2
/// Line 3
''');
    var td = library.typedefs.named('IntAlias');
    expect(td.documentation, 'Line 1');
  }

  /// Check that block-based doc comments can be placed before a typedef.
  void test_beforeTypedef2() async {
    var library = await bootPackageWithLibrary('''
/** Line 1
 */
typedef IntAlias = int; /** Line 2 */
/** Line 3
 */
''');
    var td = library.typedefs.named('IntAlias');
    expect(td.documentation, 'Line 1');
  }

  /// Check that doc comments can be placed before a private typedef.
  void test_beforeTypedef3() async {
    var library = await bootPackageWithLibrary('''
/// Line 1
typedef _IntAlias = int; /// Line 2
/// Line 3
''');
    var td = library.typedefs.named('_IntAlias');
    expect(td.documentation, 'Line 1');
  }

  /// Check that block-based doc comments can be placed before a private typedef.
  void test_beforeTypedef4() async {
    var library = await bootPackageWithLibrary('''
/** Line 1
 */
typedef _IntAlias = int; /** Line 2 */
/** Line 3
 */
''');
    var td = library.typedefs.named('_IntAlias');
    expect(td.documentation, 'Line 1');
  }

  /// Check that doc comments can be placed before an old-fashioned typedef.
  void test_beforeTypedef5() async {
    var library = await bootPackageWithLibrary('''
/// Line 1
typedef void Foo(); /// Line 2
/// Line 3
''');
    var td = library.typedefs.named('Foo');
    expect(td.documentation, 'Line 1');
  }

  /// Check that block-based doc comments can be placed before an old-fashioned
  /// typedef.
  void test_beforeTypedef6() async {
    var library = await bootPackageWithLibrary('''
/** Line 1
 */
typedef void Foo(); /** Line 2 */
/** Line 3
 */
''');
    var td = library.typedefs.named('Foo');
    expect(td.documentation, 'Line 1');
  }

  /// Check that doc comments can be placed before an old-fashioned private
  /// typedef.
  void test_beforeTypedef7() async {
    var library = await bootPackageWithLibrary('''
/// Line 1
typedef void _Foo(); /// Line 2
/// Line 3
''');
    var td = library.typedefs.named('_Foo');
    expect(td.documentation, 'Line 1');
  }

  /// Check that block-based doc comments can be placed before an old-fashioned
  /// private typedef.
  void test_beforeTypedef8() async {
    var library = await bootPackageWithLibrary('''
/** Line 1
 */
typedef void _Foo(); /** Line 2 */
/** Line 3
 */
''');
    var td = library.typedefs.named('_Foo');
    expect(td.documentation, 'Line 1');
  }

  /// Check that doc comments can be placed before a top-level function.
  void test_beforeFunction1() async {
    var library = await bootPackageWithLibrary('''
/// Line 1
void foo() { /// Line 2
/// Line 3
}
/// Line 4
''');
    var f = library.functions.named('foo');
    expect(f.documentation, 'Line 1');
  }

  /// Check that block-based doc comments can be placed before a top-level
  /// function.
  void test_beforeFunction2() async {
    var library = await bootPackageWithLibrary('''
/** Line 1
 */
void foo() { /** Line 2 */
/** Line 3
 */
}
/** Line 4
 */
''');
    var f = library.functions.named('foo');
    expect(f.documentation, 'Line 1');
  }

  /// Check that doc comments can be placed before a private top-level function.
  void test_beforeFunction3() async {
    var library = await bootPackageWithLibrary('''
/// Line 1
void _foo() { /// Line 2
/// Line 3
}
/// Line 4
''');
    var f = library.functions.named('_foo');
    expect(f.documentation, 'Line 1');
  }

  /// Check that block-based doc comments can be placed before a private
  /// top-level function.
  void test_beforeFunction4() async {
    var library = await bootPackageWithLibrary('''
/** Line 1
 */
void _foo() { /** Line 2 */
/** Line 3
 */
}
/** Line 4
 */
''');
    var f = library.functions.named('_foo');
    expect(f.documentation, 'Line 1');
  }

  /// Check that doc comments can be placed before a variable.
  void test_beforeVariable1() async {
    var library = await bootPackageWithLibrary('''
/// Line 1
int x = 0; /// Line 2
/// Line 3
''');
    var v = library.properties.named('x');
    expect(v.documentation, 'Line 1');
  }

  /// Check that block-based doc comments can be placed before a variable.
  void test_beforeVariable2() async {
    var library = await bootPackageWithLibrary('''
/** Line 1
 */
int x = 0; /** Line 2 */
/** Line 3
 */
''');
    var v = library.properties.named('x');
    expect(v.documentation, 'Line 1');
  }

  /// Check that doc comments can be placed before a private variable.
  void test_beforeVariable3() async {
    var library = await bootPackageWithLibrary('''
/// Line 1
int _x = 0; /// Line 2
/// Line 3
''');
    var v = library.properties.named('_x');
    expect(v.documentation, 'Line 1');
  }

  /// Check that block-based doc comments can be placed before a private
  /// variable.
  void test_beforeVariable4() async {
    var library = await bootPackageWithLibrary('''
/** Line 1
 */
int _x = 0; /** Line 2 */
/** Line 3
 */
''');
    var v = library.properties.named('_x');
    expect(v.documentation, 'Line 1');
  }

  /// Check that doc comments can be placed before a final variable.
  void test_beforeVariable5() async {
    var library = await bootPackageWithLibrary('''
/// Line 1
final int x = 0; /// Line 2
/// Line 3
''');
    var v = library.properties.named('x');
    expect(v.documentation, 'Line 1');
  }

  /// Check that block-based doc comments can be placed before a final variable.
  void test_beforeVariable6() async {
    var library = await bootPackageWithLibrary('''
/** Line 1
 */
final int x = 0; /** Line 2 */
/** Line 3
 */
''');
    var v = library.properties.named('x');
    expect(v.documentation, 'Line 1');
  }

  /// Check that doc comments can be placed before a private final variable.
  void test_beforeVariable7() async {
    var library = await bootPackageWithLibrary('''
/// Line 1
final int _x = 0; /// Line 2
/// Line 3
''');
    var v = library.properties.named('_x');
    expect(v.documentation, 'Line 1');
  }

  /// Check that block-based doc comments can be placed before a private final
  /// variable.
  void test_beforeVariable8() async {
    var library = await bootPackageWithLibrary('''
/** Line 1
 */
final int _x = 0; /** Line 2 */
/** Line 3
 */
''');
    var v = library.properties.named('_x');
    expect(v.documentation, 'Line 1');
  }

  /// Check that doc comments can be placed before a late variable.
  void test_beforeVariable9() async {
    var library = await bootPackageWithLibrary('''
/// Line 1
late int x; /// Line 2
/// Line 3
''');
    var v = library.properties.named('x');
    expect(v.documentation, 'Line 1');
  }

  /// Check that block-based doc comments can be placed before a late variable.
  void test_beforeVariable10() async {
    var library = await bootPackageWithLibrary('''
/** Line 1
 */
late int x = 0; /** Line 2 */
/** Line 3
 */
''');
    var v = library.properties.named('x');
    expect(v.documentation, 'Line 1');
  }

  /// Check that doc comments can be placed before a private late variable.
  void test_beforeVariable11() async {
    var library = await bootPackageWithLibrary('''
/// Line 1
late int _x; /// Line 2
/// Line 3
''');
    var v = library.properties.named('_x');
    expect(v.documentation, 'Line 1');
  }

  /// Check that block-based doc comments can be placed before a private late
  /// variable.
  void test_beforeVariable12() async {
    var library = await bootPackageWithLibrary('''
/** Line 1
 */
late int _x = 0; /** Line 2 */
/** Line 3
 */
''');
    var v = library.properties.named('_x');
    expect(v.documentation, 'Line 1');
  }

  /// Check that doc comments can be placed before a late final variable.
  void test_beforeVariable13() async {
    var library = await bootPackageWithLibrary('''
/// Line 1
late final int x; /// Line 2
/// Line 3
''');
    var v = library.properties.named('x');
    expect(v.documentation, 'Line 1');
  }

  /// Check that block-based doc comments can be placed before a late final
  /// variable.
  void test_beforeVariable14() async {
    var library = await bootPackageWithLibrary('''
/** Line 1
 */
late final int x = 0; /** Line 2 */
/** Line 3
 */
''');
    var v = library.properties.named('x');
    expect(v.documentation, 'Line 1');
  }

  /// Check that doc comments can be placed before a private late final variable.
  void test_beforeVariable15() async {
    var library = await bootPackageWithLibrary('''
/// Line 1
late final int _x; /// Line 2
/// Line 3
''');
    var v = library.properties.named('_x');
    expect(v.documentation, 'Line 1');
  }

  /// Check that block-based doc comments can be placed before a private late
  /// final variable.
  void test_beforeVariable16() async {
    var library = await bootPackageWithLibrary('''
/** Line 1
 */
late final int _x = 0; /** Line 2 */
/** Line 3
 */
''');
    var v = library.properties.named('_x');
    expect(v.documentation, 'Line 1');
  }

  /// Check that doc comments can be placed before a constant.
  void test_beforeVariable17() async {
    var library = await bootPackageWithLibrary('''
/// Line 1
const x = 42; /// Line 2
/// Line 3
''');
    var v = library.constants.named('x');
    expect(v.documentation, 'Line 1');
  }

  /// Check that block-based doc comments can be placed before a constant.
  void test_beforeVariable18() async {
    var library = await bootPackageWithLibrary('''
/** Line 1
 */
const x = 0; /** Line 2 */
/** Line 3
 */
''');
    var v = library.constants.named('x');
    expect(v.documentation, 'Line 1');
  }

  /// Check that doc comments can be placed before a private constant.
  void test_beforeVariable19() async {
    var library = await bootPackageWithLibrary('''
/// Line 1
const _x = 42; /// Line 2
/// Line 3
''');
    var v = library.constants.named('_x');
    expect(v.documentation, 'Line 1');
  }

  /// Check that block-based doc comments can be placed before a private
  /// constant.
  void test_beforeVariable20() async {
    var library = await bootPackageWithLibrary('''
/** Line 1
 */
const _x = 0; /** Line 2 */
/** Line 3
 */
''');
    var v = library.constants.named('_x');
    expect(v.documentation, 'Line 1');
  }

  /// Check that doc comments can be placed before a getter.
  void test_beforeGetter1() async {
    var library = await bootPackageWithLibrary('''
/// Line 1
int get g => 0; /// Line 2
/// Line 3
''');
    var g = library.properties.named('g');
    expect(g.documentation, 'Line 1');
  }

  /// Check that block based doc comments can be placed before a getter.
  void test_beforeGetter2() async {
    var library = await bootPackageWithLibrary('''
/** Line 1
 */
int get g => 0; /** Line 2 */
/** Line 3
 */
''');
    var g = library.properties.named('g');
    expect(g.documentation, 'Line 1');
  }

  /// Check that doc comments can be placed before a private getter.
  void test_beforeGetter3() async {
    markTestSkipped('Skipping until issue '
        'https://github.com/dart-lang/dartdoc/issues/4185 is resolved.');
//     var library = await bootPackageWithLibrary('''
// /// Line 1
// int get _g => 0; /// Line 2
// /// Line 3
// ''');
//     var g = library.properties.named('_g');
//     expect(g.documentation, 'Line 1');
  }

  /// Check that block-based doc comments can be placed before a private getter.
  void test_beforeGetter4() async {
    markTestSkipped('Skipping until issue '
        'https://github.com/dart-lang/dartdoc/issues/4185 is resolved.');
//     var library = await bootPackageWithLibrary('''
// /** Line 1
//  */
// int get _g => 0; /** Line 2 */
// /** Line 3
//  */
// ''');
//     var g = library.properties.named('_g');
//     expect(g.documentation, 'Line 1');
  }

  /// Check that doc comments can be placed before a setter.
  void test_beforeSetter1() async {
    var library = await bootPackageWithLibrary('''
/// Line 1
void set s(int _) { /// Line 2
/// Line 3
}
/// Line 4
''');
    var s = library.properties.named('s');
    expect(s.documentation, 'Line 1');
  }

  /// Check that block-based doc comments can be placed before a setter.
  void test_beforeSetter2() async {
    var library = await bootPackageWithLibrary('''
/** Line 1
 */
void set s(int _) { /** Line 2 */
/** Line 3
 */
}
/** Line 4
 */
''');
    var s = library.properties.named('s');
    expect(s.documentation, 'Line 1');
  }

  /// Check that doc comments can be placed before a private setter.
  void test_beforeSetter3() async {
    markTestSkipped('Skipping until issue '
        'https://github.com/dart-lang/dartdoc/issues/4185 is resolved.');
//     var library = await bootPackageWithLibrary('''
// /// Line 1
// void set _s(int _) { /// Line 2
// /// Line 3
// }
// /// Line 4
// ''');
//     var s = library.properties.named('_s');
//     expect(s.documentation, 'Line 1');
  }

  /// Check that block-based doc comments can be placed before a private setter.
  void test_beforeSetter4() async {
    markTestSkipped('Skipping until issue '
        'https://github.com/dart-lang/dartdoc/issues/4185 is resolved.');
//     var library = await bootPackageWithLibrary('''
// /** Line 1
//  */
// void set _s(int _) { /** Line 2 */
// /** Line 3
//  */
// }
// /** Line 4
//  */
// ''');
//     var s = library.properties.named('_s');
//     expect(s.documentation, 'Line 1');
  }
}
