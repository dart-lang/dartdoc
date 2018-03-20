// Copyright (c) 2015, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library dartdoc.html_generator_test;

import 'dart:io' show File, Directory;

import 'package:dartdoc/src/html/html_generator.dart';
import 'package:dartdoc/src/html/templates.dart';
import 'package:dartdoc/src/html/resources.g.dart';
import 'package:path/path.dart' as pathLib;
import 'package:test/test.dart';

void main() {
  group('Templates', () {
    Templates templates;

    setUp(() async {
      templates = await Templates.create();
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
        generator = await HtmlGenerator.create();
        tempOutput = Directory.systemTemp.createTempSync('doc_test_temp');
        return generator.generate(null, tempOutput.path);
      });

      tearDown(() {
        if (tempOutput != null) {
          tempOutput.deleteSync(recursive: true);
        }
      });

      test('resources are put into the right place', () {
        Directory output =
            new Directory(pathLib.join(tempOutput.path, 'static-assets'));
        expect(output, doesExist);

        for (var resource in resource_names.map((r) =>
            pathLib.relative(Uri.parse(r).path, from: 'dartdoc/resources'))) {
          expect(new File(pathLib.join(output.path, resource)), doesExist);
        }
      });
    });
  });
}

const Matcher doesExist = const _DoesExist();

class _DoesExist extends Matcher {
  const _DoesExist();
  @override
  bool matches(item, Map matchState) => item.existsSync();
  @override
  Description describe(Description description) => description.add('exists');
  @override
  Description describeMismatch(
      item, Description mismatchDescription, Map matchState, bool verbose) {
    if (item is! File && item is! Directory) {
      return mismatchDescription
          .addDescriptionOf(item)
          .add('is not a file or directory');
    } else {
      return mismatchDescription.add(' does not exist');
    }
  }
}
