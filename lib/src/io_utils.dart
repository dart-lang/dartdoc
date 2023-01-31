// Copyright (c) 2014, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// This is a helper library to make working with io easier.
library dartdoc.io_utils;

import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:io' as io;

import 'package:analyzer/file_system/file_system.dart';
import 'package:analyzer/file_system/physical_file_system.dart';
import 'package:path/path.dart' as p show Context;

const Encoding utf8AllowMalformed = Utf8Codec(allowMalformed: true);

extension PathExtensions on p.Context {
  /// Returns a canonicalized path including the home directory in place of
  /// tilde references.
  String canonicalizeWithTilde(String originalPath) =>
      canonicalize(resolveTildePath(originalPath));

  /// Return a resolved path including the home directory in place of tilde
  /// references.
  String resolveTildePath(String originalPath) {
    if (!originalPath.startsWith('~/')) {
      return originalPath;
    }

    String homeDir;

    if (io.Platform.isWindows) {
      homeDir = absolute(io.Platform.environment['USERPROFILE'] ?? '\'');
    } else {
      homeDir = absolute(io.Platform.environment['HOME'] ?? '/');
    }

    return join(homeDir, originalPath.substring(2));
  }
}

extension ResourceProviderExtensions on ResourceProvider {
  Folder createSystemTemp(String prefix) {
    if (this is PhysicalResourceProvider) {
      return getFolder(io.Directory.systemTemp.createTempSync(prefix).path);
    } else {
      return getFolder(pathContext.join('${pathContext.separator}tmp', prefix))
        ..create();
    }
  }

  String get resolvedExecutable {
    if (this is PhysicalResourceProvider) {
      return io.Platform.resolvedExecutable;
    } else {
      throw UnimplementedError('resolvedExecutable not implemented');
    }
  }

  bool isExecutable(File file) {
    if (this is PhysicalResourceProvider) {
      var mode = io.File(file.path).statSync().mode;
      return (0x1 & ((mode >> 6) | (mode >> 3) | mode)) != 0;
    } else {
      throw UnimplementedError('isExecutable not implemented');
    }
  }

  bool isNotFound(File file) {
    if (this is PhysicalResourceProvider) {
      return io.File(file.path).statSync().type ==
          io.FileSystemEntityType.notFound;
    } else {
      return !file.exists;
    }
  }

  String readAsMalformedAllowedStringSync(File file) {
    if (this is PhysicalResourceProvider) {
      return io.File(file.path).readAsStringSync(encoding: utf8AllowMalformed);
    } else {
      return file.readAsStringSync();
    }
  }
}

/// Converts `.` and `:` into `-`, adding a ".html" extension.
///
/// For example:
///
/// * dart.dartdoc => dart_dartdoc.html
/// * dart:core => dart_core.html
String getFileNameFor(String name) =>
    '${name.replaceAll(_libraryNameRegExp, '-')}.html';

final _libraryNameRegExp = RegExp('[.:]');

typedef TaskQueueClosure<T> = Future<T> Function();

void _defaultOnComplete() {}

class _TaskQueueItem<T> {
  _TaskQueueItem(this._closure, this._completer,
      {this.onComplete = _defaultOnComplete});

  final TaskQueueClosure<T> _closure;
  final Completer<T> _completer;
  void Function() onComplete;

  Future<void> run() async {
    try {
      _completer.complete(await _closure());
    } catch (e) {
      _completer.completeError(e);
    } finally {
      onComplete.call();
    }
  }
}

/// A task queue of Futures to be completed in parallel, throttling
/// the number of simultaneous tasks.
///
/// The tasks return results of type T.
class TaskQueue<T extends Object> {
  /// Creates a task queue with a maximum number of simultaneous jobs.
  /// The [maxJobs] parameter defaults to the number of CPU cores on the
  /// system.
  TaskQueue({int? maxJobs})
      : maxJobs = maxJobs ?? io.Platform.numberOfProcessors;

  /// The maximum number of jobs that this queue will run simultaneously.
  final int maxJobs;

  final Queue<_TaskQueueItem<T>> _pendingTasks = Queue<_TaskQueueItem<T>>();
  final Set<_TaskQueueItem<T>> _activeTasks = <_TaskQueueItem<T>>{};
  final Set<Completer<void>> _completeListeners = <Completer<void>>{};

  /// Returns a future that completes when all tasks in the [TaskQueue] are
  /// complete.
  Future<void> get tasksComplete {
    // In case this is called when there are no tasks, we want it to
    // signal complete immediately.
    if (_activeTasks.isEmpty && _pendingTasks.isEmpty) {
      return Future<void>.value();
    }
    final completer = Completer<void>();
    _completeListeners.add(completer);
    return completer.future;
  }

  /// Adds a single closure to the task queue, returning a future that
  /// completes when the task completes.
  Future<T> add(TaskQueueClosure<T> task) {
    final completer = Completer<T>();
    _pendingTasks.add(_TaskQueueItem<T>(task, completer));
    if (_activeTasks.length < maxJobs) {
      _processTask();
    }
    return completer.future;
  }

  // Process a single task.
  void _processTask() {
    if (_pendingTasks.isNotEmpty && _activeTasks.length <= maxJobs) {
      final item = _pendingTasks.removeFirst();
      _activeTasks.add(item);
      item.onComplete = () {
        _activeTasks.remove(item);
        _processTask();
      };
      item.run();
    } else {
      _checkForCompletion();
    }
  }

  void _checkForCompletion() {
    if (_activeTasks.isEmpty && _pendingTasks.isEmpty) {
      for (final completer in _completeListeners) {
        if (!completer.isCompleted) {
          completer.complete();
        }
      }
      _completeListeners.clear();
    }
  }
}
