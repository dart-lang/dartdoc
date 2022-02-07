// Copyright (c) 2021, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:dartdoc/src/model/comment_referable.dart';
import 'package:dartdoc/src/model/model.dart';

class MatchingLinkResult {
  final CommentReferable? commentReferable;
  final bool warn;

  MatchingLinkResult(this.commentReferable, {this.warn = true});

  @override
  bool operator ==(Object other) {
    return other is MatchingLinkResult &&
        commentReferable == other.commentReferable &&
        warn == other.warn;
  }

  @override
  int get hashCode => Object.hash(commentReferable, warn);

  @override
  String toString() {
    return 'element: [${commentReferable is Constructor ? 'new ' : ''}${commentReferable?.fullyQualifiedName}] warn: $warn';
  }
}

class _RuntimeStats {
  int totalReferences = 0;
  int resolvedReferences = 0;

  List<_PerfTask> perfTasks = [];
  List<_PerfTask> taskQueue = [];

  String _valueAndPercent(int references) {
    final percent = references.toDouble() / totalReferences.toDouble() * 100;
    return '$references (${percent.toStringAsFixed(3)}%)';
  }

  /// Start a new, named, performance task.
  ///
  /// Performance tasks may be nested. Note that this API currently depends on
  /// inner tasks ending before their parent tasks, and, sibling tasks being
  /// sequential (and not parallelized).
  void startPerfTask(String name) {
    if (taskQueue.isEmpty) {
      var task = _PerfTask(name);
      perfTasks.add(task);
      taskQueue.add(task);
    } else {
      var task = _PerfTask(name);
      taskQueue.last.children.add(task);
      taskQueue.add(task);
    }
  }

  /// End the last started performance task.
  void endPerfTask() {
    taskQueue.removeLast().finish();
  }

  String buildReport() {
    final report = StringBuffer();
    report.writeln('\nReference Counts:');
    report.writeln('  total references: $totalReferences');
    report.writeln('  resolved references:  '
        '${_valueAndPercent(resolvedReferences)}');

    if (perfTasks.isNotEmpty) {
      report.writeln('\nRuntime performance:');
      for (var task in perfTasks) {
        task.writeTo(report);
      }
    }

    return report.toString();
  }
}

/// TODO(jcollins-g): re-write to something that isn't process-global?
final _RuntimeStats runtimeStats = _RuntimeStats();

class _PerfTask {
  final String name;
  final Stopwatch timer = Stopwatch();
  List<_PerfTask> children = [];

  _PerfTask(this.name) {
    timer.start();
  }

  void finish() {
    timer.stop();
  }

  void writeTo(StringBuffer buf) {
    _writeTo(buf, '');
  }

  void _writeTo(StringBuffer buf, String indent) {
    buf.write('$indent$name '.padRight(32));
    buf.writeln('${timer.elapsedMilliseconds}ms'.padLeft(8));
    for (var child in children) {
      child._writeTo(buf, '  $indent');
    }
  }
}
