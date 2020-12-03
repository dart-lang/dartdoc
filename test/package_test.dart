// Copyright (c) 2020, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/file_system/file_system.dart';
import 'package:analyzer/file_system/memory_file_system.dart';
import 'package:dartdoc/src/dartdoc_options.dart';
import 'package:dartdoc/src/model/documentable.dart';
import 'package:dartdoc/src/package_config_provider.dart';
import 'package:dartdoc/src/package_meta.dart';
import 'package:dartdoc/src/special_elements.dart';
import 'package:test/test.dart';

import 'src/utils.dart' as utils;

void main() {
  MemoryResourceProvider resourceProvider;
  PackageMetaProvider packageMetaProvider;
  FakePackageConfigProvider packageConfigProvider;
  DartdocOptionSet optionSet;
  Folder sdkFolder;

  Folder projectRoot;
  String projectPath;
  var packageName = 'my_package';

  void writeToJoinedPath(List<String> pathSegments, String content) {
    var file = pathSegments.removeAt(pathSegments.length - 1);
    var directory = projectRoot;
    for (var d in pathSegments) {
      directory = directory.getChildAssumingFolder(d);
    }
    directory.getChildAssumingFile(file).writeAsStringSync(content);
  }

  setUp(() async {
    packageMetaProvider = utils.testPackageMetaProvider;
    resourceProvider = packageMetaProvider.resourceProvider;
    sdkFolder = packageMetaProvider.defaultSdkDir;

    optionSet = await DartdocOptionSet.fromOptionGenerators(
        'dartdoc', [createDartdocOptions], packageMetaProvider);
    packageConfigProvider = utils.getTestPackageConfigProvider(sdkFolder.path);
  });

  tearDown(() {
    projectRoot = null;
    projectPath = null;
    clearPackageMetaCache();
  });

  group('tests', () {
    group('typical package', () {
      setUp(() {
        optionSet.parseArguments([]);
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
        var library =
            packageGraph.libraries.firstWhere((lib) => lib.name == 'a');
        expect(library.isDocumented, true);
      });

      test('has anonymous libraries', () async {
        writeToJoinedPath(['lib', 'b.dart'], '''
/// Documentation comment.
int x;
''');
        var packageGraph = await utils.bootBasicPackage(
            projectPath, packageMetaProvider, packageConfigProvider);
        expect(packageGraph.libraries.where((lib) => lib.name == 'b'),
            hasLength(1));
      });

      test('has documentation via Markdown README', () async {
        writeToJoinedPath(['README.md'], 'Readme text.');
        var packageGraph = await utils.bootBasicPackage(
            projectPath, packageMetaProvider, packageConfigProvider);
        expect(packageGraph.defaultPackage.hasDocumentationFile, true);
        expect(packageGraph.defaultPackage.hasDocumentation, true);
      });

      test('has documentation via text README', () async {
        writeToJoinedPath(['README'], 'Readme text.');
        var packageGraph = await utils.bootBasicPackage(
            projectPath, packageMetaProvider, packageConfigProvider);
        expect(packageGraph.defaultPackage.hasDocumentationFile, true);
        expect(packageGraph.defaultPackage.hasDocumentation, true);
      });

      test('has documentation content', () async {
        writeToJoinedPath(['README.md'], 'Readme text.');
        var packageGraph = await utils.bootBasicPackage(
            projectPath, packageMetaProvider, packageConfigProvider);
        expect(
            packageGraph.defaultPackage.documentation, equals('Readme text.'));
      });

      test('has documentation content rendered as HTML', () async {
        writeToJoinedPath(['README.md'], 'Readme text.');
        var packageGraph = await utils.bootBasicPackage(
            projectPath, packageMetaProvider, packageConfigProvider);
        expect(packageGraph.defaultPackage.documentationAsHtml,
            equals('<p>Readme text.</p>'));
      });
    });

    test('documents single explicitly included library', () async {
      optionSet.parseArguments([]);
      projectRoot = utils.writePackage(
          packageName, resourceProvider, packageConfigProvider);
      projectPath = projectRoot.path;
      writeToJoinedPath(['lib', 'foo.dart'], '''
/// Documentation comment.
library foo;
''');
      writeToJoinedPath(['lib', 'bar.dart'], '''
/// Documentation comment.
library bar;
''');
      var packageGraph = await utils.bootBasicPackage(
          projectPath, packageMetaProvider, packageConfigProvider,
          additionalArguments: ['--include', 'foo']);

      expect(packageGraph.localPublicLibraries, hasLength(1));
      expect(packageGraph.localPublicLibraries.single.name, equals('foo'));
    });

    test('documents multiple explicitly included libraries', () async {
      optionSet.parseArguments(['--include', 'foo', '--include', 'bar']);
      projectRoot = utils.writePackage(
          packageName, resourceProvider, packageConfigProvider);
      projectPath = projectRoot.path;
      writeToJoinedPath(['lib', 'foo.dart'], '''
/// Documentation comment.
library foo;
''');
      writeToJoinedPath(['lib', 'bar.dart'], '''
/// Documentation comment.
library bar;
''');
      writeToJoinedPath(['lib', 'baz.dart'], '''
/// Documentation comment.
library baz;
''');
      var packageGraph = await utils.bootBasicPackage(
          projectPath, packageMetaProvider, packageConfigProvider,
          additionalArguments: ['--include', 'foo', '--include', 'bar']);

      var documentedLibraries = packageGraph.localPublicLibraries;
      expect(documentedLibraries, hasLength(2));
      expect(
          documentedLibraries.map((e) => e.name), containsAll(['foo', 'bar']));
      expect(documentedLibraries.map((e) => e.name), contains('bar'));
    });

    test('excludes single explicitly excluded library', () async {
      optionSet.parseArguments([]);
      projectRoot = utils.writePackage(
          packageName, resourceProvider, packageConfigProvider);
      projectPath = projectRoot.path;
      writeToJoinedPath(['lib', 'foo.dart'], '''
/// Documentation comment.
library foo;
''');
      writeToJoinedPath(['lib', 'bar.dart'], '''
/// Documentation comment.
library bar;
''');
      var packageGraph = await utils.bootBasicPackage(
          projectPath, packageMetaProvider, packageConfigProvider,
          additionalArguments: ['--exclude', 'foo']);

      expect(packageGraph.localPublicLibraries, hasLength(1));
      expect(packageGraph.localPublicLibraries.single.name, equals('bar'));
    });

    group('using --link-to-remote', () {
      Folder packageOneRoot;
      Folder packageTwoRoot;

      setUp(() {
        optionSet.parseArguments(['--link-to-remote']);
        packageOneRoot =
            utils.writePackage('one', resourceProvider, packageConfigProvider);
        packageOneRoot
            .getChildAssumingFolder('lib')
            .getChildAssumingFile('one.dart')
            .writeAsStringSync('''
/// Documentation comment.
library one;

class One {}
''');
        packageOneRoot.getChildAssumingFolder('bin').create();
        packageOneRoot
            .getChildAssumingFolder('bin')
            .getChildAssumingFile('script.dart')
            .writeAsStringSync('''
/// Documentation comment.
library script;

class Script {}
''');

        packageTwoRoot =
            utils.writePackage('two', resourceProvider, packageConfigProvider);
        packageConfigProvider.addPackageToConfigFor(
            packageTwoRoot.path, 'one', Uri.file('${packageOneRoot.path}/'));
        packageTwoRoot
            .getChildAssumingFolder('lib')
            .getChildAssumingFile('two.dart')
            .writeAsStringSync('''
/// Documentation comment.
library two;
import 'package:one/one.dart';

class Two extends One {}
''');
      });

      test('includes remote elements when linkTo -> url is specified',
          () async {
        packageOneRoot
            .getChildAssumingFile('dartdoc_options.yaml')
            .writeAsStringSync('''
dartdoc:
  linkTo:
    url: 'https://mypub.topdomain/%n%/%v%'
''');
        var packageGraph = await utils.bootBasicPackage(
            packageTwoRoot.path, packageMetaProvider, packageConfigProvider,
            additionalArguments: ['--link-to-remote']);

        expect(packageGraph.packages, hasLength(3));
        var packageOne =
            packageGraph.packages.singleWhere((p) => p.name == 'one');
        // TODO(srawlins): Why is there more than one?
        var libraryOne =
            packageOne.allLibraries.lastWhere((l) => l.name == 'one');
        var classOne = libraryOne.allClasses.firstWhere((c) => c.name == 'One');
        expect(packageOne.documentedWhere, equals(DocumentLocation.remote));
        expect(classOne.href,
            equals('https://mypub.topdomain/one/0.0.1/one/One-class.html'));
      });

      test(
          'does not include remote elements when linkTo -> url is not specified',
          () async {
        var packageGraph = await utils.bootBasicPackage(
            packageTwoRoot.path, packageMetaProvider, packageConfigProvider,
            additionalArguments: ['--link-to-remote']);

        expect(packageGraph.packages, hasLength(3));
        var packageOne =
            packageGraph.packages.singleWhere((p) => p.name == 'one');
        expect(packageOne.documentedWhere, equals(DocumentLocation.missing));
      });

      test(
          'includes external remote elements when includeExternal is specified',
          () async {
        packageOneRoot
            .getChildAssumingFile('dartdoc_options.yaml')
            .writeAsStringSync('''
dartdoc:
  includeExternal:
    - bin/script.dart
  linkTo:
    url: 'https://mypub.topdomain/%n%/%v%'
''');
        var packageGraph = await utils.bootBasicPackage(
            packageTwoRoot.path, packageMetaProvider, packageConfigProvider,
            additionalArguments: ['--link-to-remote']);

        expect(packageGraph.packages, hasLength(3));
        var packageOne =
            packageGraph.packages.singleWhere((p) => p.name == 'one');
        expect(packageOne.documentedWhere, equals(DocumentLocation.remote));
        // TODO(srawlins): Why is there more than one?
        var libraryScript =
            packageOne.allLibraries.singleWhere((l) => l.name == 'script');
        var classScript =
            libraryScript.allClasses.singleWhere((c) => c.name == 'Script');
        expect(
            classScript.href,
            equals(
                'https://mypub.topdomain/one/0.0.1/script/Script-class.html'));
      });
    });

    group('SDK package', () {
      setUp(() {
        optionSet.parseArguments([]);
      });

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

        var pragmaModelElement =
            packageGraph.specialClasses[SpecialClass.pragma];
        expect(pragmaModelElement.name, equals('pragma'));
      });
    });

    group('using default options', () {
      setUp(() {
        optionSet.parseArguments([]);
      });

      test('package with no version has a default version', () async {
        projectRoot = utils.writePackage(
            packageName, resourceProvider, packageConfigProvider,
            pubspecContent: '''
name: $packageName
''');
        projectPath = projectRoot.path;
        var packageGraph = await utils.bootBasicPackage(
            projectPath, packageMetaProvider, packageConfigProvider);

        expect(packageGraph.defaultPackage.version, equals('0.0.0-unknown'));
      });

      test('package with no doc comments has no docs', () async {
        projectRoot = utils.writePackage(
            packageName, resourceProvider, packageConfigProvider);
        projectPath = projectRoot.path;
        writeToJoinedPath(['lib', 'a.dart'], '''
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
        writeToJoinedPath(['lib', 'a.dart'], '''
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
        writeToJoinedPath(['lib', 'a.dart'], '''
// No documentation comment.
int x;
''');
        var packageGraph = await utils.bootBasicPackage(
            projectPath, packageMetaProvider, packageConfigProvider);

        expect(packageGraph.localPackages.first.hasCategories, isFalse);
        expect(packageGraph.localPackages.first.categories, isEmpty);
      });
    });
  }, onPlatform: {'windows': Skip('Test does not work on Windows (#2446)')});
}
