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
    defineReflectiveTests(PlacementParametersMethodsTest);
  });
}

@reflectiveTest
class PlacementParametersMethodsTest extends Co19TestBase {
  /// Check that doc comments placed inside a parameter list of a static method
  /// are not associated with the method.
  void test_staticMethodParameters1() async {
    var library = await bootPackageWithLibrary('''
class C {
  static void foo(/// Line 1
    int x, [
    /// Line 2
    int y = 0]) {}

  static void bar({
    /// Line 3
    int x = 0,
    /// Line 4
    required int y}) {}
}
''');
    var c = library.classes.named('C');
    var foo = c.staticMethods.named('foo');
    expect(foo.documentation, isEmpty);
    var bar = c.staticMethods.named('bar');
    expect(bar.documentation, isEmpty);
  }

  /// Check that doc comments placed inside a parameter list of a static method
  /// are ignored.
  @FailingTest(reason: 'https://github.com/dart-lang/dartdoc/issues/1259')
  void test_staticMethodParameters2() async {
    var library = await bootPackageWithLibrary('''
class C {
  static void foo(/// Line 1
    int x, [
    /// Line 2
    int y = 0]) {}

  static void bar({
    /// Line 3
    int x = 0,
    /// Line 4
    required int y}) {}
}
''');
    var c = library.classes.named('C');
    var foo = c.staticMethods.named('foo');
    expect(foo.parameters.named('x').documentation, isEmpty);
    expect(foo.parameters.named('y').documentation, isEmpty);
    var bar = c.staticMethods.named('bar');
    expect(bar.parameters.named('x').documentation, isEmpty);
    expect(bar.parameters.named('y').documentation, isEmpty);
  }

  /// Check that block-based doc comments placed inside a parameter list of a
  /// static method are not associated with the method.
  void test_blockStaticMethodParameters1() async {
    var library = await bootPackageWithLibrary('''
class C {
  static void foo(/** Line 1 */ int x, [
    /** Line 2
     */
    int y = 0]) {}

  static void bar({
    /** Line 3 */
    int x = 0,
    /** Line 4
     */
    required int y}) {}
}
''');
    var c = library.classes.named('C');
    var foo = c.staticMethods.named('foo');
    expect(foo.documentation, isEmpty);
    var bar = c.staticMethods.named('bar');
    expect(bar.documentation, isEmpty);
  }

  /// Check that block-based doc comments placed inside a parameter list of a
  /// static method are ignored.
  @FailingTest(reason: 'https://github.com/dart-lang/dartdoc/issues/1259')
  void test_blockStaticMethodParameters2() async {
    var library = await bootPackageWithLibrary('''
class C {
  static void foo(/** Line 1 */ int x, [
    /** Line 2
     */
    int y = 0]) {}

  static void bar({
    /** Line 3 */
    int x = 0,
    /** Line 4
     */
    required int y}) {}
}
''');
    var c = library.classes.named('C');
    var foo = c.staticMethods.named('foo');
    expect(foo.parameters.named('x').documentation, isEmpty);
    expect(foo.parameters.named('y').documentation, isEmpty);
    var bar = c.staticMethods.named('bar');
    expect(bar.parameters.named('x').documentation, isEmpty);
    expect(bar.parameters.named('y').documentation, isEmpty);
  }

  /// Check that doc comments placed inside a parameter list of an instance
  /// method are not associated with the method.
  void test_instanceMethodParameters1() async {
    var library = await bootPackageWithLibrary('''
class C {
  void foo(/// Line 1
    int x, [
    /// Line 2
    int y = 0]) {}

  void bar({
    /// Line 3
    int x = 0,
    /// Line 4
    required int y}) {}
}
''');
    var c = library.classes.named('C');
    var foo = c.instanceMethods.named('foo');
    expect(foo.documentation, isEmpty);
    var bar = c.instanceMethods.named('bar');
    expect(bar.documentation, isEmpty);
  }

  /// Check that doc comments placed inside a parameter list of an instance
  /// method are ignored.
  @FailingTest(reason: 'https://github.com/dart-lang/dartdoc/issues/1259')
  void test_instanceMethodParameters2() async {
    var library = await bootPackageWithLibrary('''
class C {
  void foo(/// Line 1
    int x, [
    /// Line 2
    int y = 0]) {}

  void bar({
    /// Line 3
    int x = 0,
    /// Line 4
    required int y}) {}
}
''');
    var c = library.classes.named('C');
    var foo = c.instanceMethods.named('foo');
    expect(foo.parameters.named('x').documentation, isEmpty);
    expect(foo.parameters.named('y').documentation, isEmpty);
    var bar = c.instanceMethods.named('bar');
    expect(bar.parameters.named('x').documentation, isEmpty);
    expect(bar.parameters.named('y').documentation, isEmpty);
  }

