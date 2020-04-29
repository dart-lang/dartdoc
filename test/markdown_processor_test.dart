// Copyright (c) 2016, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library dartdoc.markdown_processor_test;

import 'package:dartdoc/src/markdown_processor.dart';
import 'package:test/test.dart';

void main() {
  group('findFreeHangingGenericsPositions()', () {
    test('returns empty array if all the generics are in []', () {
      final string = 'One two [three<four>] [[five<six>] seven eight';
      expect(findFreeHangingGenericsPositions(string), equals([]));
    });

    test('returns positions of generics outside of []', () {
      final string = 'One two<int> [[three<four>] five<six>] seven<eight>';
      expect(findFreeHangingGenericsPositions(string), equals([7, 44]));
    });

    test('ignores HTML tags', () {
      final string =
          'One two<int> foo<pre> [[three<four>] five<six>] bar</pre> seven<eight>';
      expect(findFreeHangingGenericsPositions(string), equals([7, 63]));
    });
  });
}
