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

  /// Dartdoc has a few indicator files it uses to verify that a directory
  /// represents a Dart SDK. These include "bin/dart" and "bin/pub".
  void writeSdkBinFiles(Folder root) {
    var sdkBinFolder = root.getChildAssumingFolder('bin');
    sdkBinFolder.getChildAssumingFile('dart').writeAsStringSync('');
    sdkBinFolder.getChildAssumingFile('pub').writeAsStringSync('');
  }

  void writeSdk() {
    mockSdk = MockSdk(resourceProvider: resourceProvider);
    // The [MockSdk] only works in non-canonicalized paths, which include
    // "C:\sdk", on Windows. Howerver, dartdoc works almost exclusively with
    // canonical paths ("c:\sdk"). Copy all MockSdk files to the canonicalized
    // path.
    for (var l in mockSdk.sdkLibraries) {
      var p = l.path;
      resourceProvider
          .getFile(resourceProvider.pathContext.canonicalize(p))
          .writeAsStringSync(resourceProvider.getFile(p).readAsStringSync());
    }
    sdkFolder = resourceProvider.getFolder(resourceProvider.pathContext
        .canonicalize(resourceProvider.convertPath(sdkRoot)))
      ..create();
    sdkFolder.getChildAssumingFile('version').writeAsStringSync('2.9.0');

    writeSdkBinFiles(sdkFolder);
    writeSdkBinFiles(
        resourceProvider.getFolder(resourceProvider.convertPath(sdkRoot)));
  }

  void writePackage() {
    var pathContext = resourceProvider.pathContext;
    var projectsFolder = resourceProvider.getFolder(
        pathContext.canonicalize(resourceProvider.convertPath('/projects')));
    var projectFolder = projectsFolder.getChildAssumingFolder(packageName)
      ..create;
    projectRoot = projectFolder.path;
    projectFolder.getChildAssumingFile('pubspec.yaml').writeAsStringSync('''
name: $packageName
version: 0.0.1
''');
    projectFolder
        .getChildAssumingFolder('.dart_tool')
        .getChildAssumingFile('package_config.json')
        .writeAsStringSync('');
    projectFolder.getChildAssumingFolder('lib').create();
    packageConfigProvider.addPackageToConfigFor(
        projectRoot, packageName, Uri.file('$projectRoot/'));
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

  test('package with no README has no homepage', () async {
    writePackage();
    resourceProvider
        .getFile(
            resourceProvider.pathContext.join(projectRoot, 'lib', 'a.dart'))
        .writeAsStringSync('''
/// Documentation comment.
int x;
''');
    packageGraph = await utils.bootBasicPackage(
        projectRoot, [], packageMetaProvider, packageConfigProvider);

    expect(packageGraph.defaultPackage.hasHomepage, isFalse);
    expect(packageGraph.localPublicLibraries, hasLength(1));
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
