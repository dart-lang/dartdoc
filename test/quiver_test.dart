// Copyright (c) 2020, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:dartdoc/src/quiver.dart';
import 'package:test/test.dart';

void main() {
  group('concat', () {
    test('should handle empty input iterables', () {
      expect(concat([]), isEmpty);
    });

    test('should handle single input iterables', () {
      expect(
          concat([
            [1, 2, 3]
          ]),
          [1, 2, 3]);
    });

    test('should chain multiple input iterables', () {
      expect(
          concat([
            [1, 2, 3],
            [-1, -2, -3]
          ]),
          [1, 2, 3, -1, -2, -3]);
    });

    test('should reflectchanges in the inputs', () {
      var a = [1, 2];
      var b = [4, 5];
      var ab = concat([a, b]);
      expect(ab, [1, 2, 4, 5]);
      a.add(3);
      b.add(6);
      expect(ab, [1, 2, 3, 4, 5, 6]);
    });
  });
}
