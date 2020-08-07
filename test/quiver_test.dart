// Copyright (c) 2020, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:test/test.dart';
import 'package:dartdoc/src/quiver.dart';

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

    test('should throw for null input', () {
      expect(() => concat(null), throwsNoSuchMethodError);
    });

    test('should throw if any input is null', () {
      expect(
          () => concat([
                [1, 2],
                null,
                [3, 4]
              ]).toList(),
          throwsNoSuchMethodError);
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

  group('hash', () {
    test('hash2 should return an int', () {
      var h = hash2('123', 456);
      expect(h, isA<int>());
    });

    test('hash3 should return an int', () {
      var h = hash3('123', 456, true);
      expect(h, isA<int>());
    });

    test('hash4 should return an int', () {
      var h = hash4('123', 456, true, []);
      expect(h, isA<int>());
    });
  });
}
