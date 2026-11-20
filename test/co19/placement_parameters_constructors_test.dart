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
    defineReflectiveTests(PlacementParametersConstructorsTest);
  });
}

@reflectiveTest
class PlacementParametersConstructorsTest extends Co19TestBase {
  /// Check that doc comments placed inside a parameter list of a constructor
  /// are not associated with the constructor.
  void test_constructorParameters1() async {
    var library = await bootPackageWithLibrary('''
class C {
  int z;

  C(/// Line 1
    int x, [
    /// Line 2
    this.z = 0]);

  C.named({
    /// Line 3
    int x = 0,
    /// Line 4
    required this.z});

  factory C.factory(/// Line 5
    int x) => C(x);
}
''');
    var c = library.classes.named('C');
    var c1 = c.constructors.named('C.new');
    expect(c1.documentation, isEmpty);
    var c2 = c.constructors.named('C.named');
    expect(c2.documentation, isEmpty);
    var c3 = c.constructors.named('C.factory');
    expect(c3.documentation, isEmpty);
  }

  /// Check that doc comments placed inside a parameter list of a constructor
  /// are ignored.
  @FailingTest(reason: 'https://github.com/dart-lang/dartdoc/issues/1259')
  void test_constructorParameters2() async {
    var library = await bootPackageWithLibrary('''
class C {
  int z;

  C(/// Line 1
    int x, [
    /// Line 2
    this.z = 0]);

  C.named({
    /// Line 3
    int x = 0,
    /// Line 4
    required this.z});

  factory C.factory(/// Line 5
    int x) => C(x);
}
''');
    var c = library.classes.named('C');
    var c1 = c.constructors.named('C.new');
    expect(c1.parameters.named('x').documentation, isEmpty);
    expect(c1.parameters.named('z').documentation, isEmpty);
    var c2 = c.constructors.named('C.named');
    expect(c2.parameters.named('x').documentation, isEmpty);
    expect(c2.parameters.named('z').documentation, isEmpty);
    var c3 = c.constructors.named('C.factory');
    expect(c3.parameters.named('x').documentation, isEmpty);
  }

  /// Check that block-based doc comments placed inside a parameter list of a
  /// constructor are not associated with the constructor.
  void test_blockConstructorParameters1() async {
    var library = await bootPackageWithLibrary('''
class C {
  int z;

  C(/** Line 1 */ int x, [
    /** Line 2
     */
    this.z = 0]);

  C.named({
    /** Line 3 */
    int x = 0,
    /** Line 4
     */
    required this.z});

  factory C.factory(/** Line 5 */ int x) => C(x);
}
''');
    var c = library.classes.named('C');
    var c1 = c.constructors.named('C.new');
    expect(c1.documentation, isEmpty);
    var c2 = c.constructors.named('C.named');
    expect(c2.documentation, isEmpty);
    var c3 = c.constructors.named('C.factory');
    expect(c3.documentation, isEmpty);
  }

  /// Check that block-based doc comments placed inside a parameter list of a
  /// constructor are ignored.
  @FailingTest(reason: 'https://github.com/dart-lang/dartdoc/issues/1259')
  void test_blockConstructorParameters2() async {
    var library = await bootPackageWithLibrary('''
class C {
  int z;

  C(/** Line 1 */ int x, [
    /** Line 2
     */
    this.z = 0]);

  C.named({
    /** Line 3 */
    int x = 0,
    /** Line 4
     */
    required this.z});

  factory C.factory(/** Line 5 */ int x) => C(x);
}
''');
    var c = library.classes.named('C');
    var c1 = c.constructors.named('C.new');
    expect(c1.parameters.named('x').documentation, isEmpty);
    expect(c1.parameters.named('z').documentation, isEmpty);
    var c2 = c.constructors.named('C.named');
    expect(c2.parameters.named('x').documentation, isEmpty);
    expect(c2.parameters.named('z').documentation, isEmpty);
    var c3 = c.constructors.named('C.factory');
    expect(c3.parameters.named('x').documentation, isEmpty);
  }

  /// Check that doc comments placed inside a parameter list of an enum
  /// constructor are not associated with the constructor.
  void test_enumConstructorParameters1() async {
    var library = await bootPackageWithLibrary('''
enum E {
  e0(0);
  final int z;

  const E(/// Line 1
    int x, [
    /// Line 2
    this.z = 0]);

  const E.named({
    /// Line 3
    int x = 0,
    /// Line 4
    required this.z});

  factory E.factory(/// Line 5
    int x) => E.e0;
}
''');
    var e = library.enums.named('E');
    var c1 = e.constructors.named('E.new');
    expect(c1.documentation, isEmpty);
    var c2 = e.constructors.named('E.named');
    expect(c2.documentation, isEmpty);
    var c3 = e.constructors.named('E.factory');
    expect(c3.documentation, isEmpty);
  }

