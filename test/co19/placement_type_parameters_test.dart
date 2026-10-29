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
    defineReflectiveTests(PlacementTypeParametersTest);
  });
}

@reflectiveTest
class PlacementTypeParametersTest extends Co19TestBase {
  /// Check that doc comments placed inside a type parameter list are not
  /// associated with the class or function.
  void test_insideTypeParameterList1() async {
    var library = await bootLibrary('''
class C</// Line 1
  T,
  /// Line 2
  U extends num> {}

void foo<
  /// Line 3
  T,
  /// Line 4
  U extends num>() {}
''');
    var c = library.classes.named('C');
    expect(c.documentation, isEmpty);
    var foo = library.functions.named('foo');
    expect(foo.documentation, isEmpty);
  }

  /// Check that block-based doc comments placed inside a type parameter list
  /// are not associated with the class or function.
  void test_blockInsideTypeParameterList1() async {
    var library = await bootLibrary('''
class C</** Line 1 */ T,
  /** Line 2
   */
  U extends num> {}

void foo<
  /** Line 3 */
  T,
  /** Line 4
   */
  U extends num>() {}
''');
    var c = library.classes.named('C');
    expect(c.documentation, isEmpty);
    var foo = library.functions.named('foo');
    expect(foo.documentation, isEmpty);
  }

  /// Check that doc comments placed before type parameters are ignored.
  @FailingTest(reason: 'https://github.com/dart-lang/dartdoc/issues/4302')
  void test_insideTypeParameterList2() async {
    var library = await bootLibrary('''
class C</// Line 1
  T,
  /// Line 2
  U extends num> {}

void foo<
  /// Line 3
  T,
  /// Line 4
  U extends num>() {}
''');
    var c = library.classes.named('C');
    expect(c.typeParameters.named('T').documentation, isEmpty);
    expect(c.typeParameters.named('U').documentation, isEmpty);
    var foo = library.functions.named('foo');
    expect(foo.typeParameters.named('T').documentation, isEmpty);
    expect(foo.typeParameters.named('U').documentation, isEmpty);
  }

  /// Check that block-based doc comments placed before type parameters are
  /// ignored.
  @FailingTest(reason: 'https://github.com/dart-lang/dartdoc/issues/4302')
  void test_blockInsideTypeParameterList2() async {
    var library = await bootLibrary('''
class C</** Line 1 */ T,
  /** Line 2
   */
  U extends num> {}

void foo<
  /** Line 3 */
  T,
  /** Line 4
   */
  U extends num>() {}
''');
    var c = library.classes.named('C');
    expect(c.typeParameters.named('T').documentation, isEmpty);
    expect(c.typeParameters.named('U').documentation, isEmpty);
    var foo = library.functions.named('foo');
    expect(foo.typeParameters.named('T').documentation, isEmpty);
    expect(foo.typeParameters.named('U').documentation, isEmpty);
  }

  /// Check that doc comments placed inside a type parameter list of a mixin are
  /// not associated with the mixin.
  void test_insideMixinTypeParameterList1() async {
    var library = await bootLibrary('''
mixin M</// Line 1
  T,
  /// Line 2
  U extends num> {}
''');
    var mixinM = library.mixins.named('M');
    expect(mixinM.documentation, isEmpty);
  }

  /// Check that block-based doc comments placed inside a type parameter list of
  /// a mixin are not associated with the mixin.
  void test_blockInsideMixinTypeParameterList1() async {
    var library = await bootLibrary('''
mixin M</** Line 1 */ T,
  /** Line 2
   */
  U extends num> {}
''');
    var mixinM = library.mixins.named('M');
    expect(mixinM.documentation, isEmpty);
  }

  /// Check that doc comments placed before type parameters of a mixin are
  /// ignored.
  @FailingTest(reason: 'https://github.com/dart-lang/dartdoc/issues/4302')
  void test_insideMixinTypeParameterList2() async {
    var library = await bootLibrary('''
mixin M</// Line 1
  T,
  /// Line 2
  U extends num> {}
''');
    var mixinM = library.mixins.named('M');
    expect(mixinM.typeParameters.named('T').documentation, isEmpty);
    expect(mixinM.typeParameters.named('U').documentation, isEmpty);
  }

