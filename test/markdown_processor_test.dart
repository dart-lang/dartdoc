// Copyright (c) 2016, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library dartdoc.markdown_processor_test;

import 'package:dartdoc/src/markdown_processor.dart';
import 'package:test/test.dart';

void main() {
  group('findFreeHangingGenericsPositions()', () {
    test('returns empty array if all the generics are in []', () {
      final string = "One two [three<four>] [[five<six>] seven eight";
      expect(findFreeHangingGenericsPositions(string), equals([]));
    });

    test('returns positions of generics outside of []', () {
      final string = "One two<int> [[three<four>] five<six>] seven<eight>";
      expect(findFreeHangingGenericsPositions(string), equals([7, 44]));
    });

    test('ignores HTML tags', () {
      final string =
          "One two<int> foo<pre> [[three<four>] five<six>] bar</pre> seven<eight>";
      expect(findFreeHangingGenericsPositions(string), equals([7, 63]));
    });
  });

  group('MarkdownDocument', () {
    test('valid inline markup', () {
      final doc = MarkdownDocument();
      final result = doc.renderLinesToHtml([
        '# title',
        '',
        'Content text.',
        '<img src="https://example.org/image.jpg"><br>',
      ], true);
      expect(
        result.item1,
        '<h1>title</h1>\n'
        '<p>Content text.\n'
        '<img src="https://example.org/image.jpg" /><br /></p>',
      );
      expect(result.item2, 'title');
      expect(result.item3, true);
    });

    test('invalid inline markup', () {
      final doc = MarkdownDocument();
      final result = doc.renderLinesToHtml([
        '# title',
        '',
        'Content text.',
        '<script src="https://example.org/script.js"></script>',
      ], true);
      expect(
        result.item1,
        '<h1>title</h1>\n'
        '<p>Content text.</p>',
      );
      expect(result.item2, 'title');
      expect(result.item3, true);
    });

    test('invalid inline one-liner', () {
      final doc = MarkdownDocument();
      final result = doc.renderLinesToHtml([
        '<script src="https://example.org/script.js">script-content</script>',
        'Content text.',
      ], false);
      expect(result.item1, isNull);
      expect(result.item2, '');
      expect(result.item3, true);
    });
  });
}