  /// Check that block-based doc comments placed inside a parameter list of an
  /// instance method are not associated with the method.
  void test_blockInstanceMethodParameters1() async {
    var library = await bootPackageWithLibrary('''
class C {
  void foo(/** Line 1 */ int x, [
    /** Line 2
     */
    int y = 0]) {}

  void bar({
    /** Line 3 */
    int x = 0,
    /** Line 4
     */
    required int y}) {}
}
''');
    var c = library.classes.named('C');
    var foo = c.instanceMethods.named('foo');
    expect(foo.documentation, isEmpty);
    var bar = c.instanceMethods.named('bar');
    expect(bar.documentation, isEmpty);
  }

  /// Check that block-based doc comments placed inside a parameter list of an
  /// instance method are ignored.
  @FailingTest(reason: 'https://github.com/dart-lang/dartdoc/issues/1259')
  void test_blockInstanceMethodParameters2() async {
    var library = await bootPackageWithLibrary('''
class C {
  void foo(/** Line 1 */ int x, [
    /** Line 2
     */
    int y = 0]) {}

  void bar({
    /** Line 3 */
    int x = 0,
    /** Line 4
     */
    required int y}) {}
}
''');
    var c = library.classes.named('C');
    var foo = c.instanceMethods.named('foo');
    expect(foo.parameters.named('x').documentation, isEmpty);
    expect(foo.parameters.named('y').documentation, isEmpty);
    var bar = c.instanceMethods.named('bar');
    expect(bar.parameters.named('x').documentation, isEmpty);
    expect(bar.parameters.named('y').documentation, isEmpty);
  }

  /// Check that doc comments placed inside a parameter list of a static method
  /// of a mixin are not associated with the method.
  void test_mixinStaticMethodParameters1() async {
    var library = await bootPackageWithLibrary('''
mixin M {
  static void foo(/// Line 1
    int x, [
    /// Line 2
    int y = 0]) {}

  static void bar({
    /// Line 3
    int x = 0,
    /// Line 4
    required int y}) {}
}
''');
    var mixinM = library.mixins.named('M');
    var foo = mixinM.staticMethods.named('foo');
    expect(foo.documentation, isEmpty);
    var bar = mixinM.staticMethods.named('bar');
    expect(bar.documentation, isEmpty);
  }

  /// Check that doc comments placed inside a parameter list of a static method
  /// of a mixin are ignored.
  @FailingTest(reason: 'https://github.com/dart-lang/dartdoc/issues/1259')
  void test_mixinStaticMethodParameters2() async {
    var library = await bootPackageWithLibrary('''
mixin M {
  static void foo(/// Line 1
    int x, [
    /// Line 2
    int y = 0]) {}

  static void bar({
    /// Line 3
    int x = 0,
    /// Line 4
    required int y}) {}
}
''');
    var mixinM = library.mixins.named('M');
    var foo = mixinM.staticMethods.named('foo');
    expect(foo.parameters.named('x').documentation, isEmpty);
    expect(foo.parameters.named('y').documentation, isEmpty);
    var bar = mixinM.staticMethods.named('bar');
    expect(bar.parameters.named('x').documentation, isEmpty);
    expect(bar.parameters.named('y').documentation, isEmpty);
  }

  /// Check that block-based doc comments placed inside a parameter list of a
  /// static method of a mixin are not associated with the method.
  void test_blockMixinStaticMethodParameters1() async {
    var library = await bootPackageWithLibrary('''
mixin M {
  static void foo(/** Line 1 */ int x, [
    /** Line 2
     */
    int y = 0]) {}

  static void bar({
    /** Line 3 */
    int x = 0,
    /** Line 4
     */
    required int y}) {}
}
''');
    var mixinM = library.mixins.named('M');
    var foo = mixinM.staticMethods.named('foo');
    expect(foo.documentation, isEmpty);
    var bar = mixinM.staticMethods.named('bar');
    expect(bar.documentation, isEmpty);
  }

  /// Check that block-based doc comments placed inside a parameter list of a
  /// static method of a mixin are ignored.
  @FailingTest(reason: 'https://github.com/dart-lang/dartdoc/issues/1259')
  void test_blockMixinStaticMethodParameters2() async {
    var library = await bootPackageWithLibrary('''
mixin M {
  static void foo(/** Line 1 */ int x, [
    /** Line 2
     */
    int y = 0]) {}

  static void bar({
    /** Line 3 */
    int x = 0,
    /** Line 4
     */
    required int y}) {}
}
''');
    var mixinM = library.mixins.named('M');
    var foo = mixinM.staticMethods.named('foo');
    expect(foo.parameters.named('x').documentation, isEmpty);
    expect(foo.parameters.named('y').documentation, isEmpty);
    var bar = mixinM.staticMethods.named('bar');
    expect(bar.parameters.named('x').documentation, isEmpty);
    expect(bar.parameters.named('y').documentation, isEmpty);
  }

