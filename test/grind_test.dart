// Copyright (c) 2015, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library dartdoc.io_utils_test;

import 'package:test/test.dart';

import '../tool/grind.dart' hide test;

void main() {
  group('printWarningDelta', () {
    WarningsCollection original, current;
    WarningsCollection originalWithDirs, currentWithDirs;
    setUp(() {
      original =
          WarningsCollection('/a/tempdir', '/pubcache/path', 'oldbranch');
      original.add('originalwarning');
      original.add('morewarning');
      original.add('duplicateoriginalwarning');
      original.add('duplicateoriginalwarning');
      current = WarningsCollection('/a/tempdir2', '/pubcache/path2', 'current');
      current.add('newwarning');
      current.add('morewarning');
      current.add('duplicateoriginalwarning');
      originalWithDirs = WarningsCollection(
          '/a/tempdirFOO', '/pubcache/pathFOO', 'DirsOriginal');
      originalWithDirs.add(
          'originalWarning found in /a/tempdirFOO/some/subdir/program.dart!!!!');
      originalWithDirs.add(
          'another originalWarning found in /pubcache/pathFOO/some/package/lib/thingy.dart!!!');
      originalWithDirs.add(
          'insufficent exclamation mark warning found in /pubcache/pathFOO/some/package/lib/thingy.dart.');
      originalWithDirs.add(
          'another originalWarning found in /a/tempdirFOO/some/subdir/program.dart');
      currentWithDirs = WarningsCollection(
          '/a/tempdirBAR', '/pubcache/pathBAR', 'DirsCurrent');
      currentWithDirs.add(
          'originalWarning found in /a/tempdirBAR/some/subdir/program.dart!!!!');
      currentWithDirs.add(
          'another originalWarning found in /pubcache/pathBAR/some/package/lib/thingy.dart!!!');
      currentWithDirs.add(
          'insufficent exclamation mark warning found in /pubcache/pathBAR/some/package/lib/thingy.dart.');
      currentWithDirs.add(
          'another originalWarning found in /a/tempdirBAR/some/other/subdir/program.dart');
    });

    test('verify that paths are substituted when comparing warnings', () {
      expect(
          originalWithDirs.getPrintableWarningDelta(
              'Dirs diff title', currentWithDirs),
          equals(
              '*** Dirs diff title : 1 warnings from DirsOriginal, missing in DirsCurrent:\n'
              'another originalWarning found in /a/tempdirFOO/some/subdir/program.dart\n'
              '*** Dirs diff title : 1 new warnings in DirsCurrent, missing in DirsOriginal\n'
              'another originalWarning found in /a/tempdirBAR/some/other/subdir/program.dart\n'
              '*** Dirs diff title : Difference in warning output found for 2 warnings (5 warnings found)"\n'));
    });

    test('verify output of printWarningDelta', () {
      expect(
          original.getPrintableWarningDelta('Diff Title', current),
          equals(
              '*** Diff Title : 1 warnings from oldbranch, missing in current:\n'
              'originalwarning\n'
              '*** Diff Title : 1 new warnings in current, missing in oldbranch\n'
              'newwarning\n'
              '*** Diff Title : Identical warning quantity changed\n'
              '* Appeared 2 times in oldbranch, 1 in current:\n'
              'duplicateoriginalwarning\n'
              '*** Diff Title : Difference in warning output found for 3 warnings (4 warnings found)"\n'));
    });

    test('verify output when nothing changes', () {
      expect(
          original.getPrintableWarningDelta('Diff Title 2', original),
          equals(
              '*** Diff Title 2 : No difference in warning output from oldbranch to oldbranch (3 warnings found)\n'));
    });
  });
}
