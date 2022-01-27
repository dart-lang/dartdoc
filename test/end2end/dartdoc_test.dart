// Copyright (c) 2015, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library dartdoc.dartdoc_test;

import 'dart:async';
import 'dart:io' show Platform;

import 'package:analyzer/file_system/file_system.dart';
import 'package:dartdoc/dartdoc.dart' show Dartdoc, DartdocResults;
import 'package:dartdoc/options.dart';
import 'package:dartdoc/src/dartdoc_options.dart';
import 'package:dartdoc/src/failure.dart';
import 'package:dartdoc/src/io_utils.dart';
import 'package:dartdoc/src/logging.dart';
import 'package:dartdoc/src/model/documentable.dart';
import 'package:dartdoc/src/model/package_builder.dart';
import 'package:dartdoc/src/package_config_provider.dart';
import 'package:dartdoc/src/package_meta.dart';
import 'package:dartdoc/src/warnings.dart';
import 'package:path/path.dart' as path;
import 'package:pub_semver/pub_semver.dart';
import 'package:test/test.dart';

import '../src/utils.dart';

final _experimentPackageAllowed =
    VersionRange(min: Version.parse('2.15.0-0'), includeMin: true);

final _resourceProvider = pubPackageMetaProvider.resourceProvider;
final _pathContext = _resourceProvider.pathContext;

Folder _getFolder(String p) => _resourceProvider
    .getFolder(_pathContext.absolute(_pathContext.canonicalize(p)));

final _testPackageDir = _getFolder('testing/test_package');

final Folder _testPackageBadDir = _getFolder('testing/test_package_bad');
final Folder _testSkyEnginePackage = _getFolder('testing/sky_engine');
final Folder _testPackageIncludeExclude =
    _getFolder('testing/test_package_include_exclude');
final Folder _testPackageCustomTemplates =
    _getFolder('testing/test_package_custom_templates');
final Folder _testPackageExperiments =
    _getFolder('testing/test_package_experiments');

class DartdocLoggingOptionContext extends DartdocGeneratorOptionContext
    with LoggingContext {
  DartdocLoggingOptionContext(
      DartdocOptionSet optionSet, Folder dir, ResourceProvider resourceProvider)
      : super(optionSet, dir, resourceProvider);
}