  /// Check that doc comments placed inside a parameter list of an instance
  /// method of a mixin are not associated with the method.
  void test_mixinInstanceMethodParameters1() async {
    var library = await bootPackageWithLibrary('''
mixin M {
  void foo(/// Line 1
    int x, [
    /// Line 2
    int y = 0]) {}

  void bar({
    /// Line 3
    int x = 0,
    /// Line 4
    required int y}) {}
}
''');
    var mixinM = library.mixins.named('M');
    var foo = mixinM.instanceMethods.named('foo');
    expect(foo.documentation, isEmpty);
    var bar = mixinM.instanceMethods.named('bar');
    expect(bar.documentation, isEmpty);
  }

  /// Check that doc comments placed inside a parameter list of an instance
  /// method of a mixin are ignored.
  @FailingTest(reason: 'https://github.com/dart-lang/dartdoc/issues/1259')
  void test_mixinInstanceMethodParameters2() async {
    var library = await bootPackageWithLibrary('''
mixin M {
  void foo(/// Line 1
    int x, [
    /// Line 2
    int y = 0]) {}

  void bar({
    /// Line 3
    int x = 0,
    /// Line 4
    required int y}) {}
}
''');
    var mixinM = library.mixins.named('M');
    var foo = mixinM.instanceMethods.named('foo');
    expect(foo.parameters.named('x').documentation, isEmpty);
    expect(foo.parameters.named('y').documentation, isEmpty);
    var bar = mixinM.instanceMethods.named('bar');
    expect(bar.parameters.named('x').documentation, isEmpty);
    expect(bar.parameters.named('y').documentation, isEmpty);
  }

  /// Check that block-based doc comments placed inside a parameter list of an
  /// instance method of a mixin are not associated with the method.
  void test_blockMixinInstanceMethodParameters1() async {
    var library = await bootPackageWithLibrary('''
mixin M {
  void foo(/** Line 1 */ int x, [
    /** Line 2
     */
    int y = 0]) {}

  void bar({
    /** Line 3 */
    int x = 0,
    /** Line 4
     */
    required int y}) {}
}
''');
    var mixinM = library.mixins.named('M');
    var foo = mixinM.instanceMethods.named('foo');
    expect(foo.documentation, isEmpty);
    var bar = mixinM.instanceMethods.named('bar');
    expect(bar.documentation, isEmpty);
  }

  /// Check that block-based doc comments placed inside a parameter list of an
  /// instance method of a mixin are ignored.
  @FailingTest(reason: 'https://github.com/dart-lang/dartdoc/issues/1259')
  void test_blockMixinInstanceMethodParameters2() async {
    var library = await bootPackageWithLibrary('''
mixin M {
  void foo(/** Line 1 */ int x, [
    /** Line 2
     */
    int y = 0]) {}

  void bar({
    /** Line 3 */
    int x = 0,
    /** Line 4
     */
    required int y}) {}
}
''');
    var mixinM = library.mixins.named('M');
    var foo = mixinM.instanceMethods.named('foo');
    expect(foo.parameters.named('x').documentation, isEmpty);
    expect(foo.parameters.named('y').documentation, isEmpty);
    var bar = mixinM.instanceMethods.named('bar');
    expect(bar.parameters.named('x').documentation, isEmpty);
    expect(bar.parameters.named('y').documentation, isEmpty);
  }

  /// Check that doc comments placed inside a parameter list of a static method
  /// of a mixin class are not associated with the method.
  void test_mixinClassStaticMethodParameters1() async {
    var library = await bootPackageWithLibrary('''
mixin class M {
  static void foo(/// Line 1
    int x, [
    /// Line 2
    int y = 0]) {}

  static void bar({
    /// Line 3
    int x = 0,
    /// Line 4
    required int y}) {}
}
''');
    var m = library.classes.named('M');
    var foo = m.staticMethods.named('foo');
    expect(foo.documentation, isEmpty);
    var bar = m.staticMethods.named('bar');
    expect(bar.documentation, isEmpty);
  }

  /// Check that doc comments placed inside a parameter list of a static method
  /// of a mixin class are ignored.
  @FailingTest(reason: 'https://github.com/dart-lang/dartdoc/issues/1259')
  void test_mixinClassStaticMethodParameters2() async {
    var library = await bootPackageWithLibrary('''
mixin class M {
  static void foo(/// Line 1
    int x, [
    /// Line 2
    int y = 0]) {}

  static void bar({
    /// Line 3
    int x = 0,
    /// Line 4
    required int y}) {}
}
''');
    var m = library.classes.named('M');
    var foo = m.staticMethods.named('foo');
    expect(foo.parameters.named('x').documentation, isEmpty);
    expect(foo.parameters.named('y').documentation, isEmpty);
    var bar = m.staticMethods.named('bar');
    expect(bar.parameters.named('x').documentation, isEmpty);
    expect(bar.parameters.named('y').documentation, isEmpty);
  }

