// Copyright (c) 2015, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library dartdoc.dartdoc_test;

import 'dart:async';
import 'dart:io';

import 'package:dartdoc/dartdoc.dart';
import 'package:dartdoc/src/model.dart';
import 'package:dartdoc/src/tuple.dart';
import 'package:dartdoc/src/warnings.dart';
import 'package:path/path.dart' as pathLib;
import 'package:test/test.dart';

import 'src/utils.dart';

void main() {
  group('dartdoc with generators', () {
    Directory tempDir;
    List<String> outputParam;
    setUp(() {
      tempDir = Directory.systemTemp.createTempSync('dartdoc.test.');
      outputParam = ['--output', tempDir.path];
    });

    tearDown(() {
      delete(tempDir);
    });

    Future<Dartdoc> buildDartdoc(
        List<String> argv, Directory packageRoot) async {
      return await Dartdoc.withDefaultGenerators(await generatorContextFromArgv(
          argv..addAll(['--input', packageRoot.path])..addAll(outputParam)));
    }

    group('Option handling', () {
      Dartdoc dartdoc;
      DartdocResults results;
      PackageGraph p;

      setUp(() async {
        dartdoc = await buildDartdoc([], testPackageOptions);
        results = await dartdoc.generateDocsBase();
        p = results.packageGraph;
      });

      test('generator parameters', () async {
        File favicon = new File(pathLib.joinAll([tempDir.path, 'static-assets', 'favicon.png']));
        File index = new File(pathLib.joinAll([tempDir.path, 'index.html']));
        expect(favicon.readAsStringSync(), contains('Not really a png, but a test file'));
        String indexString = index.readAsStringSync();
        expect(indexString, contains('Footer things'));
        expect(indexString, contains('footer.txt data'));
        expect(indexString, contains('HTML header file'));
      });

      test('examplePathPrefix', () async {
        Class UseAnExampleHere = p.allCanonicalModelElements.firstWhere((ModelElement c) => c.name == 'UseAnExampleHere');
        expect(UseAnExampleHere.documentationAsHtml, contains('An example of an example in an unusual example location.'));
      });

      test('includeExternal and showUndocumentedCategories', () async {
        Class Something = p.allCanonicalModelElements.firstWhere((ModelElement c) => c.name == 'Something');
        expect(Something.isPublic, isTrue);
        expect(Something.displayedCategories, isNotEmpty);
      });
    });

    group('Option handling with cross-linking', () {
      DartdocResults results;
      Package testPackageOptions;

      setUp(() async {
        results = await (await buildDartdoc(['--link-to-remote'], testPackageOptionsImporter)).generateDocsBase();
        testPackageOptions = results.packageGraph.packages.firstWhere((Package p) => p.name == 'test_package_options');
      });

      test('linkToUrl', () async {
        Library main = testPackageOptions.allLibraries.firstWhere((Library l) => l.name == 'main');
        Class UseAnExampleHere = main.allClasses.firstWhere((Class c) => c.name == 'UseAnExampleHere');
        expect(testPackageOptions.documentedWhere, equals(DocumentLocation.remote));
        expect(UseAnExampleHere.href, equals('https://nonexistingsuperpackage.topdomain/test_package_options/0.0.1/main/UseAnExampleHere-class.html'));
      });

      test('includeExternal works via remote', () async {
        Library unusualLibrary = testPackageOptions.allLibraries.firstWhere((Library l) => l.name == 'unusualLibrary');
        expect(unusualLibrary.allClasses.firstWhere((Class c) => c.name == 'Something'), isNotNull);
      });
    });

    test('with broken reexport chain', () async {
      Dartdoc dartdoc = await buildDartdoc([], testPackageImportExportError);
      DartdocResults results = await dartdoc.generateDocsBase();
      PackageGraph p = results.packageGraph;
      Iterable<String> unresolvedExportWarnings = p
          .packageWarningCounter.countedWarnings.values
          .expand<String>((Set<Tuple2<PackageWarning, String>> s) => s
              .where((Tuple2<PackageWarning, String> t) =>
                  t.item1 == PackageWarning.unresolvedExport)
              .map<String>((Tuple2<PackageWarning, String> t) => t.item2));

      expect(unresolvedExportWarnings.length, equals(1));
      expect(unresolvedExportWarnings.first,
          equals('"package:not_referenced_in_pubspec/library3.dart"'));
    });

    group('include/exclude parameters', () {
      test('with config file', () async {
        Dartdoc dartdoc = await buildDartdoc([], testPackageIncludeExclude);
        DartdocResults results = await dartdoc.generateDocs();
        PackageGraph p = results.packageGraph;
        expect(p.localPublicLibraries.map((l) => l.name),
            orderedEquals(['explicitly_included', 'more_included']));
      });

      test('with include command line argument', () async {
        Dartdoc dartdoc = await buildDartdoc(
            ['--include', 'another_included'], testPackageIncludeExclude);
        DartdocResults results = await dartdoc.generateDocs();
        PackageGraph p = results.packageGraph;
        expect(p.localPublicLibraries.length, equals(1));
        expect(p.localPublicLibraries.first.name, equals('another_included'));
      });

      test('with exclude command line argument', () async {
        Dartdoc dartdoc = await buildDartdoc(
            ['--exclude', 'more_included'], testPackageIncludeExclude);
        DartdocResults results = await dartdoc.generateDocs();
        PackageGraph p = results.packageGraph;
        expect(p.localPublicLibraries.length, equals(1));
        expect(
            p.localPublicLibraries.first.name, equals('explicitly_included'));
      });
    });

    test('package without version produces valid semver in docs', () async {
      Dartdoc dartdoc = await buildDartdoc([], testPackageMinimumDir);
      DartdocResults results = await dartdoc.generateDocs();
      PackageGraph p = results.packageGraph;
      expect(p.defaultPackage.version, equals('0.0.0-unknown'));
    });

    test('basic interlinking test', () async {
      Dartdoc dartdoc =
          await buildDartdoc(['--link-to-remote'], testPackageDir);
      DartdocResults results = await dartdoc.generateDocs();
      PackageGraph p = results.packageGraph;
      Package meta = p.publicPackages.firstWhere((p) => p.name == 'meta');
      TopLevelVariable useSomethingInAnotherPackage = p.publicLibraries
          .firstWhere((l) => l.name == 'fake')
          .properties
          .firstWhere((p) => p.name == 'useSomethingInAnotherPackage');
      TopLevelVariable useSomethingInTheSdk = p.publicLibraries
          .firstWhere((l) => l.name == 'fake')
          .properties
          .firstWhere((p) => p.name == 'useSomethingInTheSdk');
      expect(meta.documentedWhere, equals(DocumentLocation.remote));
      expect(
          useSomethingInAnotherPackage.modelType.linkedName,
          startsWith(
              '<a href=\"https://pub.dartlang.org/documentation/meta/1.1.6/meta/Required-class.html\">Required</a>'));
      RegExp stringLink = new RegExp(
          'https://api.dartlang.org/(dev|stable|edge|be)/${Platform.version.split(' ').first}/dart-core/String-class.html">String</a>');
      expect(useSomethingInTheSdk.modelType.linkedName, contains(stringLink));
    });

    test('generate docs for ${pathLib.basename(testPackageDir.path)} works',
        () async {
      Dartdoc dartdoc = await buildDartdoc([], testPackageDir);

      DartdocResults results = await dartdoc.generateDocs();
      expect(results.packageGraph, isNotNull);

      PackageGraph packageGraph = results.packageGraph;
      Package p = packageGraph.defaultPackage;
      expect(p.name, 'test_package');
      expect(p.hasDocumentationFile, isTrue);
      expect(packageGraph.defaultPackage.publicLibraries, hasLength(10));
      expect(packageGraph.localPackages.length, equals(1));
    });

    test('generate docs for ${pathLib.basename(testPackageBadDir.path)} fails',
        () async {
      Dartdoc dartdoc = await buildDartdoc([], testPackageBadDir);

      try {
        await dartdoc.generateDocs();
        fail('dartdoc should fail on analysis errors');
      } catch (e) {
        expect(e is DartdocFailure, isTrue);
      }
    });

    test('generate docs for a package that does not have a readme', () async {
      Dartdoc dartdoc = await buildDartdoc([], testPackageWithNoReadme);

      DartdocResults results = await dartdoc.generateDocs();
      expect(results.packageGraph, isNotNull);

      PackageGraph p = results.packageGraph;
      expect(p.defaultPackage.name, 'test_package_small');
      expect(p.defaultPackage.hasHomepage, isFalse);
      expect(p.defaultPackage.hasDocumentationFile, isFalse);
      expect(p.localPublicLibraries, hasLength(1));
    });

    test('generate docs including a single library', () async {
      Dartdoc dartdoc =
          await buildDartdoc(['--include', 'fake'], testPackageDir);

      DartdocResults results = await dartdoc.generateDocs();
      expect(results.packageGraph, isNotNull);

      PackageGraph p = results.packageGraph;
      expect(p.defaultPackage.name, 'test_package');
      expect(p.defaultPackage.hasDocumentationFile, isTrue);
      expect(p.libraries, hasLength(1));
      expect(p.libraries.map((lib) => lib.name), contains('fake'));
    });

    test('generate docs excluding a single library', () async {
      Dartdoc dartdoc =
          await buildDartdoc(['--exclude', 'fake'], testPackageDir);

      DartdocResults results = await dartdoc.generateDocs();
      expect(results.packageGraph, isNotNull);

      PackageGraph p = results.packageGraph;
      expect(p.defaultPackage.name, 'test_package');
      expect(p.defaultPackage.hasDocumentationFile, isTrue);
      expect(p.localPublicLibraries, hasLength(9));
      expect(p.localPublicLibraries.map((lib) => lib.name).contains('fake'),
          isFalse);
    });

    test('generate docs for package with embedder yaml', () async {
      Dartdoc dartdoc = await buildDartdoc([], testPackageWithEmbedderYaml);

      DartdocResults results = await dartdoc.generateDocs();
      expect(results.packageGraph, isNotNull);

      PackageGraph p = results.packageGraph;
      expect(p.defaultPackage.name, 'test_package_embedder_yaml');
      expect(p.defaultPackage.hasDocumentationFile, isFalse);
      expect(p.libraries, hasLength(3));
      expect(p.libraries.map((lib) => lib.name).contains('dart:core'), isTrue);
      expect(p.libraries.map((lib) => lib.name).contains('dart:async'), isTrue);
      expect(p.libraries.map((lib) => lib.name).contains('dart:bear'), isTrue);
      expect(p.packageMap.length, equals(2));
      // Things that do not override the core SDK belong in their own package.
      expect(p.packageMap["Dart"].isSdk, isTrue);
      expect(p.packageMap["test_package_embedder_yaml"].isSdk, isFalse);
      // Should be true once dart-lang/sdk#32707 is fixed.
      //expect(
      //    p.publicLibraries,
      //    everyElement((Library l) =>
      //        (l.element as LibraryElement).isInSdk == l.packageMeta.isSdk));
      // Ensure that we actually parsed some source by checking for
      // the 'Bear' class.
      Library dart_bear = p.packageMap["Dart"].libraries
          .firstWhere((lib) => lib.name == 'dart:bear');
      expect(
          dart_bear.allClasses.map((cls) => cls.name).contains('Bear'), isTrue);
      expect(p.packageMap["Dart"].publicLibraries, hasLength(3));
    });
  }, timeout: new Timeout.factor(8));
}
