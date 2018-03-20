// Copyright (c) 2015, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library dartdoc.package_utils_test;

import 'dart:io';

import 'package:dartdoc/src/package_meta.dart';
import 'package:dartdoc/src/sdk.dart';
import 'package:path/path.dart' as pathLib;
import 'package:test/test.dart';

void main() {
  group('PackageMeta for a directory without a pubspec', () {
    PackageMeta p;

    setUp(() {
      var d = new Directory(
          pathLib.join(Directory.current.path, 'testing/test_package_not_valid'));
      if (!d.existsSync()) {
        throw "$d cannot be found";
      }
      p = new PackageMeta.fromDir(d);
    });

    test('is not valid', () {
      expect(p.isValid, isFalse);
      expect(p.getInvalidReasons(), isNotEmpty);
      expect(p.getInvalidReasons(), contains('no pubspec.yaml found'));
    });
  });

  group('PackageMeta.fromDir for this package', () {
    PackageMeta p = new PackageMeta.fromDir(Directory.current);

    test('has a name', () {
      expect(p.name, 'dartdoc');
    });

    test('has a version', () {
      expect(p.version, isNotNull);
    });

    test('has a description', () {
      expect(p.description, equals('A documentation generator for Dart.'));
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
    PackageMeta p = new PackageMeta.fromSdk(getSdkDir());

    test('has a name', () {
      expect(p.name, 'Dart SDK');
    });

    test('is valid', () {
      expect(p.isValid, isTrue);
      expect(p.getInvalidReasons(), isEmpty);
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
      expect(p.getReadmeContents().contents,
          startsWith('Welcome to the Dart API reference documentation'));
    });

    test('does not have a license', () {
      expect(p.getLicenseContents(), isNull);
    });
  });
}
