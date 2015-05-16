// Copyright (c) 2015, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library dartdoc.dartdoc_test;

import 'dart:io';

import 'package:dartdoc/dartdoc.dart';
import 'package:dartdoc/src/package_meta.dart';
import 'package:unittest/unittest.dart';

void main() {
  group('dartdoc test', () {
    test('version info', () {
      PackageMeta p = new PackageMeta.fromDir(Directory.current);
      expect(p.version, VERSION);
    });
  });
}
