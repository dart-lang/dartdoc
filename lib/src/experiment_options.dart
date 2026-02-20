// Copyright (c) 2018, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// Implementation of Dart language experiment option handling for dartdoc.
/// See https://github.com/dart-lang/sdk/blob/main/docs/process/experimental-flags.md.
library;

import 'package:analyzer/file_system/file_system.dart';
// ignore: implementation_imports
import 'package:analyzer/src/dart/analysis/experiments.dart';
import 'package:dartdoc/src/dartdoc_options.dart';

mixin DartdocExperimentOptionContext implements DartdocOptionContextBase {
  List<String> get enableExperiment =>
      optionSet['enable-experiment'].valueAt(context);
}

List<DartdocOption<Object>> createExperimentOptions(
    ResourceProvider resourceProvider) {
  var knownFeatures = ExperimentStatus.knownFeatures.values;
  var featureHelpTexts =
      knownFeatures.map((e) => '    [no-]${e.enableString}: ${e.documentation} '
          '(default: ${e.isEnabledByDefault})');
  return [
    DartdocOptionArgFile<List<String>>('enable-experiment', [], resourceProvider,
        splitCommas: true,
        help: 'Enable or disable listed experiments.\n'
            '${featureHelpTexts.join('\n')}'),
  ];
}
