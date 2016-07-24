// Copyright (c) 2015, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library dartdoc.utils_test;

import 'package:dartdoc/src/utils.dart';
import 'package:test/test.dart';

void main() {
  var comment;
  var documentation;

  // For readability, the multiline strings below have a left margin. This
  // is the length of that left margin.
  var multilineStringMargin = ' ' * 6;

  trimMargin(s) => s
      // Trim the left margin of the first line.
      .replaceFirst('$multilineStringMargin  ', '')
      // Trim the left margin of every following line.
      .replaceAll('\n$multilineStringMargin  ', '\n')
      // Trim the last line.
      .replaceFirst(new RegExp('\n$multilineStringMargin\$'), '');

  expectCorrectDocumentation() =>
      expect(stripComments(trimMargin(comment)), trimMargin(documentation));

  group('///-style', () {
    test('one-line comment', () {
      expect(stripComments('/// One line.'), equals('One line.'));
    });

    test('unbuffered one-line comment', () {
      expect(stripComments('///One line.'), equals('One line.'));
    });

    test('multi-line comment', () {
      comment = '''
        /// First line.
        /// Second line.
      ''';
      documentation = '''
        First line.
        Second line.
      ''';
      expectCorrectDocumentation();
    });

    test('multi-line comment with empty lines', () {
      comment = '''
        /// First line.
        ///
        /// Third line.
      ''';
      documentation = '''
        First line.

        Third line.
      ''';
      expectCorrectDocumentation();
    });

    test('multi-line comment with indented lines', () {
      comment = '''
        /// First line.
        ///
        ///     Third line.
        ///     Fourth line.
      ''';
      documentation = '''
        First line.

            Third line.
            Fourth line.
      ''';
      expectCorrectDocumentation();
    });

    test('unbuffered multi-line comment', () {
      comment = '''
        ///First line.
        ///Second line.
        ///Third line.
      ''';
      documentation = '''
        First line.
        Second line.
        Third line.
      ''';
      expectCorrectDocumentation();
    });
  });

  group('/**-style', () {
    test('one-line comment', () {
      expect(stripComments('/** One line. */'), equals('One line.'));
    });

    test('unbuffered one-line comment', () {
      expect(stripComments('/**One line.*/'), equals('One line.'));
    });

    test('multi-line comment', () {
      comment = '''
        /**
         * First line.
         * Second line.
         */
      ''';
      documentation = '''
        First line.
        Second line.
      ''';
      expectCorrectDocumentation();
    });

    test('multi-line comment with empty lines', () {
      comment = '''
        /**
         * First line.
         *
         * Third line.
         */
      ''';
      documentation = '''
        First line.

        Third line.
      ''';
      expectCorrectDocumentation();
    });

    test('multi-line comment with indented lines', () {
      comment = '''
        /**
         * First line.
         *
         *     Third line.
         *     Fourth line.
         */
      ''';
      documentation = '''
        First line.

            Third line.
            Fourth line.
      ''';
      expectCorrectDocumentation();
    });

    test('multi-line comment', () {
      comment = '''
        /**
         *First line.
         *Second line.
         *Third line.
         */
      ''';
      documentation = '''
        First line.
        Second line.
        Third line.
      ''';
      expectCorrectDocumentation();
    });
  });

  group('truncateString', () {
    test('normal', () {
      expect(truncateString('foo bar baz qux', 100), hasLength(15));
    });

    test('truncates', () {
      expect(truncateString('foo bar baz qux', 10), hasLength(11));
      expect(truncateString('foo bar baz qux', 10), 'foo bar ba…');
    });
  });
}
