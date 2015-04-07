// Copyright (c) 2015, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library dartdoc.html_generator_test;

import 'package:unittest/unittest.dart';

import 'package:dartdoc/src/html_generator.dart';

void main() {
  group('Templates', () {
    Templates templates;

    setUp(() {
      templates = new Templates("<p>User inserted message</p>");
    });

    test('index html', () {
      expect(templates.indexTemplate != null, true);
    });

    test('library', () {
      expect(templates.libraryTemplate != null, true);
    });

    test('class', () {
      expect(templates.classTemplate != null, true);
    });

    test('function', () {
      expect(templates.functionTemplate != null, true);
    });

    test('constructor', () {
      expect(templates.constructorTemplate != null, true);
    });

    test('method', () {
      expect(templates.methodTemplate != null, true);
    });

    test('constant', () {
      expect(templates.constantTemplate != null, true);
    });

    test('property', () {
      expect(templates.propertyTemplate != null, true);
    });

    test('top level constant', () {
      expect(templates.topLevelConstantTemplate != null, true);
    });

    test('top level property', () {
      expect(templates.topLevelPropertyTemplate != null, true);
    });

    test('header and footer', () {
      String content = templates.indexTemplate({},
          assumeNullNonExistingProperty: true, errorOnMissingProperty: false);
      expect(content.contains('<p>User inserted message</p>'), true);
    });
  });
}
