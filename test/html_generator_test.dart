// Copyright (c) 2015, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library dartdoc.html_generator_test;

import 'dart:io' show File, Directory;

import 'package:dartdoc/src/html/html_generator.dart';
import 'package:dartdoc/src/html/templates.dart';
import 'package:dartdoc/src/html/resources.g.dart';
import 'package:dartdoc/src/model/package_graph.dart';
import 'package:dartdoc/src/warnings.dart';
import 'package:path/path.dart' as path;
import 'package:test/test.dart';

import 'src/utils.dart' as utils;

void main() {
  group('Templates', () {
    Templates templates;

    setUp(() async {
      templates = await Templates.createDefault();
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
            Directory(path.join(tempOutput.path, 'static-assets'));
        expect(output, doesExist);

        for (var resource in resource_names.map((r) =>
            path.relative(Uri.parse(r).path, from: 'dartdoc/resources'))) {
          expect(File(path.join(output.path, resource)), doesExist);
        }
      });
    });

    group('for a package that causes duplicate files', () {
      HtmlGenerator generator;
      PackageGraph packageGraph;
      Directory tempOutput;

      setUp(() async {
        generator = await HtmlGenerator.create();
        packageGraph = await utils
            .bootBasicPackage(utils.testPackageDuplicateDir.path, []);
        tempOutput = await Directory.systemTemp.createTemp('doc_test_temp');
      });

      tearDown(() {
        if (tempOutput != null) {
          tempOutput.deleteSync(recursive: true);
        }
      });

      test('run generator and verify duplicate file error', () async {
        await generator.generate(packageGraph, tempOutput.path);
        expect(generator, isNotNull);
        expect(tempOutput, isNotNull);
        String expectedPath =
            path.join('aDuplicate', 'aDuplicate-library.html');
        expect(
            packageGraph.localPublicLibraries,
            anyElement((l) => packageGraph.packageWarningCounter
                .hasWarning(l, PackageWarning.duplicateFile, expectedPath)));
      }, timeout: Timeout.factor(4));
    });
  });
}

const Matcher doesExist = _DoesExist();

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
