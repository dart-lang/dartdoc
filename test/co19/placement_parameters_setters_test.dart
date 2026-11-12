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
    defineReflectiveTests(PlacementParametersSettersTest);
  });
}

@reflectiveTest
class PlacementParametersSettersTest extends Co19TestBase {
  /// Check that doc comments placed inside a parameter list of a static setter
  /// are not associated with the setter.
  void test_staticSetterParameters1() async {
    var library = await bootPackageWithLibrary('''
class C {
  static set foo(/// Line 1
    int x) {}

  static set bar(
    /// Line 2
    int x) {}
}
''');
    var c = library.classes.named('C');
    var foo = c.staticFields.named('foo');
    expect(foo.documentation, isEmpty);
    var bar = c.staticFields.named('bar');
    expect(bar.documentation, isEmpty);
  }

  /// Check that doc comments placed inside a parameter list of a static setter
  /// are ignored.
  @FailingTest(reason: 'https://github.com/dart-lang/dartdoc/issues/1259')
  void test_staticSetterParameters2() async {
    var library = await bootPackageWithLibrary('''
class C {
  static set foo(/// Line 1
    int x) {}

  static set bar(
    /// Line 2
    int x) {}
}
''');
    var c = library.classes.named('C');
    var foo = c.staticFields.named('foo');
    expect(foo.parameters.named('x').documentation, isEmpty);
    var bar = c.staticFields.named('bar');
    expect(bar.parameters.named('x').documentation, isEmpty);
  }

  /// Check that block-based doc comments placed inside a parameter list of a
  /// static setter are not associated with the setter.
  void test_blockStaticSetterParameters1() async {
    var library = await bootPackageWithLibrary('''
class C {
  static set foo(/** Line 1 */ int x) {}

  static set bar(
    /** Line 2
     */
    int x) {}
}
''');
    var c = library.classes.named('C');
    var foo = c.staticFields.named('foo');
    expect(foo.documentation, isEmpty);
    var bar = c.staticFields.named('bar');
    expect(bar.documentation, isEmpty);
  }

  /// Check that block-based doc comments placed inside a parameter list of a
  /// static setter are ignored.
  @FailingTest(reason: 'https://github.com/dart-lang/dartdoc/issues/1259')
  void test_blockStaticSetterParameters2() async {
    var library = await bootPackageWithLibrary('''
class C {
  static set foo(/** Line 1 */ int x) {}

  static set bar(
    /** Line 2
     */
    int x) {}
}
''');
    var c = library.classes.named('C');
    var foo = c.staticFields.named('foo');
    expect(foo.parameters.named('x').documentation, isEmpty);
    var bar = c.staticFields.named('bar');
    expect(bar.parameters.named('x').documentation, isEmpty);
  }

  /// Check that doc comments placed inside a parameter list of an instance
  /// setter are not associated with the setter.
  void test_instanceSetterParameters1() async {
    var library = await bootPackageWithLibrary('''
class C {
  set foo(/// Line 1
    int x) {}

  set bar(
    /// Line 2
    int x) {}
}
''');
    var c = library.classes.named('C');
    var foo = c.instanceFields.named('foo');
    expect(foo.documentation, isEmpty);
    var bar = c.instanceFields.named('bar');
    expect(bar.documentation, isEmpty);
  }

  /// Check that doc comments placed inside a parameter list of an instance
  /// setter are ignored.
  @FailingTest(reason: 'https://github.com/dart-lang/dartdoc/issues/1259')
  void test_instanceSetterParameters2() async {
    var library = await bootPackageWithLibrary('''
class C {
  set foo(/// Line 1
    int x) {}

  set bar(
    /// Line 2
    int x) {}
}
''');
    var c = library.classes.named('C');
    var foo = c.instanceFields.named('foo');
    expect(foo.parameters.named('x').documentation, isEmpty);
    var bar = c.instanceFields.named('bar');
    expect(bar.parameters.named('x').documentation, isEmpty);
  }

