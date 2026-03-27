// Copyright (c) 2026, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:dartdoc/src/dartdoc.dart';
import 'package:dartdoc/src/dartdoc_options.dart';
import 'package:dartdoc/src/model/model.dart';
import 'package:dartdoc/src/package_meta.dart';
import 'package:dartdoc/src/runtime_stats.dart';

/// Benchmarks the performance of [Dartdoc].
///
/// Usage: `dart tool/benchmark.dart`
void main() async {
  var config = parseOptions(pubPackageMetaProvider, ['--no-generate-docs'])!;
  var packageBuilder = PubPackageBuilder(config, pubPackageMetaProvider);
  var dartdoc = Dartdoc.fromContext(config, packageBuilder);

  var sw = Stopwatch()..start();
  print('Building package graph...');
  runtimeStats.startPerfTask('buildPackageGraph');
  var packageGraph = await packageBuilder.buildPackageGraph();
  runtimeStats.endPerfTask();
  print('Package graph built in: ${sw.elapsedMilliseconds} ms');

  sw.reset();
  print('Generating docs...');
  await dartdoc.generator.generate(packageGraph);
  print('Docs generated in: ${sw.elapsedMilliseconds} ms');

  print(runtimeStats.buildReport());
}