  /// Check that doc comments placed inside a parameter list of an enum
  /// constructor are ignored.
  @FailingTest(reason: 'https://github.com/dart-lang/dartdoc/issues/1259')
  void test_enumConstructorParameters2() async {
    var library = await bootPackageWithLibrary('''
enum E {
  e0(0);
  final int z;

  const E(/// Line 1
    int x, [
    /// Line 2
    this.z = 0]);

  const E.named({
    /// Line 3
    int x = 0,
    /// Line 4
    required this.z});

  factory E.factory(/// Line 5
    int x) => E.e0;
}
''');
    var e = library.enums.named('E');
    var c1 = e.constructors.named('E.new');
    expect(c1.parameters.named('x').documentation, isEmpty);
    expect(c1.parameters.named('z').documentation, isEmpty);
    var c2 = e.constructors.named('E.named');
    expect(c2.parameters.named('x').documentation, isEmpty);
    expect(c2.parameters.named('z').documentation, isEmpty);
    var c3 = e.constructors.named('E.factory');
    expect(c3.parameters.named('x').documentation, isEmpty);
  }

  /// Check that block-based doc comments placed inside a parameter list of an
  /// enum constructor are not associated with the constructor.
  void test_blockEnumConstructorParameters1() async {
    var library = await bootPackageWithLibrary('''
enum E {
  e0(0);
  final int z;

  const E(/** Line 1 */ int x, [
    /** Line 2
     */
    this.z = 0]);

  const E.named({
    /** Line 3 */
    int x = 0,
    /** Line 4
     */
    required this.z});

  factory E.factory(/** Line 5 */ int x) => E.e0;
}
''');
    var e = library.enums.named('E');
    var c1 = e.constructors.named('E.new');
    expect(c1.documentation, isEmpty);
    var c2 = e.constructors.named('E.named');
    expect(c2.documentation, isEmpty);
    var c3 = e.constructors.named('E.factory');
    expect(c3.documentation, isEmpty);
  }

  /// Check that block-based doc comments placed inside a parameter list of an
  /// enum constructor are ignored.
  @FailingTest(reason: 'https://github.com/dart-lang/dartdoc/issues/1259')
  void test_blockEnumConstructorParameters2() async {
    var library = await bootPackageWithLibrary('''
enum E {
  e0(0);
  final int z;

  const E(/** Line 1 */ int x, [
    /** Line 2
     */
    this.z = 0]);

  const E.named({
    /** Line 3 */
    int x = 0,
    /** Line 4
     */
    required this.z});

  factory E.factory(/** Line 5 */ int x) => E.e0;
}
''');
    var e = library.enums.named('E');
    var c1 = e.constructors.named('E.new');
    expect(c1.parameters.named('x').documentation, isEmpty);
    expect(c1.parameters.named('z').documentation, isEmpty);
    var c2 = e.constructors.named('E.named');
    expect(c2.parameters.named('x').documentation, isEmpty);
    expect(c2.parameters.named('z').documentation, isEmpty);
    var c3 = e.constructors.named('E.factory');
    expect(c3.parameters.named('x').documentation, isEmpty);
  }

  /// Check that doc comments placed inside a parameter list of an extension
  /// type constructor are not associated with the constructor.
  void test_extensionTypeConstructorParameters1() async {
    var library = await bootPackageWithLibrary('''
extension type ET._(int z) {
  ET(/// Line 1
    int x, [
    /// Line 2
    this.z = 0]);

  ET.named({
    /// Line 3
    int x = 0,
    /// Line 4
    required this.z});

  factory ET.factory(/// Line 5
    int x) => ET(x);
}
''');
    var et = library.extensionTypes.named('ET');
    var c1 = et.constructors.named('ET.new');
    expect(c1.documentation, isEmpty);
    var c2 = et.constructors.named('ET.named');
    expect(c2.documentation, isEmpty);
    var c3 = et.constructors.named('ET.factory');
    expect(c3.documentation, isEmpty);
  }