  /// Check that block-based doc comments placed before type parameters of a
  /// mixin are ignored.
  @FailingTest(reason: 'https://github.com/dart-lang/dartdoc/issues/4302')
  void test_blockInsideMixinTypeParameterList2() async {
    var library = await bootLibrary('''
mixin M</** Line 1 */ T,
  /** Line 2
   */
  U extends num> {}
''');
    var mixinM = library.mixins.named('M');
    expect(mixinM.typeParameters.named('T').documentation, isEmpty);
    expect(mixinM.typeParameters.named('U').documentation, isEmpty);
  }

  /// Check that doc comments placed inside a type parameter list of a mixin
  /// class are not associated with the mixin class.
  void test_insideMixinClassTypeParameterList1() async {
    var library = await bootLibrary('''
mixin class MC</// Line 1
  T,
  /// Line 2
  U extends num> {}
''');
    var mc = library.classes.named('MC');
    expect(mc.documentation, isEmpty);
  }

  /// Check that block-based doc comments placed inside a type parameter list of
  /// a mixin class are not associated with the mixin class.
  void test_blockInsideMixinClassTypeParameterList1() async {
    var library = await bootLibrary('''
mixin class MC</** Line 1 */ T,
  /** Line 2
   */
  U extends num> {}
''');
    var mc = library.classes.named('MC');
    expect(mc.documentation, isEmpty);
  }

  /// Check that doc comments placed before type parameters of a mixin class are
  /// ignored.
  @FailingTest(reason: 'https://github.com/dart-lang/dartdoc/issues/4302')
  void test_insideMixinClassTypeParameterList2() async {
    var library = await bootLibrary('''
mixin class MC</// Line 1
  T,
  /// Line 2
  U extends num> {}
''');
    var mc = library.classes.named('MC');
    expect(mc.typeParameters.named('T').documentation, isEmpty);
    expect(mc.typeParameters.named('U').documentation, isEmpty);
  }

  /// Check that block-based doc comments placed before type parameters of a
  /// mixin class are ignored.
  @FailingTest(reason: 'https://github.com/dart-lang/dartdoc/issues/4302')
  void test_blockInsideMixinClassTypeParameterList2() async {
    var library = await bootLibrary('''
mixin class MC</** Line 1 */ T,
  /** Line 2
   */
  U extends num> {}
''');
    var mc = library.classes.named('MC');
    expect(mc.typeParameters.named('T').documentation, isEmpty);
    expect(mc.typeParameters.named('U').documentation, isEmpty);
  }

  /// Check that doc comments placed inside a type parameter list of an enum are
  /// not associated with the enum.
  void test_insideEnumTypeParameterList1() async {
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
  }

  /// Check that block-based doc comments placed inside a type parameter list of
  /// an enum are not associated with the enum.
  void test_blockInsideEnumTypeParameterList1() async {
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
  }

  /// Check that doc comments placed before type parameters of an enum are
  /// ignored.
  @FailingTest(reason: 'https://github.com/dart-lang/dartdoc/issues/4302')
  void test_insideEnumTypeParameterList2() async {
    var library = await bootLibrary('''
enum E</// Line 1
  T,
  /// Line 2
  U extends num> {
  e0;
}
''');
    var e = library.enums.named('E');
    expect(e.typeParameters.named('T').documentation, isEmpty);
    expect(e.typeParameters.named('U').documentation, isEmpty);
  }

  /// Check that block-based doc comments placed before type parameters of an
  /// enum are ignored.
  @FailingTest(reason: 'https://github.com/dart-lang/dartdoc/issues/4302')
  void test_blockInsideEnumTypeParameterList2() async {
    var library = await bootLibrary('''
enum E</** Line 1 */ T,
  /** Line 2
   */
  U extends num> {
  e0;
}
''');
    var e = library.enums.named('E');
    expect(e.typeParameters.named('T').documentation, isEmpty);
    expect(e.typeParameters.named('U').documentation, isEmpty);
  }

