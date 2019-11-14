// Copyright (c) 2019, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:dartdoc/src/html/template_render_helper.dart';
import 'package:test/test.dart';

void main() {
  group('HtmlTemplateHelper', () {
    HtmlRenderHelper renderHelper;

    setUpAll(() {
      renderHelper = HtmlRenderHelper();
    });

    test('composeLayoutTitle', () {
      String test = renderHelper.composeLayoutTitle('Banana', 'Fruit', false);
      expect(test, equals('Banana Fruit'));
    });

    test('composeLayoutTitle deprecated', () {
      String test = renderHelper.composeLayoutTitle('Banana', 'Fruit', true);
      expect(test, equals('<span class="deprecated">Banana</span> Fruit'));
    });
  });
}