  /// Check that doc comments placed inside a parameter list of an extension
  /// type constructor are ignored.
  @FailingTest(reason: 'https://github.com/dart-lang/dartdoc/issues/1259')
  void test_extensionTypeConstructorParameters2() async {
    var library = await bootPackageWithLibrary('''
extension type ET._(int z) {
  ET(/// Line 1
    int x, [
    /// Line 2
    this.z = 0]);

  ET.named({
    /// Line 3
    int x = 0,
    /// Line 4
    required this.z});

  factory ET.factory(/// Line 5
    int x) => ET(x);
}
''');
    var et = library.extensionTypes.named('ET');
    var c1 = et.constructors.named('ET.new');
    expect(c1.parameters.named('x').documentation, isEmpty);
    expect(c1.parameters.named('z').documentation, isEmpty);
    var c2 = et.constructors.named('ET.named');
    expect(c2.parameters.named('x').documentation, isEmpty);
    expect(c2.parameters.named('z').documentation, isEmpty);
    var c3 = et.constructors.named('ET.factory');
    expect(c3.parameters.named('x').documentation, isEmpty);
  }

  /// Check that block-based doc comments placed inside a parameter list of an
  /// extension type constructor are not associated with the constructor.
  void test_blockExtensionTypeConstructorParameters1() async {
    var library = await bootPackageWithLibrary('''
extension type ET._(int z) {
  ET(/** Line 1 */ int x, [
    /** Line 2
     */
    this.z = 0]);

  ET.named({
    /** Line 3 */
    int x = 0,
    /** Line 4
     */
    required this.z});

  factory ET.factory(/** Line 5 */ int x) => ET(x);
}
''');
    var et = library.extensionTypes.named('ET');
    var c1 = et.constructors.named('ET.new');
    expect(c1.documentation, isEmpty);
    var c2 = et.constructors.named('ET.named');
    expect(c2.documentation, isEmpty);
    var c3 = et.constructors.named('ET.factory');
    expect(c3.documentation, isEmpty);
  }

  /// Check that block-based doc comments placed inside a parameter list of an
  /// extension type constructor are ignored.
  @FailingTest(reason: 'https://github.com/dart-lang/dartdoc/issues/1259')
  void test_blockExtensionTypeConstructorParameters2() async {
    var library = await bootPackageWithLibrary('''
extension type ET._(int z) {
  ET(/** Line 1 */ int x, [
    /** Line 2
     */
    this.z = 0]);

  ET.named({
    /** Line 3 */
    int x = 0,
    /** Line 4
     */
    required this.z});

  factory ET.factory(/** Line 5 */ int x) => ET(x);
}
''');
    var et = library.extensionTypes.named('ET');
    var c1 = et.constructors.named('ET.new');
    expect(c1.parameters.named('x').documentation, isEmpty);
    expect(c1.parameters.named('z').documentation, isEmpty);
    var c2 = et.constructors.named('ET.named');
    expect(c2.parameters.named('x').documentation, isEmpty);
    expect(c2.parameters.named('z').documentation, isEmpty);
    var c3 = et.constructors.named('ET.factory');
    expect(c3.parameters.named('x').documentation, isEmpty);
  }

  /// Check that doc comments placed inside a parameter list of a primary
  /// constructor of a class are not associated with the class or with the
  /// constructor.
  void test_primaryConstructorParameters1() async {
    var library = await bootPackageWithLibrary('''
class C1(/// Line 1
  int x, [
  /// Line 2
  int z = 0]);

class C2.named({
  /// Line 3
  int x = 0,
  /// Line 4
  required int z});
''');
    var c1 = library.classes.named('C1');
    expect(c1.documentation, isEmpty);
    var c1c = c1.constructors.named('C1.new');
    expect(c1c.documentation, isEmpty);
    var c2 = library.classes.named('C2');
    expect(c2.documentation, isEmpty);
    var c2c = c2.constructors.named('C2.named');
    expect(c2c.documentation, isEmpty);
  }

  /// Check that doc comments placed inside a parameter list of a primary
  /// constructor of a class are ignored.
  @FailingTest(reason: 'https://github.com/dart-lang/dartdoc/issues/1259')
  void test_primaryConstructorParameters2() async {
    var library = await bootPackageWithLibrary('''
class C1(/// Line 1
  int x, [
  /// Line 2
  int z = 0]);

class C2.named({
  /// Line 3
  int x = 0,
  /// Line 4
  required int z});
''');
    var c1 = library.classes.named('C1');
    var c1c = c1.constructors.named('C1.new');
    expect(c1c.parameters.named('x').documentation, isEmpty);
    expect(c1c.parameters.named('z').documentation, isEmpty);
    var c2 = library.classes.named('C2');
    var c2c = c2.constructors.named('C2.named');
    expect(c2c.parameters.named('x').documentation, isEmpty);
    expect(c2c.parameters.named('z').documentation, isEmpty);
  }

