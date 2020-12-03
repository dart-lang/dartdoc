// Copyright (c) 2020, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/file_system/file_system.dart';
import 'package:analyzer/file_system/memory_file_system.dart';
import 'package:dartdoc/dartdoc.dart';
import 'package:dartdoc/src/generator/generator_frontend.dart';
import 'package:dartdoc/src/generator/html_generator.dart';
import 'package:dartdoc/src/generator/html_resources.g.dart';
import 'package:dartdoc/src/generator/templates.dart';
import 'package:dartdoc/src/package_config_provider.dart';
import 'package:dartdoc/src/package_meta.dart';
import 'package:dartdoc/src/warnings.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

import 'src/utils.dart' as utils;

void main() {
  MemoryResourceProvider resourceProvider;
  p.Context pathContext;

  PackageMetaProvider packageMetaProvider;
  FakePackageConfigProvider packageConfigProvider;

  Templates templates;
  GeneratorFrontEnd generator;
  DartdocFileWriter writer;

  Folder projectRoot;
  String projectPath;

  setUp(() async {
    packageMetaProvider = utils.testPackageMetaProvider;
    resourceProvider = packageMetaProvider.resourceProvider;
    pathContext = resourceProvider.pathContext;
    packageConfigProvider = utils
        .getTestPackageConfigProvider(packageMetaProvider.defaultSdkDir.path);

    templates = await Templates.createDefault('html');
    generator = GeneratorFrontEnd(HtmlGeneratorBackend(null, templates));

    projectRoot = utils.writePackage(
        'my_package', resourceProvider, packageConfigProvider);
    projectPath = projectRoot.path;
    var outputPath = projectRoot.getChildAssumingFolder('doc').path;
    writer = DartdocFileWriter(outputPath, resourceProvider);
  });

  File getConvertedFile(String path) =>
      resourceProvider.getFile(resourceProvider.convertPath(path));

  tearDown(() {
    projectRoot = null;
    projectPath = null;
    clearPackageMetaCache();
  });

  test('a null package has some assets', () async {
    await generator.generate(null, writer);
    var outputPath = projectRoot.getChildAssumingFolder('doc').path;
    var output = resourceProvider
        .getFolder(pathContext.join(outputPath, 'static-assets'));
    expect(output, doesExist);

    for (var resource in resource_names.map((r) =>
        pathContext.relative(Uri.parse(r).path, from: 'dartdoc/resources'))) {
      expect(resourceProvider.getFile(pathContext.join(output.path, resource)),
          doesExist);
    }
  });

  test('libraries with no duplicates are not warned about', () async {
    getConvertedFile('$projectPath/lib/a.dart').writeAsStringSync('library a;');
    getConvertedFile('$projectPath/lib/b.dart').writeAsStringSync('library b;');
    var packageGraph = await utils.bootBasicPackage(
        projectPath, packageMetaProvider, packageConfigProvider);
    await generator.generate(packageGraph, writer);

    expect(packageGraph.packageWarningCounter.errorCount, 0);
  }, onPlatform: {'windows': Skip('Test does not work on Windows (#2446)')});

  test('libraries with duplicate names are warned about', () async {
    getConvertedFile('$projectPath/lib/a.dart').writeAsStringSync('library a;');
    getConvertedFile('$projectPath/lib/b.dart').writeAsStringSync('library a;');
    var packageGraph = await utils.bootBasicPackage(
        projectPath, packageMetaProvider, packageConfigProvider);
    await generator.generate(packageGraph, writer);

    var expectedPath = pathContext.join('a', 'a-library.html');
    expect(
        packageGraph.localPublicLibraries,
        anyElement((l) => packageGraph.packageWarningCounter
            .hasWarning(l, PackageWarning.duplicateFile, expectedPath)));
  }, onPlatform: {'windows': Skip('Test does not work on Windows (#2446)')});

  test('has HTML templates', () async {
    expect(templates.indexTemplate, isNotNull);
    expect(templates.libraryTemplate, isNotNull);
    expect(templates.classTemplate, isNotNull);
    expect(templates.functionTemplate, isNotNull);
    expect(templates.constructorTemplate, isNotNull);
    expect(templates.methodTemplate, isNotNull);
    expect(templates.propertyTemplate, isNotNull);
    expect(templates.topLevelPropertyTemplate, isNotNull);
  }, onPlatform: {'windows': Skip('Test does not work on Windows (#2446)')});
}

const Matcher doesExist = _DoesExist();

class _DoesExist extends Matcher {
  const _DoesExist();
  @override
  bool matches(Object item, Map matchState) => (item as Resource).exists;
  @override
  Description describe(Description description) => description.add('exists');
  @override
  Description describeMismatch(Object item, Description mismatchDescription,
      Map matchState, bool verbose) {
    if (item is! File && item is! Folder) {
      return mismatchDescription
          .addDescriptionOf(item)
          .add('is not a file or directory');
    } else {
      return mismatchDescription.add(' does not exist');
    }
  }
}
