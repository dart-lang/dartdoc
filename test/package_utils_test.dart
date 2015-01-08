// Copyright (c) 2015, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library dartdoc.package_utils_test;

import 'dart:io';

import 'package:unittest/unittest.dart';

import '../lib/src/package_utils.dart';

tests() {
  group('package utils test', () {

    test('get package name', () {
      String name = getPackageName(Directory.current.path);
      expect(name, 'dartdoc');
    });

    test('get package version', () {
      String version = getPackageVersion(Directory.current.path);
      expect(version != null, true);
    });

    test('get package description', () {
      String desc = getPackageDescription(Directory.current.path);
      expect(desc, 'A documentation generator for Dart.');
    });
  });
}
