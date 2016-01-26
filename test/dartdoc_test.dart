// Copyright (c) 2015, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library dartdoc.dartdoc_test;

import 'dart:io';

import 'package:cli_util/cli_util.dart';
import 'package:dartdoc/dartdoc.dart';
import 'package:dartdoc/src/model.dart';
import 'package:dartdoc/src/package_meta.dart';
import 'package:path/path.dart' as path;
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

    test('generate docs for ${path.basename(testPackageDir.path)} works',
        () async {
      PackageMeta meta = new PackageMeta.fromDir(testPackageDir);
      DartDoc dartdoc =
          new DartDoc(testPackageDir, [], getSdkDir(), [], tempDir, meta, []);

      DartDocResults results = await dartdoc.generateDocs();
      expect(results.package, isNotNull);

      Package p = results.package;
      expect(p.name, 'test_package');
      expect(p.hasDocumentationFile, isTrue);
      expect(p.libraries, hasLength(9));
    });

    test('generate docs for ${path.basename(testPackageBadDir.path)} fails',
        () async {
      PackageMeta meta = new PackageMeta.fromDir(testPackageBadDir);
      DartDoc dartdoc = new DartDoc(
          testPackageBadDir, [], getSdkDir(), [], tempDir, meta, []);

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
          testPackageWithNoReadme, [], getSdkDir(), [], tempDir, meta, []);

      DartDocResults results = await dartdoc.generateDocs();
      expect(results.package, isNotNull);

      Package p = results.package;
      expect(p.name, 'test_package_small');
      expect(p.hasDocumentationFile, isFalse);
      expect(p.libraries, hasLength(1));
    });

    test('generate docs including a single library', () async {
      PackageMeta meta = new PackageMeta.fromDir(testPackageDir);
      DartDoc dartdoc = new DartDoc(
          testPackageDir, [], getSdkDir(), [], tempDir, meta, ['fake']);

      DartDocResults results = await dartdoc.generateDocs();
      expect(results.package, isNotNull);

      Package p = results.package;
      expect(p.name, 'test_package');
      expect(p.hasDocumentationFile, isTrue);
      expect(p.libraries, hasLength(1));
      expect(p.libraries.map((lib) => lib.name), contains('fake'));
    });

    test('generate docs excluding a single library', () async {
      PackageMeta meta = new PackageMeta.fromDir(testPackageDir);
      DartDoc dartdoc = new DartDoc(
          testPackageDir, ['fake'], getSdkDir(), [], tempDir, meta, []);

      DartDocResults results = await dartdoc.generateDocs();
      expect(results.package, isNotNull);

      Package p = results.package;
      expect(p.name, 'test_package');
      expect(p.hasDocumentationFile, isTrue);
      expect(p.libraries, hasLength(8));
      expect(p.libraries.map((lib) => lib.name).contains('fake'), isFalse);
    });
  });
}
