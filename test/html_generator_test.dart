// Copyright (c) 2020, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:convert';

import 'package:analyzer/file_system/file_system.dart';
import 'package:analyzer/file_system/memory_file_system.dart';
import 'package:analyzer_testing/utilities/extensions/resource_provider.dart';
import 'package:dartdoc/src/dartdoc.dart' show DartdocFileWriter;
import 'package:dartdoc/src/dartdoc_options.dart';
import 'package:dartdoc/src/generator/generator.dart';
import 'package:dartdoc/src/generator/generator_backend.dart';
import 'package:dartdoc/src/generator/html_generator_backend.dart';
import 'package:dartdoc/src/generator/html_resources.g.dart';
import 'package:dartdoc/src/generator/templates.dart';
import 'package:dartdoc/src/model/library.dart';
import 'package:dartdoc/src/package_meta.dart';
import 'package:dartdoc/src/warnings.dart';
import 'package:html/parser.dart' as html_parser;
import 'package:path/path.dart' as path;
import 'package:test/test.dart';

import 'src/utils.dart' as utils;

void main() {
  group('HTML generator tests', onPlatform: {
    'windows': Skip('Tests do not work on Windows after NNBD conversion')
  }, () {
    late MemoryResourceProvider resourceProvider;
    late path.Context pathContext;

    late PackageMetaProvider packageMetaProvider;

    final Templates templates = HtmlAotTemplates();
    late Generator generator;

    late Folder projectRoot;
    late String projectPath;

    setUp(() async {
      packageMetaProvider = utils.testPackageMetaProvider;
      resourceProvider =
          packageMetaProvider.resourceProvider as MemoryResourceProvider;
      pathContext = resourceProvider.pathContext;
      await utils.writeDartdocResources(resourceProvider);

      var optionRoot = DartdocOptionRoot.fromOptionGenerators(
          'dartdoc',
          [
            createDartdocOptions,
            createGeneratorOptions,
          ],
          packageMetaProvider);
      optionRoot.parseArguments([]);

      var defaultContext =
          DartdocGeneratorOptionContext.fromDefaultContextLocation(
              optionRoot, resourceProvider);
      var options = DartdocGeneratorBackendOptions.fromContext(defaultContext);
      projectRoot = utils.writePackage('my_package', resourceProvider);
      projectPath = projectRoot.path;
      var outputPath = projectRoot.getFolder('doc').path;
      var writer = DartdocFileWriter(outputPath, resourceProvider);

      generator = Generator(
          HtmlGeneratorBackend(options, templates, writer, resourceProvider));
    });

    File getConvertedFile(String filePath) => resourceProvider.getFile(
        ResourceProviderExtension(resourceProvider).convertPath(filePath));

    tearDown(clearPackageMetaCache);

    test('a null package has some assets', () async {
      await generator.generate(null);
      var outputPath = projectRoot.getFolder('doc').path;
      var output = resourceProvider
          .getFolder(pathContext.join(outputPath, 'static-assets'));
      expect(output, doesExist);

      for (var resource in resourceNames) {
        expect(
            resourceProvider.getFile(pathContext.join(output.path, resource)),
            doesExist);
      }
    });

    test('libraries with no duplicates are not warned about',
        onPlatform: {'windows': Skip('Test does not work on Windows (#2446)')},
        () async {
      getConvertedFile('$projectPath/lib/a.dart')
          .writeAsStringSync('library a;');
      getConvertedFile('$projectPath/lib/b.dart')
          .writeAsStringSync('library b;');
      var packageGraph =
          await utils.bootBasicPackage(projectPath, packageMetaProvider);
      await generator.generate(packageGraph);

      expect(packageGraph.packageWarningCounter.errorCount, 0);
    });

    test('libraries with duplicate names are warned about',
        onPlatform: {'windows': Skip('Test does not work on Windows (#2446)')},
        () async {
      getConvertedFile('$projectPath/lib/a.dart')
          .writeAsStringSync('library a;');
      getConvertedFile('$projectPath/lib/b.dart')
          .writeAsStringSync('library a;');
      var packageGraph =
          await utils.bootBasicPackage(projectPath, packageMetaProvider);
      await generator.generate(packageGraph);

      var expectedPath = pathContext.join('a', 'a-library.html');
      expect(
          packageGraph.localPublicLibraries,
          anyElement((Library l) => packageGraph.packageWarningCounter
              .hasWarning(l, PackageWarning.duplicateFile, expectedPath)));
    });

    test(
        'generated pages link SDK to canonical URLs, defer scripts, and subset Material Symbols icons',
        onPlatform: {
          'windows': Skip('Test does not work on Windows (#2446)')
        }, () async {
      getConvertedFile('$projectPath/lib/a.dart').writeAsStringSync('''
library a;

/// Returns [Future] of [int].
Future<int> fetchCount() async => 0;
''');
      var packageGraph = await utils.bootBasicPackage(
        projectPath,
        packageMetaProvider,
        additionalArguments: ['--link-to-remote'],
      );
      await generator.generate(packageGraph);

      var outputPath = projectRoot.getFolder('doc').path;
      var libDoc = html_parser.parse(
        resourceProvider
            .getFile(pathContext.join(outputPath, 'a', 'fetchCount.html'))
            .readAsStringSync(),
      );
      var stylesCss = utf8.decode(
        base64
            .decode(bundledResourcesBase64['styles.css']!.replaceAll('\n', '')),
      );

      // Default remote Dart SDK links point to unversioned https://api.dart.dev.
      var sdkHrefs = libDoc
          .querySelectorAll('a[href^="https://api.dart.dev/"]')
          .map((a) => a.attributes['href']!)
          .toList();
      expect(
          sdkHrefs, contains('https://api.dart.dev/dart-core/int-class.html'));

      // External scripts are deferred while dark-mode init runs inline first.
      var externalScripts = libDoc.querySelectorAll('script[src]');
      expect(externalScripts, isNotEmpty);
      for (var script in externalScripts) {
        expect(script.attributes.containsKey('defer'), isTrue);
      }
      var firstBodyChild = libDoc.body!.children.first;
      expect(firstBodyChild.localName, 'script');
      expect(firstBodyChild.text, contains('try{'));
      expect(firstBodyChild.text, contains('colorTheme'));

      // Material Symbols stylesheet query parameters stay alphabetically sorted
      // (required by Google Fonts) and cover every template & CSS alert icon.
      var symbolsHref = libDoc
          .querySelectorAll('link[rel="stylesheet"]')
          .map((l) => l.attributes['href'] ?? '')
          .singleWhere((h) => h.contains('Material+Symbols+Outlined'));
      var symbolsUri = Uri.parse(symbolsHref);
      expect(symbolsUri.queryParameters['display'], 'block');
      var iconNames = symbolsUri.queryParameters['icon_names']!.split(',');
      expect(iconNames, orderedEquals([...iconNames]..sort()));

      var templateIcons = {
        for (var el in libDoc.querySelectorAll('.material-symbols-outlined'))
          el.text.trim(),
      };
      var cssAlertIcons = {
        for (var m in RegExp(
          r'markdown-alert-title::?before\{content:"([^"]+)"\}',
        ).allMatches(stylesCss))
          m.group(1)!,
      };
      expect(cssAlertIcons, isNotEmpty);
      expect(iconNames, containsAll({...templateIcons, ...cssAlertIcons}));
    });
  });
}

const Matcher doesExist = _DoesExist();

class _DoesExist extends Matcher {
  const _DoesExist();

  @override
  bool matches(Object? item, Map<Object?, Object?> matchState) =>
      (item as Resource).exists;

  @override
  Description describe(Description description) => description.add('exists');

  @override
  Description describeMismatch(Object? item, Description mismatchDescription,
      Map<Object?, Object?> matchState, bool verbose) {
    if (item is! File && item is! Folder) {
      return mismatchDescription
          .addDescriptionOf(item)
          .add('is not a file or directory');
    } else {
      return mismatchDescription.add(' does not exist');
    }
  }
}