  /// Check that block-based doc comments placed inside a parameter list of an
  /// instance setter are not associated with the setter.
  void test_blockInstanceSetterParameters1() async {
    var library = await bootPackageWithLibrary('''
class C {
  set foo(/** Line 1 */ int x) {}

  set bar(
    /** Line 2
     */
    int x) {}
}
''');
    var c = library.classes.named('C');
    var foo = c.instanceFields.named('foo');
    expect(foo.documentation, isEmpty);
    var bar = c.instanceFields.named('bar');
    expect(bar.documentation, isEmpty);
  }

  /// Check that block-based doc comments placed inside a parameter list of an
  /// instance setter are ignored.
  @FailingTest(reason: 'https://github.com/dart-lang/dartdoc/issues/1259')
  void test_blockInstanceSetterParameters2() async {
    var library = await bootPackageWithLibrary('''
class C {
  set foo(/** Line 1 */ int x) {}

  set bar(
    /** Line 2
     */
    int x) {}
}
''');
    var c = library.classes.named('C');
    var foo = c.instanceFields.named('foo');
    expect(foo.parameters.named('x').documentation, isEmpty);
    var bar = c.instanceFields.named('bar');
    expect(bar.parameters.named('x').documentation, isEmpty);
  }

  /// Check that doc comments placed inside a parameter list of a static setter
  /// of a mixin are not associated with the setter.
  void test_mixinStaticSetterParameters1() async {
    var library = await bootPackageWithLibrary('''
mixin M {
  static set foo(/// Line 1
    int x) {}

  static set bar(
    /// Line 2
    int x) {}
}
''');
    var mixinM = library.mixins.named('M');
    var foo = mixinM.staticFields.named('foo');
    expect(foo.documentation, isEmpty);
    var bar = mixinM.staticFields.named('bar');
    expect(bar.documentation, isEmpty);
  }

  /// Check that doc comments placed inside a parameter list of a static setter
  /// of a mixin are ignored.
  @FailingTest(reason: 'https://github.com/dart-lang/dartdoc/issues/1259')
  void test_mixinStaticSetterParameters2() async {
    var library = await bootPackageWithLibrary('''
mixin M {
  static set foo(/// Line 1
    int x) {}

  static set bar(
    /// Line 2
    int x) {}
}
''');
    var mixinM = library.mixins.named('M');
    var foo = mixinM.staticFields.named('foo');
    expect(foo.parameters.named('x').documentation, isEmpty);
    var bar = mixinM.staticFields.named('bar');
    expect(bar.parameters.named('x').documentation, isEmpty);
  }

  /// Check that block-based doc comments placed inside a parameter list of a
  /// static setter of a mixin are not associated with the setter.
  void test_blockMixinStaticSetterParameters1() async {
    var library = await bootPackageWithLibrary('''
mixin M {
  static set foo(/** Line 1 */ int x) {}

  static set bar(
    /** Line 2
     */
    int x) {}
}
''');
    var mixinM = library.mixins.named('M');
    var foo = mixinM.staticFields.named('foo');
    expect(foo.documentation, isEmpty);
    var bar = mixinM.staticFields.named('bar');
    expect(bar.documentation, isEmpty);
  }

  /// Check that block-based doc comments placed inside a parameter list of a
  /// static setter of a mixin are ignored.
  @FailingTest(reason: 'https://github.com/dart-lang/dartdoc/issues/1259')
  void test_blockMixinStaticSetterParameters2() async {
    var library = await bootPackageWithLibrary('''
mixin M {
  static set foo(/** Line 1 */ int x) {}

  static set bar(
    /** Line 2
     */
    int x) {}
}
''');
    var mixinM = library.mixins.named('M');
    var foo = mixinM.staticFields.named('foo');
    expect(foo.parameters.named('x').documentation, isEmpty);
    var bar = mixinM.staticFields.named('bar');
    expect(bar.parameters.named('x').documentation, isEmpty);
  }

