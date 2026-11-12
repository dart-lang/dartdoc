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
    defineReflectiveTests(PlacementParametersOperatorsTest);
  });
}

@reflectiveTest
class PlacementParametersOperatorsTest extends Co19TestBase {
  /// Check that doc comments placed inside a parameter list of an operator are
  /// not associated with the operator.
  void test_operatorParameters1() async {
    var library = await bootPackageWithLibrary('''
class C {
  int operator +(/// Line 1
    Object? other) => 0;

  void operator []=(
    /// Line 2
    int index,
    /// Line 3
    int value) {}
}
''');
    var c = library.classes.named('C');
    var op1 = c.instanceOperators.named('operator +');
    expect(op1.documentation, isEmpty);
    var op2 = c.instanceOperators.named('operator []=');
    expect(op2.documentation, isEmpty);
  }

  /// Check that doc comments placed inside a parameter list of an operator are
  /// ignored.
  @FailingTest(reason: 'https://github.com/dart-lang/dartdoc/issues/1259')
  void test_operatorParameters2() async {
    var library = await bootPackageWithLibrary('''
class C {
  int operator +(/// Line 1
    Object? other) => 0;

  void operator []=(
    /// Line 2
    int index,
    /// Line 3
    int value) {}
}
''');
    var c = library.classes.named('C');
    var op1 = c.instanceOperators.named('operator +');
    expect(op1.parameters.named('other').documentation, isEmpty);
    var op2 = c.instanceOperators.named('operator []=');
    expect(op2.parameters.named('index').documentation, isEmpty);
    expect(op2.parameters.named('value').documentation, isEmpty);
  }

  /// Check that block-based doc comments placed inside a parameter list of an
  /// operator are not associated with the operator.
  void test_blockOperatorParameters1() async {
    var library = await bootPackageWithLibrary('''
class C {
  int operator +(/** Line 1 */ Object? other) => 0;

  void operator []=(
    /** Line 2 */
    int index,
    /** Line 3
     */
    int value) {}
}
''');
    var c = library.classes.named('C');
    var op1 = c.instanceOperators.named('operator +');
    expect(op1.documentation, isEmpty);
    var op2 = c.instanceOperators.named('operator []=');
    expect(op2.documentation, isEmpty);
  }

  /// Check that block-based doc comments placed inside a parameter list of an
  /// operator are ignored.
  @FailingTest(reason: 'https://github.com/dart-lang/dartdoc/issues/1259')
  void test_blockOperatorParameters2() async {
    var library = await bootPackageWithLibrary('''
class C {
  int operator +(/** Line 1 */ Object? other) => 0;

  void operator []=(
    /** Line 2 */
    int index,
    /** Line 3
     */
    int value) {}
}
''');
    var c = library.classes.named('C');
    var op1 = c.instanceOperators.named('operator +');
    expect(op1.parameters.named('other').documentation, isEmpty);
    var op2 = c.instanceOperators.named('operator []=');
    expect(op2.parameters.named('index').documentation, isEmpty);
    expect(op2.parameters.named('value').documentation, isEmpty);
  }

  /// Check that doc comments placed inside a parameter list of an operator of a
  /// mixin are not associated with the operator.
  void test_mixinOperatorParameters1() async {
    var library = await bootPackageWithLibrary('''
mixin M {
  int operator +(/// Line 1
    Object? other) => 0;

  void operator []=(
    /// Line 2
    int index,
    /// Line 3
    int value) {}
}
''');
    var m = library.mixins.named('M');
    var op1 = m.instanceOperators.named('operator +');
    expect(op1.documentation, isEmpty);
    var op2 = m.instanceOperators.named('operator []=');
    expect(op2.documentation, isEmpty);
  }

  /// Check that doc comments placed inside a parameter list of an operator of a
  /// mixin are ignored.
  @FailingTest(reason: 'https://github.com/dart-lang/dartdoc/issues/1259')
  void test_mixinOperatorParameters2() async {
    var library = await bootPackageWithLibrary('''
mixin M {
  int operator +(/// Line 1
    Object? other) => 0;

  void operator []=(
    /// Line 2
    int index,
    /// Line 3
    int value) {}
}
''');
    var m = library.mixins.named('M');
    var op1 = m.instanceOperators.named('operator +');
    expect(op1.parameters.named('other').documentation, isEmpty);
    var op2 = m.instanceOperators.named('operator []=');
    expect(op2.parameters.named('index').documentation, isEmpty);
    expect(op2.parameters.named('value').documentation, isEmpty);
  }