  /// Check that block-based doc comments placed inside a parameter list of a
  /// primary constructor of a class are not associated with the class or with
  /// the constructor.
  void test_blockPrimaryConstructorParameters1() async {
    var library = await bootPackageWithLibrary('''
class C1(/** Line 1 */ int x, [
  /** Line 2
   */
  int z = 0]);

class C2.named({
  /** Line 3 */
  int x = 0,
  /** Line 4
   */
  required int z});
''');
    var c1 = library.classes.named('C1');
    expect(c1.documentation, isEmpty);
    var c1c = c1.constructors.named('C1.new');
    expect(c1c.documentation, isEmpty);
    var c2 = library.classes.named('C2');
    expect(c2.documentation, isEmpty);
    var c2c = c2.constructors.named('C2.named');
    expect(c2c.documentation, isEmpty);
  }

  /// Check that block-based doc comments placed inside a parameter list of a
  /// primary constructor of a class are ignored.
  @FailingTest(reason: 'https://github.com/dart-lang/dartdoc/issues/1259')
  void test_blockPrimaryConstructorParameters2() async {
    var library = await bootPackageWithLibrary('''
class C1(/** Line 1 */ int x, [
  /** Line 2
   */
  int z = 0]);

class C2.named({
  /** Line 3 */
  int x = 0,
  /** Line 4
   */
  required int z});
''');
    var c1 = library.classes.named('C1');
    var c1c = c1.constructors.named('C1.new');
    expect(c1c.parameters.named('x').documentation, isEmpty);
    expect(c1c.parameters.named('z').documentation, isEmpty);
    var c2 = library.classes.named('C2');
    var c2c = c2.constructors.named('C2.named');
    expect(c2c.parameters.named('x').documentation, isEmpty);
    expect(c2c.parameters.named('z').documentation, isEmpty);
  }

  /// Check that doc comments placed inside a parameter list of a primary
  /// constructor of an enum are not associated with the enum or with the
  /// constructor.
  void test_enumPrimaryConstructorParameters1() async {
    var library = await bootPackageWithLibrary('''
enum E1(/// Line 1
  int x, [
  /// Line 2
  int z = 0]) {
  e0(1);
}

enum E2.named({
  /// Line 3
  int x = 0,
  /// Line 4
  required int z}) {
  e0.named(z: 1);
}
''');
    var e1 = library.enums.named('E1');
    expect(e1.documentation, isEmpty);
    var e1c = e1.constructors.named('E1.new');
    expect(e1c.documentation, isEmpty);
    var e2 = library.enums.named('E2');
    expect(e2.documentation, isEmpty);
    var e2c = e2.constructors.named('E2.named');
    expect(e2c.documentation, isEmpty);
  }

  /// Check that doc comments placed inside a parameter list of a primary
  /// constructor of an enum are ignored.
  @FailingTest(reason: 'https://github.com/dart-lang/dartdoc/issues/1259')
  void test_enumPrimaryConstructorParameters2() async {
    var library = await bootPackageWithLibrary('''
enum E1(/// Line 1
  int x, [
  /// Line 2
  int z = 0]) {
  e0(1);
}

enum E2.named({
  /// Line 3
  int x = 0,
  /// Line 4
  required int z}) {
  e0.named(z: 1);
}
''');
    var e1 = library.enums.named('E1');
    var e1c = e1.constructors.named('E1.new');
    expect(e1c.parameters.named('x').documentation, isEmpty);
    expect(e1c.parameters.named('z').documentation, isEmpty);
    var e2 = library.enums.named('E2');
    var e2c = e2.constructors.named('E2.named');
    expect(e2c.parameters.named('x').documentation, isEmpty);
    expect(e2c.parameters.named('z').documentation, isEmpty);
  }

  /// Check that block-based doc comments placed inside a parameter list of a
  /// primary constructor of an enum are not associated with the enum or with
  /// the constructor.
  void test_blockEnumPrimaryConstructorParameters1() async {
    var library = await bootPackageWithLibrary('''
enum E1(/** Line 1 */ int x, [
  /** Line 2
   */
  int z = 0]) {
  e0(1);
}

enum E2.named({
  /** Line 3 */
  int x = 0,
  /** Line 4
   */
  required int z}) {
  e0.named(z: 1);
}
''');
    var e1 = library.enums.named('E1');
    expect(e1.documentation, isEmpty);
    var e1c = e1.constructors.named('E1.new');
    expect(e1c.documentation, isEmpty);
    var e2 = library.enums.named('E2');
    expect(e2.documentation, isEmpty);
    var e2c = e2.constructors.named('E2.named');
    expect(e2c.documentation, isEmpty);
  }

