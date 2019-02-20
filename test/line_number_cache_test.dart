// Copyright (c) 2016, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library dartdoc.cache_test;

import 'dart:io';

import 'package:dartdoc/src/line_number_cache.dart';
import 'package:path/path.dart' as pathLib;
import 'package:test/test.dart';
import 'package:dartdoc/src/tuple.dart';

void main() {
  group('Verify basic line cache behavior', () {
    Directory _tempDir;

    setUp(() {
      _tempDir = Directory.systemTemp.createTempSync('line_number_cache');
    });

    tearDown(() {
      _tempDir.deleteSync(recursive: true);
    });

    test('validate empty file behavior', () {
      File emptyFile = File(pathLib.join(_tempDir.path, 'empty_file'))
        ..writeAsStringSync('');
      LineNumberCache cache = LineNumberCache();
      expect(cache.lineAndColumn(emptyFile.path, 0), equals(Tuple2(1, 0)));
    });

    test('single line without newline', () {
      File singleLineWithoutNewline =
          File(pathLib.join(_tempDir.path, 'single_line'))
            ..writeAsStringSync('a single line');
      LineNumberCache cache = LineNumberCache();
      expect(cache.lineAndColumn(singleLineWithoutNewline.path, 2),
          equals(Tuple2(1, 2)));
      expect(cache.lineAndColumn(singleLineWithoutNewline.path, 0),
          equals(Tuple2(1, 0)));
    });

    test('multiple line without trailing newline', () {
      File multipleLine = File(pathLib.join(_tempDir.path, 'multiple_line'))
        ..writeAsStringSync('This is the first line\nThis is the second line');
      LineNumberCache cache = LineNumberCache();
      expect(cache.lineAndColumn(multipleLine.path, 60), equals(Tuple2(2, 38)));
      expect(cache.lineAndColumn(multipleLine.path, 30), equals(Tuple2(2, 8)));
      expect(cache.lineAndColumn(multipleLine.path, 5), equals(Tuple2(1, 5)));
      expect(cache.lineAndColumn(multipleLine.path, 0), equals(Tuple2(1, 0)));
    });

    test('multiple lines with trailing newline', () {
      File multipleLine = File(pathLib.join(_tempDir.path, 'multiple_line'))
        ..writeAsStringSync(
            'This is the first line\nThis is the second line\n');
      LineNumberCache cache = LineNumberCache();
      expect(cache.lineAndColumn(multipleLine.path, 60), equals(Tuple2(3, 14)));
      expect(cache.lineAndColumn(multipleLine.path, 30), equals(Tuple2(2, 8)));
      expect(cache.lineAndColumn(multipleLine.path, 5), equals(Tuple2(1, 5)));
      expect(cache.lineAndColumn(multipleLine.path, 0), equals(Tuple2(1, 0)));
    });
  });
}
