// Copyright (c) 2015, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library dartdoc.package_utils_test;

import 'package:dartdoc/src/io_utils.dart';
import 'package:dartdoc/src/package_meta.dart';
import 'package:test/test.dart';

void main() {
  var resourceProvider = pubPackageMetaProvider.resourceProvider;

  group('PackageMeta for a directory without a pubspec', () {
    PackageMeta p;

    setUp(() {
      var d = resourceProvider.createSystemTemp('test_package_not_valid');
      p = pubPackageMetaProvider.fromDir(d);
    });

    test('is not valid', () {
      expect(p, isNull);
    });
  });

  group('PackageMeta for the test package', () {
    PackageMeta p;

    setUp(() {
      p = pubPackageMetaProvider.fromDir(resourceProvider.getFolder(
          resourceProvider.pathContext.join(
              resourceProvider.pathContext.current,
              'testing',
              'test_package')));
    });

    test('readme with corrupt UTF-8 loads without throwing', () {
      expect(
          resourceProvider
              .readAsMalformedAllowedStringSync(p.getReadmeContents()),
          contains('Here is some messed up UTF-8.\nÃf'));
    });
  });

  group('PackageMeta.fromDir for this package', () {
    var p = pubPackageMetaProvider.fromDir(
        resourceProvider.getFolder(resourceProvider.pathContext.current));

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
          resourceProvider
              .readAsMalformedAllowedStringSync(p.getReadmeContents()),
          contains(
              'Use `dartdoc` to generate HTML documentaton for your Dart package.'));
    });

    test('has a license', () {
      expect(p.getLicenseContents(), isNotNull);
      expect(
          resourceProvider
              .readAsMalformedAllowedStringSync(p.getLicenseContents()),
          contains('Copyright 2014, the Dart project authors.'));
    });

    test('has a changelog', () {
      expect(p.getChangelogContents(), isNotNull);
      expect(
          resourceProvider
              .readAsMalformedAllowedStringSync(p.getChangelogContents()),
          contains('## 0.2.2'));
    });
  });

  group('PackageMeta.fromSdk', () {
    var p =
        pubPackageMetaProvider.fromDir(pubPackageMetaProvider.defaultSdkDir);

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
      expect(
          resourceProvider
              .readAsMalformedAllowedStringSync(p.getReadmeContents()),
          startsWith('Welcome'));
    });

    test('does not have a license', () {
      expect(p.getLicenseContents(), isNull);
    });
  });
}
