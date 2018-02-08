// Copyright (c) 2015, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library dartdoc.io_utils_test;

import 'package:dartdoc/src/io_utils.dart';
import 'package:test/test.dart';

void main() {
  group('io utils', () {
    test('converts : to -', () {
      expect(getFileNameFor('dart:io'), 'dart-io.html');
    });

    test('converts . to -', () {
      expect(getFileNameFor('dartdoc.generator'), 'dartdoc-generator.html');
    });
  });
}