  /// Check that block-based doc comments placed inside a parameter list of a
  /// static method of a mixin class are not associated with the method.
  void test_blockMixinClassStaticMethodParameters1() async {
    var library = await bootPackageWithLibrary('''
mixin class M {
  static void foo(/** Line 1 */ int x, [
    /** Line 2
     */
    int y = 0]) {}

  static void bar({
    /** Line 3 */
    int x = 0,
    /** Line 4
     */
    required int y}) {}
}
''');
    var m = library.classes.named('M');
    var foo = m.staticMethods.named('foo');
    expect(foo.documentation, isEmpty);
    var bar = m.staticMethods.named('bar');
    expect(bar.documentation, isEmpty);
  }

  /// Check that block-based doc comments placed inside a parameter list of a
  /// static method of a mixin class are ignored.
  @FailingTest(reason: 'https://github.com/dart-lang/dartdoc/issues/1259')
  void test_blockMixinClassStaticMethodParameters2() async {
    var library = await bootPackageWithLibrary('''
mixin class M {
  static void foo(/** Line 1 */ int x, [
    /** Line 2
     */
    int y = 0]) {}

  static void bar({
    /** Line 3 */
    int x = 0,
    /** Line 4
     */
    required int y}) {}
}
''');
    var m = library.classes.named('M');
    var foo = m.staticMethods.named('foo');
    expect(foo.parameters.named('x').documentation, isEmpty);
    expect(foo.parameters.named('y').documentation, isEmpty);
    var bar = m.staticMethods.named('bar');
    expect(bar.parameters.named('x').documentation, isEmpty);
    expect(bar.parameters.named('y').documentation, isEmpty);
  }

  /// Check that doc comments placed inside a parameter list of an instance
  /// method of a mixin class are not associated with the method.
  void test_mixinClassInstanceMethodParameters1() async {
    var library = await bootPackageWithLibrary('''
mixin class M {
  void foo(/// Line 1
    int x, [
    /// Line 2
    int y = 0]) {}

  void bar({
    /// Line 3
    int x = 0,
    /// Line 4
    required int y}) {}
}
''');
    var m = library.classes.named('M');
    var foo = m.instanceMethods.named('foo');
    expect(foo.documentation, isEmpty);
    var bar = m.instanceMethods.named('bar');
    expect(bar.documentation, isEmpty);
  }

  /// Check that doc comments placed inside a parameter list of an instance
  /// method of a mixin class are ignored.
  @FailingTest(reason: 'https://github.com/dart-lang/dartdoc/issues/1259')
  void test_mixinClassInstanceMethodParameters2() async {
    var library = await bootPackageWithLibrary('''
mixin class M {
  void foo(/// Line 1
    int x, [
    /// Line 2
    int y = 0]) {}

  void bar({
    /// Line 3
    int x = 0,
    /// Line 4
    required int y}) {}
}
''');
    var m = library.classes.named('M');
    var foo = m.instanceMethods.named('foo');
    expect(foo.parameters.named('x').documentation, isEmpty);
    expect(foo.parameters.named('y').documentation, isEmpty);
    var bar = m.instanceMethods.named('bar');
    expect(bar.parameters.named('x').documentation, isEmpty);
    expect(bar.parameters.named('y').documentation, isEmpty);
  }

  /// Check that block-based doc comments placed inside a parameter list of an
  /// instance method of a mixin class are not associated with the method.
  void test_blockMixinClassInstanceMethodParameters1() async {
    var library = await bootPackageWithLibrary('''
mixin class M {
  void foo(/** Line 1 */ int x, [
    /** Line 2
     */
    int y = 0]) {}

  void bar({
    /** Line 3 */
    int x = 0,
    /** Line 4
     */
    required int y}) {}
}
''');
    var m = library.classes.named('M');
    var foo = m.instanceMethods.named('foo');
    expect(foo.documentation, isEmpty);
    var bar = m.instanceMethods.named('bar');
    expect(bar.documentation, isEmpty);
  }

  /// Check that block-based doc comments placed inside a parameter list of an
  /// instance method of a mixin class are ignored.
  @FailingTest(reason: 'https://github.com/dart-lang/dartdoc/issues/1259')
  void test_blockMixinClassInstanceMethodParameters2() async {
    var library = await bootPackageWithLibrary('''
mixin class M {
  void foo(/** Line 1 */ int x, [
    /** Line 2
     */
    int y = 0]) {}

  void bar({
    /** Line 3 */
    int x = 0,
    /** Line 4
     */
    required int y}) {}
}
''');
    var m = library.classes.named('M');
    var foo = m.instanceMethods.named('foo');
    expect(foo.parameters.named('x').documentation, isEmpty);
    expect(foo.parameters.named('y').documentation, isEmpty);
    var bar = m.instanceMethods.named('bar');
    expect(bar.parameters.named('x').documentation, isEmpty);
    expect(bar.parameters.named('y').documentation, isEmpty);
  }

