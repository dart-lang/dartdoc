// Copyright (c) 2026, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// @assertion While not strictly disallowed by the language, any other
/// placement of a comment with the `///` syntax, is not considered a doc
/// comment, and hence should be ignored by documentation tools.
/// @author sgrekhov22@gmail.com
library;

import 'package:dartdoc/src/model/model.dart';
import 'package:test/test.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

import '../src/utils.dart';
import 'co19_test_base.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(PlacementTypeParametersTest);
  });
}

@reflectiveTest
class PlacementTypeParametersTest extends Co19TestBase {
  /// Checks that none of the [typeParameters] has documentation.
  void expectNoTypeParameterDocs(List<TypeParameter> typeParameters) {
    expect(typeParameters, hasLength(2));
    for (var t in typeParameters) {
      expect(t.documentation, isEmpty);
    }
  }

  /// Check that doc comments placed inside a type parameter list of a class or
  /// function are not associated with the class or function or with its type
  /// parameters.
  void test_insideTypeParameterList() async {
    var library = await bootLibrary('''
class C</// Line 1
  T,
  /// Line 2
  U extends num> {}

void foo</// Line 1
  T,
  /// Line 2
  U extends num>() {}
''');
    var c = library.classes.named('C');
    expect(c.documentation, isEmpty);
    expectNoTypeParameterDocs(c.typeParameters);
    var foo = library.functions.named('foo');
    expect(foo.documentation, isEmpty);
    expectNoTypeParameterDocs(foo.typeParameters);
  }

  /// Check that block-based doc comments placed inside a type parameter list of
  /// a class or function are not associated with the class or function or with
  /// its type parameters.
  void test_blockInsideTypeParameterList() async {
    var library = await bootLibrary('''
class C</** Line 1 */ T,
  /** Line 2
   */
  U extends num> {}

void foo</** Line 1 */ T,
  /** Line 2
   */
  U extends num>() {}
''');
    var c = library.classes.named('C');
    expect(c.documentation, isEmpty);
    expectNoTypeParameterDocs(c.typeParameters);
    var foo = library.functions.named('foo');
    expect(foo.documentation, isEmpty);
    expectNoTypeParameterDocs(foo.typeParameters);
  }

  /// Check that doc comments placed inside a type parameter list of a mixin are
  /// not associated with the mixin or with its type parameters.
  void test_insideMixinTypeParameterList() async {
    var library = await bootLibrary('''
mixin M</// Line 1
  T,
  /// Line 2
  U extends num> {}
''');
    var mixinM = library.mixins.named('M');
    expect(mixinM.documentation, isEmpty);
    expectNoTypeParameterDocs(mixinM.typeParameters);
  }

  /// Check that block-based doc comments placed inside a type parameter list of
  /// a mixin are not associated with the mixin or with its type parameters.
  void test_blockInsideMixinTypeParameterList() async {
    var library = await bootLibrary('''
mixin M</** Line 1 */ T,
  /** Line 2
   */
  U extends num> {}
''');
    var mixinM = library.mixins.named('M');
    expect(mixinM.documentation, isEmpty);
    expectNoTypeParameterDocs(mixinM.typeParameters);
  }

  /// Check that doc comments placed inside a type parameter list of a mixin
  /// class are not associated with the mixin class or with its type parameters.
  void test_insideMixinClassTypeParameterList() async {
    var library = await bootLibrary('''
mixin class MC</// Line 1
  T,
  /// Line 2
  U extends num> {}
''');
    var mc = library.classes.named('MC');
    expect(mc.documentation, isEmpty);
    expectNoTypeParameterDocs(mc.typeParameters);
  }

  /// Check that block-based doc comments placed inside a type parameter list of
  /// a mixin class are not associated with the mixin class or with its type
  /// parameters.
  void test_blockInsideMixinClassTypeParameterList() async {
    var library = await bootLibrary('''
mixin class MC</** Line 1 */ T,
  /** Line 2
   */
  U extends num> {}
''');
    var mc = library.classes.named('MC');
    expect(mc.documentation, isEmpty);
    expectNoTypeParameterDocs(mc.typeParameters);
  }

  /// Check that doc comments placed inside a type parameter list of an enum are
  /// not associated with the enum or with its type parameters.
  void test_insideEnumTypeParameterList() async {
    var library = await bootLibrary('''
enum E</// Line 1
  T,
  /// Line 2
  U extends num> {
  e0;
}
''');
    var e = library.enums.named('E');
    expect(e.documentation, isEmpty);
    expectNoTypeParameterDocs(e.typeParameters);
  }

  /// Check that block-based doc comments placed inside a type parameter list of
  /// an enum are not associated with the enum or with its type parameters.
  void test_blockInsideEnumTypeParameterList() async {
    var library = await bootLibrary('''
enum E</** Line 1 */ T,
  /** Line 2
   */
  U extends num> {
  e0;
}
''');
    var e = library.enums.named('E');
    expect(e.documentation, isEmpty);
    expectNoTypeParameterDocs(e.typeParameters);
  }

