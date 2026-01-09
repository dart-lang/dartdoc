// Copyright (c) 2025, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// @assertion A line-based doc comment is a comment that starts with `///`. One
/// or more consecutive lines that begin with `///` form a doc comment block.
///
/// The block continues even if interrupted by single-line non-doc comments
/// (lines starting with `//`) or by blank lines. The interrupting lines are
/// ignored when extracting documentation text.
///
/// For each line that begins with `///`, the parser removes the three slashes
/// and all leading whitespace to produce the documentation text. Exception:
/// inside fenced code blocks (` ``` `), whitespace after the leading `///` is
/// preserved to maintain code formatting.
/// @author sgrekhov22@gmail.com
library;

import 'package:test/test.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

import 'co19_test_base.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(LineBasedDocCommentsTest);
  });
}

@reflectiveTest
class LineBasedDocCommentsTest extends Co19TestBase {
  /// Check that the parser removes the three slashes and all leading
  /// whitespace
  void test_removesTripleSlashes() async {
    await writePackageWithCommentedLibrary('''
/// Text.
/// More text.
''');
    expectDocComment(equals('''
Text.
More text.'''));
  }

  /// Check empty lines after three slashes are preserved
  void test_leavesBlankLines() async {
    await writePackageWithCommentedLibrary('''
/// Text.
///
/// More text.
''');
    expectDocComment(equals('''
Text.

More text.'''));
  }

  /// Check that the parser removes the three slashes and all leading
  /// whitespace
  void test_removesSpaceAfterTripleSlashes() async {
    markTestSkipped('Skipping until issue '
        'https://github.com/dart-lang/dartdoc/issues/4137 is resolved.');
    return;
/*
    await writePackageWithCommentedLibrary('''
///  Text.
///    More text.
''');
    expectDocComment(equals('''
Text.
More text.'''));
*/
  }

  /// Check that interrupting blank lines and starting with `// ` are ignored.
  void test_interruptingLinesIgnored() async {
    await writePackageWithCommentedLibrary('''
/// Text.
//
/// More text.
// Some text
/// And more text.

/// And more.
''');
    expectDocComment(equals('''
Text.
More text.
And more text.
And more.'''));
  }

  /// Check that the doc comment starts after `///` even if there is no trailing
  /// whitespace.
  void test_noTrailingWhitespace() async {
    await writePackageWithCommentedLibrary('''
//// Text.
/////More text.
///And more.
''');
    expectDocComment(equals('''
/ Text.
//More text.
And more.'''));
  }

  /// Check that inside fenced code blocks (```), whitespace after the leading
  /// `///` is preserved
  void test_whitespaceInBacktickCodeBlocks() async {
    await writePackageWithCommentedLibrary('''
/// ```
/// void main() {
///   /// This line prints "Hello, world!"
///   print('Hello, world!');
/// }
/// ```
''');
    expectDocComment(equals('''
```
void main() {
  /// This line prints "Hello, world!"
  print('Hello, world!');
}
```'''));
  }

  /// Check that inside fenced code blocks (~~~), whitespace after the leading
  /// `///` is preserved
  void test_whitespaceInTildesCodeBlocks() async {
    await writePackageWithCommentedLibrary('''
/// ~~~
/// void main() {
///   /// This line prints "Hello, world!"
///   print('Hello, world!');
/// }
/// ~~~
''');
    expectDocComment(equals('''
~~~
void main() {
  /// This line prints "Hello, world!"
  print('Hello, world!');
}
~~~'''));
  }

  /// Check that inside fenced code span (`), whitespace after the leading
  /// `///` is removed.
  void test_whitespaceInCodeSpan() async {
    markTestSkipped('Skipping until issue '
        'https://github.com/dart-lang/dartdoc/issues/4138 is resolved.');
    return;
/*
    await writePackageWithCommentedLibrary('''
/// `
/// void main() {
///   /// This line prints "Hello, world!"
///   print('Hello, world!');
/// }
/// `
''');
    expectDocComment(equals('''
`
void main() {
/// This line prints "Hello, world!"
print('Hello, world!');
}
`'''));
*/
  }

  /// Check that the parser removes leading whitespace before the three slashes
  void test_whitespaceBeforeTripleSlashes() async {
    await writePackageWithCommentedLibrary('''
/// Text.
   /// More text.
''');
    expectDocComment(equals('''
Text.
More text.'''));
  }
}
