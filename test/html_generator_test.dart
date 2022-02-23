// Copyright (c) 2020, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/file_system/file_system.dart';
import 'package:analyzer/file_system/memory_file_system.dart';
import 'package:dartdoc/dartdoc.dart' show DartdocFileWriter;
import 'package:dartdoc/options.dart';
import 'package:dartdoc/src/dartdoc_options.dart';
import 'package:dartdoc/src/generator/dartdoc_generator_backend.dart';
import 'package:dartdoc/src/generator/generator.dart';
import 'package:dartdoc/src/generator/generator_frontend.dart';
import 'package:dartdoc/src/generator/html_generator.dart';
import 'package:dartdoc/src/generator/html_resources.g.dart';
import 'package:dartdoc/src/generator/resource_loader.dart';
import 'package:dartdoc/src/generator/templates.dart';
import 'package:dartdoc/src/package_config_provider.dart';
import 'package:dartdoc/src/package_meta.dart';
import 'package:dartdoc/src/warnings.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

import 'src/utils.dart' as utils;

void main() {
  group('HTML generator tests', () {
    late MemoryResourceProvider resourceProvider;
    late p.Context pathContext;

    late PackageMetaProvider packageMetaProvider;
    late FakePackageConfigProvider packageConfigProvider;

    final Templates templates = HtmlAotTemplates();
    late GeneratorFrontEnd generator;
    late DartdocFileWriter writer;

    late Folder projectRoot;
    late String projectPath;

    setUp(() async {
      packageMetaProvider = utils.testPackageMetaProvider;
      resourceProvider =
          packageMetaProvider.resourceProvider as MemoryResourceProvider;
      pathContext = resourceProvider.pathContext;
      packageConfigProvider = utils
          .getTestPackageConfigProvider(packageMetaProvider.defaultSdkDir.path);
      for (var template in [
        '_accessor_getter',
        '_accessor_setter',
        '_callable',
        '_callable_multiline',
        '_categorization',
        '_class',
        '_constant',
        '_documentation',
        '_extension',
        '_features',
        '_feature_set',
        '_footer',
        '_head',
        '_library',
        '_mixin',
        '_name_summary',
        '_packages',
        '_property',
        '_search_sidebar',
        '_sidebar_for_category',
        '_sidebar_for_container',
        '_sidebar_for_library',
        '_source_code',
        '_source_link',
        '_super_chain',
        '_type',
        '_typedef',
        '_type_multiline',
        '_typedef_multiline',
        '404error',
        'category',
        'class',
        'constructor',
        'enum',
        'extension',
        'function',
        'index',
        'library',
        'method',
        'mixin',
        'property',
        'top_level_property',
        'typedef',
      ]) {
        await resourceProvider.writeDartdocResource(
            'templates/html/$template.html', 'CONTENT');
      }

      for (var resource in [
        'favicon.png',
        'github.css',
        'highlight.pack.js',
        'play_button.svg',
        'readme.md',
        'script.js',
        'styles.css',
      ]) {
        await resourceProvider.writeDartdocResource(
            'resources/$resource', 'CONTENT');
      }

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

      generator = GeneratorFrontEnd(
          HtmlGeneratorBackend(options, templates, resourceProvider));

      projectRoot = utils.writePackage(
          'my_package', resourceProvider, packageConfigProvider);
      projectPath = projectRoot.path;
      var outputPath = projectRoot.getChildAssumingFolder('doc').path;
      writer = DartdocFileWriter(outputPath, resourceProvider);
    });

    File getConvertedFile(String path) =>
        resourceProvider.getFile(resourceProvider.convertPath(path));

    tearDown(() {
      clearPackageMetaCache();
    });

    test('a null package has some assets', () async {
      await generator.generate(null, writer);
      var outputPath = projectRoot.getChildAssumingFolder('doc').path;
      var output = resourceProvider
          .getFolder(pathContext.join(outputPath, 'static-assets'));
      expect(output, doesExist);

      for (var resource in resourceNames) {
        expect(
            resourceProvider.getFile(pathContext.join(output.path, resource)),
            doesExist);
      }
    });

    test('libraries with no duplicates are not warned about', () async {
      getConvertedFile('$projectPath/lib/a.dart')
          .writeAsStringSync('library a;');
      getConvertedFile('$projectPath/lib/b.dart')
          .writeAsStringSync('library b;');
      var packageGraph = await utils.bootBasicPackage(
          projectPath, packageMetaProvider, packageConfigProvider);
      await generator.generate(packageGraph, writer);

      expect(packageGraph.packageWarningCounter.errorCount, 0);
    }, onPlatform: {'windows': Skip('Test does not work on Windows (#2446)')});

    test('libraries with duplicate names are warned about', () async {
      getConvertedFile('$projectPath/lib/a.dart')
          .writeAsStringSync('library a;');
      getConvertedFile('$projectPath/lib/b.dart')
          .writeAsStringSync('library a;');
      var packageGraph = await utils.bootBasicPackage(
          projectPath, packageMetaProvider, packageConfigProvider);
      await generator.generate(packageGraph, writer);

      var expectedPath = pathContext.join('a', 'a-library.html');
      expect(
          packageGraph.localPublicLibraries,
          anyElement((l) => packageGraph.packageWarningCounter
              .hasWarning(l, PackageWarning.duplicateFile, expectedPath)));
    }, onPlatform: {'windows': Skip('Test does not work on Windows (#2446)')});
  }, onPlatform: {
    'windows': Skip('Tests do not work on Windows after NNBD conversion')
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

/// Extension methods just for tests.
extension on ResourceProvider {
  Future<void> writeDartdocResource(String path, String content) async {
    var fileUri = await resolveResourceUri(Uri.parse('package:dartdoc/$path'));
    getFile(fileUri.toFilePath()).writeAsStringSync(content);
  }
}
