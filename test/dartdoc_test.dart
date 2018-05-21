// Copyright (c) 2015, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library dartdoc.dartdoc_test;

import 'dart:async';
import 'dart:io';

import 'package:dartdoc/dartdoc.dart';
import 'package:dartdoc/src/model.dart';
import 'package:dartdoc/src/package_meta.dart';
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

    Future<DartdocGeneratorOptionContext> generatorContextFromArgvTemp(
        List<String> argv) async {
      return await generatorContextFromArgv(argv..addAll(outputParam));
    }

    test('package without version produces valid semver in docs', () async {
      Dartdoc dartdoc = await Dartdoc.withDefaultGenerators(
          await generatorContextFromArgvTemp(
              ['--input', testPackageMinimumDir.path]));
      DartdocResults results = await dartdoc.generateDocs();
      PackageGraph p = results.packageGraph;
      assert(p.version == '0.0.0-unknown');
    });

    test('basic interlinking test', () async {
      Dartdoc dartdoc = await Dartdoc.withDefaultGenerators(
          await generatorContextFromArgvTemp(
              ['--input', testPackageDir.path, '--link-to-remote']));
      DartdocResults results = await dartdoc.generateDocs();
      PackageGraph p = results.packageGraph;
      Package tuple = p.publicPackages.firstWhere((p) => p.name == 'tuple');
      TopLevelVariable useSomethingInAnotherPackage = p.publicLibraries
          .firstWhere((l) => l.name == 'fake')
          .properties
          .firstWhere((p) => p.name == 'useSomethingInAnotherPackage');
      expect(tuple.documentedWhere, equals(DocumentLocation.remote));
      expect(
          (useSomethingInAnotherPackage.modelType.typeArguments.first
                  as ParameterizedElementType)
              .element
              .package
              .documentedWhere,
          equals(DocumentLocation.remote));
      expect(
          useSomethingInAnotherPackage.modelType.linkedName,
          startsWith(
              '<a href="https://pub.dartlang.org/documentation/tuple/1.0.1/tuple/Tuple2-class.html">Tuple2</a>'));
      RegExp stringLink = new RegExp(
          'https://api.dartlang.org/(dev|stable|be)/${Platform.version.split(' ').first}/dart-core/String-class.html">String</a>');
      expect(useSomethingInAnotherPackage.modelType.linkedName,
          contains(stringLink));
    });

    test('generate docs for ${pathLib.basename(testPackageDir.path)} works',
        () async {
      Dartdoc dartdoc = await Dartdoc.withDefaultGenerators(
          await generatorContextFromArgvTemp(['--input', testPackageDir.path]));

      DartdocResults results = await dartdoc.generateDocs();
      expect(results.packageGraph, isNotNull);

      PackageGraph p = results.packageGraph;
      expect(p.name, 'test_package');
      expect(p.hasDocumentationFile, isTrue);
      expect(p.defaultPackage.publicLibraries, hasLength(10));
      expect(p.localPackages.length, equals(1));
    });

    test('generate docs for ${pathLib.basename(testPackageBadDir.path)} fails',
        () async {
      Dartdoc dartdoc = await Dartdoc.withDefaultGenerators(
          await generatorContextFromArgvTemp(
              ['--input', testPackageBadDir.path]));

      try {
        await dartdoc.generateDocs();
        fail('dartdoc should fail on analysis errors');
      } catch (e) {
        expect(e is DartdocFailure, isTrue);
      }
    });

    test('generate docs for a package that does not have a readme', () async {
      Dartdoc dartdoc = await Dartdoc.withDefaultGenerators(
          await generatorContextFromArgvTemp(
              ['--input', testPackageWithNoReadme.path]));

      DartdocResults results = await dartdoc.generateDocs();
      expect(results.packageGraph, isNotNull);

      PackageGraph p = results.packageGraph;
      expect(p.name, 'test_package_small');
      expect(p.hasHomepage, isFalse);
      expect(p.hasDocumentationFile, isFalse);
      expect(p.localPublicLibraries, hasLength(1));
    });

    test('generate docs including a single library', () async {
      Dartdoc dartdoc = await Dartdoc.withDefaultGenerators(
          await generatorContextFromArgvTemp(
              ['--input', testPackageDir.path, '--include', 'fake']));

      DartdocResults results = await dartdoc.generateDocs();
      expect(results.packageGraph, isNotNull);

      PackageGraph p = results.packageGraph;
      expect(p.name, 'test_package');
      expect(p.hasDocumentationFile, isTrue);
      expect(p.libraries, hasLength(1));
      expect(p.libraries.map((lib) => lib.name), contains('fake'));
    });

    test('generate docs excluding a single library', () async {
      Dartdoc dartdoc = await Dartdoc.withDefaultGenerators(
          await generatorContextFromArgvTemp(
              ['--input', testPackageDir.path, '--exclude', 'fake']));

      DartdocResults results = await dartdoc.generateDocs();
      expect(results.packageGraph, isNotNull);

      PackageGraph p = results.packageGraph;
      expect(p.name, 'test_package');
      expect(p.hasDocumentationFile, isTrue);
      expect(p.localPublicLibraries, hasLength(9));
      expect(p.localPublicLibraries.map((lib) => lib.name).contains('fake'),
          isFalse);
    });

    test('generate docs for package with embedder yaml', () async {
      PackageMeta meta = new PackageMeta.fromDir(testPackageWithEmbedderYaml);
      if (meta.needsPubGet) meta.runPubGet();
      Dartdoc dartdoc = await Dartdoc.withDefaultGenerators(
          await generatorContextFromArgvTemp(
              ['--input', testPackageWithEmbedderYaml.path]));

      DartdocResults results = await dartdoc.generateDocs();
      expect(results.packageGraph, isNotNull);

      PackageGraph p = results.packageGraph;
      expect(p.name, 'test_package_embedder_yaml');
      expect(p.hasDocumentationFile, isFalse);
      expect(p.libraries, hasLength(3));
      expect(p.libraries.map((lib) => lib.name).contains('dart:core'), isTrue);
      expect(p.libraries.map((lib) => lib.name).contains('dart:async'), isTrue);
      expect(p.libraries.map((lib) => lib.name).contains('dart:bear'), isTrue);
      expect(p.packageMap.length, equals(1));
      // Things that do not override the core SDK do not belong in their own package.
      expect(p.packageMap["Dart"].isSdk, isTrue);
      expect(p.packageMap["test_package_embedder_yaml"], isNull);
      // Should be true once dart-lang/sdk#32707 is fixed.
      //expect(
      //    p.publicLibraries,
      //    everyElement((Library l) =>
      //        (l.element as LibraryElement).isInSdk == l.packageMeta.isSdk));
      // Ensure that we actually parsed some source by checking for
      // the 'Bear' class.
      Library dart_bear =
          p.libraries.firstWhere((lib) => lib.name == 'dart:bear');
      expect(dart_bear, isNotNull);
      expect(
          dart_bear.allClasses.map((cls) => cls.name).contains('Bear'), isTrue);
      expect(p.packageMap["Dart"].publicLibraries, hasLength(3));
    });
  }, timeout: new Timeout.factor(8));
}