  /// Check that doc comments placed inside a parameter list of an instance
  /// setter of a mixin are not associated with the setter.
  void test_mixinInstanceSetterParameters1() async {
    var library = await bootPackageWithLibrary('''
mixin M {
  set foo(/// Line 1
    int x) {}

  set bar(
    /// Line 2
    int x) {}
}
''');
    var mixinM = library.mixins.named('M');
    var foo = mixinM.instanceFields.named('foo');
    expect(foo.documentation, isEmpty);
    var bar = mixinM.instanceFields.named('bar');
    expect(bar.documentation, isEmpty);
  }

  /// Check that doc comments placed inside a parameter list of an instance
  /// setter of a mixin are ignored.
  @FailingTest(reason: 'https://github.com/dart-lang/dartdoc/issues/1259')
  void test_mixinInstanceSetterParameters2() async {
    var library = await bootPackageWithLibrary('''
mixin M {
  set foo(/// Line 1
    int x) {}

  set bar(
    /// Line 2
    int x) {}
}
''');
    var mixinM = library.mixins.named('M');
    var foo = mixinM.instanceFields.named('foo');
    expect(foo.parameters.named('x').documentation, isEmpty);
    var bar = mixinM.instanceFields.named('bar');
    expect(bar.parameters.named('x').documentation, isEmpty);
  }

  /// Check that block-based doc comments placed inside a parameter list of an
  /// instance setter of a mixin are not associated with the setter.
  void test_blockMixinInstanceSetterParameters1() async {
    var library = await bootPackageWithLibrary('''
mixin M {
  set foo(/** Line 1 */ int x) {}

  set bar(
    /** Line 2
     */
    int x) {}
}
''');
    var mixinM = library.mixins.named('M');
    var foo = mixinM.instanceFields.named('foo');
    expect(foo.documentation, isEmpty);
    var bar = mixinM.instanceFields.named('bar');
    expect(bar.documentation, isEmpty);
  }

  /// Check that block-based doc comments placed inside a parameter list of an
  /// instance setter of a mixin are ignored.
  @FailingTest(reason: 'https://github.com/dart-lang/dartdoc/issues/1259')
  void test_blockMixinInstanceSetterParameters2() async {
    var library = await bootPackageWithLibrary('''
mixin M {
  set foo(/** Line 1 */ int x) {}

  set bar(
    /** Line 2
     */
    int x) {}
}
''');
    var mixinM = library.mixins.named('M');
    var foo = mixinM.instanceFields.named('foo');
    expect(foo.parameters.named('x').documentation, isEmpty);
    var bar = mixinM.instanceFields.named('bar');
    expect(bar.parameters.named('x').documentation, isEmpty);
  }

  /// Check that doc comments placed inside a parameter list of a static setter
  /// of a mixin class are not associated with the setter.
  void test_mixinClassStaticSetterParameters1() async {
    var library = await bootPackageWithLibrary('''
mixin class M {
  static set foo(/// Line 1
    int x) {}

  static set bar(
    /// Line 2
    int x) {}
}
''');
    var m = library.classes.named('M');
    var foo = m.staticFields.named('foo');
    expect(foo.documentation, isEmpty);
    var bar = m.staticFields.named('bar');
    expect(bar.documentation, isEmpty);
  }

  /// Check that doc comments placed inside a parameter list of a static setter
  /// of a mixin class are ignored.
  @FailingTest(reason: 'https://github.com/dart-lang/dartdoc/issues/1259')
  void test_mixinClassStaticSetterParameters2() async {
    var library = await bootPackageWithLibrary('''
mixin class M {
  static set foo(/// Line 1
    int x) {}

  static set bar(
    /// Line 2
    int x) {}
}
''');
    var m = library.classes.named('M');
    var foo = m.staticFields.named('foo');
    expect(foo.parameters.named('x').documentation, isEmpty);
    var bar = m.staticFields.named('bar');
    expect(bar.parameters.named('x').documentation, isEmpty);
  }

