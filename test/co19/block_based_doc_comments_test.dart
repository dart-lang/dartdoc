// Copyright (c) 2026, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// @assertion A block-based doc comment is a comment that starts with `/**` and
/// ends with the matching `*/`.
///
/// Block comments may contain nested comment sequences (for example:
/// `/**` outer /* inner */ outer */`). Documentation tools must respect nesting
/// and ensure that the comment block only ends at the closing `*/` that matches
/// the opening delimiter.
///
/// The content within the delimiters is treated as the documentation. On each
/// line after the opening `/**`, any leading whitespace followed by a single
/// asterisk (`*`) is considered stylistic and is stripped by doc generators.
/// Any whitespace immediately following the asterisk is also stripped, if
/// present.
/// @author sgrekhov22@gmail.com
library;

import 'package:test/test.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

import 'co19_test_base.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(BlockBasedDocCommentsTest);
  });
}

@reflectiveTest
class BlockBasedDocCommentsTest extends Co19TestBase {
  /// Check that the content within the delimiters is treated as the
  /// documentation.
  void test_content() async {
    await writePackageWithCommentedLibrary('''
/** Line 1.
 * Line 2.
 */
''');
    expectDocComment(equals('''
Line 1.
Line 2.'''));
  }

  /// Check that the content within the delimiters is treated as the
  /// documentation. Test single-line comment.
  void test_singleLine() async {
    await writePackageWithCommentedLibrary('''
/** Line 1. */
''');
    expectDocComment(equals('Line 1.'));
  }

  /// Check that leading asterisk without trailing whitespace is stripped
  void test_contentNoTrailingWhitespace1() async {
    markTestSkipped('Skipping until issue '
        'https://github.com/dart-lang/dartdoc/issues/4151 is resolved.');
    return;
//     await writePackageWithCommentedLibrary('''
// /**Line 1.
//  *Line 2.
//  */
// ''');
//     expectDocComment(equals('''
// Line 1.
// Line 2.'''));
  }

  /// Check that only a leading asterisk is stripped
  void test_contentNoTrailingWhitespace2() async {
    markTestSkipped('Skipping until issue '
        'https://github.com/dart-lang/dartdoc/issues/4151 is resolved.');
    return;
//     await writePackageWithCommentedLibrary('''
// /***Line 1.
//  **Line 2.
//  **/
// ''');
//     expectDocComment(equals('''
// *Line 1.
// *Line 2.
// *'''));
  }

  /// Check that leading whitespace followed by a single asterisk is stripped
  void test_leadingWhitespace() async {
    markTestSkipped('Skipping until issue '
        'https://github.com/dart-lang/dartdoc/issues/4150 is resolved.');
    return;
//     await writePackageWithCommentedLibrary('''
// /** Line 1.
//       * Line 2.
//  */
// ''');
//     expectDocComment(equals('''
// Line 1.
// Line 2.'''));
  }

  /// Check empty lines after asterisk are preserved
  void test_leavesBlankLines() async {
    await writePackageWithCommentedLibrary('''
/** Line 1.
 *
 * Line 2.
 */
''');
    expectDocComment(equals('''
Line 1.

Line 2.'''));
  }

  /// Check that any whitespace immediately following the asterisk is stripped
  void test_removeWhitespaceAfterAsterisk() async {
    markTestSkipped('Skipping until issue '
        'https://github.com/dart-lang/dartdoc/issues/4156 is resolved.');
    return;
//     await writePackageWithCommentedLibrary('''
// /**  Line 1.
//  *     Line 2.
//  */
// ''');
//     expectDocComment(equals('''
// Line 1.
// Line 2.'''));
  }

  /// Check that line after /** with no leading `*` is left unchanged
  void test_noAsteriskLinePreserved() async {
    markTestSkipped('Skipping until issue '
        'https://github.com/dart-lang/dartdoc/issues/4157 is resolved.');
    return;
//     await writePackageWithCommentedLibrary('''
// /** Line 1
//  * Line 2
//    Line 3
//  * Line 4
//
//  * Line 5
//  */
// ''');
//     expectDocComment(equals('''
// Line 1
// Line 2
//    Line 3
// Line 4
//
// Line 5'''));
  }

  /// Check nesting block comments
  void test_nestedBlocks() async {
    await writePackageWithCommentedLibrary('''
/** Line 1.
 * /**
 * Line 2.
 * /* Line 3.
 * Line 4.
 * */ Line 5.
 * */ Line 6.
 * /* Line 7 */
 */
''');
    expectDocComment(equals('''
Line 1.
/**
Line 2.
/* Line 3.
Line 4.
*/ Line 5.
*/ Line 6.
/* Line 7 */'''));
  }

  /// Check that whitespace in fenced code block (```) is preserved
  /// Please note https://github.com/dart-lang/dartdoc/issues/4160
  void test_whitespaceInBacktickCodeBlocks() async {
    await writePackageWithCommentedLibrary('''
/**
 * ```
 * main() {
 *   print('Hello word');
 * }
 * ```
 */
''');
    expectDocComment(equals('''
```
main() {
  print('Hello word');
}
```'''));
  }

  /// Check that whitespace in fenced code block (~~~) is preserved
  /// Please note https://github.com/dart-lang/dartdoc/issues/4160
  void test_whitespaceInTildesCodeBlocks() async {
    await writePackageWithCommentedLibrary('''
/**
 * ~~~
 * main() {
 *   print('Hello word');
 * }
 * ~~~
 */
''');
    expectDocComment(equals('''
~~~
main() {
  print('Hello word');
}
~~~'''));
  }

  /// Check that inside fenced code span (`), whitespace after the leading
  /// `*` is removed.
  void test_whitespaceInCodeSpan() async {
    markTestSkipped('Skipping until issue '
        'https://github.com/dart-lang/dartdoc/issues/4138 is resolved.');
    return;
//     await writePackageWithCommentedLibrary('''
// /**
//  * `
//  * void main() {
//  *   /// This line prints "Hello, world!"
//  *   print('Hello, world!');
//  * }
//  * `
//  */
// ''');
//     expectDocComment(equals('''
// `
// void main() {
// /// This line prints "Hello, world!"
// print('Hello, world!');
// }
// `'''));
  }
}
