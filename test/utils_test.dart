// Copyright (c) 2015, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:dartdoc/src/utils.dart';
import 'package:test/test.dart';

void main() {
  late String comment;
  late String documentation;

  // For readability, the multiline strings below have a left margin. This
  // is the length of that left margin.
  var multilineStringMargin = ' ' * 6;

  String trimMargin(String s) => s
      // Trim the left margin of the first line.
      .replaceFirst('$multilineStringMargin  ', '')
      // Trim the left margin of every following line.
      .replaceAll('\n$multilineStringMargin  ', '\n')
      // Trim the last line.
      .replaceFirst(RegExp('\n$multilineStringMargin\$'), '');

  void expectCorrectDocumentation() => expect(
      stripCommentDelimiters(trimMargin(comment)), trimMargin(documentation));

  group('///-style', () {
    test('one-line comment', () {
      expect(stripCommentDelimiters('/// One line.'), equals('One line.'));
    });

    test('unbuffered one-line comment', () {
      expect(stripCommentDelimiters('///One line.'), equals('One line.'));
    });

    test('multiple runs with multiline comments', () {
      expect(stripCommentDelimiters(stripCommentDelimiters('''
          /// A line.
          /// * An asterisk
      ''')), equals('A line.\n* An asterisk'));
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
    test('multiple runs with cstyle comments', () {
      expect(stripCommentDelimiters(stripCommentDelimiters('''
          /**
           * A line.
           * * An asterisk
           */
      ''')), equals('A line.\n* An asterisk'));
    });

    test('one-line comment', () {
      expect(stripCommentDelimiters('/** One line. */'), equals('One line.'));
    });

    test('unbuffered one-line comment', () {
      expect(stripCommentDelimiters('/**One line.*/'), equals('One line.'));
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

  group('leadingWhitespace', () {
    test('strip common leading whitespace, but no more', () {
      var input = '   3 space indent\n'
          '    4 space indent (one preserved)\n'
          '       7 space indent (four preserved)\n'
          '\t  2 spaces, one tab (same as 3 space)\n'
          '    \t4 spaces, one tab (preserve the tab)\n'
          '   3 space indent again\n';
      var output = '3 space indent\n'
          ' 4 space indent (one preserved)\n'
          '    7 space indent (four preserved)\n'
          '2 spaces, one tab (same as 3 space)\n'
          ' \t4 spaces, one tab (preserve the tab)\n'
          '3 space indent again\n';
      expect(stripCommonWhitespace(input).join('\n'), equals(output));
    });
  });

  group('isSafeHttpUrl', () {
    test('accepts plain http(s) URLs', () {
      for (var url in [
        'http://example.com',
        'https://example.com/',
        'https://pub.dev/documentation/foo/1.0.0/',
        'https://api.dart.dev/stable/3.0.0/',
        'https://github.com/org/repo/blob/main/lib/a.dart#L12',
        'https://example.com/a?b=1&c=2',
        'HTTPS://EXAMPLE.COM/A',
        // Unsubstituted template placeholders are odd, but harmless.
        'https://example.com/%x%/',
      ]) {
        expect(isSafeHttpUrl(url), isTrue, reason: url);
      }
    });

    test('rejects URLs which can break out of an HTML attribute', () {
      for (var url in [
        'x"><img src=x onerror=alert(1)><a x="',
        "https://example.com/'onmouseover=alert(1)",
        'https://example.com/<script>',
        'https://example.com/`',
        'https://example.com/a b',
        'https://example.com/a\tb',
        'https://example.com/a\nb',
        'https://example.com/a\x00b',
      ]) {
        expect(isSafeHttpUrl(url), isFalse, reason: url);
      }
    });

    test('rejects non-http(s) and relative URLs', () {
      for (var url in [
        '',
        'javascript:alert(1)',
        ' javascript:alert(1)',
        'JavaScript:alert(1)',
        'data:text/html,<script>alert(1)</script>',
        'vbscript:msgbox(1)',
        'file:///etc/passwd',
        'ftp://example.com/',
        '//example.com/',
        '/docs/',
        '../docs/',
        'docs/',
        'https:',
        'https://',
        'https:///path',
      ]) {
        expect(isSafeHttpUrl(url), isFalse, reason: url);
      }
    });
  });

  group('htmlAttributeEscape', () {
    test('escapes attribute delimiters but not slashes', () {
      expect(htmlAttributeEscape.convert('https://example.com/a?b=1&c=2'),
          equals('https://example.com/a?b=1&amp;c=2'));
      expect(htmlAttributeEscape.convert('x"><img src=x onerror=alert(1)>'),
          equals('x&quot;&gt;&lt;img src=x onerror=alert(1)&gt;'));
    });
  });
}
