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
  U extends num> {
  void instanceMethod</// Line 1
    T,
    /// Line 2
    U extends num>() {}

  static void staticMethod</// Line 1
    T,
    /// Line 2
    U extends num>() {}
}

void foo</// Line 1
  T,
  /// Line 2
  U extends num>() {}
''');
    var c = library.classes.named('C');
    expect(c.documentation, isEmpty);
    expectNoTypeParameterDocs(c.typeParameters);
    var cM = c.instanceMethods.named('instanceMethod');
    expect(cM.documentation, isEmpty);
    expectNoTypeParameterDocs(cM.typeParameters);
    var cS = c.staticMethods.named('staticMethod');
    expect(cS.documentation, isEmpty);
    expectNoTypeParameterDocs(cS.typeParameters);
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
  U extends num> {
  void instanceMethod</** Line 1 */ T,
    /** Line 2
     */
    U extends num>() {}

  static void staticMethod</** Line 1 */ T,
    /** Line 2
     */
    U extends num>() {}
}

void foo</** Line 1 */ T,
  /** Line 2
   */
  U extends num>() {}
''');
    var c = library.classes.named('C');
    expect(c.documentation, isEmpty);
    expectNoTypeParameterDocs(c.typeParameters);
    var cM = c.instanceMethods.named('instanceMethod');
    expect(cM.documentation, isEmpty);
    expectNoTypeParameterDocs(cM.typeParameters);
    var cS = c.staticMethods.named('staticMethod');
    expect(cS.documentation, isEmpty);
    expectNoTypeParameterDocs(cS.typeParameters);
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
  U extends num> {
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
    var mixinM = library.mixins.named('M');
    expect(mixinM.documentation, isEmpty);
    expectNoTypeParameterDocs(mixinM.typeParameters);
    var mixinMM = mixinM.instanceMethods.named('instanceMethod');
    expect(mixinMM.documentation, isEmpty);
    expectNoTypeParameterDocs(mixinMM.typeParameters);
    var mixinMS = mixinM.staticMethods.named('staticMethod');
    expect(mixinMS.documentation, isEmpty);
    expectNoTypeParameterDocs(mixinMS.typeParameters);
  }

  /// Check that block-based doc comments placed inside a type parameter list of
  /// a mixin are not associated with the mixin or with its type parameters.
  void test_blockInsideMixinTypeParameterList() async {
    var library = await bootLibrary('''
mixin M</** Line 1 */ T,
  /** Line 2
   */
  U extends num> {
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
    var mixinM = library.mixins.named('M');
    expect(mixinM.documentation, isEmpty);
    expectNoTypeParameterDocs(mixinM.typeParameters);
    var mixinMM = mixinM.instanceMethods.named('instanceMethod');
    expect(mixinMM.documentation, isEmpty);
    expectNoTypeParameterDocs(mixinMM.typeParameters);
    var mixinMS = mixinM.staticMethods.named('staticMethod');
    expect(mixinMS.documentation, isEmpty);
    expectNoTypeParameterDocs(mixinMS.typeParameters);
  }

  /// Check that doc comments placed inside a type parameter list of a mixin
  /// class are not associated with the mixin class or with its type parameters.
  void test_insideMixinClassTypeParameterList() async {
    var library = await bootLibrary('''
mixin class MC</// Line 1
  T,
  /// Line 2
  U extends num> {
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
    var mc = library.classes.named('MC');
    expect(mc.documentation, isEmpty);
    expectNoTypeParameterDocs(mc.typeParameters);
    var mcM = mc.instanceMethods.named('instanceMethod');
    expect(mcM.documentation, isEmpty);
    expectNoTypeParameterDocs(mcM.typeParameters);
    var mcS = mc.staticMethods.named('staticMethod');
    expect(mcS.documentation, isEmpty);
    expectNoTypeParameterDocs(mcS.typeParameters);
  }

  /// Check that block-based doc comments placed inside a type parameter list of
  /// a mixin class are not associated with the mixin class or with its type
  /// parameters.
  void test_blockInsideMixinClassTypeParameterList() async {
    var library = await bootLibrary('''
mixin class MC</** Line 1 */ T,
  /** Line 2
   */
  U extends num> {
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
    var mc = library.classes.named('MC');
    expect(mc.documentation, isEmpty);
    expectNoTypeParameterDocs(mc.typeParameters);
    var mcM = mc.instanceMethods.named('instanceMethod');
    expect(mcM.documentation, isEmpty);
    expectNoTypeParameterDocs(mcM.typeParameters);
    var mcS = mc.staticMethods.named('staticMethod');
    expect(mcS.documentation, isEmpty);
    expectNoTypeParameterDocs(mcS.typeParameters);
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
    var e = library.enums.named('E');
    expect(e.documentation, isEmpty);
    expectNoTypeParameterDocs(e.typeParameters);
    var eM = e.instanceMethods.named('instanceMethod');
    expect(eM.documentation, isEmpty);
    expectNoTypeParameterDocs(eM.typeParameters);
    var eS = e.staticMethods.named('staticMethod');
    expect(eS.documentation, isEmpty);
    expectNoTypeParameterDocs(eS.typeParameters);
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
    var e = library.enums.named('E');
    expect(e.documentation, isEmpty);
    expectNoTypeParameterDocs(e.typeParameters);
    var eM = e.instanceMethods.named('instanceMethod');
    expect(eM.documentation, isEmpty);
    expectNoTypeParameterDocs(eM.typeParameters);
    var eS = e.staticMethods.named('staticMethod');
    expect(eS.documentation, isEmpty);
    expectNoTypeParameterDocs(eS.typeParameters);
  }

  /// Check that doc comments placed inside a type parameter list of an
  /// extension are not associated with the extension or with its type
  /// parameters.
  void test_insideExtensionTypeParameterList() async {
    var library = await bootLibrary('''
extension Ext</// Line 1
  T,
  /// Line 2
  U extends num> on List<T> {
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
    var ext = library.extensions.named('Ext');
    expect(ext.documentation, isEmpty);
    expectNoTypeParameterDocs(ext.typeParameters);
    var extM = ext.instanceMethods.named('instanceMethod');
    expect(extM.documentation, isEmpty);
    expectNoTypeParameterDocs(extM.typeParameters);
    var extS = ext.staticMethods.named('staticMethod');
    expect(extS.documentation, isEmpty);
    expectNoTypeParameterDocs(extS.typeParameters);
  }

  /// Check that block-based doc comments placed inside a type parameter list of
  /// an extension are not associated with the extension or with its type
  /// parameters.
  void test_blockInsideExtensionTypeParameterList() async {
    var library = await bootLibrary('''
extension Ext</** Line 1 */ T,
  /** Line 2
   */
  U extends num> on List<T> {
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
    var ext = library.extensions.named('Ext');
    expect(ext.documentation, isEmpty);
    expectNoTypeParameterDocs(ext.typeParameters);
    var extM = ext.instanceMethods.named('instanceMethod');
    expect(extM.documentation, isEmpty);
    expectNoTypeParameterDocs(extM.typeParameters);
    var extS = ext.staticMethods.named('staticMethod');
    expect(extS.documentation, isEmpty);
    expectNoTypeParameterDocs(extS.typeParameters);
  }

  /// Check that doc comments placed inside a type parameter list of an
  /// extension type are not associated with the extension type or with its type
  /// parameters.
  void test_insideExtensionTypeTypeParameterList() async {
    var library = await bootLibrary('''
extension type ET</// Line 1
  T,
  /// Line 2
  U extends num>(int id) {
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
    var et = library.extensionTypes.named('ET');
    expect(et.documentation, isEmpty);
    expectNoTypeParameterDocs(et.typeParameters);
    var etM = et.instanceMethods.named('instanceMethod');
    expect(etM.documentation, isEmpty);
    expectNoTypeParameterDocs(etM.typeParameters);
    var etS = et.staticMethods.named('staticMethod');
    expect(etS.documentation, isEmpty);
    expectNoTypeParameterDocs(etS.typeParameters);
  }

  /// Check that block-based doc comments placed inside a type parameter list of
  /// an extension type are not associated with the extension type or with its
  /// type parameters.
  void test_blockInsideExtensionTypeTypeParameterList() async {
    var library = await bootLibrary('''
extension type ET</** Line 1 */ T,
  /** Line 2
   */
  U extends num>(int id) {
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
    var et = library.extensionTypes.named('ET');
    expect(et.documentation, isEmpty);
    expectNoTypeParameterDocs(et.typeParameters);
    var etM = et.instanceMethods.named('instanceMethod');
    expect(etM.documentation, isEmpty);
    expectNoTypeParameterDocs(etM.typeParameters);
    var etS = et.staticMethods.named('staticMethod');
    expect(etS.documentation, isEmpty);
    expectNoTypeParameterDocs(etS.typeParameters);
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