  /// Check that block-based doc comments placed inside a parameter list of an
  /// operator of a mixin are not associated with the operator.
  void test_blockMixinOperatorParameters1() async {
    var library = await bootPackageWithLibrary('''
mixin M {
  int operator +(/** Line 1 */ Object? other) => 0;

  void operator []=(
    /** Line 2 */
    int index,
    /** Line 3
     */
    int value) {}
}
''');
    var m = library.mixins.named('M');
    var op1 = m.instanceOperators.named('operator +');
    expect(op1.documentation, isEmpty);
    var op2 = m.instanceOperators.named('operator []=');
    expect(op2.documentation, isEmpty);
  }

  /// Check that block-based doc comments placed inside a parameter list of an
  /// operator of a mixin are ignored.
  @FailingTest(reason: 'https://github.com/dart-lang/dartdoc/issues/1259')
  void test_blockMixinOperatorParameters2() async {
    var library = await bootPackageWithLibrary('''
mixin M {
  int operator +(/** Line 1 */ Object? other) => 0;

  void operator []=(
    /** Line 2 */
    int index,
    /** Line 3
     */
    int value) {}
}
''');
    var m = library.mixins.named('M');
    var op1 = m.instanceOperators.named('operator +');
    expect(op1.parameters.named('other').documentation, isEmpty);
    var op2 = m.instanceOperators.named('operator []=');
    expect(op2.parameters.named('index').documentation, isEmpty);
    expect(op2.parameters.named('value').documentation, isEmpty);
  }

  /// Check that doc comments placed inside a parameter list of an operator of a
  /// mixin class are not associated with the operator.
  void test_mixinClassOperatorParameters1() async {
    var library = await bootPackageWithLibrary('''
mixin class M {
  int operator +(/// Line 1
    Object? other) => 0;

  void operator []=(
    /// Line 2
    int index,
    /// Line 3
    int value) {}
}
''');
    var m = library.classes.named('M');
    var op1 = m.instanceOperators.named('operator +');
    expect(op1.documentation, isEmpty);
    var op2 = m.instanceOperators.named('operator []=');
    expect(op2.documentation, isEmpty);
  }

  /// Check that doc comments placed inside a parameter list of an operator of a
  /// mixin class are ignored.
  @FailingTest(reason: 'https://github.com/dart-lang/dartdoc/issues/1259')
  void test_mixinClassOperatorParameters2() async {
    var library = await bootPackageWithLibrary('''
mixin class M {
  int operator +(/// Line 1
    Object? other) => 0;

  void operator []=(
    /// Line 2
    int index,
    /// Line 3
    int value) {}
}
''');
    var m = library.classes.named('M');
    var op1 = m.instanceOperators.named('operator +');
    expect(op1.parameters.named('other').documentation, isEmpty);
    var op2 = m.instanceOperators.named('operator []=');
    expect(op2.parameters.named('index').documentation, isEmpty);
    expect(op2.parameters.named('value').documentation, isEmpty);
  }

  /// Check that block-based doc comments placed inside a parameter list of an
  /// operator of a mixin class are not associated with the operator.
  void test_blockMixinClassOperatorParameters1() async {
    var library = await bootPackageWithLibrary('''
mixin class M {
  int operator +(/** Line 1 */ Object? other) => 0;

  void operator []=(
    /** Line 2 */
    int index,
    /** Line 3
     */
    int value) {}
}
''');
    var m = library.classes.named('M');
    var op1 = m.instanceOperators.named('operator +');
    expect(op1.documentation, isEmpty);
    var op2 = m.instanceOperators.named('operator []=');
    expect(op2.documentation, isEmpty);
  }

  /// Check that block-based doc comments placed inside a parameter list of an
  /// operator of a mixin class are ignored.
  @FailingTest(reason: 'https://github.com/dart-lang/dartdoc/issues/1259')
  void test_blockMixinClassOperatorParameters2() async {
    var library = await bootPackageWithLibrary('''
mixin class M {
  int operator +(/** Line 1 */ Object? other) => 0;

  void operator []=(
    /** Line 2 */
    int index,
    /** Line 3
     */
    int value) {}
}
''');
    var m = library.classes.named('M');
    var op1 = m.instanceOperators.named('operator +');
    expect(op1.parameters.named('other').documentation, isEmpty);
    var op2 = m.instanceOperators.named('operator []=');
    expect(op2.parameters.named('index').documentation, isEmpty);
    expect(op2.parameters.named('value').documentation, isEmpty);
  }

