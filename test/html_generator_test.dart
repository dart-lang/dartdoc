// Copyright (c) 2015, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library dartdoc.html_generator_test;

import 'dart:io' show File, Directory, FileSystemEntity, FileSystemEntityType;

import 'package:path/path.dart' as p;
import 'package:test/test.dart';
import 'package:dartdoc/src/html_generator.dart';

void main() {
  group('Templates', () {
    Templates templates;

    setUp(() async {
      templates = new Templates(null, null);
      await templates.init();
    });

    test('index html', () {
      expect(templates.indexTemplate, isNotNull);
    });

    test('library', () {
      expect(templates.libraryTemplate, isNotNull);
    });

    test('class', () {
      expect(templates.classTemplate, isNotNull);
    });

    test('function', () {
      expect(templates.functionTemplate, isNotNull);
    });

    test('constructor', () {
      expect(templates.constructorTemplate, isNotNull);
    });

    test('method', () {
      expect(templates.methodTemplate, isNotNull);
    });

    test('constant', () {
      expect(templates.constantTemplate, isNotNull);
    });

    test('property', () {
      expect(templates.propertyTemplate, isNotNull);
    });

    test('top level constant', () {
      expect(templates.topLevelConstantTemplate, isNotNull);
    });

    test('top level property', () {
      expect(templates.topLevelPropertyTemplate, isNotNull);
    });

    test('header and footer', () {
      String content = templates.indexTemplate({},
          assumeNullNonExistingProperty: true, errorOnMissingProperty: false);
      expect(content.contains('<p>User inserted message</p>'), isFalse);
    });
  });

  group('HtmlGenerator', () {
    // TODO: Run the HtmlGenerator and validate important constraints.
    group('for a null package', () {
      HtmlGenerator generator;
      Directory tempOutput;

      setUp(() async {
        generator = new HtmlGenerator(null);
        tempOutput = Directory.systemTemp.createTempSync('doc_test_temp');
        return generator.generate(null, tempOutput);
      });

      tearDown(() {
        if (tempOutput != null) {
          tempOutput.deleteSync(recursive: true);
        }
      });

      test('resources are put into the right place', () {
        Directory output =
            new Directory(p.join(tempOutput.path, 'static-assets'));
        expect(output.existsSync(), isTrue);
        new Directory(p.join('lib', 'resources'))
            .listSync(recursive: true)
            .forEach((FileSystemEntity f) {
          if (f.statSync().type == FileSystemEntityType.FILE) {
            String subPath =
                f.path.substring(p.join('lib', 'resources').length + 1);
            expect(new File(p.join(output.path, subPath)).existsSync(), isTrue);
          }
        });
      });
    });
  });
}
