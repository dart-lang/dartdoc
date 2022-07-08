// Copyright (c) 2015, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library dartdoc.model_utils_test;

import 'package:dartdoc/src/model_utils.dart';
import 'package:test/test.dart';

void main() {
  group('match glob', () {
    test('basic POSIX', () {
      expect(
          matchGlobs(['/a/b/*', '/b/c/*'], '/b/c/d', isWindows: false), isTrue);
      expect(matchGlobs(['/q/r/s'], '/foo', isWindows: false), isFalse);
    });

    test('basic Windows', () {
      expect(matchGlobs([r'C:\a\b\*'], r'c:\a\b\d', isWindows: true), isTrue);
    });

    test('Windows does not pass for different drive letters', () {
      expect(matchGlobs([r'C:\a\b\*'], r'D:\a\b\d', isWindows: true), isFalse);
    });
  });
}