  /// Check that block-based doc comments placed inside a parameter list of a
  /// primary constructor of an enum are ignored.
  @FailingTest(reason: 'https://github.com/dart-lang/dartdoc/issues/1259')
  void test_blockEnumPrimaryConstructorParameters2() async {
    var library = await bootPackageWithLibrary('''
enum E1(/** Line 1 */ int x, [
  /** Line 2
   */
  int z = 0]) {
  e0(1);
}

enum E2.named({
  /** Line 3 */
  int x = 0,
  /** Line 4
   */
  required int z}) {
  e0.named(z: 1);
}
''');
    var e1 = library.enums.named('E1');
    var e1c = e1.constructors.named('E1.new');
    expect(e1c.parameters.named('x').documentation, isEmpty);
    expect(e1c.parameters.named('z').documentation, isEmpty);
    var e2 = library.enums.named('E2');
    var e2c = e2.constructors.named('E2.named');
    expect(e2c.parameters.named('x').documentation, isEmpty);
    expect(e2c.parameters.named('z').documentation, isEmpty);
  }

  /// Check that doc comments placed inside a parameter list of a primary
  /// constructor of an extension type are not associated with the extension
  /// type or with the constructor.
  void test_extensionTypePrimaryConstructorParameters1() async {
    var library = await bootPackageWithLibrary('''
extension type ET1(/// Line 1
  int x) {}

extension type ET2.named(/// Line 2
  int x) {}
''');
    var et1 = library.extensionTypes.named('ET1');
    expect(et1.documentation, isEmpty);
    var et1c = et1.constructors.named('ET1.new');
    expect(et1c.documentation, isEmpty);
    var et2 = library.extensionTypes.named('ET2');
    expect(et2.documentation, isEmpty);
    var et2c = et2.constructors.named('ET2.named');
    expect(et2c.documentation, isEmpty);
  }

  /// Check that doc comments placed inside a parameter list of a primary
  /// constructor of an extension type are ignored.
  @FailingTest(reason: 'https://github.com/dart-lang/dartdoc/issues/1259')
  void test_extensionTypePrimaryConstructorParameters2() async {
    var library = await bootPackageWithLibrary('''
extension type ET1(/// Line 1
  int x) {}

extension type ET2.named(/// Line 2
  int x) {}
''');
    var et1 = library.extensionTypes.named('ET1');
    var et1c = et1.constructors.named('ET1.new');
    expect(et1c.parameters.named('x').documentation, isEmpty);
    var et2 = library.extensionTypes.named('ET2');
    var et2c = et2.constructors.named('ET2.named');
    expect(et2c.parameters.named('x').documentation, isEmpty);
  }

  /// Check that block-based doc comments placed inside a parameter list of a
  /// primary constructor of an extension type are not associated with the
  /// extension type or with the constructor.
  void test_blockExtensionTypePrimaryConstructorParameters1() async {
    var library = await bootPackageWithLibrary('''
extension type ET1(/** Line 1 */ int x) {}

extension type ET2.named(/** Line 2
  */
  int x) {}
''');
    var et1 = library.extensionTypes.named('ET1');
    expect(et1.documentation, isEmpty);
    var et1c = et1.constructors.named('ET1.new');
    expect(et1c.documentation, isEmpty);
    var et2 = library.extensionTypes.named('ET2');
    expect(et2.documentation, isEmpty);
    var et2c = et2.constructors.named('ET2.named');
    expect(et2c.documentation, isEmpty);
  }

  /// Check that block-based doc comments placed inside a parameter list of a
  /// primary constructor of an extension type are ignored.
  @FailingTest(reason: 'https://github.com/dart-lang/dartdoc/issues/1259')
  void test_blockExtensionTypePrimaryConstructorParameters2() async {
    var library = await bootPackageWithLibrary('''
extension type ET1(/** Line 1 */ int x) {}

extension type ET2.named(/** Line 2
  */
  int x) {}
''');
    var et1 = library.extensionTypes.named('ET1');
    var et1c = et1.constructors.named('ET1.new');
    expect(et1c.parameters.named('x').documentation, isEmpty);
    var et2 = library.extensionTypes.named('ET2');
    var et2c = et2.constructors.named('ET2.named');
    expect(et2c.parameters.named('x').documentation, isEmpty);
  }