  /// Check that block-based doc comments placed inside a parameter list of a
  /// static setter of a mixin class are not associated with the setter.
  void test_blockMixinClassStaticSetterParameters1() async {
    var library = await bootPackageWithLibrary('''
mixin class M {
  static set foo(/** Line 1 */ int x) {}

  static set bar(
    /** Line 2
     */
    int x) {}
}
''');
    var m = library.classes.named('M');
    var foo = m.staticFields.named('foo');
    expect(foo.documentation, isEmpty);
    var bar = m.staticFields.named('bar');
    expect(bar.documentation, isEmpty);
  }

  /// Check that block-based doc comments placed inside a parameter list of a
  /// static setter of a mixin class are ignored.
  @FailingTest(reason: 'https://github.com/dart-lang/dartdoc/issues/1259')
  void test_blockMixinClassStaticSetterParameters2() async {
    var library = await bootPackageWithLibrary('''
mixin class M {
  static set foo(/** Line 1 */ int x) {}

  static set bar(
    /** Line 2
     */
    int x) {}
}
''');
    var m = library.classes.named('M');
    var foo = m.staticFields.named('foo');
    expect(foo.parameters.named('x').documentation, isEmpty);
    var bar = m.staticFields.named('bar');
    expect(bar.parameters.named('x').documentation, isEmpty);
  }

  /// Check that doc comments placed inside a parameter list of an instance
  /// setter of a mixin class are not associated with the setter.
  void test_mixinClassInstanceSetterParameters1() async {
    var library = await bootPackageWithLibrary('''
mixin class M {
  set foo(/// Line 1
    int x) {}

  set bar(
    /// Line 2
    int x) {}
}
''');
    var m = library.classes.named('M');
    var foo = m.instanceFields.named('foo');
    expect(foo.documentation, isEmpty);
    var bar = m.instanceFields.named('bar');
    expect(bar.documentation, isEmpty);
  }

  /// Check that doc comments placed inside a parameter list of an instance
  /// setter of a mixin class are ignored.
  @FailingTest(reason: 'https://github.com/dart-lang/dartdoc/issues/1259')
  void test_mixinClassInstanceSetterParameters2() async {
    var library = await bootPackageWithLibrary('''
mixin class M {
  set foo(/// Line 1
    int x) {}

  set bar(
    /// Line 2
    int x) {}
}
''');
    var m = library.classes.named('M');
    var foo = m.instanceFields.named('foo');
    expect(foo.parameters.named('x').documentation, isEmpty);
    var bar = m.instanceFields.named('bar');
    expect(bar.parameters.named('x').documentation, isEmpty);
  }

  /// Check that block-based doc comments placed inside a parameter list of an
  /// instance setter of a mixin class are not associated with the setter.
  void test_blockMixinClassInstanceSetterParameters1() async {
    var library = await bootPackageWithLibrary('''
mixin class M {
  set foo(/** Line 1 */ int x) {}

  set bar(
    /** Line 2
     */
    int x) {}
}
''');
    var m = library.classes.named('M');
    var foo = m.instanceFields.named('foo');
    expect(foo.documentation, isEmpty);
    var bar = m.instanceFields.named('bar');
    expect(bar.documentation, isEmpty);
  }

  /// Check that block-based doc comments placed inside a parameter list of an
  /// instance setter of a mixin class are ignored.
  @FailingTest(reason: 'https://github.com/dart-lang/dartdoc/issues/1259')
  void test_blockMixinClassInstanceSetterParameters2() async {
    var library = await bootPackageWithLibrary('''
mixin class M {
  set foo(/** Line 1 */ int x) {}

  set bar(
    /** Line 2
     */
    int x) {}
}
''');
    var m = library.classes.named('M');
    var foo = m.instanceFields.named('foo');
    expect(foo.parameters.named('x').documentation, isEmpty);
    var bar = m.instanceFields.named('bar');
    expect(bar.parameters.named('x').documentation, isEmpty);
  }