  /// Check that doc comments placed inside a parameter list of an operator of
  /// an enum are not associated with the operator.
  void test_enumOperatorParameters1() async {
    var library = await bootPackageWithLibrary('''
enum E {
  e0;

  int operator +(/// Line 1
    Object? other) => 0;

  void operator []=(
    /// Line 2
    int index,
    /// Line 3
    int value) {}
}
''');
    var e = library.enums.named('E');
    var op1 = e.instanceOperators.named('operator +');
    expect(op1.documentation, isEmpty);
    var op2 = e.instanceOperators.named('operator []=');
    expect(op2.documentation, isEmpty);
  }

  /// Check that doc comments placed inside a parameter list of an operator of
  /// an enum are ignored.
  @FailingTest(reason: 'https://github.com/dart-lang/dartdoc/issues/1259')
  void test_enumOperatorParameters2() async {
    var library = await bootPackageWithLibrary('''
enum E {
  e0;

  int operator +(/// Line 1
    Object? other) => 0;

  void operator []=(
    /// Line 2
    int index,
    /// Line 3
    int value) {}
}
''');
    var e = library.enums.named('E');
    var op1 = e.instanceOperators.named('operator +');
    expect(op1.parameters.named('other').documentation, isEmpty);
    var op2 = e.instanceOperators.named('operator []=');
    expect(op2.parameters.named('index').documentation, isEmpty);
    expect(op2.parameters.named('value').documentation, isEmpty);
  }

  /// Check that block-based doc comments placed inside a parameter list of an
  /// operator of an enum are not associated with the operator.
  void test_blockEnumOperatorParameters1() async {
    var library = await bootPackageWithLibrary('''
enum E {
  e0;

  int operator +(/** Line 1 */ Object? other) => 0;

  void operator []=(
    /** Line 2 */
    int index,
    /** Line 3
     */
    int value) {}
}
''');
    var e = library.enums.named('E');
    var op1 = e.instanceOperators.named('operator +');
    expect(op1.documentation, isEmpty);
    var op2 = e.instanceOperators.named('operator []=');
    expect(op2.documentation, isEmpty);
  }

  /// Check that block-based doc comments placed inside a parameter list of an
  /// operator of an enum are ignored.
  @FailingTest(reason: 'https://github.com/dart-lang/dartdoc/issues/1259')
  void test_blockEnumOperatorParameters2() async {
    var library = await bootPackageWithLibrary('''
enum E {
  e0;

  int operator +(/** Line 1 */ Object? other) => 0;

  void operator []=(
    /** Line 2 */
    int index,
    /** Line 3
     */
    int value) {}
}
''');
    var e = library.enums.named('E');
    var op1 = e.instanceOperators.named('operator +');
    expect(op1.parameters.named('other').documentation, isEmpty);
    var op2 = e.instanceOperators.named('operator []=');
    expect(op2.parameters.named('index').documentation, isEmpty);
    expect(op2.parameters.named('value').documentation, isEmpty);
  }

  /// Check that doc comments placed inside a parameter list of an operator of
  /// an extension are not associated with the operator.
  void test_extensionOperatorParameters1() async {
    var library = await bootPackageWithLibrary('''
class A {}

extension Ext on A {
  int operator +(/// Line 1
    Object? other) => 0;

  void operator []=(
    /// Line 2
    int index,
    /// Line 3
    int value) {}
}
''');
    var ext = library.extensions.named('Ext');
    var op1 = ext.instanceOperators.named('operator +');
    expect(op1.documentation, isEmpty);
    var op2 = ext.instanceOperators.named('operator []=');
    expect(op2.documentation, isEmpty);
  }

  /// Check that doc comments placed inside a parameter list of an operator of
  /// an extension are ignored.
  @FailingTest(reason: 'https://github.com/dart-lang/dartdoc/issues/1259')
  void test_extensionOperatorParameters2() async {
    var library = await bootPackageWithLibrary('''
class A {}

extension Ext on A {
  int operator +(/// Line 1
    Object? other) => 0;

  void operator []=(
    /// Line 2
    int index,
    /// Line 3
    int value) {}
}
''');
    var ext = library.extensions.named('Ext');
    var op1 = ext.instanceOperators.named('operator +');
    expect(op1.parameters.named('other').documentation, isEmpty);
    var op2 = ext.instanceOperators.named('operator []=');
    expect(op2.parameters.named('index').documentation, isEmpty);
    expect(op2.parameters.named('value').documentation, isEmpty);
  }

