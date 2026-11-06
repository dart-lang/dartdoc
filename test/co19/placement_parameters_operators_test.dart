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
}