  /// Check that doc comments placed inside a parameter list of a static setter
  /// of an enum are not associated with the setter.
  void test_enumStaticSetterParameters1() async {
    var library = await bootPackageWithLibrary('''
enum E {
  e0;

  static set foo(/// Line 1
    int x) {}

  static set bar(
    /// Line 2
    int x) {}
}
''');
    var e = library.enums.named('E');
    var foo = e.staticFields.named('foo');
    expect(foo.documentation, isEmpty);
    var bar = e.staticFields.named('bar');
    expect(bar.documentation, isEmpty);
  }

  /// Check that doc comments placed inside a parameter list of a static setter
  /// of an enum are ignored.
  @FailingTest(reason: 'https://github.com/dart-lang/dartdoc/issues/1259')
  void test_enumStaticSetterParameters2() async {
    var library = await bootPackageWithLibrary('''
enum E {
  e0;

  static set foo(/// Line 1
    int x) {}

  static set bar(
    /// Line 2
    int x) {}
}
''');
    var e = library.enums.named('E');
    var foo = e.staticFields.named('foo');
    expect(foo.parameters.named('x').documentation, isEmpty);
    var bar = e.staticFields.named('bar');
    expect(bar.parameters.named('x').documentation, isEmpty);
  }

  /// Check that block-based doc comments placed inside a parameter list of a
  /// static setter of an enum are not associated with the setter.
  void test_blockEnumStaticSetterParameters1() async {
    var library = await bootPackageWithLibrary('''
enum E {
  e0;

  static set foo(/** Line 1 */ int x) {}

  static set bar(
    /** Line 2
     */
    int x) {}
}
''');
    var e = library.enums.named('E');
    var foo = e.staticFields.named('foo');
    expect(foo.documentation, isEmpty);
    var bar = e.staticFields.named('bar');
    expect(bar.documentation, isEmpty);
  }

  /// Check that block-based doc comments placed inside a parameter list of a
  /// static setter of an enum are ignored.
  @FailingTest(reason: 'https://github.com/dart-lang/dartdoc/issues/1259')
  void test_blockEnumStaticSetterParameters2() async {
    var library = await bootPackageWithLibrary('''
enum E {
  e0;

  static set foo(/** Line 1 */ int x) {}

  static set bar(
    /** Line 2
     */
    int x) {}
}
''');
    var e = library.enums.named('E');
    var foo = e.staticFields.named('foo');
    expect(foo.parameters.named('x').documentation, isEmpty);
    var bar = e.staticFields.named('bar');
    expect(bar.parameters.named('x').documentation, isEmpty);
  }

  /// Check that doc comments placed inside a parameter list of an instance
  /// setter of an enum are not associated with the setter.
  void test_enumInstanceSetterParameters1() async {
    var library = await bootPackageWithLibrary('''
enum E {
  e0;

  set foo(/// Line 1
    int x) {}

  set bar(
    /// Line 2
    int x) {}
}
''');
    var e = library.enums.named('E');
    var foo = e.instanceFields.named('foo');
    expect(foo.documentation, isEmpty);
    var bar = e.instanceFields.named('bar');
    expect(bar.documentation, isEmpty);
  }

  /// Check that doc comments placed inside a parameter list of an instance
  /// setter of an enum are ignored.
  @FailingTest(reason: 'https://github.com/dart-lang/dartdoc/issues/1259')
  void test_enumInstanceSetterParameters2() async {
    var library = await bootPackageWithLibrary('''
enum E {
  e0;

  set foo(/// Line 1
    int x) {}

  set bar(
    /// Line 2
    int x) {}
}
''');
    var e = library.enums.named('E');
    var foo = e.instanceFields.named('foo');
    expect(foo.parameters.named('x').documentation, isEmpty);
    var bar = e.instanceFields.named('bar');
    expect(bar.parameters.named('x').documentation, isEmpty);
  }

