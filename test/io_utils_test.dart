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

  group('TaskQueue', () {
    /// A special test designed to check shared [TaskQueue]
    /// behavior when exceptions occur after a delay in the passed closures to
    /// [TaskQueue.add].
    test('no deadlock when delayed exceptions fire in closures', () async {
      var sharedTracker = TaskQueue(maxJobs: 2);
      expect(() async {
        var t =
            Future.delayed(Duration(milliseconds: 10), () => throw Exception());
        await sharedTracker.add(() => t);
        return t;
      }, throwsA(const TypeMatcher<Exception>()));
      expect(() async {
        var t =
            Future.delayed(Duration(milliseconds: 10), () => throw Exception());
        await sharedTracker.add(() => t);
        return t;
      }, throwsA(const TypeMatcher<Exception>()));
      expect(() async {
        var t =
            Future.delayed(Duration(milliseconds: 10), () => throw Exception());
        // ignore: empty_catches
        await sharedTracker.add(() => t);
        return t;
      }, throwsA(const TypeMatcher<Exception>()));
      expect(() async {
        var t =
            Future.delayed(Duration(milliseconds: 10), () => throw Exception());
        await sharedTracker.add(() => t);
        return t;
      }, throwsA(const TypeMatcher<Exception>()));

      /// We deadlock here if the exception is not handled properly.
      await sharedTracker.tasksComplete;
    });

    test('basic sequential processing works with no deadlock', () async {
      var completed = <int>{};
      var tracker = TaskQueue(maxJobs: 1);
      await tracker.add(() async => completed.add(1));
      await tracker.add(() async => completed.add(2));
      await tracker.add(() async => completed.add(3));
      await tracker.tasksComplete;
      expect(completed.length, equals(3));
    });

    test('basic sequential processing works on exceptions', () async {
      var completed = <int>{};
      var tracker = TaskQueue(maxJobs: 1);
      await tracker.add(() async => completed.add(0));
      await tracker.add(() async => throw Exception()).catchError((e) => -1);
      await tracker.add(() async => throw Exception()).catchError((e) => -1);
      await tracker.add(() async => completed.add(3));
      await tracker.tasksComplete;
      expect(completed.length, equals(2));
    });

    /// Verify that if there are more exceptions than the maximum number
    /// of in-flight [Future]s that there is no deadlock.
    test('basic parallel processing works with no deadlock', () async {
      var completed = <int>{};
      var tracker = TaskQueue(maxJobs: 10);
      for (var i = 0; i < 100; i++) {
        await tracker.add(() async => completed.add(i));
      }
      await tracker.tasksComplete;
      expect(completed.length, equals(100));
    });

    test('basic parallel processing works on exceptions', () async {
      var completed = <int>{};
      var tracker = TaskQueue(maxJobs: 10);
      for (var i = 0; i < 50; i++) {
        await tracker.add(() async => completed.add(i));
      }
      for (var i = 50; i < 65; i++) {
        try {
          await tracker.add(() async => throw TestException());
        } on TestException {
          // Ignore
        }
      }
      for (var i = 65; i < 100; i++) {
        await tracker.add(() async => completed.add(i));
      }
      await tracker.tasksComplete;
      expect(completed.length, equals(85));
    });
  });
}

class TestException implements Exception {}