  /// Check that doc comments placed between `(` and `[` or `{` of a parameter
  /// list of a constructor are not associated with the constructor and its
  /// parameters.
  void test_constructorOptionalParameters() async {
    var library = await bootPackageWithLibrary('''
class C {
  int z;

  C(/// Line 1
    [this.z = 0]);

  C.named(/// Line 2
    {int x = 0, this.z = 0});

  factory C.factory1(/// Line 3
    [int x = 0]) => C(x);

  factory C.factory2(/// Line 4
    {required int x}) => C(x);
}
''');
    var c = library.classes.named('C');
    var c1 = c.constructors.named('C.new');
    expect(c1.documentation, isEmpty);
    expect(c1.parameters.named('z').documentation, isEmpty);
    var c2 = c.constructors.named('C.named');
    expect(c2.documentation, isEmpty);
    expect(c2.parameters.named('x').documentation, isEmpty);
    expect(c2.parameters.named('z').documentation, isEmpty);
    var c3 = c.constructors.named('C.factory1');
    expect(c3.documentation, isEmpty);
    expect(c3.parameters.named('x').documentation, isEmpty);
    var c4 = c.constructors.named('C.factory2');
    expect(c4.documentation, isEmpty);
    expect(c4.parameters.named('x').documentation, isEmpty);
  }

  /// Check that block-based doc comments placed between `(` and `[` or `{` of a
  /// parameter list of a constructor are not associated with the constructor
  /// and its parameters.
  void test_blockConstructorOptionalParameters() async {
    var library = await bootPackageWithLibrary('''
class C {
  int z;

  C(/** Line 1 */ [this.z = 0]);

  C.named(/** Line 2
   */
  {int x = 0, this.z = 0});

  factory C.factory1(/** Line 3 */ [int x = 0]) => C(x);

  factory C.factory2(/** Line 4
   */
  {required int x}) => C(x);
}
''');
    var c = library.classes.named('C');
    var c1 = c.constructors.named('C.new');
    expect(c1.documentation, isEmpty);
    expect(c1.parameters.named('z').documentation, isEmpty);
    var c2 = c.constructors.named('C.named');
    expect(c2.documentation, isEmpty);
    expect(c2.parameters.named('x').documentation, isEmpty);
    expect(c2.parameters.named('z').documentation, isEmpty);
    var c3 = c.constructors.named('C.factory1');
    expect(c3.documentation, isEmpty);
    expect(c3.parameters.named('x').documentation, isEmpty);
    var c4 = c.constructors.named('C.factory2');
    expect(c4.documentation, isEmpty);
    expect(c4.parameters.named('x').documentation, isEmpty);
  }

  /// Check that doc comments placed between `(` and `[` or `{` of a parameter
  /// list of an enum constructor are not associated with the constructor and
  /// its parameters.
  void test_enumConstructorOptionalParameters() async {
    var library = await bootPackageWithLibrary('''
enum E {
  e0;
  final int z;

  const E(/// Line 1
    [this.z = 0]);

  const E.named(/// Line 2
    {int x = 0, this.z = 0});

  factory E.factory1(/// Line 3
    [int x = 0]) => E.e0;

  factory E.factory2(/// Line 4
    {required int x}) => E.e0;
}
''');
    var e = library.enums.named('E');
    var c1 = e.constructors.named('E.new');
    expect(c1.documentation, isEmpty);
    expect(c1.parameters.named('z').documentation, isEmpty);
    var c2 = e.constructors.named('E.named');
    expect(c2.documentation, isEmpty);
    expect(c2.parameters.named('x').documentation, isEmpty);
    expect(c2.parameters.named('z').documentation, isEmpty);
    var c3 = e.constructors.named('E.factory1');
    expect(c3.documentation, isEmpty);
    expect(c3.parameters.named('x').documentation, isEmpty);
    var c4 = e.constructors.named('E.factory2');
    expect(c4.documentation, isEmpty);
    expect(c4.parameters.named('x').documentation, isEmpty);
  }

  /// Check that block-based doc comments placed between `(` and `[` or `{` of a
  /// parameter list of an enum constructor are not associated with the
  /// constructor and its parameters.
  void test_blockEnumConstructorOptionalParameters() async {
    var library = await bootPackageWithLibrary('''
enum E {
  e0;
  final int z;

  const E(/** Line 1 */ [this.z = 0]);

  const E.named(/** Line 2
   */
  {int x = 0, this.z = 0});

  factory E.factory1(/** Line 3 */ [int x = 0]) => E.e0;

  factory E.factory2(/** Line 4
   */
  {required int x}) => E.e0;
}
''');
    var e = library.enums.named('E');
    var c1 = e.constructors.named('E.new');
    expect(c1.documentation, isEmpty);
    expect(c1.parameters.named('z').documentation, isEmpty);
    var c2 = e.constructors.named('E.named');
    expect(c2.documentation, isEmpty);
    expect(c2.parameters.named('x').documentation, isEmpty);
    expect(c2.parameters.named('z').documentation, isEmpty);
    var c3 = e.constructors.named('E.factory1');
    expect(c3.documentation, isEmpty);
    expect(c3.parameters.named('x').documentation, isEmpty);
    var c4 = e.constructors.named('E.factory2');
    expect(c4.documentation, isEmpty);
    expect(c4.parameters.named('x').documentation, isEmpty);
  }

