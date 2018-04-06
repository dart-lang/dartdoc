// Copyright (c) 2015, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library dartdoc.dartdoc_test;

import 'dart:io';

import 'package:dartdoc/dartdoc.dart';
import 'package:dartdoc/src/model.dart';
import 'package:dartdoc/src/package_meta.dart';
import 'package:path/path.dart' as pathLib;
import 'package:test/test.dart';

import 'src/utils.dart';

void main() {
  group('dartdoc', () {
    Directory tempDir;

    setUp(() {
      tempDir = Directory.systemTemp.createTempSync('dartdoc.test.');
    });

    tearDown(() {
      delete(tempDir);
    });

    test('generate docs for ${pathLib.basename(testPackageDir.path)} works',
        () async {
      PackageMeta meta = new PackageMeta.fromDir(testPackageDir);
      DartDoc dartdoc = new DartDoc(
          new DartDocConfig.fromParameters(inputDir: testPackageDir),
          [],
          tempDir,
          meta);

      DartDocResults results = await dartdoc.generateDocs();
      expect(results.packageGraph, isNotNull);

      PackageGraph p = results.packageGraph;
      expect(p.name, 'test_package');
      expect(p.hasDocumentationFile, isTrue);
      expect(p.defaultPackage.publicLibraries, hasLength(10));
      expect(p.localPackages.length, equals(1));
    });

    test('generate docs for ${pathLib.basename(testPackageBadDir.path)} fails',
        () async {
      PackageMeta meta = new PackageMeta.fromDir(testPackageBadDir);
      DartDoc dartdoc = new DartDoc(
          new DartDocConfig.fromParameters(inputDir: testPackageBadDir),
          [],
          tempDir,
          meta);

      try {
        await dartdoc.generateDocs();
        fail('dartdoc should fail on analysis errors');
      } catch (e) {
        expect(e is DartDocFailure, isTrue);
      }
    });

    test('generate docs for a package that does not have a readme', () async {
      PackageMeta meta = new PackageMeta.fromDir(testPackageWithNoReadme);
      DartDoc dartdoc = new DartDoc(
          new DartDocConfig.fromParameters(inputDir: testPackageWithNoReadme),
          [],
          tempDir,
          meta);

      DartDocResults results = await dartdoc.generateDocs();
      expect(results.packageGraph, isNotNull);

      PackageGraph p = results.packageGraph;
      expect(p.name, 'test_package_small');
      expect(p.hasHomepage, isFalse);
      expect(p.hasDocumentationFile, isFalse);
      expect(p.localPublicLibraries, hasLength(1));
    });

    test('generate docs including a single library', () async {
      PackageMeta meta = new PackageMeta.fromDir(testPackageDir);
      DartDoc dartdoc = new DartDoc(
          new DartDocConfig.fromParameters(
              inputDir: testPackageDir, includeLibraries: ['fake']),
          [],
          tempDir,
          meta);

      DartDocResults results = await dartdoc.generateDocs();
      expect(results.packageGraph, isNotNull);

      PackageGraph p = results.packageGraph;
      expect(p.name, 'test_package');
      expect(p.hasDocumentationFile, isTrue);
      expect(p.libraries, hasLength(1));
      expect(p.libraries.map((lib) => lib.name), contains('fake'));
    });

    test('generate docs excluding a single library', () async {
      PackageMeta meta = new PackageMeta.fromDir(testPackageDir);
      DartDoc dartdoc = new DartDoc(
        new DartDocConfig.fromParameters(inputDir: testPackageDir, excludeLibraries: ['fake']),
          [], tempDir, meta);

      DartDocResults results = await dartdoc.generateDocs();
      expect(results.packageGraph, isNotNull);

      PackageGraph p = results.packageGraph;
      expect(p.name, 'test_package');
      expect(p.hasDocumentationFile, isTrue);
      expect(p.publicLibraries, hasLength(9));
      expect(p.publicLibraries.map((lib) => lib.name).contains('fake'), isFalse);
    });

    test('generate docs for package with embedder yaml', () async {
      PackageMeta meta = new PackageMeta.fromDir(testPackageWithEmbedderYaml);
      if (meta.needsPubGet) meta.runPubGet();
      DartDoc dartdoc = new DartDoc(
          new DartDocConfig.fromParameters(
              inputDir: testPackageWithEmbedderYaml),
          [],
          tempDir,
          meta);

      DartDocResults results = await dartdoc.generateDocs();
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
  }, timeout: new Timeout.factor(4));
}