void main() {
  group('dartdoc with generators', () {
    late Folder tempDir;

    setUpAll(() async {
      var optionSet = await DartdocOptionRoot.fromOptionGenerators(
          'dartdoc',
          [createDartdocProgramOptions, createLoggingOptions],
          pubPackageMetaProvider);
      optionSet.parseArguments([]);
      startLogging(DartdocLoggingOptionContext(
          optionSet,
          _resourceProvider.getFolder(_pathContext.current),
          _resourceProvider));
    });

    setUp(() async {
      tempDir = _resourceProvider.createSystemTemp('dartdoc.test.');
    });

    tearDown(() async {
      tempDir.delete();
    });

    Future<Dartdoc> buildDartdoc(
        List<String> argv, Folder packageRoot, Folder tempDir) async {
      var context = await generatorContextFromArgv(argv
        ..addAll(['--input', packageRoot.path, '--output', tempDir.path]));

      return await Dartdoc.fromContext(
        context,
        PubPackageBuilder(
            context, pubPackageMetaProvider, PhysicalPackageConfigProvider(),
            skipUnreachableSdkLibraries: true),
      );
    }

    test('errors generate errors even when warnings are off', () async {
      var dartdoc =
          await buildDartdoc(['--allow-tools'], testPackageToolError, tempDir);
      var results = await dartdoc.generateDocsBase();
      var p = results.packageGraph;
      var unresolvedToolErrors = p.packageWarningCounter.countedWarnings.values
          .map((e) => e[PackageWarning.toolError] ?? {})
          .expand((element) => element);

      expect(p.packageWarningCounter.errorCount, equals(1));
      expect(unresolvedToolErrors.length, equals(1));
      expect(unresolvedToolErrors.first,
          contains('Tool "drill" returned non-zero exit code'));
    });

    group('include/exclude parameters', () {
      test('with config file', () async {
        var dartdoc =
            await buildDartdoc([], _testPackageIncludeExclude, tempDir);
        var results = await dartdoc.generateDocs();
        var p = results.packageGraph;
        expect(p.localPublicLibraries.map((l) => l.name),
            orderedEquals(['explicitly_included', 'more_included']));
      });

      test('with include command line argument', () async {
        var dartdoc = await buildDartdoc(['--include', 'another_included'],
            _testPackageIncludeExclude, tempDir);
        var results = await dartdoc.generateDocs();
        var p = results.packageGraph;
        expect(p.localPublicLibraries.length, equals(1));
        expect(p.localPublicLibraries.first.name, equals('another_included'));
      });

      test('with exclude command line argument', () async {
        var dartdoc = await buildDartdoc(['--exclude', 'more_included'],
            _testPackageIncludeExclude, tempDir);
        var results = await dartdoc.generateDocs();
        var p = results.packageGraph;
        expect(p.localPublicLibraries.length, equals(1));
        expect(
            p.localPublicLibraries.first.name, equals('explicitly_included'));
      });
    });

    test('basic interlinking test', () async {
      var dartdoc = await buildDartdoc(
          ['--exclude-packages=args'], _testPackageDir, tempDir);
      var results = await dartdoc.generateDocs();
      var p = results.packageGraph;
      var meta = p.publicPackages.firstWhere((p) => p.name == 'meta');
      var args = p.publicPackages.firstWhere((p) => p.name == 'args');
      var useSomethingInAnotherPackage = p.publicLibraries
          .firstWhere((l) => l.name == 'fake')
          .properties
          .firstWhere((p) => p.name == 'useSomethingInAnotherPackage');
      var useSomethingInTheSdk = p.publicLibraries
          .firstWhere((l) => l.name == 'fake')
          .properties
          .firstWhere((p) => p.name == 'useSomethingInTheSdk');
      expect(meta.documentedWhere, equals(DocumentLocation.remote));
      expect(args.documentedWhere, equals(DocumentLocation.missing));
      expect(
          useSomethingInAnotherPackage.modelType.linkedName,
          matches(
              r'<a href="https://pub.dev/documentation/meta/[^"]*/meta/Required-class.html">Required</a>'));
      var stringLink = RegExp(
          'https://api.dart.dev/(dev|stable|edge|be|beta)/${Platform.version.split(' ').first}/dart-core/String-class.html">String</a>');
      expect(useSomethingInTheSdk.modelType.linkedName, contains(stringLink));
    });

    group('validate basic doc generation', () {
      late final DartdocResults results;
      late final Folder tempDir;

      setUpAll(() async {
        tempDir = _resourceProvider.createSystemTemp('dartdoc.test.');
        var dartdoc = await buildDartdoc([], _testPackageDir, tempDir);
        results = await dartdoc.generateDocs();
      });

      test('generate docs for ${path.basename(_testPackageDir.path)} works',
          () async {
        expect(results.packageGraph, isNotNull);
        var packageGraph = results.packageGraph;
        var p = packageGraph.defaultPackage;
        expect(p.name, 'test_package');
        expect(p.packageMeta.getReadmeContents(), isNotNull);
        // Total number of public libraries in test_package.
        // +2 since we are not manually excluding anything.
        expect(packageGraph.defaultPackage.publicLibraries,
            hasLength(kTestPackagePublicLibraries + 2));
        expect(packageGraph.localPackages.length, equals(1));
      });

      test('source code links are visible', () async {
        // Picked this object as this library explicitly should never contain
        // a library directive, so we can predict what line number it will be.
        var anonymousOutput = _resourceProvider.getFile(_pathContext.join(
            tempDir.path,
            'anonymous_library',
            'anonymous_library-library.html'));
        expect(anonymousOutput.exists, isTrue);
        expect(
            anonymousOutput.readAsStringSync(),
            contains(r'<a title="View source code" class="source-link" '
                'href="https://github.com/dart-lang/dartdoc/blob/master/testing/test_package/lib/anonymous_library.dart#L1">'
                '<i class="material-icons">description</i></a>'));
      });
    });

    test('generate docs for ${path.basename(_testPackageBadDir.path)} fails',
        () async {
      var dartdoc = await buildDartdoc([], _testPackageBadDir, tempDir);

      try {
        await dartdoc.generateDocs();
        fail('dartdoc should fail on analysis errors');
      } catch (e) {
        expect(e is DartdocFailure, isTrue);
      }
    },
        skip: 'Blocked on getting analysis errors with correct interpretation '
            'from analysis_options');

    test('generate docs for package with embedder yaml', () async {
      var dartdoc = await buildDartdoc([], _testSkyEnginePackage, tempDir);

      var results = await dartdoc.generateDocs();
      expect(results.packageGraph, isNotNull);

      var p = results.packageGraph;
      expect(p.defaultPackage.name, 'sky_engine');
      expect(p.defaultPackage.packageMeta.getReadmeContents(), isNull);
      expect(p.libraries, hasLength(3));
      expect(p.libraries.map((lib) => lib.name).contains('dart:core'), isTrue);
      expect(p.libraries.map((lib) => lib.name).contains('dart:async'), isTrue);
      expect(p.libraries.map((lib) => lib.name).contains('dart:bear'), isTrue);
      expect(p.packageMap.length, equals(2));
      var dartPackage = p.packageMap['Dart']!;
      // Things that do not override the core SDK belong in their own package.
      expect(dartPackage.isSdk, isTrue);
      expect(p.packageMap['sky_engine']!.isSdk, isFalse);
      // Should be true once dart-lang/sdk#32707 is fixed.
      //expect(
      //    p.publicLibraries,
      //    everyElement((Library l) =>
      //        (l.element as LibraryElement).isInSdk == l.packageMeta.isSdk));
      // Ensure that we actually parsed some source by checking for
      // the 'Bear' class.
      var dartBear =
          dartPackage.libraries.firstWhere((lib) => lib.name == 'dart:bear');
      expect(
          dartBear.allClasses.map((cls) => cls.name).contains('Bear'), isTrue);
      expect(dartPackage.publicLibraries, hasLength(3));
    });

    test('generate docs with custom templates', () async {
      var templatesDir =
          path.join(_testPackageCustomTemplates.path, 'templates');
      var dartdoc = await buildDartdoc(['--templates-dir', templatesDir],
          _testPackageCustomTemplates, tempDir);

      var results = await dartdoc.generateDocs();
      expect(results.packageGraph, isNotNull);

      var p = results.packageGraph;
      expect(p.defaultPackage.name, 'test_package_custom_templates');
      expect(p.localPublicLibraries, hasLength(1));

      var index = _resourceProvider
          .getFile(_pathContext.join(tempDir.path, 'index.html'));
      expect(index.readAsStringSync(),
          contains('Welcome my friends to a custom template'));
    });

    test('generate docs with missing required template fails', () async {
      var templatesDir = path.join(path.current, 'test/templates');
      try {
        await buildDartdoc(['--templates-dir', templatesDir],
            _testPackageCustomTemplates, tempDir);
        fail('dartdoc should fail with missing required template');
      } catch (e) {
        expect(e is DartdocFailure, isTrue);
        expect((e as DartdocFailure).message,
            startsWith('Missing required template file'));
      }
    });

    test('generate docs with bad templatesDir path fails', () async {
      var badPath = path.join(tempDir.path, 'BAD');
      try {
        await buildDartdoc(
            ['--templates-dir', badPath], _testPackageCustomTemplates, tempDir);
        fail('dartdoc should fail with bad templatesDir path');
      } catch (e) {
        expect(e is DartdocFailure, isTrue);
      }
    });

    test('generating markdown docs does not crash', () async {
      var dartdoc =
          await buildDartdoc(['--format', 'md'], _testPackageDir, tempDir);
      await dartdoc.generateDocsBase();
    });

    test('generating markdown docs for experimental features does not crash',
        () async {
      var dartdoc = await buildDartdoc(
          ['--format', 'md'], _testPackageExperiments, tempDir);
      await dartdoc.generateDocsBase();
    }, skip: !_experimentPackageAllowed.allows(platformVersion));

    test('rel canonical prefix does not include base href', () async {
      final prefix = 'foo.bar/baz';
      var dartdoc = await buildDartdoc(
          ['--rel-canonical-prefix', prefix], _testPackageDir, tempDir);
      await dartdoc.generateDocsBase();

      // Verify files at different levels have correct <link> content.
      var level1 = _resourceProvider
          .getFile(_pathContext.join(tempDir.path, 'ex', 'Apple-class.html'));
      expect(level1.exists, isTrue);
      expect(
          level1.readAsStringSync(),
          contains(
              '<link rel="canonical" href="$prefix/ex/Apple-class.html">'));
      var level2 = _resourceProvider
          .getFile(_pathContext.join(tempDir.path, 'ex', 'Apple', 'm.html'));
      expect(level2.exists, isTrue);
      expect(level2.readAsStringSync(),
          contains('<link rel="canonical" href="$prefix/ex/Apple/m.html">'));
    });

    test('generate docs with bad output format', () async {
      try {
        await buildDartdoc(['--format', 'bad'], _testPackageDir, tempDir);
        fail('dartdoc should fail with bad output format');
      } catch (e) {
        expect(e is DartdocFailure, isTrue);
        expect((e as DartdocFailure).message,
            startsWith('Unsupported output format'));
      }
    });
  }, timeout: Timeout.factor(12));
}
