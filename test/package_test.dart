// Copyright (c) 2020, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/file_system/file_system.dart';
import 'package:analyzer/file_system/memory_file_system.dart';
import 'package:analyzer/src/test_utilities/mock_sdk.dart';
import 'package:dartdoc/src/dartdoc_options.dart';
import 'package:dartdoc/src/model/model.dart';
import 'package:dartdoc/src/package_config_provider.dart';
import 'package:dartdoc/src/package_meta.dart';
import 'package:test/test.dart';

import 'src/utils.dart' as utils;

void main() {
  MemoryResourceProvider resourceProvider;
  MockSdk mockSdk;
  Folder sdkFolder;
  String projectRoot;
  var packageName = 'my_package';
  PackageMetaProvider packageMetaProvider;
  FakePackageConfigProvider packageConfigProvider;
  PackageGraph packageGraph;

  void writeSdk() {
    mockSdk = MockSdk(resourceProvider: resourceProvider);
    sdkFolder = resourceProvider.getFolder(sdkRoot);
    var pathContext = resourceProvider.pathContext;
    resourceProvider.getFolder(sdkRoot).create();
    resourceProvider
        .getFile(pathContext.join(sdkRoot, 'bin', 'dart'))
        .writeAsStringSync('');
    resourceProvider
        .getFile(pathContext.join(sdkRoot, 'bin', 'pub'))
        .writeAsStringSync('');
  }

  void writePackage() {
    var pathContext = resourceProvider.pathContext;
    var projectFolder = resourceProvider
        .getFolder(resourceProvider.convertPath('/projects/$packageName'));
    projectRoot = projectFolder.path;
    projectFolder.create();
    resourceProvider
        .getFile(pathContext.join(projectRoot, 'pubspec.yaml'))
        .writeAsStringSync('''
name: $packageName
''');
    resourceProvider
        .getFile(
            pathContext.join(projectRoot, '.dart_tool', 'package_config.json'))
        .writeAsStringSync('');
    resourceProvider.getFolder(pathContext.join(projectRoot, 'lib')).create();
    packageConfigProvider.addPackageToConfigFor(
        Uri.file(projectRoot), packageName, Uri.file('$projectRoot/'));
  }

  setUp(() async {
    resourceProvider = MemoryResourceProvider();
    writeSdk();

    packageMetaProvider = PackageMetaProvider(
      PubPackageMeta.fromElement,
      PubPackageMeta.fromFilename,
      PubPackageMeta.fromDir,
      resourceProvider,
      sdkFolder,
      defaultSdk: mockSdk,
    );
    var optionSet = await DartdocOptionSet.fromOptionGenerators(
        'dartdoc', [createDartdocOptions], packageMetaProvider);
    optionSet.parseArguments([]);
    packageConfigProvider = FakePackageConfigProvider();
  });

  test('package with no deps has 2 local packages, including SDK', () async {
    writePackage();
    resourceProvider
        .getFile(
            resourceProvider.pathContext.join(projectRoot, 'lib', 'a.dart'))
        .writeAsStringSync('''
/// Documentation comment.
int x;
''');
    packageGraph = await utils.bootBasicPackage(
        projectRoot, [], packageMetaProvider, packageConfigProvider,
        additionalArguments: [
          '--auto-include-dependencies',
          '--no-link-to-remote'
        ]);

    var localPackages = packageGraph.localPackages;
    expect(localPackages, hasLength(2));
    expect(localPackages[0].name, equals(packageName));
    expect(localPackages[1].name, equals('Dart'));
  });

  test('package with no deps has 1 local package, excluding SDK', () async {
    writePackage();
    resourceProvider
        .getFile(
            resourceProvider.pathContext.join(projectRoot, 'lib', 'a.dart'))
        .writeAsStringSync('''
/// Documentation comment.
int x;
''');
    packageGraph = await utils.bootBasicPackage(
        projectRoot, [], packageMetaProvider, packageConfigProvider,
        additionalArguments: ['--no-link-to-remote']);

    var localPackages = packageGraph.localPackages;
    expect(localPackages, hasLength(1));
    expect(localPackages[0].name, equals(packageName));
  });

  test('package with no doc comments has no docs', () async {
    writePackage();
    resourceProvider
        .getFile(
            resourceProvider.pathContext.join(projectRoot, 'lib', 'a.dart'))
        .writeAsStringSync('''
// No documentation comment.
int x;
''');
    packageGraph = await utils.bootBasicPackage(
        projectRoot, [], packageMetaProvider, packageConfigProvider);

    expect(packageGraph.defaultPackage.hasDocumentation, isFalse);
    expect(packageGraph.defaultPackage.hasDocumentationFile, isFalse);
    expect(packageGraph.defaultPackage.documentationFile, isNull);
    expect(packageGraph.defaultPackage.documentation, isNull);
  });

  test('package with no doc comments has no categories', () async {
    writePackage();
    resourceProvider
        .getFile(
            resourceProvider.pathContext.join(projectRoot, 'lib', 'a.dart'))
        .writeAsStringSync('''
// No documentation comment.
int x;
''');
    packageGraph = await utils.bootBasicPackage(
        projectRoot, [], packageMetaProvider, packageConfigProvider);

    expect(packageGraph.localPackages.first.hasCategories, isFalse);
    expect(packageGraph.localPackages.first.categories, isEmpty);
  });
}
