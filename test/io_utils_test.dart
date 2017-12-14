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

  group('printWarningDelta', () {
    Map<String, int> original;
    Map<String, int> current;
    setUp(() {
      original = new Map.fromIterables(["originalwarning", "morewarning", "duplicateoriginalwarning"],
                                       [1, 1, 2]);
      current = new Map.fromIterables(["newwarning", "morewarning", "duplicateoriginalwarning"],
          [1, 1, 1]);
    });

    test('verify output of printWarningDelta', () {
      expect(printWarningDelta('Diff Title', 'oldbranch', original, current),
          equals('*** Diff Title : 1 warnings from original (oldbranch) missing in current:\n'
              'originalwarning\n'
              '*** Diff Title : 1 new warnings not in original (oldbranch)\n'
              'newwarning\n'
              '*** Diff Title : Identical warning quantity changed\n'
              '* Appeared 2 times in original (oldbranch), now 1:\n'
              'duplicateoriginalwarning\n'));
    });

    test('verify output when nothing changes', () {
      expect(printWarningDelta('Diff Title 2', 'oldbranch2', original, original),
          equals('*** Diff Title 2 : No difference in warning output from original (oldbranch2) (3 warnings found)\n'));
    });
  });
}
