// Copyright (c) 2015, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library dartdoc.package_utils_test;

import 'dart:io';

import 'package:cli_util/cli_util.dart';
import 'package:dartdoc/src/package_meta.dart';
import 'package:unittest/unittest.dart';

void main() {
  group('PackageMeta.fromDir', () {
    PackageMeta p = new PackageMeta.fromDir(Directory.current);

    test('name', () {
      expect(p.name, 'dartdoc');
    });

    test('version', () {
      expect(p.version, isNotNull);
    });

    test('description', () {
      expect(p.description, isNotNull);
    });

    test('homepage', () {
      expect(p.homepage, isNotNull);
    });

    test('getReadmeContents()', () {
      expect(p.getReadmeContents(), isNotNull);
    });

    test('getLicenseContents()', () {
      expect(p.getLicenseContents(), isNotNull);
    });

    test('getChangelogContents()', () {
      expect(p.getChangelogContents(), isNotNull);
    });
  });

  group('PackageMeta.fromSdk', () {
    PackageMeta p = new PackageMeta.fromSdk(getSdkDir());

    test('name', () {
      expect(p.name, 'Dart API Reference');
    });

    test('version', () {
      expect(p.version, isNotNull);
    });

    test('description', () {
      expect(p.description, isNotNull);
    });

    test('homepage', () {
      expect(p.homepage, isNotNull);
    });

    test('getReadmeContents()', () {
      // TODO: This is null for SDK 1.10.
      //expect(p.getReadmeContents(), isNotNull);
    });

    test('getLicenseContents()', () {
      expect(p.getLicenseContents(), isNull);
    });
  });
}