  /// Check that block-based doc comments placed inside a parameter list of an
  /// instance setter of an enum are not associated with the setter.
  void test_blockEnumInstanceSetterParameters1() async {
    var library = await bootPackageWithLibrary('''
enum E {
  e0;

  set foo(/** Line 1 */ int x) {}

  set bar(
    /** Line 2
     */
    int x) {}
}
''');
    var e = library.enums.named('E');
    var foo = e.instanceFields.named('foo');
    expect(foo.documentation, isEmpty);
    var bar = e.instanceFields.named('bar');
    expect(bar.documentation, isEmpty);
  }

  /// Check that block-based doc comments placed inside a parameter list of an
  /// instance setter of an enum are ignored.
  @FailingTest(reason: 'https://github.com/dart-lang/dartdoc/issues/1259')
  void test_blockEnumInstanceSetterParameters2() async {
    var library = await bootPackageWithLibrary('''
enum E {
  e0;

  set foo(/** Line 1 */ int x) {}

  set bar(
    /** Line 2
     */
    int x) {}
}
''');
    var e = library.enums.named('E');
    var foo = e.instanceFields.named('foo');
    expect(foo.parameters.named('x').documentation, isEmpty);
    var bar = e.instanceFields.named('bar');
    expect(bar.parameters.named('x').documentation, isEmpty);
  }

  /// Check that doc comments placed inside a parameter list of a static setter
  /// of an extension are not associated with the setter.
  void test_extensionStaticSetterParameters1() async {
    var library = await bootPackageWithLibrary('''
class A {}

extension Ext on A {
  static set foo(/// Line 1
    int x) {}

  static set bar(
    /// Line 2
    int x) {}
}
''');
    var ext = library.extensions.named('Ext');
    var foo = ext.staticFields.named('foo');
    expect(foo.documentation, isEmpty);
    var bar = ext.staticFields.named('bar');
    expect(bar.documentation, isEmpty);
  }

  /// Check that doc comments placed inside a parameter list of a static setter
  /// of an extension are ignored.
  @FailingTest(reason: 'https://github.com/dart-lang/dartdoc/issues/1259')
  void test_extensionStaticSetterParameters2() async {
    var library = await bootPackageWithLibrary('''
class A {}

extension Ext on A {
  static set foo(/// Line 1
    int x) {}

  static set bar(
    /// Line 2
    int x) {}
}
''');
    var ext = library.extensions.named('Ext');
    var foo = ext.staticFields.named('foo');
    expect(foo.parameters.named('x').documentation, isEmpty);
    var bar = ext.staticFields.named('bar');
    expect(bar.parameters.named('x').documentation, isEmpty);
  }

  /// Check that block-based doc comments placed inside a parameter list of a
  /// static setter of an extension are not associated with the setter.
  void test_blockExtensionStaticSetterParameters1() async {
    var library = await bootPackageWithLibrary('''
class A {}

extension Ext on A {
  static set foo(/** Line 1 */ int x) {}

  static set bar(
    /** Line 2
     */
    int x) {}
}
''');
    var ext = library.extensions.named('Ext');
    var foo = ext.staticFields.named('foo');
    expect(foo.documentation, isEmpty);
    var bar = ext.staticFields.named('bar');
    expect(bar.documentation, isEmpty);
  }

  /// Check that block-based doc comments placed inside a parameter list of a
  /// static setter of an extension are ignored.
  @FailingTest(reason: 'https://github.com/dart-lang/dartdoc/issues/1259')
  void test_blockExtensionStaticSetterParameters2() async {
    var library = await bootPackageWithLibrary('''
class A {}

extension Ext on A {
  static set foo(/** Line 1 */ int x) {}

  static set bar(
    /** Line 2
     */
    int x) {}
}
''');
    var ext = library.extensions.named('Ext');
    var foo = ext.staticFields.named('foo');
    expect(foo.parameters.named('x').documentation, isEmpty);
    var bar = ext.staticFields.named('bar');
    expect(bar.parameters.named('x').documentation, isEmpty);
  }

