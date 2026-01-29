// Copyright (c) 2026, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:dartdoc/src/model/model.dart';
import 'package:test/test.dart';

class DocumentationCommentFake with DocumentationComment {
  @override
  final String? documentationComment;

  DocumentationCommentFake([this.documentationComment]);

  @override
  ModelNode? get modelNode => null;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  ({List<String> categories, List<String> subCategories}) parse(String input) =>
      DocumentationCommentFake().parseCategorization(input);

  group('DocumentationComment.parseCategorization', () {
    test('returns empty lists for null or empty input', () {
      final result = parse('');
      expect(result.categories, isEmpty);
      expect(result.subCategories, isEmpty);
    });

    test('extracts and sorts multiple categories', () {
      final result = parse('{@category B} {@category A}');
      expect(result.categories, equals(['A', 'B']));
    });

    test('extracts and sorts subcategories independently', () {
      final result = parse('{@subCategory Z} {@subCategory Y}');
      expect(result.subCategories, equals(['Y', 'Z']));
    });

    test('trims whitespace and handles multi-line comments', () {
      final input = '''
        /// Some text.
        /// {@category  Main }
        /// {@subCategory Sub }
      ''';
      final result = parse(input);
      expect(result.categories, equals(['Main']));
      expect(result.subCategories, equals(['Sub']));
    });

    test('ignores malformed tags', () {
      final result = parse('{@category}'); // Missing name
      expect(result.categories, isEmpty);
    });

    test('getters lazily initialize from documentationComment', () {
      final fake = DocumentationCommentFake('{@category A}');
      // Verify getters work without calling any other processing
      expect(fake.categoryNames, equals(['A']));
    });

    test('includes categories inside templates', () {
      final result = parse('{@template T}{@category A}{@endtemplate}');
      expect(result.categories, equals(['A']));
    });
  });
}
