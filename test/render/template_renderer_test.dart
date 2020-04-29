// Copyright (c) 2019, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:dartdoc/src/render/template_renderer.dart';
import 'package:test/test.dart';

void main() {
  group('HtmlTemplateRenderer', () {
    HtmlTemplateRenderer renderer;

    setUpAll(() {
      renderer = HtmlTemplateRenderer();
    });

    test('composeLayoutTitle', () {
      var test = renderer.composeLayoutTitle('Banana', 'Fruit', false);
      expect(test, equals('Banana Fruit'));
    });

    test('composeLayoutTitle deprecated', () {
      var test = renderer.composeLayoutTitle('Banana', 'Fruit', true);
      expect(test, equals('<span class="deprecated">Banana</span> Fruit'));
    });
  });

  group('MdTemplateRenderer', () {
    MdTemplateRenderer renderer;

    setUpAll(() {
      renderer = MdTemplateRenderer();
    });

    test('composeLayoutTitle', () {
      var test = renderer.composeLayoutTitle('Banana', 'Fruit', false);
      expect(test, equals('Banana Fruit'));
    });

    test('composeLayoutTitle deprecated', () {
      var test = renderer.composeLayoutTitle('Banana', 'Fruit', true);
      expect(test, equals('~~Banana~~ Fruit'));
    });
  });
}