  /// Check that doc comments placed inside a type parameter list of an
  /// extension are not associated with the extension or with its type
  /// parameters.
  void test_insideExtensionTypeParameterList() async {
    var library = await bootLibrary('''
extension Ext</// Line 1
  T,
  /// Line 2
  U extends num> on List<T> {}
''');
    var ext = library.extensions.named('Ext');
    expect(ext.documentation, isEmpty);
    expectNoTypeParameterDocs(ext.typeParameters);
  }

  /// Check that block-based doc comments placed inside a type parameter list of
  /// an extension are not associated with the extension or with its type
  /// parameters.
  void test_blockInsideExtensionTypeParameterList() async {
    var library = await bootLibrary('''
extension Ext</** Line 1 */ T,
  /** Line 2
   */
  U extends num> on List<T> {}
''');
    var ext = library.extensions.named('Ext');
    expect(ext.documentation, isEmpty);
    expectNoTypeParameterDocs(ext.typeParameters);
  }

  /// Check that doc comments placed inside a type parameter list of an
  /// extension type are not associated with the extension type or with its type
  /// parameters.
  void test_insideExtensionTypeTypeParameterList() async {
    var library = await bootLibrary('''
extension type ET</// Line 1
  T,
  /// Line 2
  U extends num>(int id) {}
''');
    var et = library.extensionTypes.named('ET');
    expect(et.documentation, isEmpty);
    expectNoTypeParameterDocs(et.typeParameters);
  }

  /// Check that block-based doc comments placed inside a type parameter list of
  /// an extension type are not associated with the extension type or with its
  /// type parameters.
  void test_blockInsideExtensionTypeTypeParameterList() async {
    var library = await bootLibrary('''
extension type ET</** Line 1 */ T,
  /** Line 2
   */
  U extends num>(int id) {}
''');
    var et = library.extensionTypes.named('ET');
    expect(et.documentation, isEmpty);
    expectNoTypeParameterDocs(et.typeParameters);
  }

  /// Check that doc comments placed inside a type parameter list of a method
  /// are not associated with the method or with its type parameters.
  void test_insideMethodTypeParameterList() async {
    var library = await bootLibrary('''
class C {
  void instanceMethod</// Line 1
  T,
  /// Line 2
  U extends num>() {}

  static void staticMethod</// Line 1
  T,
  /// Line 2
  U extends num>() {}
}
''');
    var c = library.classes.named('C');
    var m = c.instanceMethods.named('instanceMethod');
    expect(m.documentation, isEmpty);
    expectNoTypeParameterDocs(m.typeParameters);
    var s = c.staticMethods.named('staticMethod');
    expect(s.documentation, isEmpty);
    expectNoTypeParameterDocs(s.typeParameters);
  }

  /// Check that block-based doc comments placed inside a type parameter list of
  /// a method are not associated with the method or with its type parameters.
  void test_blockInsideMethodTypeParameterList() async {
    var library = await bootLibrary('''
class C {
  void instanceMethod</** Line 1 */ T,
  /** Line 2
   */
  U extends num>() {}

  static void staticMethod</** Line 1 */ T,
  /** Line 2
   */
  U extends num>() {}
}
''');
    var c = library.classes.named('C');
    var m = c.instanceMethods.named('instanceMethod');
    expect(m.documentation, isEmpty);
    expectNoTypeParameterDocs(m.typeParameters);
    var s = c.staticMethods.named('staticMethod');
    expect(s.documentation, isEmpty);
    expectNoTypeParameterDocs(s.typeParameters);
  }

  /// Check that doc comments placed inside a type parameter list of a typedef
  /// are not associated with the typedef or with its type parameters.
  void test_insideTypedefTypeParameterList() async {
    var library = await bootLibrary('''
typedef F</// Line 1
  T,
  /// Line 2
  U extends num> = void Function(T, U);

typedef void G</// Line 1
  T,
  /// Line 2
  U extends num>(T t, U u);
''');
    var f = library.typedefs.named('F');
    expect(f.documentation, isEmpty);
    expectNoTypeParameterDocs(f.typeParameters);
    var g = library.typedefs.named('G');
    expect(g.documentation, isEmpty);
    expectNoTypeParameterDocs(g.typeParameters);
  }

  /// Check that block-based doc comments placed inside a type parameter list of
  /// a typedef are not associated with the typedef or with its type parameters.
  void test_blockInsideTypedefTypeParameterList() async {
    var library = await bootLibrary('''
typedef F</** Line 1 */ T,
  /** Line 2
   */
  U extends num> = void Function(T, U);

typedef void G</** Line 1 */ T,
  /** Line 2
   */
  U extends num>(T t, U u);
''');
    var f = library.typedefs.named('F');
    expect(f.documentation, isEmpty);
    expectNoTypeParameterDocs(f.typeParameters);
    var g = library.typedefs.named('G');
    expect(g.documentation, isEmpty);
    expectNoTypeParameterDocs(g.typeParameters);
  }
}
