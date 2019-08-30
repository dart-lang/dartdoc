// Copyright (c) 2015, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library dartdoc.dartdoc_test;

import 'dart:async';
import 'dart:io';

import 'package:dartdoc/dartdoc.dart';
import 'package:dartdoc/src/logging.dart';
import 'package:dartdoc/src/model.dart';
import 'package:dartdoc/src/tuple.dart';
import 'package:dartdoc/src/warnings.dart';
import 'package:path/path.dart' as path;
import 'package:test/test.dart';

import 'src/utils.dart';

class DartdocLoggingOptionContext extends DartdocGeneratorOptionContext
    with LoggingContext {
  DartdocLoggingOptionContext(DartdocOptionSet optionSet, Directory dir)
      : super(optionSet, dir);
}

void main() {
  group('dartdoc with generators', () {
    Directory tempDir;

    setUpAll(() async {
      tempDir = Directory.systemTemp.createTempSync('dartdoc.test.');
      DartdocOptionSet optionSet = await DartdocOptionSet.fromOptionGenerators(
          'dartdoc', [createLoggingOptions]);
      optionSet.parseArguments([]);
      startLogging(DartdocLoggingOptionContext(optionSet, Directory.current));
    });

    setUp(() async {
      tempDir = Directory.systemTemp.createTempSync('dartdoc.test.');
    });

    tearDown(() async {
      tempDir.deleteSync(recursive: true);
    });

    Future<Dartdoc> buildDartdoc(
        List<String> argv, Directory packageRoot, Directory tempDir) async {
      return await Dartdoc.withDefaultGenerators(await generatorContextFromArgv(
          argv
            ..addAll(['--input', packageRoot.path, '--output', tempDir.path])));
    }

    group('Option handling', () {
      Dartdoc dartdoc;
      DartdocResults results;
      PackageGraph p;
      Directory tempDir;

      setUpAll(() async {
        tempDir = Directory.systemTemp.createTempSync('dartdoc.test.');
        dartdoc = await buildDartdoc([], testPackageOptions, tempDir);
        results = await dartdoc.generateDocsBase();
        p = results.packageGraph;
      });

      tearDownAll(() async {
        tempDir.deleteSync(recursive: true);
      });

      test('generator parameters', () async {
        File favicon =
            File(path.joinAll([tempDir.path, 'static-assets', 'favicon.png']));
        File index = File(path.joinAll([tempDir.path, 'index.html']));
        expect(favicon.readAsStringSync(),
            contains('Not really a png, but a test file'));
        String indexString = index.readAsStringSync();
        expect(indexString, contains('Footer things'));
        expect(indexString, contains('footer.txt data'));
        expect(indexString, contains('HTML header file'));
      });

      test('examplePathPrefix', () async {
        Class UseAnExampleHere = p.allCanonicalModelElements
            .whereType<Class>()
            .firstWhere((ModelElement c) => c.name == 'UseAnExampleHere');
        expect(
            UseAnExampleHere.documentationAsHtml,
            contains(
                'An example of an example in an unusual example location.'));
      });

      test('includeExternal and showUndocumentedCategories', () async {
        Class Something = p.allCanonicalModelElements
            .whereType<Class>()
            .firstWhere((ModelElement c) => c.name == 'Something');
        expect(Something.isPublic, isTrue);
        expect(Something.displayedCategories, isNotEmpty);
      });
    });

    test('errors generate errors even when warnings are off', () async {
      Dartdoc dartdoc =
          await buildDartdoc(['--allow-tools'], testPackageToolError, tempDir);
      DartdocResults results = await dartdoc.generateDocsBase();
      PackageGraph p = results.packageGraph;
      Iterable<String> unresolvedToolErrors = p
          .packageWarningCounter.countedWarnings.values
          .expand<String>((Set<Tuple2<PackageWarning, String>> s) => s
              .where((Tuple2<PackageWarning, String> t) =>
                  t.item1 == PackageWarning.toolError)
              .map<String>((Tuple2<PackageWarning, String> t) => t.item2));

      expect(p.packageWarningCounter.errorCount, equals(1));
      expect(unresolvedToolErrors.length, equals(1));
      expect(unresolvedToolErrors.first,
          contains('Tool "drill" returned non-zero exit code'));
    });

    group('Option handling with cross-linking', () {
      DartdocResults results;
      Package testPackageOptions;
      Directory tempDir;

      setUpAll(() async {
        tempDir = Directory.systemTemp.createTempSync('dartdoc.test.');
        results = await (await buildDartdoc(
                ['--link-to-remote'], testPackageOptionsImporter, tempDir))
            .generateDocsBase();
        testPackageOptions = results.packageGraph.packages
            .firstWhere((Package p) => p.name == 'test_package_options');
      });

      tearDownAll(() async {
        tempDir.deleteSync(recursive: true);
      });

      test('linkToUrl', () async {
        Library main = testPackageOptions.allLibraries
            .firstWhere((Library l) => l.name == 'main');
        Class UseAnExampleHere = main.allClasses
            .firstWhere((Class c) => c.name == 'UseAnExampleHere');
        expect(testPackageOptions.documentedWhere,
            equals(DocumentLocation.remote));
        expect(
            UseAnExampleHere.href,
            equals(
                'https://nonexistingsuperpackage.topdomain/test_package_options/0.0.1/main/UseAnExampleHere-class.html'));
      });

      test('includeExternal works via remote', () async {
        Library unusualLibrary = testPackageOptions.allLibraries
            .firstWhere((Library l) => l.name == 'unusualLibrary');
        expect(
            unusualLibrary.allClasses
                .firstWhere((Class c) => c.name == 'Something'),
            isNotNull);
      });
    });

    test('with broken reexport chain', () async {
      Dartdoc dartdoc =
          await buildDartdoc([], testPackageImportExportError, tempDir);
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
        Dartdoc dartdoc =
            await buildDartdoc([], testPackageIncludeExclude, tempDir);
        DartdocResults results = await dartdoc.generateDocs();
        PackageGraph p = results.packageGraph;
        expect(p.localPublicLibraries.map((l) => l.name),
            orderedEquals(['explicitly_included', 'more_included']));
      });

      test('with include command line argument', () async {
        Dartdoc dartdoc = await buildDartdoc(['--include', 'another_included'],
            testPackageIncludeExclude, tempDir);
        DartdocResults results = await dartdoc.generateDocs();
        PackageGraph p = results.packageGraph;
        expect(p.localPublicLibraries.length, equals(1));
        expect(p.localPublicLibraries.first.name, equals('another_included'));
      });

      test('with exclude command line argument', () async {
        Dartdoc dartdoc = await buildDartdoc(
            ['--exclude', 'more_included'], testPackageIncludeExclude, tempDir);
        DartdocResults results = await dartdoc.generateDocs();
        PackageGraph p = results.packageGraph;
        expect(p.localPublicLibraries.length, equals(1));
        expect(
            p.localPublicLibraries.first.name, equals('explicitly_included'));
      });
    });

    test('package without version produces valid semver in docs', () async {
      Dartdoc dartdoc = await buildDartdoc([], testPackageMinimumDir, tempDir);
      DartdocResults results = await dartdoc.generateDocs();
      PackageGraph p = results.packageGraph;
      expect(p.defaultPackage.version, equals('0.0.0-unknown'));
    });

    test('basic interlinking test', () async {
      Dartdoc dartdoc =
          await buildDartdoc(['--link-to-remote'], testPackageDir, tempDir);
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
          matches(
              '<a href=\"https://pub.dartlang.org/documentation/meta/[^\"]*/meta/Required-class.html\">Required</a>'));
      RegExp stringLink = RegExp(
          'https://api.dartlang.org/(dev|stable|edge|be)/${Platform.version.split(' ').first}/dart-core/String-class.html">String</a>');
      expect(useSomethingInTheSdk.modelType.linkedName, contains(stringLink));
    });

    group('validate basic doc generation', () {
      Dartdoc dartdoc;
      DartdocResults results;
      Directory tempDir;

      setUpAll(() async {
        tempDir = Directory.systemTemp.createTempSync('dartdoc.test.');
        dartdoc = await buildDartdoc([], testPackageDir, tempDir);
        results = await dartdoc.generateDocs();
      });

      tearDownAll(() async {
        tempDir.deleteSync(recursive: true);
      });

      test('generate docs for ${path.basename(testPackageDir.path)} works',
          () async {
        expect(results.packageGraph, isNotNull);
        PackageGraph packageGraph = results.packageGraph;
        Package p = packageGraph.defaultPackage;
        expect(p.name, 'test_package');
        expect(p.hasDocumentationFile, isTrue);
        // Total number of public libraries in test_package.
        expect(packageGraph.defaultPackage.publicLibraries, hasLength(14));
        expect(packageGraph.localPackages.length, equals(1));
      });

      test('source code links are visible', () async {
        // Picked this object as this library explicitly should never contain
        // a library directive, so we can predict what line number it will be.
        File anonymousOutput = File(path.join(tempDir.path, 'anonymous_library',
            'anonymous_library-library.html'));
        expect(anonymousOutput.existsSync(), isTrue);
        expect(
            anonymousOutput.readAsStringSync(),
            contains(
                r'<a title="View source code" class="source-link" href="https://github.com/dart-lang/dartdoc/blob/master/testing/test_package/lib/anonymous_library.dart#L1"><i class="material-icons">description</i></a>'));
      });
    });

    test('generate docs for ${path.basename(testPackageBadDir.path)} fails',
        () async {
      Dartdoc dartdoc = await buildDartdoc([], testPackageBadDir, tempDir);

      try {
        await dartdoc.generateDocs();
        fail('dartdoc should fail on analysis errors');
      } catch (e) {
        expect(e is DartdocFailure, isTrue);
      }
    },
        skip: 'Blocked on getting analysis errors with correct interpretation'
            'from analysis_options');

    test('generate docs for a package that does not have a readme', () async {
      Dartdoc dartdoc =
          await buildDartdoc([], testPackageWithNoReadme, tempDir);

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
          await buildDartdoc(['--include', 'fake'], testPackageDir, tempDir);

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
          await buildDartdoc(['--exclude', 'fake'], testPackageDir, tempDir);

      DartdocResults results = await dartdoc.generateDocs();
      expect(results.packageGraph, isNotNull);

      PackageGraph p = results.packageGraph;
      expect(p.defaultPackage.name, 'test_package');
      expect(p.defaultPackage.hasDocumentationFile, isTrue);
      expect(p.localPublicLibraries, hasLength(13));
      expect(p.localPublicLibraries.map((lib) => lib.name).contains('fake'),
          isFalse);
    });

    test('generate docs for package with embedder yaml', () async {
      Dartdoc dartdoc =
          await buildDartdoc([], testPackageWithEmbedderYaml, tempDir);

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

    test('generate docs with custom templates', () async {
      String templatesDir =
          path.join(testPackageCustomTemplates.path, 'templates');
      Dartdoc dartdoc = await buildDartdoc(['--templates-dir', templatesDir],
          testPackageCustomTemplates, tempDir);

      DartdocResults results = await dartdoc.generateDocs();
      expect(results.packageGraph, isNotNull);

      PackageGraph p = results.packageGraph;
      expect(p.defaultPackage.name, 'test_package_custom_templates');
      expect(p.localPublicLibraries, hasLength(1));
    });

    test('generate docs with missing required template fails', () async {
      var templatesDir = path.join(path.current, 'test/templates');
      try {
        await buildDartdoc(['--templates-dir', templatesDir],
            testPackageCustomTemplates, tempDir);
        fail('dartdoc should fail with missing required template');
      } catch (e) {
        expect(e is DartdocFailure, isTrue);
        expect((e as DartdocFailure).message,
            startsWith('Missing required template file'));
      }
    });

    test('generate docs with bad templatesDir path fails', () async {
      String badPath = path.join(tempDir.path, 'BAD');
      try {
        await buildDartdoc(
            ['--templates-dir', badPath], testPackageCustomTemplates, tempDir);
        fail('dartdoc should fail with bad templatesDir path');
      } catch (e) {
        expect(e is DartdocFailure, isTrue);
      }
    });
  }, timeout: Timeout.factor(8));
}