  /// Check that doc comments placed inside a parameter list of a static method
  /// of an enum are not associated with the method.
  void test_enumStaticMethodParameters1() async {
    var library = await bootPackageWithLibrary('''
enum E {
  e0;

  static void foo(/// Line 1
    int x, [
    /// Line 2
    int y = 0]) {}

  static void bar({
    /// Line 3
    int x = 0,
    /// Line 4
    required int y}) {}
}
''');
    var e = library.enums.named('E');
    var foo = e.staticMethods.named('foo');
    expect(foo.documentation, isEmpty);
    var bar = e.staticMethods.named('bar');
    expect(bar.documentation, isEmpty);
  }

  /// Check that doc comments placed inside a parameter list of a static method
  /// of an enum are ignored.
  @FailingTest(reason: 'https://github.com/dart-lang/dartdoc/issues/1259')
  void test_enumStaticMethodParameters2() async {
    var library = await bootPackageWithLibrary('''
enum E {
  e0;

  static void foo(/// Line 1
    int x, [
    /// Line 2
    int y = 0]) {}

  static void bar({
    /// Line 3
    int x = 0,
    /// Line 4
    required int y}) {}
}
''');
    var e = library.enums.named('E');
    var foo = e.staticMethods.named('foo');
    expect(foo.parameters.named('x').documentation, isEmpty);
    expect(foo.parameters.named('y').documentation, isEmpty);
    var bar = e.staticMethods.named('bar');
    expect(bar.parameters.named('x').documentation, isEmpty);
    expect(bar.parameters.named('y').documentation, isEmpty);
  }

  /// Check that block-based doc comments placed inside a parameter list of a
  /// static method of an enum are not associated with the method.
  void test_blockEnumStaticMethodParameters1() async {
    var library = await bootPackageWithLibrary('''
enum E {
  e0;

  static void foo(/** Line 1 */ int x, [
    /** Line 2
     */
    int y = 0]) {}

  static void bar({
    /** Line 3 */
    int x = 0,
    /** Line 4
     */
    required int y}) {}
}
''');
    var e = library.enums.named('E');
    var foo = e.staticMethods.named('foo');
    expect(foo.documentation, isEmpty);
    var bar = e.staticMethods.named('bar');
    expect(bar.documentation, isEmpty);
  }

  /// Check that block-based doc comments placed inside a parameter list of a
  /// static method of an enum are ignored.
  @FailingTest(reason: 'https://github.com/dart-lang/dartdoc/issues/1259')
  void test_blockEnumStaticMethodParameters2() async {
    var library = await bootPackageWithLibrary('''
enum E {
  e0;

  static void foo(/** Line 1 */ int x, [
    /** Line 2
     */
    int y = 0]) {}

  static void bar({
    /** Line 3 */
    int x = 0,
    /** Line 4
     */
    required int y}) {}
}
''');
    var e = library.enums.named('E');
    var foo = e.staticMethods.named('foo');
    expect(foo.parameters.named('x').documentation, isEmpty);
    expect(foo.parameters.named('y').documentation, isEmpty);
    var bar = e.staticMethods.named('bar');
    expect(bar.parameters.named('x').documentation, isEmpty);
    expect(bar.parameters.named('y').documentation, isEmpty);
  }

  /// Check that doc comments placed inside a parameter list of an instance
  /// method of an enum are not associated with the method.
  void test_enumInstanceMethodParameters1() async {
    var library = await bootPackageWithLibrary('''
enum E {
  e0;

  void foo(/// Line 1
    int x, [
    /// Line 2
    int y = 0]) {}

  void bar({
    /// Line 3
    int x = 0,
    /// Line 4
    required int y}) {}
}
''');
    var e = library.enums.named('E');
    var foo = e.instanceMethods.named('foo');
    expect(foo.documentation, isEmpty);
    var bar = e.instanceMethods.named('bar');
    expect(bar.documentation, isEmpty);
  }

  /// Check that doc comments placed inside a parameter list of an instance
  /// method of an enum are ignored.
  @FailingTest(reason: 'https://github.com/dart-lang/dartdoc/issues/1259')
  void test_enumInstanceMethodParameters2() async {
    var library = await bootPackageWithLibrary('''
enum E {
  e0;

  void foo(/// Line 1
    int x, [
    /// Line 2
    int y = 0]) {}

  void bar({
    /// Line 3
    int x = 0,
    /// Line 4
    required int y}) {}
}
''');
    var e = library.enums.named('E');
    var foo = e.instanceMethods.named('foo');
    expect(foo.parameters.named('x').documentation, isEmpty);
    expect(foo.parameters.named('y').documentation, isEmpty);
    var bar = e.instanceMethods.named('bar');
    expect(bar.parameters.named('x').documentation, isEmpty);
    expect(bar.parameters.named('y').documentation, isEmpty);
  }

