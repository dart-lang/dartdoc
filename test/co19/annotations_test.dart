// Copyright (c) 2026, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// @assertion Doc comments can be placed either before or after metadata
/// annotations (e.g., `@override`, `@deprecated`). If doc comments appear in
/// both locations, the doc comment closest to the declaration (after the
/// annotation) takes precedence. The comment before the annotations is ignored,
/// and documentation tools should issue a warning.
/// @author sgrekhov22@gmail.com
library;

import 'package:test/test.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

import '../src/utils.dart';
import 'co19_test_base.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(AnnotationsTest);
  });
}

@reflectiveTest
class AnnotationsTest extends Co19TestBase {
  /// Check that doc comments can be placed before annotations if there are no
  /// doc comments after.
  void test_before() async {
    var library = await bootPackageWithLibrary('''
const Meta = 0;

/// Before
@Meta
class C {}
''');
    var c = library.classes.named('C');
    expect(c.documentation, 'Before');
  }

  /// Check that block-based doc comments can be placed before annotations if
  /// there are no doc comments after.
  void test_blockBefore() async {
    var library = await bootPackageWithLibrary('''
const Meta = 0;

/**
 * Before
 */
@Meta
class C {}
''');
    var c = library.classes.named('C');
    expect(c.documentation, 'Before');
  }

  /// Check that doc comments can be placed after annotations.
  void test_after() async {
    var library = await bootPackageWithLibrary('''
const Meta = 0;

@Meta
/// After
class C {}
''');
    var c = library.classes.named('C');
    expect(c.documentation, 'After');
  }

  /// Check that block-based doc comments can be placed after annotations.
  void test_blockAfter() async {
    var library = await bootPackageWithLibrary('''
const Meta = 0;

@Meta
/**
 * After
 */
class C {}
''');
    var c = library.classes.named('C');
    expect(c.documentation, 'After');
  }

  /// Check that if there are doc comments both before and after annotations
  /// then the comment before the annotations is ignored.
  void test_beforeAndAfter1() async {
    var library = await bootPackageWithLibrary('''
const Meta = 0;

/// Before
@Meta
/// After
class C {}
''');
    var c = library.classes.named('C');
    expect(c.documentation, 'After');
  }

  /// Check that if there are block-based doc comments both before and after
  /// an annotation then the comment before the annotation is ignored.
  void test_blockBeforeAndAfter1() async {
    var library = await bootPackageWithLibrary('''
const Meta = 0;

/** 
 * Before
 */
@Meta
/** 
 * After
 */
class C {}
''');
    var c = library.classes.named('C');
    expect(c.documentation, 'After');
  }

  /// Check that if there are doc comments both before and after annotations
  /// then the comments before the annotations are ignored.
  void test_beforeAndAfter2() async {
    var library = await bootPackageWithLibrary('''
const Meta1 = 1;
const Meta2 = 2;

/// Line 1
@Meta1
/// Line 2
@Meta2
/// Line 3
class C {}
''');
    var c = library.classes.named('C');
    expect(c.documentation, 'Line 3');
  }

  /// Check that if there are block-based doc comments both before and after
  /// annotations then the comments before the annotations are ignored.
  void test_blockBeforeAndAfter2() async {
    var library = await bootPackageWithLibrary('''
const Meta1 = 1;
const Meta2 = 2;

/** 
 * Line 1
 */
@Meta1
/** 
 * Line 2
 */
@Meta2
/** 
 * Line 3
 */
class C {}
''');
    var c = library.classes.named('C');
    expect(c.documentation, 'Line 3');
  }

  /// Check that if there are block-based doc comments before and line-based
  /// after an annotation then the comment before the annotation is ignored.
  void test_mixedBeforeAndAfter1() async {
    var library = await bootPackageWithLibrary('''
const Meta = 0;

/** 
 * Before
 */
@Meta
/// After
class C {}
''');
    var c = library.classes.named('C');
    expect(c.documentation, 'After');
  }

  /// Check that if there are line-based doc comments before and block-based
  /// after an annotation then the comment before the annotation is ignored.
  void test_mixedBeforeAndAfter2() async {
    var library = await bootPackageWithLibrary('''
const Meta = 0;

/// Before
@Meta
/** 
 * After
 */
class C {}
''');
    var c = library.classes.named('C');
    expect(c.documentation, 'After');
  }

  /// Check that if there are different doc comments before and after an
  /// annotation then only the last comment is taken into account.
  void test_mixedBeforeAndAfter3() async {
    var library = await bootPackageWithLibrary('''
const Meta1 = 1;
const Meta1 = 2;

/// Line 1
@Meta1
/** 
 * Line 2
 */
 @Meta2
 /// Line 3
class C {}
''');
    var c = library.classes.named('C');
    expect(c.documentation, 'Line 3');
  }

  /// Check that if there are different doc comments before and after an
  /// annotation then only the last comment is taken into account.
  void test_mixedBeforeAndAfter4() async {
    var library = await bootPackageWithLibrary('''
const Meta1 = 1;
const Meta1 = 2;

/** 
 * Line 1
 */
@Meta1
/// Line 2
 @Meta2
/** 
 * Line 3
 */
class C {}
''');
    var c = library.classes.named('C');
    expect(c.documentation, 'Line 3');
  }

  /// Check that if there is an annotation in a doc comment it is treated as
  /// part of the comment.
  void test_inside1() async {
    var library = await bootPackageWithLibrary('''
const Meta = 1;

@Meta
/// @Meta Line 1
/// `@Meta` Line 2  
class C {}
''');
    var c = library.classes.named('C');
    expect(c.documentation, '''
@Meta Line 1
`@Meta` Line 2''');
  }

  /// Check that if there is an annotation in a doc comment it is treated as
  /// part of the comment.
  void test_inside2() async {
    var library = await bootPackageWithLibrary('''
const Meta = 1;

@Meta
/** @Meta Line 1
 * `@Meta` Line 2
 */  
class C {}
''');
    var c = library.classes.named('C');
    expect(c.documentation, '''
@Meta Line 1
`@Meta` Line 2''');
  }
}
