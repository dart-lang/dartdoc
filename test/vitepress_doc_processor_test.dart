// Copyright (c) 2025, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:dartdoc/src/generator/vitepress_doc_processor.dart';
import 'package:dartdoc/src/generator/vitepress_renderer.dart';
import 'package:test/test.dart';

void main() {
  group('VitePressDocProcessor.sanitizeHtml', () {
    // -- Null byte removal --------------------------------------------------

    test('removes null bytes', () {
      expect(
        VitePressDocProcessor.sanitizeHtml('abc\x00def'),
        equals('abcdef'),
      );
    });

    test('removes null bytes inside tags', () {
      expect(
        VitePressDocProcessor.sanitizeHtml('<di\x00v>hello</div>'),
        equals('<div>hello</div>'),
      );
    });

    // -- <script> removal ---------------------------------------------------

    test('removes script tags', () {
      expect(
        VitePressDocProcessor.sanitizeHtml(
            'before<script>alert("xss")</script>after'),
        equals('beforeafter'),
      );
    });

    test('removes script tags case-insensitively', () {
      expect(
        VitePressDocProcessor.sanitizeHtml('a<SCRIPT>bad</SCRIPT>b'),
        equals('ab'),
      );
    });

    test('removes self-closing script tags', () {
      expect(
        VitePressDocProcessor.sanitizeHtml('a<script src="x"/>b'),
        equals('ab'),
      );
    });

    test('removes script tags with whitespace in tag name', () {
      expect(
        VitePressDocProcessor.sanitizeHtml('a< script>alert(1)</ script>b'),
        equals('ab'),
      );
    });

    test('removes script tags with attributes', () {
      expect(
        VitePressDocProcessor.sanitizeHtml(
            '<script type="text/javascript" src="evil.js"></script>safe'),
        equals('safe'),
      );
    });

    // -- <style> removal ----------------------------------------------------

    test('removes style tags', () {
      expect(
        VitePressDocProcessor.sanitizeHtml(
            'a<style>body{display:none}</style>b'),
        equals('ab'),
      );
    });

    test('removes style tags case-insensitively', () {
      expect(
        VitePressDocProcessor.sanitizeHtml('a<STYLE>.x{color:red}</STYLE>b'),
        equals('ab'),
      );
    });

    // -- Dangerous embed elements -------------------------------------------

    test('removes embed tags', () {
      expect(
        VitePressDocProcessor.sanitizeHtml('a<embed src="evil.swf"/>b'),
        equals('ab'),
      );
    });

    test('removes object tags', () {
      expect(
        VitePressDocProcessor.sanitizeHtml(
            'a<object data="evil.swf"></object>b'),
        equals('ab'),
      );
    });

    test('removes applet tags', () {
      expect(
        VitePressDocProcessor.sanitizeHtml(
            'a<applet code="Evil.class"></applet>b'),
        equals('ab'),
      );
    });

    test('removes form tags', () {
      expect(
        VitePressDocProcessor.sanitizeHtml(
            'a<form action="evil"><input/></form>b'),
        equals('ab'),
      );
    });

    // -- <iframe> filtering -------------------------------------------------

    test('removes non-YouTube iframes', () {
      expect(
        VitePressDocProcessor.sanitizeHtml(
            'a<iframe src="https://evil.com"></iframe>b'),
        equals('ab'),
      );
    });

    test('keeps YouTube iframe', () {
      const youtube =
          '<iframe src="https://www.youtube.com/embed/abc"></iframe>';
      expect(
        VitePressDocProcessor.sanitizeHtml('a${youtube}b'),
        equals('a${youtube}b'),
      );
    });

    test('keeps YouTube-nocookie iframe', () {
      const youtube =
          '<iframe src="https://www.youtube-nocookie.com/embed/abc"></iframe>';
      expect(
        VitePressDocProcessor.sanitizeHtml('a${youtube}b'),
        equals('a${youtube}b'),
      );
    });

    // -- javascript: URL removal --------------------------------------------

    test('removes javascript: in href', () {
      final result = VitePressDocProcessor.sanitizeHtml(
          '<a href="javascript:alert(1)">click</a>');
      expect(result, contains('href="'));
      expect(result, isNot(contains('javascript:')));
    });

    test('removes javascript: in src', () {
      final result =
          VitePressDocProcessor.sanitizeHtml('<img src="javascript:alert(1)">');
      expect(result, contains('src="'));
      expect(result, isNot(contains('javascript:')));
    });

    test('removes javascript: case-insensitively', () {
      final result = VitePressDocProcessor.sanitizeHtml(
          '<a href="JaVaScRiPt:alert(1)">click</a>');
      expect(result, isNot(contains('JaVaScRiPt:')));
    });

    // -- Event handler removal ----------------------------------------------

    test('removes onclick handler', () {
      expect(
        VitePressDocProcessor.sanitizeHtml(
            '<div onclick="alert(1)">text</div>'),
        equals('<div>text</div>'),
      );
    });

    test('removes onmouseover handler', () {
      expect(
        VitePressDocProcessor.sanitizeHtml('<a onmouseover="steal()">link</a>'),
        equals('<a>link</a>'),
      );
    });

    test('removes multiple event handlers', () {
      final result = VitePressDocProcessor.sanitizeHtml(
          '<div onclick="a()" onload="b()">x</div>');
      expect(result, isNot(contains('onclick')));
      expect(result, isNot(contains('onload')));
    });

    // -- Benign HTML passes through -----------------------------------------

    test('passes through safe HTML unchanged', () {
      const safe = '<p>Hello <strong>world</strong></p>';
      expect(VitePressDocProcessor.sanitizeHtml(safe), equals(safe));
    });

    test('passes through empty string', () {
      expect(VitePressDocProcessor.sanitizeHtml(''), equals(''));
    });

    // -- data: URI removal --------------------------------------------------

    test('removes data: URI in href', () {
      final result = VitePressDocProcessor.sanitizeHtml(
          '<a href="data:text/html,<script>alert(1)</script>">x</a>');
      expect(result, isNot(contains('data:')));
    });

    test('removes data: URI in src', () {
      final result = VitePressDocProcessor.sanitizeHtml(
          '<img src="data:text/html;base64,PHNjcmlwdD4=">');
      expect(result, isNot(contains('data:')));
    });

    test('removes data: URI case-insensitively', () {
      final result = VitePressDocProcessor.sanitizeHtml(
          '<a href="DaTa:text/html,evil">x</a>');
      expect(result, isNot(contains('DaTa:')));
    });

    // -- SVG removal --------------------------------------------------------

    test('removes svg tags', () {
      expect(
        VitePressDocProcessor.sanitizeHtml(
            'a<svg onload="alert(1)"><circle/></svg>b'),
        equals('ab'),
      );
    });

    test('removes svg with foreignObject', () {
      expect(
        VitePressDocProcessor.sanitizeHtml(
            'a<svg><foreignObject><script>x</script></foreignObject></svg>b'),
        equals('ab'),
      );
    });

    // -- base tag removal ---------------------------------------------------

    test('removes base tags', () {
      expect(
        VitePressDocProcessor.sanitizeHtml('a<base href="https://evil.com/">b'),
        equals('ab'),
      );
    });

    test('removes base tags with spaces', () {
      expect(
        VitePressDocProcessor.sanitizeHtml(
            'a< base href="https://evil.com/" />b'),
        equals('ab'),
      );
    });

    // -- Unquoted event handlers --------------------------------------------

    test('removes unquoted event handler', () {
      final result = VitePressDocProcessor.sanitizeHtml(
          '<div onclick=alert(1)>text</div>');
      expect(result, isNot(contains('onclick')));
      expect(result, contains('text'));
    });

    test('removes unquoted event handler with complex value', () {
      final result = VitePressDocProcessor.sanitizeHtml(
          '<img onerror=fetch("evil") src="x">');
      expect(result, isNot(contains('onerror')));
    });

    // -- YouTube iframe bypass prevention -----------------------------------

    test('removes iframe with youtube.com in non-src attribute', () {
      expect(
        VitePressDocProcessor.sanitizeHtml(
            '<iframe src="https://evil.com" title="youtube.com"></iframe>'),
        equals(''),
      );
    });

    test('keeps iframe with youtube.com in src attribute', () {
      const tag =
          '<iframe src="https://www.youtube.com/embed/abc123"></iframe>';
      expect(
        VitePressDocProcessor.sanitizeHtml(tag),
        equals(tag),
      );
    });

    // -- meta tag removal ---------------------------------------------------

    test('removes meta refresh tag', () {
      expect(
        VitePressDocProcessor.sanitizeHtml(
            'a<meta http-equiv="refresh" content="0;url=evil">b'),
        equals('ab'),
      );
    });

    // -- link tag removal ---------------------------------------------------

    test('removes link stylesheet tag', () {
      expect(
        VitePressDocProcessor.sanitizeHtml(
            'a<link rel="stylesheet" href="evil.css">b'),
        equals('ab'),
      );
    });

    // -- Vue template interpolation -----------------------------------------

    test('escapes Vue template interpolation', () {
      final result =
          VitePressDocProcessor.sanitizeHtml('text {{ alert(1) }} more');
      expect(result, isNot(contains('{{')));
      expect(result, contains(r'\{\{'));
    });

    test('escapes nested Vue interpolation', () {
      final result =
          VitePressDocProcessor.sanitizeHtml('{{ constructor("evil") }}');
      expect(result, isNot(contains('{{')));
    });
  });

  group('escapeTableCell', () {
    test('escapes pipe characters', () {
      expect(escapeTableCell('a|b'), equals(r'a\|b'));
    });

    test('escapes multiple pipes', () {
      expect(escapeTableCell('a|b|c'), equals(r'a\|b\|c'));
    });

    test('passes through text without pipes', () {
      expect(escapeTableCell('hello world'), equals('hello world'));
    });
  });

  group('yamlEscape', () {
    test('escapes backslashes', () {
      expect(yamlEscape(r'a\b'), equals(r'a\\b'));
    });

    test('escapes double quotes', () {
      expect(yamlEscape('a"b'), equals(r'a\"b'));
    });

    test('escapes newlines', () {
      expect(yamlEscape('a\nb'), equals(r'a\nb'));
    });

    test('escapes carriage returns', () {
      expect(yamlEscape('a\rb'), equals(r'a\rb'));
    });

    test('escapes combined special characters', () {
      expect(yamlEscape('a\\b"c\nd'), equals(r'a\\b\"c\nd'));
    });

    test('passes through plain text', () {
      expect(yamlEscape('hello world'), equals('hello world'));
    });
  });

  group('escapeGenerics', () {
    test('escapes angle brackets', () {
      expect(escapeGenerics('List<int>'), equals(r'List\<int\>'));
    });

    test('escapes nested angle brackets', () {
      expect(escapeGenerics('Map<String, List<int>>'),
          equals(r'Map\<String, List\<int\>\>'));
    });

    test('passes through text without angle brackets', () {
      expect(escapeGenerics('MyClass'), equals('MyClass'));
    });
  });

  group('MarkdownRenderer _openTag attribute escaping', () {
    test('sanitizeHtml preserves safe attributes', () {
      final result = VitePressDocProcessor.sanitizeHtml(
          '<a href="https://example.com">link</a>');
      expect(result, contains('href="https://example.com"'));
    });
  });
}
