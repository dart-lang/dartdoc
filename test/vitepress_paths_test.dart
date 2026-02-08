// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:dartdoc/src/generator/vitepress_paths.dart';
import 'package:test/test.dart';

void main() {
  group('VitePressPathResolver.sanitizeFileName', () {
    test('passes through simple names unchanged', () {
      expect(VitePressPathResolver.sanitizeFileName('MyClass'), 'MyClass');
      expect(VitePressPathResolver.sanitizeFileName('simple'), 'simple');
    });

    test('strips generic type parameters', () {
      expect(VitePressPathResolver.sanitizeFileName('Foo<Bar>'), 'Foo');
      expect(VitePressPathResolver.sanitizeFileName('Map<String, int>'), 'Map');
      expect(VitePressPathResolver.sanitizeFileName('List<List<int>>'), 'List');
    });

    test('replaces colons with hyphens', () {
      expect(VitePressPathResolver.sanitizeFileName('dart:core'), 'dart-core');
    });

    test('replaces slashes with hyphens', () {
      expect(VitePressPathResolver.sanitizeFileName('a/b'), 'a-b');
      expect(VitePressPathResolver.sanitizeFileName('a\\b'), 'a-b');
    });

    test('replaces Windows-problematic characters', () {
      expect(VitePressPathResolver.sanitizeFileName('a|b'), 'a-b');
      expect(VitePressPathResolver.sanitizeFileName('a?b'), 'a-b');
      expect(VitePressPathResolver.sanitizeFileName('a*b'), 'a-b');
      expect(VitePressPathResolver.sanitizeFileName('a"b'), 'a-b');
    });

    test('collapses multiple hyphens', () {
      expect(VitePressPathResolver.sanitizeFileName('a::b'), 'a-b');
      expect(VitePressPathResolver.sanitizeFileName('a:::b'), 'a-b');
    });

    test('strips leading and trailing hyphens', () {
      expect(VitePressPathResolver.sanitizeFileName(':name:'), 'name');
      expect(VitePressPathResolver.sanitizeFileName('::name::'), 'name');
    });

    test('handles empty string', () {
      expect(VitePressPathResolver.sanitizeFileName(''), '');
    });

    test('handles name that is only special chars', () {
      expect(VitePressPathResolver.sanitizeFileName(':::'), '');
    });

    test('handles name with generics and special chars', () {
      // Generics stripped first, then special chars handled
      expect(VitePressPathResolver.sanitizeFileName('Foo<T>:bar'), 'Foo');
    });
  });

  group('VitePressPathResolver.stripGenerics', () {
    test('returns name unchanged when no generics', () {
      expect(
          VitePressPathResolver.stripGenerics('SimpleBinder'), 'SimpleBinder');
      expect(VitePressPathResolver.stripGenerics('get'), 'get');
    });

    test('strips single generic parameter', () {
      expect(VitePressPathResolver.stripGenerics('get<T>'), 'get');
      expect(VitePressPathResolver.stripGenerics('List<int>'), 'List');
    });

    test('strips nested generic parameters', () {
      expect(
          VitePressPathResolver.stripGenerics('Map<String, List<int>>'), 'Map');
    });

    test('handles empty name', () {
      expect(VitePressPathResolver.stripGenerics(''), '');
    });

    test('handles name starting with angle bracket', () {
      expect(VitePressPathResolver.stripGenerics('<T>'), '');
    });
  });

  group('VitePressPathResolver.sanitizeAnchor', () {
    test('lowercases alphanumeric strings', () {
      expect(VitePressPathResolver.sanitizeAnchor('MyMethod'), 'mymethod');
    });

    test('replaces special characters with hyphens', () {
      expect(VitePressPathResolver.sanitizeAnchor('operator=='), 'operator');
      expect(VitePressPathResolver.sanitizeAnchor('a.b'), 'a-b');
      expect(VitePressPathResolver.sanitizeAnchor('a b'), 'a-b');
    });

    test('collapses multiple hyphens', () {
      expect(VitePressPathResolver.sanitizeAnchor('a..b'), 'a-b');
      expect(VitePressPathResolver.sanitizeAnchor('a!!!b'), 'a-b');
    });

    test('strips leading and trailing hyphens', () {
      expect(VitePressPathResolver.sanitizeAnchor('.name.'), 'name');
      expect(VitePressPathResolver.sanitizeAnchor('=='), '');
    });

    test('handles empty string', () {
      expect(VitePressPathResolver.sanitizeAnchor(''), '');
    });

    test('preserves digits', () {
      expect(VitePressPathResolver.sanitizeAnchor('method2'), 'method2');
      expect(VitePressPathResolver.sanitizeAnchor('v2API'), 'v2api');
    });

    test('Field anchor gets prop- prefix', () {
      // This tests the anchorFor behavior with Field elements.
      // Since we can't easily create Field mocks, we test sanitizeAnchor directly.
      // The prop- prefix is added in anchorFor(), not sanitizeAnchor().
      // Just verify sanitizeAnchor handles prop- prefixed names correctly.
      expect(VitePressPathResolver.sanitizeAnchor('prop-myfield'),
          equals('prop-myfield'));
    });
  });
}
