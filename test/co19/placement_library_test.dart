// Copyright (c) 2026, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// @assertion Doc comments are associated with the declaration that immediately
/// follows them. They are only considered valid when placed directly before the
/// following types of declarations:
/// ...
/// - `library` directives.
/// @author sgrekhov22@gmail.com
library;

import 'package:test/test.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

import 'co19_test_base.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(PlacementLibraryTest);
  });
}

/// Verifies that a doc comment placed directly before a `library` directive is
/// treated as the documentation of the library.
@reflectiveTest
class PlacementLibraryTest extends Co19TestBase {
  /// Check that doc comments can be placed before a named `library` directive.
  void test_beforeNamedLibrary1() async {
    var library = await bootLibrary('''
/// Line 1
library co19; /// Line 2
/// Line 3
''');
    expect(library.documentation, 'Line 1');
  }

  /// Check that block-based doc comments can be placed before a named
  /// `library` directive.
  void test_beforeNamedLibrary2() async {
    var library = await bootLibrary('''
/** Line 1
 */
library co19; /** Line 2 */
/** Line 3
 */
''');
    expect(library.documentation, 'Line 1');
  }

  /// Check that doc comments can be placed before an unnamed `library`
  /// directive.
  void test_beforeUnnamedLibrary1() async {
    var library = await bootLibrary('''
/// Line 1
library; /// Line 2
/// Line 3
''');
    expect(library.documentation, 'Line 1');
  }

  /// Check that block-based doc comments can be placed before an unnamed
  /// `library` directive.
  void test_beforeUnnamedLibrary2() async {
    var library = await bootLibrary('''
/** Line 1
 */
library; /** Line 2 */
/** Line 3
 */
''');
    expect(library.documentation, 'Line 1');
  }

  /// Check that multi-line doc comments can be placed before a `library`
  /// directive.
  void test_beforeLibraryMultiline1() async {
    var library = await bootLibrary('''
/// Line 1
/// Line 2
library;
''');
    expect(library.documentation, 'Line 1\nLine 2');
  }

  /// Check that multi-line block-based doc comments can be placed before a
  /// `library` directive.
  void test_beforeLibraryMultiline2() async {
    var library = await bootLibrary('''
/**
 * Line 1
 * Line 2
 */
library;
''');
    expect(library.documentation, 'Line 1\nLine 2');
  }

  /// Check that doc comments can be placed before a `library` directive
  /// followed by other directives and declarations.
  void test_beforeLibraryWithDirectives1() async {
    var library = await bootLibrary('''
/// Line 1
library; /// Line 2
/// Line 3
import 'dart:async'; /// Line 4
/// Line 5
export 'dart:async';
/// Line 6
class C {}
''');
    expect(library.documentation, 'Line 1');
  }

  /// Check that block-based doc comments can be placed before a `library`
  /// directive followed by other directives and declarations.
  void test_beforeLibraryWithDirectives2() async {
    var library = await bootLibrary('''
/** Line 1
 */
library; /** Line 2 */
/** Line 3
 */
import 'dart:async'; /** Line 4 */
/** Line 5
 */
export 'dart:async';
/** Line 6
 */
class C {}
''');
    expect(library.documentation, 'Line 1');
  }

  /// Check that doc comments can be placed before a `library` directive that
  /// is preceded by non-doc comments.
  void test_beforeLibraryAfterComments1() async {
    var library = await bootLibrary('''
// Copyright (c) 2026.
/* Some comment */

/// Line 1
library;
''');
    expect(library.documentation, 'Line 1');
  }

  /// Check that block-based doc comments can be placed before a `library`
  /// directive that is preceded by non-doc comments.
  void test_beforeLibraryAfterComments2() async {
    var library = await bootLibrary('''
// Copyright (c) 2026.
/* Some comment */

/** Line 1
 */
library;
''');
    expect(library.documentation, 'Line 1');
  }

  /// Check that doc comments can be placed before a `library` directive that
  /// is preceded by a script tag.
  void test_beforeLibraryAfterScriptTag1() async {
    var library = await bootLibrary('''
#!/usr/bin/env dart
/// Line 1
library;
''');
    expect(library.documentation, 'Line 1');
  }

  /// Check that block-based doc comments can be placed before a `library`
  /// directive that is preceded by a script tag.
  void test_beforeLibraryAfterScriptTag2() async {
    var library = await bootLibrary('''
#!/usr/bin/env dart
/** Line 1
 */
library;
''');
    expect(library.documentation, 'Line 1');
  }

  /// Check that doc comments can be placed before an annotated `library`
  /// directive.
  void test_beforeAnnotatedLibrary1() async {
    var library = await bootLibrary('''
/// Line 1
@deprecated
library; /// Line 2
/// Line 3
''');
    expect(library.documentation, 'Line 1');
  }

  /// Check that block-based doc comments can be placed before an annotated
  /// `library` directive.
  void test_beforeAnnotatedLibrary2() async {
    var library = await bootLibrary('''
/** Line 1
 */
@deprecated
library; /** Line 2 */
/** Line 3
 */
''');
    expect(library.documentation, 'Line 1');
  }

  /// Check that doc comments can be placed between an annotation and a
  /// `library` directive.
  void test_beforeAnnotatedLibrary3() async {
    var library = await bootLibrary('''
@deprecated
/// Line 1
library; /// Line 2
/// Line 3
''');
    expect(library.documentation, 'Line 1');
  }

  /// Check that block-based doc comments can be placed between an annotation
  /// and a `library` directive.
  void test_beforeAnnotatedLibrary4() async {
    var library = await bootLibrary('''
@deprecated
/** Line 1
 */
library; /** Line 2 */
/** Line 3
 */
''');
    expect(library.documentation, 'Line 1');
  }
}