  /// Check that block-based doc comments placed inside a parameter list of an
  /// instance method of an enum are not associated with the method.
  void test_blockEnumInstanceMethodParameters1() async {
    var library = await bootPackageWithLibrary('''
enum E {
  e0;

  void foo(/** Line 1 */ int x, [
    /** Line 2
     */
    int y = 0]) {}

  void bar({
    /** Line 3 */
    int x = 0,
    /** Line 4
     */
    required int y}) {}
}
''');
    var e = library.enums.named('E');
    var foo = e.instanceMethods.named('foo');
    expect(foo.documentation, isEmpty);
    var bar = e.instanceMethods.named('bar');
    expect(bar.documentation, isEmpty);
  }

  /// Check that block-based doc comments placed inside a parameter list of an
  /// instance method of an enum are ignored.
  @FailingTest(reason: 'https://github.com/dart-lang/dartdoc/issues/1259')
  void test_blockEnumInstanceMethodParameters2() async {
    var library = await bootPackageWithLibrary('''
enum E {
  e0;

  void foo(/** Line 1 */ int x, [
    /** Line 2
     */
    int y = 0]) {}

  void bar({
    /** Line 3 */
    int x = 0,
    /** Line 4
     */
    required int y}) {}
}
''');
    var e = library.enums.named('E');
    var foo = e.instanceMethods.named('foo');
    expect(foo.parameters.named('x').documentation, isEmpty);
    expect(foo.parameters.named('y').documentation, isEmpty);
    var bar = e.instanceMethods.named('bar');
    expect(bar.parameters.named('x').documentation, isEmpty);
    expect(bar.parameters.named('y').documentation, isEmpty);
  }

  /// Check that doc comments placed inside a parameter list of a static method
  /// of an extension are not associated with the method.
  void test_extensionStaticMethodParameters1() async {
    var library = await bootPackageWithLibrary('''
class A {}

extension Ext on A {
  static void foo(/// Line 1
    int x, [
    /// Line 2
    int y = 0]) {}

  static void bar({
    /// Line 3
    int x = 0,
    /// Line 4
    required int y}) {}
}
''');
    var ext = library.extensions.named('Ext');
    var foo = ext.staticMethods.named('foo');
    expect(foo.documentation, isEmpty);
    var bar = ext.staticMethods.named('bar');
    expect(bar.documentation, isEmpty);
  }

  /// Check that doc comments placed inside a parameter list of a static method
  /// of an extension are ignored.
  @FailingTest(reason: 'https://github.com/dart-lang/dartdoc/issues/1259')
  void test_extensionStaticMethodParameters2() async {
    var library = await bootPackageWithLibrary('''
class A {}

extension Ext on A {
  static void foo(/// Line 1
    int x, [
    /// Line 2
    int y = 0]) {}

  static void bar({
    /// Line 3
    int x = 0,
    /// Line 4
    required int y}) {}
}
''');
    var ext = library.extensions.named('Ext');
    var foo = ext.staticMethods.named('foo');
    expect(foo.parameters.named('x').documentation, isEmpty);
    expect(foo.parameters.named('y').documentation, isEmpty);
    var bar = ext.staticMethods.named('bar');
    expect(bar.parameters.named('x').documentation, isEmpty);
    expect(bar.parameters.named('y').documentation, isEmpty);
  }

  /// Check that block-based doc comments placed inside a parameter list of a
  /// static method of an extension are not associated with the method.
  void test_blockExtensionStaticMethodParameters1() async {
    var library = await bootPackageWithLibrary('''
class A {}

extension Ext on A {
  static void foo(/** Line 1 */ int x, [
    /** Line 2
     */
    int y = 0]) {}

  static void bar({
    /** Line 3 */
    int x = 0,
    /** Line 4
     */
    required int y}) {}
}
''');
    var ext = library.extensions.named('Ext');
    var foo = ext.staticMethods.named('foo');
    expect(foo.documentation, isEmpty);
    var bar = ext.staticMethods.named('bar');
    expect(bar.documentation, isEmpty);
  }

  /// Check that block-based doc comments placed inside a parameter list of a
  /// static method of an extension are ignored.
  @FailingTest(reason: 'https://github.com/dart-lang/dartdoc/issues/1259')
  void test_blockExtensionStaticMethodParameters2() async {
    var library = await bootPackageWithLibrary('''
class A {}

extension Ext on A {
  static void foo(/** Line 1 */ int x, [
    /** Line 2
     */
    int y = 0]) {}

  static void bar({
    /** Line 3 */
    int x = 0,
    /** Line 4
     */
    required int y}) {}
}
''');
    var ext = library.extensions.named('Ext');
    var foo = ext.staticMethods.named('foo');
    expect(foo.parameters.named('x').documentation, isEmpty);
    expect(foo.parameters.named('y').documentation, isEmpty);
    var bar = ext.staticMethods.named('bar');
    expect(bar.parameters.named('x').documentation, isEmpty);
    expect(bar.parameters.named('y').documentation, isEmpty);
  }