  /// Check that doc comments placed inside a parameter list of an instance
  /// setter of an extension are not associated with the setter.
  void test_extensionInstanceSetterParameters1() async {
    var library = await bootPackageWithLibrary('''
class A {}

extension Ext on A {
  set foo(/// Line 1
    int x) {}

  set bar(
    /// Line 2
    int x) {}
}
''');
    var ext = library.extensions.named('Ext');
    var foo = ext.instanceFields.named('foo');
    expect(foo.documentation, isEmpty);
    var bar = ext.instanceFields.named('bar');
    expect(bar.documentation, isEmpty);
  }

  /// Check that doc comments placed inside a parameter list of an instance
  /// setter of an extension are ignored.
  @FailingTest(reason: 'https://github.com/dart-lang/dartdoc/issues/1259')
  void test_extensionInstanceSetterParameters2() async {
    var library = await bootPackageWithLibrary('''
class A {}

extension Ext on A {
  set foo(/// Line 1
    int x) {}

  set bar(
    /// Line 2
    int x) {}
}
''');
    var ext = library.extensions.named('Ext');
    var foo = ext.instanceFields.named('foo');
    expect(foo.parameters.named('x').documentation, isEmpty);
    var bar = ext.instanceFields.named('bar');
    expect(bar.parameters.named('x').documentation, isEmpty);
  }

  /// Check that block-based doc comments placed inside a parameter list of an
  /// instance setter of an extension are not associated with the setter.
  void test_blockExtensionInstanceSetterParameters1() async {
    var library = await bootPackageWithLibrary('''
class A {}

extension Ext on A {
  set foo(/** Line 1 */ int x) {}

  set bar(
    /** Line 2
     */
    int x) {}
}
''');
    var ext = library.extensions.named('Ext');
    var foo = ext.instanceFields.named('foo');
    expect(foo.documentation, isEmpty);
    var bar = ext.instanceFields.named('bar');
    expect(bar.documentation, isEmpty);
  }

  /// Check that block-based doc comments placed inside a parameter list of an
  /// instance setter of an extension are ignored.
  @FailingTest(reason: 'https://github.com/dart-lang/dartdoc/issues/1259')
  void test_blockExtensionInstanceSetterParameters2() async {
    var library = await bootPackageWithLibrary('''
class A {}

extension Ext on A {
  set foo(/** Line 1 */ int x) {}

  set bar(
    /** Line 2
     */
    int x) {}
}
''');
    var ext = library.extensions.named('Ext');
    var foo = ext.instanceFields.named('foo');
    expect(foo.parameters.named('x').documentation, isEmpty);
    var bar = ext.instanceFields.named('bar');
    expect(bar.parameters.named('x').documentation, isEmpty);
  }

  /// Check that doc comments placed inside a parameter list of a static setter
  /// of an extension type are not associated with the setter.
  void test_extensionTypeStaticSetterParameters1() async {
    var library = await bootPackageWithLibrary('''
extension type ET(int v) {
  static set foo(/// Line 1
    int x) {}

  static set bar(
    /// Line 2
    int x) {}
}
''');
    var et = library.extensionTypes.named('ET');
    var foo = et.staticFields.named('foo');
    expect(foo.documentation, isEmpty);
    var bar = et.staticFields.named('bar');
    expect(bar.documentation, isEmpty);
  }

  /// Check that doc comments placed inside a parameter list of a static setter
  /// of an extension type are ignored.
  @FailingTest(reason: 'https://github.com/dart-lang/dartdoc/issues/1259')
  void test_extensionTypeStaticSetterParameters2() async {
    var library = await bootPackageWithLibrary('''
extension type ET(int v) {
  static set foo(/// Line 1
    int x) {}

  static set bar(
    /// Line 2
    int x) {}
}
''');
    var et = library.extensionTypes.named('ET');
    var foo = et.staticFields.named('foo');
    expect(foo.parameters.named('x').documentation, isEmpty);
    var bar = et.staticFields.named('bar');
    expect(bar.parameters.named('x').documentation, isEmpty);
  }