  /// Check that block-based doc comments placed inside a parameter list of an
  /// operator of an extension are not associated with the operator.
  void test_blockExtensionOperatorParameters1() async {
    var library = await bootPackageWithLibrary('''
class A {}

extension Ext on A {
  int operator +(/** Line 1 */ Object? other) => 0;

  void operator []=(
    /** Line 2 */
    int index,
    /** Line 3
     */
    int value) {}
}
''');
    var ext = library.extensions.named('Ext');
    var op1 = ext.instanceOperators.named('operator +');
    expect(op1.documentation, isEmpty);
    var op2 = ext.instanceOperators.named('operator []=');
    expect(op2.documentation, isEmpty);
  }

  /// Check that block-based doc comments placed inside a parameter list of an
  /// operator of an extension are ignored.
  @FailingTest(reason: 'https://github.com/dart-lang/dartdoc/issues/1259')
  void test_blockExtensionOperatorParameters2() async {
    var library = await bootPackageWithLibrary('''
class A {}

extension Ext on A {
  int operator +(/** Line 1 */ Object? other) => 0;

  void operator []=(
    /** Line 2 */
    int index,
    /** Line 3
     */
    int value) {}
}
''');
    var ext = library.extensions.named('Ext');
    var op1 = ext.instanceOperators.named('operator +');
    expect(op1.parameters.named('other').documentation, isEmpty);
    var op2 = ext.instanceOperators.named('operator []=');
    expect(op2.parameters.named('index').documentation, isEmpty);
    expect(op2.parameters.named('value').documentation, isEmpty);
  }

  /// Check that doc comments placed inside a parameter list of an operator of
  /// an extension type are not associated with the operator.
  void test_extensionTypeOperatorParameters1() async {
    var library = await bootPackageWithLibrary('''
extension type ET(int v) {
  int operator +(/// Line 1
    Object? other) => 0;

  void operator []=(
    /// Line 2
    int index,
    /// Line 3
    int value) {}
}
''');
    var et = library.extensionTypes.named('ET');
    var op1 = et.instanceOperators.named('operator +');
    expect(op1.documentation, isEmpty);
    var op2 = et.instanceOperators.named('operator []=');
    expect(op2.documentation, isEmpty);
  }

  /// Check that doc comments placed inside a parameter list of an operator of
  /// an extension type are ignored.
  @FailingTest(reason: 'https://github.com/dart-lang/dartdoc/issues/1259')
  void test_extensionTypeOperatorParameters2() async {
    var library = await bootPackageWithLibrary('''
extension type ET(int v) {
  int operator +(/// Line 1
    Object? other) => 0;

  void operator []=(
    /// Line 2
    int index,
    /// Line 3
    int value) {}
}
''');
    var et = library.extensionTypes.named('ET');
    var op1 = et.instanceOperators.named('operator +');
    expect(op1.parameters.named('other').documentation, isEmpty);
    var op2 = et.instanceOperators.named('operator []=');
    expect(op2.parameters.named('index').documentation, isEmpty);
    expect(op2.parameters.named('value').documentation, isEmpty);
  }

  /// Check that block-based doc comments placed inside a parameter list of an
  /// operator of an extension type are not associated with the operator.
  void test_blockExtensionTypeOperatorParameters1() async {
    var library = await bootPackageWithLibrary('''
extension type ET(int v) {
  int operator +(/** Line 1 */ Object? other) => 0;

  void operator []=(
    /** Line 2 */
    int index,
    /** Line 3
     */
    int value) {}
}
''');
    var et = library.extensionTypes.named('ET');
    var op1 = et.instanceOperators.named('operator +');
    expect(op1.documentation, isEmpty);
    var op2 = et.instanceOperators.named('operator []=');
    expect(op2.documentation, isEmpty);
  }

  /// Check that block-based doc comments placed inside a parameter list of an
  /// operator of an extension type are ignored.
  @FailingTest(reason: 'https://github.com/dart-lang/dartdoc/issues/1259')
  void test_blockExtensionTypeOperatorParameters2() async {
    var library = await bootPackageWithLibrary('''
extension type ET(int v) {
  int operator +(/** Line 1 */ Object? other) => 0;

  void operator []=(
    /** Line 2 */
    int index,
    /** Line 3
     */
    int value) {}
}
''');
    var et = library.extensionTypes.named('ET');
    var op1 = et.instanceOperators.named('operator +');
    expect(op1.parameters.named('other').documentation, isEmpty);
    var op2 = et.instanceOperators.named('operator []=');
    expect(op2.parameters.named('index').documentation, isEmpty);
    expect(op2.parameters.named('value').documentation, isEmpty);
  }
}
