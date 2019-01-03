// Copyright (c) 2018, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

///
/// Implementation of Dart language experiment option handling for dartdoc.
/// See https://github.com/dart-lang/sdk/blob/master/docs/process/experimental-flags.md.
///
library dartdoc.experiment_options;

import 'dart:io';

import 'package:dartdoc/src/dartdoc_options.dart';

/// Assumes the immediate parent of this option returns a list of strings that
/// we can use to calculate the value of this experiment.
class DartdocExperimentOption extends DartdocOption<bool> {
  /// Whether overriding the default is allowed for this experiment.
  final bool expired;

  /// Whether this option should be hidden in help text.
  final bool hide;

  @override
  DartdocOption<List<String>> get parent => super.parent;

  DartdocExperimentOption(String name, bool defaultsTo,
      {String help = '',
      bool expired = false,
      bool hide = false})
      : this.expired = expired, this.hide = hide, super(name, defaultsTo, help, false, false, false, null);

  @override
  bool valueAt(Directory dir) {
    bool value = defaultsTo;
    for (String option in parent.valueAt(dir)) {
      if (option == name) {
        value = true;
      } else if (option == 'no-${name}') {
        value = false;
      }
    }
    if (expired && value != defaultsTo) {
      throw new DartdocOptionError('Experiment ${name} can not be set to ${value} -- experiment has expired');
    }
    return value;
  }
}

abstract class DartdocExperimentOptionContext implements DartdocOptionContextBase {
  bool get experimentConstantUpdate2018 => optionSet['enable-experiment']['constant-update-2018'].valueAt(context);
  bool get experimentNonNullable => optionSet['enable-experiment']['non-nullable'].valueAt(context);
  bool get experimentSetLiterals => optionSet['enable-experiment']['set-literals'].valueAt(context);
}

// TODO(jcollins-g): Implement YAML parsing for these flags and generation
// of [DartdocExperimentOptionContext], once a YAML file is available.
Future<List<DartdocOption>> createExperimentOptions() async {
  List<DartdocExperimentOption> experiments = [
    new DartdocExperimentOption('constant-update-2018', false, help: 'Q4 2018 Constant Update'),
    new DartdocExperimentOption('non-nullable', false, help: 'Non Nullable'),
    new DartdocExperimentOption('set-literals', false, help: 'Set Literals'),
  ];

  return <DartdocOption>[
    new DartdocOptionArgFile<List<String>>('enable-experiment', [],
        help: 'Enable or disable listed experiments.\n' +
            experiments.where((e) => !e.hide).map((e) => '    [no-]${e.name}: ${e.help} (default: ${e.defaultsTo})').join('\n'))..addAll(experiments),
  ];
}
