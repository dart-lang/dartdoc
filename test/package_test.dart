// Copyright (c) 2020, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/file_system/file_system.dart';
import 'package:analyzer/file_system/memory_file_system.dart';
import 'package:analyzer/src/test_utilities/mock_sdk.dart';
import 'package:dartdoc/src/dartdoc_options.dart';
import 'package:dartdoc/src/package_config_provider.dart';
import 'package:dartdoc/src/package_meta.dart';
import 'package:dartdoc/src/special_elements.dart';
import 'package:test/test.dart';

import 'src/utils.dart' as utils;

void main() {
  MemoryResourceProvider resourceProvider;
  MockSdk mockSdk;
  Folder sdkFolder;

  Folder projectRoot;
  String projectPath;
  var packageName = 'my_package';
  PackageMetaProvider packageMetaProvider;
  FakePackageConfigProvider packageConfigProvider;

  setUp(() async {
    resourceProvider = MemoryResourceProvider();
    mockSdk = MockSdk(resourceProvider: resourceProvider);
    sdkFolder = utils.writeMockSdkFiles(mockSdk);

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
    // To build the package graph, we always ask package_config for a
    // [PackageConfig] for the SDK directory. Put a dummy entry in.
    packageConfigProvider.addPackageToConfigFor(
        sdkFolder.path, 'analyzer', Uri.file('/sdk/pkg/analyzer/'));
  });

  tearDown(() {
    projectRoot = null;
    projectPath = null;
    clearPackageMetaCache();
  });

  group('typical package', () {
    setUp(() {
      projectRoot = utils.writePackage(
          packageName, resourceProvider, packageConfigProvider);
      projectPath = projectRoot.path;
      projectRoot
          .getChildAssumingFolder('lib')
          .getChildAssumingFile('a.dart')
          .writeAsStringSync('''
/// Documentation comment.
int x;
''');
    });

    test('with no deps has 2 local packages, including SDK', () async {
      var packageGraph = await utils.bootBasicPackage(
          projectPath, packageMetaProvider, packageConfigProvider,
          additionalArguments: [
            '--auto-include-dependencies',
            '--no-link-to-remote'
          ]);

      var localPackages = packageGraph.localPackages;
      expect(localPackages, hasLength(2));
      expect(localPackages[0].name, equals(packageName));
      expect(localPackages[1].name, equals('Dart'));
    });

    test('with no deps has 1 local package, excluding SDK', () async {
      var packageGraph = await utils.bootBasicPackage(
          projectPath, packageMetaProvider, packageConfigProvider,
          additionalArguments: ['--no-link-to-remote']);

      var localPackages = packageGraph.localPackages;
      expect(localPackages, hasLength(1));
      expect(localPackages[0].name, equals(packageName));
    });

    test('has proper name and kind', () async {
      var packageGraph = await utils.bootBasicPackage(
          projectPath, packageMetaProvider, packageConfigProvider);

      var package = packageGraph.defaultPackage;
      expect(package.name, equals('my_package'));
      expect(package.kind, equals('package'));
    });

    test('has public libraries', () async {
      var packageGraph = await utils.bootBasicPackage(
          projectPath, packageMetaProvider, packageConfigProvider);

      expect(packageGraph.localPublicLibraries, hasLength(1));
    });

    test('has private libraries', () async {
      var packageGraph = await utils.bootBasicPackage(
          projectPath, packageMetaProvider, packageConfigProvider);
      var interceptorsLib = packageGraph.libraries
          .firstWhere((lib) => lib.name == 'dart:_interceptors');

      expect(interceptorsLib.isPublic, isFalse);
    });

    test('has a homepage', () async {
      var packageGraph = await utils.bootBasicPackage(
          projectPath, packageMetaProvider, packageConfigProvider);

      expect(packageGraph.defaultPackage.hasHomepage, isTrue);
      expect(packageGraph.defaultPackage.homepage,
          equals('https://github.com/dart-lang'));
    });

    test('has a public library', () async {
      var packageGraph = await utils.bootBasicPackage(
          projectPath, packageMetaProvider, packageConfigProvider);
      var library = packageGraph.libraries.firstWhere((lib) => lib.name == 'a');
      expect(library.isDocumented, true);
    });

    test('has anonymous libraries', () async {
      projectRoot
          .getChildAssumingFolder('lib')
          .getChildAssumingFile('b.dart')
          .writeAsStringSync('''
/// Documentation comment.
int x;
''');
      var packageGraph = await utils.bootBasicPackage(
          projectPath, packageMetaProvider, packageConfigProvider);
      expect(
          packageGraph.libraries.where((lib) => lib.name == 'b'), hasLength(1));
    });

    test('has documentation via Markdown README', () async {
      projectRoot
          .getChildAssumingFile('README.md')
          .writeAsStringSync('Readme text.');
      var packageGraph = await utils.bootBasicPackage(
          projectPath, packageMetaProvider, packageConfigProvider);
      expect(packageGraph.defaultPackage.hasDocumentationFile, true);
      expect(packageGraph.defaultPackage.hasDocumentation, true);
    });

    test('has documentation via text README', () async {
      projectRoot
          .getChildAssumingFile('README')
          .writeAsStringSync('Readme text.');
      var packageGraph = await utils.bootBasicPackage(
          projectPath, packageMetaProvider, packageConfigProvider);
      expect(packageGraph.defaultPackage.hasDocumentationFile, true);
      expect(packageGraph.defaultPackage.hasDocumentation, true);
    });

    test('has documentation content', () async {
      projectRoot
          .getChildAssumingFile('README.md')
          .writeAsStringSync('Readme text.');
      var packageGraph = await utils.bootBasicPackage(
          projectPath, packageMetaProvider, packageConfigProvider);
      expect(packageGraph.defaultPackage.documentation, equals('Readme text.'));
    });

    test('has documentation content rendered as HTML', () async {
      projectRoot
          .getChildAssumingFile('README.md')
          .writeAsStringSync('Readme text.');
      var packageGraph = await utils.bootBasicPackage(
          projectPath, packageMetaProvider, packageConfigProvider);
      expect(packageGraph.defaultPackage.documentationAsHtml,
          equals('<p>Readme text.</p>'));
    });
  });

  group('SDK package', () {
    test('has proper name and kind', () async {
      var packageGraph = await utils.bootBasicPackage(
          sdkFolder.path, packageMetaProvider, packageConfigProvider,
          additionalArguments: [
            '--input',
            packageMetaProvider.defaultSdkDir.path,
          ]);

      var sdkPackage = packageGraph.defaultPackage;
      expect(sdkPackage.name, equals('Dart'));
      expect(sdkPackage.kind, equals('SDK'));
    });

    test('has a homepage', () async {
      var packageGraph = await utils.bootBasicPackage(
          sdkFolder.path, packageMetaProvider, packageConfigProvider,
          additionalArguments: [
            '--input',
            packageMetaProvider.defaultSdkDir.path,
          ]);

      var sdkPackage = packageGraph.defaultPackage;
      expect(sdkPackage.hasHomepage, isTrue);
      expect(sdkPackage.homepage, equals('https://github.com/dart-lang/sdk'));
    });

    test('has a version', () async {
      var packageGraph = await utils.bootBasicPackage(
          sdkFolder.path, packageMetaProvider, packageConfigProvider,
          additionalArguments: [
            '--input',
            packageMetaProvider.defaultSdkDir.path,
          ]);

      var sdkPackage = packageGraph.defaultPackage;
      expect(sdkPackage.version, isNotNull);
    });

    test('has a description', () async {
      var packageGraph = await utils.bootBasicPackage(
          sdkFolder.path, packageMetaProvider, packageConfigProvider,
          additionalArguments: [
            '--input',
            packageMetaProvider.defaultSdkDir.path,
          ]);

      var sdkPackage = packageGraph.defaultPackage;
      expect(sdkPackage.documentation, startsWith('Welcome'));
    });

    test('Pragma is hidden in docs', () async {
      var packageGraph = await utils.bootBasicPackage(
          sdkFolder.path, packageMetaProvider, packageConfigProvider,
          additionalArguments: [
            '--input',
            packageMetaProvider.defaultSdkDir.path,
          ]);

      var pragmaModelElement = packageGraph.specialClasses[SpecialClass.pragma];
      expect(pragmaModelElement.name, equals('pragma'));
    });
  });

  test('package with no doc comments has no docs', () async {
    projectRoot = utils.writePackage(
        packageName, resourceProvider, packageConfigProvider);
    projectPath = projectRoot.path;
    projectRoot
        .getChildAssumingFolder('lib')
        .getChildAssumingFile('a.dart')
        .writeAsStringSync('''
// No documentation comment.
int x;
''');
    var packageGraph = await utils.bootBasicPackage(
        projectPath, packageMetaProvider, packageConfigProvider);

    expect(packageGraph.defaultPackage.hasDocumentation, isFalse);
    expect(packageGraph.defaultPackage.hasDocumentationFile, isFalse);
    expect(packageGraph.defaultPackage.documentationFile, isNull);
    expect(packageGraph.defaultPackage.documentation, isNull);
  });

  test('package with no homepage in the pubspec has no homepage', () async {
    projectRoot = utils.writePackage(
        packageName, resourceProvider, packageConfigProvider,
        pubspecContent: '''
name: $packageName
version: 0.0.1
''');
    projectPath = projectRoot.path;
    projectRoot
        .getChildAssumingFolder('lib')
        .getChildAssumingFile('a.dart')
        .writeAsStringSync('''
/// Documentation comment.
int x;
''');
    var packageGraph = await utils.bootBasicPackage(
        projectPath, packageMetaProvider, packageConfigProvider);

    expect(packageGraph.defaultPackage.hasHomepage, isFalse);
  });

  test('package with no doc comments has no categories', () async {
    projectRoot = utils.writePackage(
        packageName, resourceProvider, packageConfigProvider);
    projectPath = projectRoot.path;
    projectRoot
        .getChildAssumingFolder('lib')
        .getChildAssumingFile('a.dart')
        .writeAsStringSync('''
// No documentation comment.
int x;
''');
    var packageGraph = await utils.bootBasicPackage(
        projectPath, packageMetaProvider, packageConfigProvider);

    expect(packageGraph.localPackages.first.hasCategories, isFalse);
    expect(packageGraph.localPackages.first.categories, isEmpty);
  });
}
