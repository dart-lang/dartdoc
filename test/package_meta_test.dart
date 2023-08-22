// Copyright (c) 2015, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:dartdoc/src/io_utils.dart';
import 'package:dartdoc/src/package_meta.dart';
import 'package:test/test.dart';

void main() {
  var resourceProvider = pubPackageMetaProvider.resourceProvider;

  test('PackageMeta for a directory without a pubspec is not valid', () {
    var d = resourceProvider.createSystemTemp('test_package_not_valid');
    var p = pubPackageMetaProvider.fromDir(d);
    expect(p, isNull);
  });

  group('PackageMeta for the test package', () {
    late PackageMeta p;

    setUp(() {
      p = pubPackageMetaProvider.fromDir(resourceProvider.getFolder(
          resourceProvider.pathContext.join(
              resourceProvider.pathContext.current,
              'testing',
              'test_package')))!;
    });

    test('readme with corrupt UTF-8 loads without throwing', () {
      expect(
          resourceProvider
              .readAsMalformedAllowedStringSync(p.getReadmeContents()!),
          contains('Here is some messed up UTF-8.\nÃf'));
    });
  });

  group('PackageMeta.fromDir for this package', () {
    var p = pubPackageMetaProvider.fromDir(
        resourceProvider.getFolder(resourceProvider.pathContext.current))!;

    test('has a name', () {
      expect(p.name, 'dartdoc');
    });

    test('has a version', () {
      expect(p.version, isNotNull);
    });

    test('is valid', () {
      expect(p.isValid, isTrue);
      expect(p.getInvalidReasons(), isEmpty);
    });

    test('has a readme', () {
      expect(p.getReadmeContents(), isNotNull);
      expect(
          resourceProvider
              .readAsMalformedAllowedStringSync(p.getReadmeContents()!),
          contains(
              'Use `dart doc` to generate HTML documentation for your Dart package.'));
    });
  });

  group('PackageMeta.fromSdk', () {
    var p =
        pubPackageMetaProvider.fromDir(pubPackageMetaProvider.defaultSdkDir)!;

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

    test('has a homepage', () {
      expect(p.homepage, equals('https://github.com/dart-lang/sdk'));
    });

    test('has a readme', () {
      expect(p.getReadmeContents(), isNotNull);
      expect(
          resourceProvider
              .readAsMalformedAllowedStringSync(p.getReadmeContents()!),
          contains('Welcome to the'));
    });
  });
}