  /// Check that doc comments placed inside a parameter list of an instance
  /// method of an extension are not associated with the method.
  void test_extensionInstanceMethodParameters1() async {
    var library = await bootPackageWithLibrary('''
class A {}

extension Ext on A {
  void foo(/// Line 1
    int x, [
    /// Line 2
    int y = 0]) {}

  void bar({
    /// Line 3
    int x = 0,
    /// Line 4
    required int y}) {}
}
''');
    var ext = library.extensions.named('Ext');
    var foo = ext.instanceMethods.named('foo');
    expect(foo.documentation, isEmpty);
    var bar = ext.instanceMethods.named('bar');
    expect(bar.documentation, isEmpty);
  }

  /// Check that doc comments placed inside a parameter list of an instance
  /// method of an extension are ignored.
  @FailingTest(reason: 'https://github.com/dart-lang/dartdoc/issues/1259')
  void test_extensionInstanceMethodParameters2() async {
    var library = await bootPackageWithLibrary('''
class A {}

extension Ext on A {
  void foo(/// Line 1
    int x, [
    /// Line 2
    int y = 0]) {}

  void bar({
    /// Line 3
    int x = 0,
    /// Line 4
    required int y}) {}
}
''');
    var ext = library.extensions.named('Ext');
    var foo = ext.instanceMethods.named('foo');
    expect(foo.parameters.named('x').documentation, isEmpty);
    expect(foo.parameters.named('y').documentation, isEmpty);
    var bar = ext.instanceMethods.named('bar');
    expect(bar.parameters.named('x').documentation, isEmpty);
    expect(bar.parameters.named('y').documentation, isEmpty);
  }

  /// Check that block-based doc comments placed inside a parameter list of an
  /// instance method of an extension are not associated with the method.
  void test_blockExtensionInstanceMethodParameters1() async {
    var library = await bootPackageWithLibrary('''
class A {}

extension Ext on A {
  void foo(/** Line 1 */ int x, [
    /** Line 2
     */
    int y = 0]) {}

  void bar({
    /** Line 3 */
    int x = 0,
    /** Line 4
     */
    required int y}) {}
}
''');
    var ext = library.extensions.named('Ext');
    var foo = ext.instanceMethods.named('foo');
    expect(foo.documentation, isEmpty);
    var bar = ext.instanceMethods.named('bar');
    expect(bar.documentation, isEmpty);
  }

  /// Check that block-based doc comments placed inside a parameter list of an
  /// instance method of an extension are ignored.
  @FailingTest(reason: 'https://github.com/dart-lang/dartdoc/issues/1259')
  void test_blockExtensionInstanceMethodParameters2() async {
    var library = await bootPackageWithLibrary('''
class A {}

extension Ext on A {
  void foo(/** Line 1 */ int x, [
    /** Line 2
     */
    int y = 0]) {}

  void bar({
    /** Line 3 */
    int x = 0,
    /** Line 4
     */
    required int y}) {}
}
''');
    var ext = library.extensions.named('Ext');
    var foo = ext.instanceMethods.named('foo');
    expect(foo.parameters.named('x').documentation, isEmpty);
    expect(foo.parameters.named('y').documentation, isEmpty);
    var bar = ext.instanceMethods.named('bar');
    expect(bar.parameters.named('x').documentation, isEmpty);
    expect(bar.parameters.named('y').documentation, isEmpty);
  }

  /// Check that doc comments placed inside a parameter list of a static method
  /// of an extension type are not associated with the method.
  void test_extensionTypeStaticMethodParameters1() async {
    var library = await bootPackageWithLibrary('''
extension type ET(int v) {
  static void foo(/// Line 1
    int x, [
    /// Line 2
    int y = 0]) {}

  static void bar({
    /// Line 3
    int x = 0,
    /// Line 4
    required int y}) {}
}
''');
    var et = library.extensionTypes.named('ET');
    var foo = et.staticMethods.named('foo');
    expect(foo.documentation, isEmpty);
    var bar = et.staticMethods.named('bar');
    expect(bar.documentation, isEmpty);
  }

  /// Check that doc comments placed inside a parameter list of a static method
  /// of an extension type are ignored.
  @FailingTest(reason: 'https://github.com/dart-lang/dartdoc/issues/1259')
  void test_extensionTypeStaticMethodParameters2() async {
    var library = await bootPackageWithLibrary('''
extension type ET(int v) {
  static void foo(/// Line 1
    int x, [
    /// Line 2
    int y = 0]) {}

  static void bar({
    /// Line 3
    int x = 0,
    /// Line 4
    required int y}) {}
}
''');
    var et = library.extensionTypes.named('ET');
    var foo = et.staticMethods.named('foo');
    expect(foo.parameters.named('x').documentation, isEmpty);
    expect(foo.parameters.named('y').documentation, isEmpty);
    var bar = et.staticMethods.named('bar');
    expect(bar.parameters.named('x').documentation, isEmpty);
    expect(bar.parameters.named('y').documentation, isEmpty);
  }

