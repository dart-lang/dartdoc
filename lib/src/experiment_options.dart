// Copyright (c) 2018, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

///
/// Implementation of Dart language experiment option handling for dartdoc.
/// See https://github.com/dart-lang/sdk/blob/master/docs/process/experimental-flags.md.
///
library dartdoc.experiment_options;

import 'package:analyzer/src/dart/analysis/experiments.dart';
import 'package:dartdoc/src/dartdoc_options.dart';

abstract class DartdocExperimentOptionContext
    implements DartdocOptionContextBase {
  List<String> get enableExperiment =>
      optionSet['enable-experiment'].valueAt(context);
  ExperimentStatus get experimentStatus =>
      optionSet['experimentStatus'].valueAt(context);
}

// TODO(jcollins-g): Implement YAML parsing for these flags and generation
// of [DartdocExperimentOptionContext], once a YAML file is available.
Future<List<DartdocOption>> createExperimentOptions() async {
  return <DartdocOption>[
    // TODO(jcollins-g): Consider loading experiment values from dartdoc_options.yaml?
    DartdocOptionArgOnly<List<String>>('enable-experiment', [],
        help: 'Enable or disable listed experiments.\n' +
            ExperimentStatus.knownFeatures.values
                .where((e) => e.documentation != null)
                .map((e) =>
                    '    [no-]${e.enableString}: ${e.documentation} (default: ${e.isEnabledByDefault})')
                .join('\n')),
    DartdocOptionSyntheticOnly<ExperimentStatus>(
        'experimentStatus',
        (option, dir) => ExperimentStatus.fromStrings(
            option.parent['enable-experiment'].valueAt(dir))),
  ];
}
