// Copyright (c) 2015, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library dartdoc.dartdoc_test;

import 'dart:async';
import 'dart:io';
import 'dart:mirrors';

import 'package:dartdoc/dartdoc.dart';
import 'package:dartdoc/src/logging.dart';
import 'package:dartdoc/src/model.dart';
import 'package:dartdoc/src/tuple.dart';
import 'package:dartdoc/src/warnings.dart';
import 'package:path/path.dart' as pathLib;
import 'package:test/test.dart';

import 'src/utils.dart';

Uri get _currentFileUri =>
    (reflect(main) as ClosureMirror).function.location.sourceUri;
String get _testPackagePath =>
    pathLib.fromUri(_currentFileUri.resolve('../testing/test_package'));
String get _testPackageFlutterPluginPath => pathLib
    .fromUri(_currentFileUri.resolve('../testing/test_package_flutter_plugin'));

class DartdocLoggingOptionContext extends DartdocGeneratorOptionContext
    with LoggingContext {
  DartdocLoggingOptionContext(DartdocOptionSet optionSet, Directory dir)
      : super(optionSet, dir);
}

void main() {
  group('dartdoc with generators', () {
    Directory tempDir;
    List<String> outputParam;

    setUpAll(() async {
      tempDir = Directory.systemTemp.createTempSync('dartdoc.test.');
      outputParam = ['--output', tempDir.path];
      DartdocOptionSet optionSet = await DartdocOptionSet.fromOptionGenerators(
          'dartdoc', [createLoggingOptions]);
      optionSet.parseArguments([]);
      startLogging(
          new DartdocLoggingOptionContext(optionSet, Directory.current));
    });

    tearDown(() async {
      tempDir.listSync().forEach((FileSystemEntity f) {
        f.deleteSync(recursive: true);
      });
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

      setUpAll(() async {
        dartdoc = await buildDartdoc([], testPackageOptions);
        results = await dartdoc.generateDocsBase();
        p = results.packageGraph;
      });

      test('generator parameters', () async {
        File favicon = new File(
            pathLib.joinAll([tempDir.path, 'static-assets', 'favicon.png']));
        File index = new File(pathLib.joinAll([tempDir.path, 'index.html']));
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
      Dartdoc dartdoc = await buildDartdoc([], testPackageToolError);
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

    group('Invoking command-line dartdoc', () {
      String dartdocPath =
          pathLib.canonicalize(pathLib.join('bin', 'dartdoc.dart'));
      CoverageSubprocessLauncher subprocessLauncher;

      setUpAll(() {
        subprocessLauncher =
            new CoverageSubprocessLauncher('dartdoc_test-subprocesses');
      });

      tearDownAll(() async {
        await Future.wait(CoverageSubprocessLauncher.coverageResults);
      });

      test('running --no-generate-docs is quiet and does not generate docs',
          () async {
        Directory outputDir =
            await Directory.systemTemp.createTemp('dartdoc.testEmpty.');
        List<String> outputLines = [];
        await subprocessLauncher.runStreamed(Platform.resolvedExecutable,
            [dartdocPath, '--output', outputDir.path, '--no-generate-docs'],
            perLine: outputLines.add, workingDirectory: _testPackagePath);
        expect(outputLines, isNot(contains(matches('^parsing'))));
        expect(outputLines, contains(matches('^  warning:')));
        expect(
            outputLines.last, matches(r'^found \d+ warnings and \d+ errors'));
      });

      test('invalid parameters return non-zero and print a fatal-error',
          () async {
        List outputLines = [];
        await expectLater(
            () => subprocessLauncher.runStreamed(
                Platform.resolvedExecutable,
                [
                  dartdocPath,
                  '--nonexisting',
                ],
                perLine: outputLines.add),
            throwsA(const TypeMatcher<ProcessException>()));
        expect(
            outputLines.firstWhere((l) => l.startsWith(' fatal')),
            equals(
                ' fatal error: Could not find an option named "nonexisting".'));
      });

      test('missing a required file path prints a fatal-error', () async {
        List outputLines = [];
        String impossiblePath = pathLib.join(dartdocPath, 'impossible');
        await expectLater(
            () => subprocessLauncher.runStreamed(
                Platform.resolvedExecutable,
                [
                  dartdocPath,
                  '--input',
                  impossiblePath,
                ],
                perLine: outputLines.add),
            throwsA(const TypeMatcher<ProcessException>()));
        expect(
            outputLines.firstWhere((l) => l.startsWith(' fatal')),
            startsWith(
                ' fatal error: Argument --input, set to ${impossiblePath}, resolves to missing path: '));
      });

      test('errors cause non-zero exit when warnings are off', () async {
        expect(
            () => subprocessLauncher.runStreamed(Platform.resolvedExecutable, [
                  dartdocPath,
                  '--input=${testPackageToolError.path}',
                  '--output=${pathLib.join(tempDir.absolute.path, 'test_package_tool_error')}'
                ]),
            throwsA(const TypeMatcher<ProcessException>()));
      });

      test('help prints command line args', () async {
        List<String> outputLines = [];
        await subprocessLauncher.runStreamed(
            Platform.resolvedExecutable, [dartdocPath, '--help'],
            perLine: outputLines.add);
        expect(outputLines,
            contains('Generate HTML documentation for Dart libraries.'));
        expect(
            outputLines.join('\n'),
            contains(new RegExp('^-h, --help[ ]+Show command help.',
                multiLine: true)));
      });

      test('Validate missing FLUTTER_ROOT exception is clean', () async {
        StringBuffer output = new StringBuffer();
        var args = <String>[dartdocPath];
        Future run = subprocessLauncher.runStreamed(
            Platform.resolvedExecutable, args,
            environment: new Map.from(Platform.environment)
              ..remove('FLUTTER_ROOT'),
            includeParentEnvironment: false,
            workingDirectory: _testPackageFlutterPluginPath, perLine: (s) {
          output.writeln(s);
        });
        // Asynchronous exception, but we still need the output, too.
        expect(run, throwsA(new TypeMatcher<ProcessException>()));
        try {
          await run;
        } on ProcessException catch (_) {}

        expect(
            output.toString(),
            contains(new RegExp(
                'Top level package requires Flutter but FLUTTER_ROOT environment variable not set|test_package_flutter_plugin requires the Flutter SDK, version solving failed')));
        expect(output.toString(), isNot(contains('asynchronous gap')));
      });

      test("Validate --version works", () async {
        StringBuffer output = new StringBuffer();
        var args = <String>[dartdocPath, '--version'];
        await subprocessLauncher.runStreamed(Platform.resolvedExecutable, args,
            workingDirectory: _testPackagePath,
            perLine: (s) => output.writeln(s));
        PackageMeta dartdocMeta = new PackageMeta.fromFilename(dartdocPath);
        expect(output.toString(),
            endsWith('dartdoc version: ${dartdocMeta.version}\n'));
      });

      test('Check for sample code in examples', () async {
        StringBuffer output = new StringBuffer();
        var args = <String>[
          dartdocPath,
          '--include',
          'ex',
          '--no-include-source',
          '--output',
          tempDir.path
        ];

        await subprocessLauncher.runStreamed(Platform.resolvedExecutable, args,
            workingDirectory: _testPackagePath,
            perLine: (s) => output.writeln(s));

        // Examples are reported as unfound because we (purposefully)
        // did not use --example-path-prefix above.
        final sep = '.'; // We don't care what the path separator character is
        final firstUnfoundExample =
            new RegExp('warning: lib${sep}example.dart: '
                '@example file not found.*test_package${sep}dog${sep}food.md');
        if (!output.toString().contains(firstUnfoundExample)) {
          fail('Should warn about unfound @example files');
        }
      });

      test('Validate JSON output', () async {
        var args = <String>[
          dartdocPath,
          '--include',
          'ex',
          '--no-include-source',
          '--output',
          tempDir.path,
          '--json'
        ];

        Iterable<Map> jsonValues = await subprocessLauncher.runStreamed(
            Platform.resolvedExecutable, args,
            workingDirectory: _testPackagePath);

        expect(jsonValues, isNotEmpty,
            reason: 'All STDOUT lines should be JSON-encoded maps.');
      }, timeout: new Timeout.factor(2));

      test('--footer-text includes text', () async {
        String footerTextPath =
            pathLib.join(Directory.systemTemp.path, 'footer.txt');
        new File(footerTextPath).writeAsStringSync(' footer text include ');

        var args = <String>[
          dartdocPath,
          '--footer-text=${footerTextPath}',
          '--include',
          'ex',
          '--output',
          tempDir.path
        ];

        await subprocessLauncher.runStreamed(Platform.resolvedExecutable, args,
            workingDirectory: _testPackagePath);

        File outFile = new File(pathLib.join(tempDir.path, 'index.html'));
        expect(outFile.readAsStringSync(), contains('footer text include'));
      });
    }, timeout: new Timeout.factor(3));

    group('Option handling with cross-linking', () {
      DartdocResults results;
      Package testPackageOptions;

      setUpAll(() async {
        results = await (await buildDartdoc(
                ['--link-to-remote'], testPackageOptionsImporter))
            .generateDocsBase();
        testPackageOptions = results.packageGraph.packages
            .firstWhere((Package p) => p.name == 'test_package_options');
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
          matches(
              '<a href=\"https://pub.dartlang.org/documentation/meta/[^\"]*/meta/Required-class.html\">Required</a>'));
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
      // Total number of public libraries in test_package.
      expect(packageGraph.defaultPackage.publicLibraries, hasLength(12));
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
    },
        skip: 'Blocked on getting analysis errors with correct interpretation'
            'from analysis_options');

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
      expect(p.localPublicLibraries, hasLength(11));
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