  /// Check that block-based doc comments placed inside a parameter list of a
  /// static setter of an extension type are not associated with the setter.
  void test_blockExtensionTypeStaticSetterParameters1() async {
    var library = await bootPackageWithLibrary('''
extension type ET(int v) {
  static set foo(/** Line 1 */ int x) {}

  static set bar(
    /** Line 2
     */
    int x) {}
}
''');
    var et = library.extensionTypes.named('ET');
    var foo = et.staticFields.named('foo');
    expect(foo.documentation, isEmpty);
    var bar = et.staticFields.named('bar');
    expect(bar.documentation, isEmpty);
  }

  /// Check that block-based doc comments placed inside a parameter list of a
  /// static setter of an extension type are ignored.
  @FailingTest(reason: 'https://github.com/dart-lang/dartdoc/issues/1259')
  void test_blockExtensionTypeStaticSetterParameters2() async {
    var library = await bootPackageWithLibrary('''
extension type ET(int v) {
  static set foo(/** Line 1 */ int x) {}

  static set bar(
    /** Line 2
     */
    int x) {}
}
''');
    var et = library.extensionTypes.named('ET');
    var foo = et.staticFields.named('foo');
    expect(foo.parameters.named('x').documentation, isEmpty);
    var bar = et.staticFields.named('bar');
    expect(bar.parameters.named('x').documentation, isEmpty);
  }

  /// Check that doc comments placed inside a parameter list of an instance
  /// setter of an extension type are not associated with the setter.
  void test_extensionTypeInstanceSetterParameters1() async {
    var library = await bootPackageWithLibrary('''
extension type ET(int v) {
  set foo(/// Line 1
    int x) {}

  set bar(
    /// Line 2
    int x) {}
}
''');
    var et = library.extensionTypes.named('ET');
    var foo = et.instanceFields.named('foo');
    expect(foo.documentation, isEmpty);
    var bar = et.instanceFields.named('bar');
    expect(bar.documentation, isEmpty);
  }

  /// Check that doc comments placed inside a parameter list of an instance
  /// setter of an extension type are ignored.
  @FailingTest(reason: 'https://github.com/dart-lang/dartdoc/issues/1259')
  void test_extensionTypeInstanceSetterParameters2() async {
    var library = await bootPackageWithLibrary('''
extension type ET(int v) {
  set foo(/// Line 1
    int x) {}

  set bar(
    /// Line 2
    int x) {}
}
''');
    var et = library.extensionTypes.named('ET');
    var foo = et.instanceFields.named('foo');
    expect(foo.parameters.named('x').documentation, isEmpty);
    var bar = et.instanceFields.named('bar');
    expect(bar.parameters.named('x').documentation, isEmpty);
  }

  /// Check that block-based doc comments placed inside a parameter list of an
  /// instance setter of an extension type are not associated with the setter.
  void test_blockExtensionTypeInstanceSetterParameters1() async {
    var library = await bootPackageWithLibrary('''
extension type ET(int v) {
  set foo(/** Line 1 */ int x) {}

  set bar(
    /** Line 2
     */
    int x) {}
}
''');
    var et = library.extensionTypes.named('ET');
    var foo = et.instanceFields.named('foo');
    expect(foo.documentation, isEmpty);
    var bar = et.instanceFields.named('bar');
    expect(bar.documentation, isEmpty);
  }

  /// Check that block-based doc comments placed inside a parameter list of an
  /// instance setter of an extension type are ignored.
  @FailingTest(reason: 'https://github.com/dart-lang/dartdoc/issues/1259')
  void test_blockExtensionTypeInstanceSetterParameters2() async {
    var library = await bootPackageWithLibrary('''
extension type ET(int v) {
  set foo(/** Line 1 */ int x) {}

  set bar(
    /** Line 2
     */
    int x) {}
}
''');
    var et = library.extensionTypes.named('ET');
    var foo = et.instanceFields.named('foo');
    expect(foo.parameters.named('x').documentation, isEmpty);
    var bar = et.instanceFields.named('bar');
    expect(bar.parameters.named('x').documentation, isEmpty);
  }
}