  /// Check that block-based doc comments placed inside a parameter list of a
  /// static method of an extension type are not associated with the method.
  void test_blockExtensionTypeStaticMethodParameters1() async {
    var library = await bootPackageWithLibrary('''
extension type ET(int v) {
  static void foo(/** Line 1 */ int x, [
    /** Line 2
     */
    int y = 0]) {}

  static void bar({
    /** Line 3 */
    int x = 0,
    /** Line 4
     */
    required int y}) {}
}
''');
    var et = library.extensionTypes.named('ET');
    var foo = et.staticMethods.named('foo');
    expect(foo.documentation, isEmpty);
    var bar = et.staticMethods.named('bar');
    expect(bar.documentation, isEmpty);
  }

  /// Check that block-based doc comments placed inside a parameter list of a
  /// static method of an extension type are ignored.
  @FailingTest(reason: 'https://github.com/dart-lang/dartdoc/issues/1259')
  void test_blockExtensionTypeStaticMethodParameters2() async {
    var library = await bootPackageWithLibrary('''
extension type ET(int v) {
  static void foo(/** Line 1 */ int x, [
    /** Line 2
     */
    int y = 0]) {}

  static void bar({
    /** Line 3 */
    int x = 0,
    /** Line 4
     */
    required int y}) {}
}
''');
    var et = library.extensionTypes.named('ET');
    var foo = et.staticMethods.named('foo');
    expect(foo.parameters.named('x').documentation, isEmpty);
    expect(foo.parameters.named('y').documentation, isEmpty);
    var bar = et.staticMethods.named('bar');
    expect(bar.parameters.named('x').documentation, isEmpty);
    expect(bar.parameters.named('y').documentation, isEmpty);
  }

  /// Check that doc comments placed inside a parameter list of an instance
  /// method of an extension type are not associated with the method.
  void test_extensionTypeInstanceMethodParameters1() async {
    var library = await bootPackageWithLibrary('''
extension type ET(int v) {
  void foo(/// Line 1
    int x, [
    /// Line 2
    int y = 0]) {}

  void bar({
    /// Line 3
    int x = 0,
    /// Line 4
    required int y}) {}
}
''');
    var et = library.extensionTypes.named('ET');
    var foo = et.instanceMethods.named('foo');
    expect(foo.documentation, isEmpty);
    var bar = et.instanceMethods.named('bar');
    expect(bar.documentation, isEmpty);
  }

  /// Check that doc comments placed inside a parameter list of an instance
  /// method of an extension type are ignored.
  @FailingTest(reason: 'https://github.com/dart-lang/dartdoc/issues/1259')
  void test_extensionTypeInstanceMethodParameters2() async {
    var library = await bootPackageWithLibrary('''
extension type ET(int v) {
  void foo(/// Line 1
    int x, [
    /// Line 2
    int y = 0]) {}

  void bar({
    /// Line 3
    int x = 0,
    /// Line 4
    required int y}) {}
}
''');
    var et = library.extensionTypes.named('ET');
    var foo = et.instanceMethods.named('foo');
    expect(foo.parameters.named('x').documentation, isEmpty);
    expect(foo.parameters.named('y').documentation, isEmpty);
    var bar = et.instanceMethods.named('bar');
    expect(bar.parameters.named('x').documentation, isEmpty);
    expect(bar.parameters.named('y').documentation, isEmpty);
  }

  /// Check that block-based doc comments placed inside a parameter list of an
  /// instance method of an extension type are not associated with the method.
  void test_blockExtensionTypeInstanceMethodParameters1() async {
    var library = await bootPackageWithLibrary('''
extension type ET(int v) {
  void foo(/** Line 1 */ int x, [
    /** Line 2
     */
    int y = 0]) {}

  void bar({
    /** Line 3 */
    int x = 0,
    /** Line 4
     */
    required int y}) {}
}
''');
    var et = library.extensionTypes.named('ET');
    var foo = et.instanceMethods.named('foo');
    expect(foo.documentation, isEmpty);
    var bar = et.instanceMethods.named('bar');
    expect(bar.documentation, isEmpty);
  }

  /// Check that block-based doc comments placed inside a parameter list of an
  /// instance method of an extension type are ignored.
  @FailingTest(reason: 'https://github.com/dart-lang/dartdoc/issues/1259')
  void test_blockExtensionTypeInstanceMethodParameters2() async {
    var library = await bootPackageWithLibrary('''
extension type ET(int v) {
  void foo(/** Line 1 */ int x, [
    /** Line 2
     */
    int y = 0]) {}

  void bar({
    /** Line 3 */
    int x = 0,
    /** Line 4
     */
    required int y}) {}
}
''');
    var et = library.extensionTypes.named('ET');
    var foo = et.instanceMethods.named('foo');
    expect(foo.parameters.named('x').documentation, isEmpty);
    expect(foo.parameters.named('y').documentation, isEmpty);
    var bar = et.instanceMethods.named('bar');
    expect(bar.parameters.named('x').documentation, isEmpty);
    expect(bar.parameters.named('y').documentation, isEmpty);
  }
}
