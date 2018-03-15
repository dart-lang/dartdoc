// Copyright (c) 2018, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library dartdoc.options_test;

import 'dart:io';

import 'package:dartdoc/src/dartdoc_options.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

void main() {
  Directory tempDir;
  Directory firstDir;
  Directory firstDirFirstSub;
  Directory secondDir;
  Directory secondDirFirstSub;
  Directory secondDirSecondSub;

  File pubspecYamlOne;
  File dartdocOptionsOne;
  File dartdocOptionsTwo;
  File dartdocOptionsTwoFirstSub;

  setUpAll(() {
    tempDir = Directory.systemTemp.createTempSync('options_test');
    firstDir = new Directory(p.join(tempDir.path, 'firstDir'))..createSync();
    secondDir = new Directory(p.join(tempDir.path, 'secondDir'))..createSync();

    firstDirFirstSub = new Directory(p.join(firstDir.path, 'firstSub'))..createSync();
    secondDirFirstSub = new Directory(p.join(secondDir.path, 'firstSub'))..createSync();
    secondDirSecondSub = new Directory(p.join(secondDir.path, 'secondSub'))..createSync();

    dartdocOptionsOne = new File(p.join(firstDir.path, 'dartdoc_options.yaml'));
    pubspecYamlOne = new File(p.join(firstDirFirstSub.path, 'pubspec.yaml'));
    dartdocOptionsTwo = new File(p.join(secondDir.path, 'dartdoc_options.yaml'));
    dartdocOptionsTwoFirstSub = new File(p.join(secondDirFirstSub.path, 'dartdoc_options.yaml'));

    pubspecYamlOne.writeAsStringSync('# Sentinel to block dartdoc options loading');
    dartdocOptionsOne.writeAsStringSync('''
dartdoc:
  categoryOrder: ['options_one']
        ''');
    dartdocOptionsTwo.writeAsStringSync('''
dartdoc:
  categoryOrder: ['options_two']
        ''');
    dartdocOptionsTwoFirstSub.writeAsStringSync('''
dartdoc:
  categoryOrder: ['options_two_first_sub']
    ''');
  });

  tearDownAll(() {
    tempDir.deleteSync(recursive: true);
  });

  group('dartdoc options', () {

    group('options file finding and loading', () {
      test('DartdocOptions loads defaults', () {
        DartdocOptions options = new DartdocOptions.fromDir(tempDir);
        expect(options.categoryOrder, isEmpty);
      });

      test('DartdocOptions loads defaults if blocked by pubspec.yaml', () {
        DartdocOptions options = new DartdocOptions.fromDir(firstDirFirstSub);
        expect(options.categoryOrder, isEmpty);
      });

      test('DartdocOptions loads a file', () {
        DartdocOptions options = new DartdocOptions.fromDir(firstDir);
        expect(options.categoryOrder, orderedEquals(['options_one']));
      });

      test('DartdocOptions loads a file in parent directories', () {
        DartdocOptions options = new DartdocOptions.fromDir(secondDirSecondSub);
        expect(options.categoryOrder, orderedEquals(['options_two']));
      });

      test('DartdocOptions loads the override file and valid parents', () {
        DartdocOptions options = new DartdocOptions.fromDir(secondDirFirstSub);
        expect(options.categoryOrder, orderedEquals(['options_two_first_sub']));
        expect(options.parent.categoryOrder, orderedEquals(['options_two']));
        expect(options.parent.parent.categoryOrder, isEmpty);
      });
    });
  });
}