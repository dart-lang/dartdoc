// Copyright (c) 2022, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

class _RuntimeStats {
  int totalReferences = 0;
  int resolvedReferences = 0;

  final List<_PerfTask> perfTasks = [];
  final List<_PerfTask> taskQueue = [];

  final Map<String, int> _accumulators = {};

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

  void resetAccumulators(Iterable<String> names) {
    for (var name in names) {
      _accumulators[name] = 0;
    }
  }

  /// Increments the accumulator named [name].
  ///
  /// Accumulator key must exist before calling.
  void incrementAccumulator(String name) =>
      _accumulators.update(name, (c) => c + 1);

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

    if (_accumulators.isNotEmpty) {
      report.writeln('\nAccumulators:');
      _accumulators.forEach((name, count) {
        report.writeln('  $name: $count');
      });
    }

    return report.toString();
  }
}

/// Statistics that get populated as the package graph is built up (like a count
/// of all comment references) and as files are written (like the number of
/// class files that are written).
// TODO(jcollins-g): re-write to something that isn't process-global?
final runtimeStats = _RuntimeStats();

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