  /// Check that doc comments placed inside a type parameter list of an
  /// extension are not associated with the extension.
  void test_insideExtensionTypeParameterList1() async {
    var library = await bootLibrary('''
extension Ext</// Line 1
  T,
  /// Line 2
  U extends num> on List<T> {}
''');
    var ext = library.extensions.named('Ext');
    expect(ext.documentation, isEmpty);
  }

  /// Check that block-based doc comments placed inside a type parameter list of
  /// an extension are not associated with the extension.
  void test_blockInsideExtensionTypeParameterList1() async {
    var library = await bootLibrary('''
extension Ext</** Line 1 */ T,
  /** Line 2
   */
  U extends num> on List<T> {}
''');
    var ext = library.extensions.named('Ext');
    expect(ext.documentation, isEmpty);
  }

  /// Check that doc comments placed before type parameters of an extension are
  /// ignored.
  @FailingTest(reason: 'https://github.com/dart-lang/dartdoc/issues/4302')
  void test_insideExtensionTypeParameterList2() async {
    var library = await bootLibrary('''
extension Ext</// Line 1
  T,
  /// Line 2
  U extends num> on List<T> {}
''');
    var ext = library.extensions.named('Ext');
    expect(ext.typeParameters.named('T').documentation, isEmpty);
    expect(ext.typeParameters.named('U').documentation, isEmpty);
  }

  /// Check that block-based doc comments placed before type parameters of an
  /// extension are ignored.
  @FailingTest(reason: 'https://github.com/dart-lang/dartdoc/issues/4302')
  void test_blockInsideExtensionTypeParameterList2() async {
    var library = await bootLibrary('''
extension Ext</** Line 1 */ T,
  /** Line 2
   */
  U extends num> on List<T> {}
''');
    var ext = library.extensions.named('Ext');
    expect(ext.typeParameters.named('T').documentation, isEmpty);
    expect(ext.typeParameters.named('U').documentation, isEmpty);
  }

  /// Check that doc comments placed inside a type parameter list of an
  /// extension type are not associated with the extension type.
  void test_insideExtensionTypeTypeParameterList1() async {
    var library = await bootLibrary('''
extension type ET</// Line 1
  T,
  /// Line 2
  U extends num>(int id) {}
''');
    var et = library.extensionTypes.named('ET');
    expect(et.documentation, isEmpty);
  }

  /// Check that block-based doc comments placed inside a type parameter list of
  /// an extension type are not associated with the extension type.
  void test_blockInsideExtensionTypeTypeParameterList1() async {
    var library = await bootLibrary('''
extension type ET</** Line 1 */ T,
  /** Line 2
   */
  U extends num>(int id) {}
''');
    var et = library.extensionTypes.named('ET');
    expect(et.documentation, isEmpty);
  }

  /// Check that doc comments placed before type parameters of an extension type
  /// are ignored.
  @FailingTest(reason: 'https://github.com/dart-lang/dartdoc/issues/4302')
  void test_insideExtensionTypeTypeParameterList2() async {
    var library = await bootLibrary('''
extension type ET</// Line 1
  T,
  /// Line 2
  U extends num>(int id) {}
''');
    var et = library.extensionTypes.named('ET');
    expect(et.typeParameters.named('T').documentation, isEmpty);
    expect(et.typeParameters.named('U').documentation, isEmpty);
  }

  /// Check that block-based doc comments placed before type parameters of an
  /// extension type are ignored.
  @FailingTest(reason: 'https://github.com/dart-lang/dartdoc/issues/4302')
  void test_blockInsideExtensionTypeTypeParameterList2() async {
    var library = await bootLibrary('''
extension type ET</** Line 1 */ T,
  /** Line 2
   */
  U extends num>(int id) {}
''');
    var et = library.extensionTypes.named('ET');
    expect(et.typeParameters.named('T').documentation, isEmpty);
    expect(et.typeParameters.named('U').documentation, isEmpty);
  }
}