  /// Check that doc comments placed between `(` and `[` or `{` of a parameter
  /// list of an extension type constructor are not associated with the
  /// constructor and its parameters.
  void test_extensionTypeConstructorOptionalParameters() async {
    var library = await bootPackageWithLibrary('''
extension type ET._(int z) {
  ET(/// Line 1
    [this.z = 0]);

  ET.named(/// Line 2
    {int x = 0, this.z = 0});

  factory ET.factory1(/// Line 3
    [int x = 0]) => ET(x);

  factory ET.factory2(/// Line 4
    {required int x}) => ET(x);
}
''');
    var et = library.extensionTypes.named('ET');
    var c1 = et.constructors.named('ET.new');
    expect(c1.documentation, isEmpty);
    expect(c1.parameters.named('z').documentation, isEmpty);
    var c2 = et.constructors.named('ET.named');
    expect(c2.documentation, isEmpty);
    expect(c2.parameters.named('x').documentation, isEmpty);
    expect(c2.parameters.named('z').documentation, isEmpty);
    var c3 = et.constructors.named('ET.factory1');
    expect(c3.documentation, isEmpty);
    expect(c3.parameters.named('x').documentation, isEmpty);
    var c4 = et.constructors.named('ET.factory2');
    expect(c4.documentation, isEmpty);
    expect(c4.parameters.named('x').documentation, isEmpty);
  }

  /// Check that block-based doc comments placed between `(` and `[` or `{` of a
  /// parameter list of an extension type constructor are not associated with
  /// the constructor and its parameters.
  void test_blockExtensionTypeConstructorOptionalParameters() async {
    var library = await bootPackageWithLibrary('''
extension type ET._(int z) {
  ET(/** Line 1 */ [this.z = 0]);

  ET.named(/** Line 2
   */
  {int x = 0, this.z = 0});

  factory ET.factory1(/** Line 3 */ [int x = 0]) => ET(x);

  factory ET.factory2(/** Line 4
   */
  {required int x}) => ET(x);
}
''');
    var et = library.extensionTypes.named('ET');
    var c1 = et.constructors.named('ET.new');
    expect(c1.documentation, isEmpty);
    expect(c1.parameters.named('z').documentation, isEmpty);
    var c2 = et.constructors.named('ET.named');
    expect(c2.documentation, isEmpty);
    expect(c2.parameters.named('x').documentation, isEmpty);
    expect(c2.parameters.named('z').documentation, isEmpty);
    var c3 = et.constructors.named('ET.factory1');
    expect(c3.documentation, isEmpty);
    expect(c3.parameters.named('x').documentation, isEmpty);
    var c4 = et.constructors.named('ET.factory2');
    expect(c4.documentation, isEmpty);
    expect(c4.parameters.named('x').documentation, isEmpty);
  }

  /// Check that doc comments placed between `(` and `[` or `{` of a parameter
  /// list of a primary constructor of a class are not associated with the
  /// class, the constructor and its parameters.
  void test_primaryConstructorOptionalParameters() async {
    var library = await bootPackageWithLibrary('''
class C1(/// Line 1
  [int x = 0]);

class C2.named(/// Line 2
  {int x = 0, int z = 0});
''');
    var c1 = library.classes.named('C1');
    expect(c1.documentation, isEmpty);
    var c1c = c1.constructors.named('C1.new');
    expect(c1c.documentation, isEmpty);
    expect(c1c.parameters.named('x').documentation, isEmpty);
    var c2 = library.classes.named('C2');
    expect(c2.documentation, isEmpty);
    var c2c = c2.constructors.named('C2.named');
    expect(c2c.documentation, isEmpty);
    expect(c2c.parameters.named('x').documentation, isEmpty);
    expect(c2c.parameters.named('z').documentation, isEmpty);
  }

