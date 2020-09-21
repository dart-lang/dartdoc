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

  group('MultiFutureTracker', () {
    test('basic sequential processing works with no deadlock', () async {
      var completed = <int>{};
      var tracker = MultiFutureTracker(1);
      await tracker.addFutureFromClosure(() async => completed.add(1));
      await tracker.addFutureFromClosure(() async => completed.add(2));
      await tracker.addFutureFromClosure(() async => completed.add(3));
      expect(completed.length, equals(3));
    });

    test('basic sequential processing works with no deadlock on exceptions',
        () async {
      var completed = <int>{};
      var tracker = MultiFutureTracker(1);
      await tracker.addFutureFromClosure(() async => completed.add(1));
      await tracker.addFutureFromClosure(() async => throw Exception);
      await tracker.addFutureFromClosure(() async => completed.add(3));
      expect(completed.length, equals(2));
    });

    test('basic parallel processing works with no deadlock', () async {
      var completed = <int>{};
      var tracker = MultiFutureTracker(10);
      for (var i = 0; i < 100; i++) {
        await tracker.addFutureFromClosure(() async => completed.add(i));
      }
      await tracker.wait();
      expect(completed.length, equals(100));
    });

    test('basic parallel processing works with no deadlock on exceptions',
        () async {
      var completed = <int>{};
      var tracker = MultiFutureTracker(10);
      for (var i = 0; i < 50; i++) {
        await tracker.addFutureFromClosure(() async => completed.add(i));
      }
      await tracker.addFutureFromClosure(() async => throw Exception);
      for (var i = 51; i < 100; i++) {
        await tracker.addFutureFromClosure(() async => completed.add(i));
      }
      await tracker.wait();
      expect(completed.length, equals(99));
    });
  });
}
