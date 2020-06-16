// Copyright (c) 2015, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library dartdoc.package_utils_test;

import 'dart:io';

import 'package:dartdoc/src/package_meta.dart';
import 'package:path/path.dart' as path;
import 'package:pub_semver/pub_semver.dart';
import 'package:test/test.dart';

void main() {
  group('NNBD', () {
    void expectVersion(String version, bool expectation) {
      var parsedVersion = Version.parse(version);
      if (expectation == false) {
        sdkNullableRanges.map((v) {
          expect(v.allows(parsedVersion), isFalse);
        });
      } else {
        expect(sdkNullableRanges.any((v) => v.allows(parsedVersion)), isTrue);
      }
    }

    test('nnbd sdk ranges allow correct versions', () {
      expectVersion('2.9.0-edge.b2d41ab0a219af9342fdf205e97bed68011fed51',
          true);
      expectVersion('2.9.0-13.0.dev', true);
      expectVersion('2.9.0-16.0.dev', true);
      expectVersion('2.9.0-1.0.beta', true);
      expectVersion('2.9.0', true);
      expectVersion('2.10.0', true);
    });

    test('nnbd sdk ranges disallow other versions', () {
      expectVersion('2.9.0-8.0.dev', false);
      expectVersion('2.8.4', false);
      expectVersion('2.0.0', false);
    });

    test('PackageMeta for a NNBD enabled package allows NNBD', () {
      var p = pubPackageMetaProvider.fromDir(Directory(
          path.join(Directory.current.path, 'testing',
              'test_package_experiments')));
      expect(p.allowsNNBD, isTrue);
    });

    test('PackageMeta for a non-NNBD enabled package disallows NNBD', () {
      var p = pubPackageMetaProvider.fromDir(Directory(
          path.join(Directory.current.path, 'testing', 'test_package')));
      expect(p.allowsNNBD, isFalse);
    });
  });

  group('PackageMeta for a directory without a pubspec', () {
    PackageMeta p;

    setUp(() {
      var d = Directory.systemTemp.createTempSync('test_package_not_valid');
      p = pubPackageMetaProvider.fromDir(d);
    });

    test('is not valid', () {
      expect(p, isNull);
    });
  });

  group('PackageMeta for the test package', () {
    var p = pubPackageMetaProvider.fromDir(Directory(
        path.join(Directory.current.path, 'testing', 'test_package')));

    test('readme with corrupt UTF-8 loads without throwing', () {
      expect(p.getReadmeContents().contents,
          contains('Here is some messed up UTF-8.\nÃf'));
    });
  });

  group('PackageMeta.fromDir for this package', () {
    var p = pubPackageMetaProvider.fromDir(Directory.current);

    test('has a name', () {
      expect(p.name, 'dartdoc');
    });

    test('has a version', () {
      expect(p.version, isNotNull);
    });

    test('has a description', () {
      expect(
          p.description,
          equals(
              'A non-interactive HTML documentation generator for Dart source code.'));
    });

    test('has a homepage', () {
      expect(p.homepage, equals('https://github.com/dart-lang/dartdoc'));
    });

    test('is valid', () {
      expect(p.isValid, isTrue);
      expect(p.getInvalidReasons(), isEmpty);
    });

    test('has a readme', () {
      expect(p.getReadmeContents(), isNotNull);
      expect(
          p.getReadmeContents().contents,
          contains(
              'Use `dartdoc` to generate HTML documentaton for your Dart package.'));
    });

    test('has a license', () {
      expect(p.getLicenseContents(), isNotNull);
      expect(p.getLicenseContents().contents,
          contains('Copyright 2014, the Dart project authors.'));
    });

    test('has a changelog', () {
      expect(p.getChangelogContents(), isNotNull);
      expect(p.getChangelogContents().contents, contains('## 0.2.2'));
    });
  });

  group('PackageMeta.fromSdk', () {
    var p = pubPackageMetaProvider.fromDir(defaultSdkDir);

    test('has a name', () {
      expect(p.name, 'Dart');
    });

    test('is valid', () {
      expect(p.isValid, isTrue);
      expect(p.getInvalidReasons(), isEmpty);
      expect(p.isSdk, isTrue);
    });

    test('has a version', () {
      expect(p.version, isNotNull);
    });

    test('has a description', () {
      expect(
          p.description,
          equals(
              'The Dart SDK is a set of tools and libraries for the Dart programming language.'));
    });

    test('has a homepage', () {
      expect(p.homepage, equals('https://github.com/dart-lang/sdk'));
    });

    test('has a readme', () {
      expect(p.getReadmeContents(), isNotNull);
      expect(p.getReadmeContents().contents, startsWith('Welcome'));
    });

    test('does not have a license', () {
      expect(p.getLicenseContents(), isNull);
    });
  });
}