  /// Check that block-based doc comments placed between `(` and `[` or `{` of a
  /// parameter list of a primary constructor of a class are not associated with
  /// the class, the constructor and its parameters.
  void test_blockPrimaryConstructorOptionalParameters() async {
    var library = await bootPackageWithLibrary('''
class C1(/** Line 1 */ [int x = 0]);

class C2.named(/** Line 2
  */
  {int x = 0, int z = 0});
''');
    var c1 = library.classes.named('C1');
    expect(c1.documentation, isEmpty);
    var c1c = c1.constructors.named('C1.new');
    expect(c1c.documentation, isEmpty);
    expect(c1c.parameters.named('x').documentation, isEmpty);
    var c2 = library.classes.named('C2');
    expect(c2.documentation, isEmpty);
    var c2c = c2.constructors.named('C2.named');
    expect(c2c.documentation, isEmpty);
    expect(c2c.parameters.named('x').documentation, isEmpty);
    expect(c2c.parameters.named('z').documentation, isEmpty);
  }

  /// Check that doc comments placed between `(` and `[` or `{` of a parameter
  /// list of a primary constructor of an enum are not associated with the enum,
  /// the constructor and its parameters.
  void test_enumPrimaryConstructorOptionalParameters() async {
    var library = await bootPackageWithLibrary('''
enum E1(/// Line 1
  [int x = 0]) {
  e0;
}

enum E2.named(/// Line 2
  {int x = 0}) {
  e0.named();
}
''');
    var e1 = library.enums.named('E1');
    expect(e1.documentation, isEmpty);
    var e1c = e1.constructors.named('E1.new');
    expect(e1c.documentation, isEmpty);
    expect(e1c.parameters.named('x').documentation, isEmpty);
    var e2 = library.enums.named('E2');
    expect(e2.documentation, isEmpty);
    var e2c = e2.constructors.named('E2.named');
    expect(e2c.documentation, isEmpty);
    expect(e2c.parameters.named('x').documentation, isEmpty);
  }

  /// Check that block-based doc comments placed between `(` and `[` or `{` of a
  /// parameter list of a primary constructor of an enum are not associated with
  /// the enum, the constructor and its parameters.
  void test_blockEnumPrimaryConstructorOptionalParameters() async {
    var library = await bootPackageWithLibrary('''
enum E1(/** Line 1 */ [int x = 0]) {
  e0;
}

enum E2.named(/** Line 2
  */
  {int x = 0}) {
  e0.named();
}
''');
    var e1 = library.enums.named('E1');
    expect(e1.documentation, isEmpty);
    var e1c = e1.constructors.named('E1.new');
    expect(e1c.documentation, isEmpty);
    expect(e1c.parameters.named('x').documentation, isEmpty);
    var e2 = library.enums.named('E2');
    expect(e2.documentation, isEmpty);
    var e2c = e2.constructors.named('E2.named');
    expect(e2c.documentation, isEmpty);
    expect(e2c.parameters.named('x').documentation, isEmpty);
  }

  /// Check that doc comments placed between `(` and `[` or `{` of a parameter
  /// list of a primary constructor of an extension type are not associated with
  /// the extension type, the constructor and its parameters.
  void test_extensionTypePrimaryConstructorOptionalParameters() async {
    var library = await bootPackageWithLibrary('''
extension type ET1(/// Line 1
  [int x = 0]) {}

extension type ET2.named(/// Line 2
  {required int x}) {}
''');
    var et1 = library.extensionTypes.named('ET1');
    expect(et1.documentation, isEmpty);
    var et1c = et1.constructors.named('ET1.new');
    expect(et1c.documentation, isEmpty);
    expect(et1c.parameters.named('x').documentation, isEmpty);
    var et2 = library.extensionTypes.named('ET2');
    expect(et2.documentation, isEmpty);
    var et2c = et2.constructors.named('ET2.named');
    expect(et2c.documentation, isEmpty);
    expect(et2c.parameters.named('x').documentation, isEmpty);
  }

  /// Check that block-based doc comments placed between `(` and `[` or `{` of a
  /// parameter list of a primary constructor of an extension type are not
  /// associated with the extension type, the constructor and its parameters.
  void test_blockExtensionTypePrimaryConstructorOptionalParameters() async {
    var library = await bootPackageWithLibrary('''
extension type ET1(/** Line 1 */ [int x = 0]) {}

extension type ET2.named(/** Line 2
  */
  {required int x}) {}
''');
    var et1 = library.extensionTypes.named('ET1');
    expect(et1.documentation, isEmpty);
    var et1c = et1.constructors.named('ET1.new');
    expect(et1c.documentation, isEmpty);
    expect(et1c.parameters.named('x').documentation, isEmpty);
    var et2 = library.extensionTypes.named('ET2');
    expect(et2.documentation, isEmpty);
    var et2c = et2.constructors.named('ET2.named');
    expect(et2c.documentation, isEmpty);
    expect(et2c.parameters.named('x').documentation, isEmpty);
  }
}
