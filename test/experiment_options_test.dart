// Copyright (c) 2018, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// Unit tests for lib/src/experiment_options.dart.
library dartdoc.experiment_options_test;

import 'dart:io';

import 'package:analyzer/src/dart/analysis/experiments.dart';
import 'package:dartdoc/src/dartdoc_options.dart';
import 'package:dartdoc/src/experiment_options.dart';
import 'package:test/test.dart';

void main() {
  DartdocOptionSet experimentOptions;
  Directory emptyTempDir;
  ExperimentalFeature defaultOnNotExpired, defaultOffNotExpired;
  ExperimentalFeature defaultOnExpired, defaultOffExpired;

  setUp(() async {
    experimentOptions = await DartdocOptionSet.fromOptionGenerators(
        'dartdoc', [createExperimentOptions]);
  });

  setUpAll(() {
    emptyTempDir =
        Directory.systemTemp.createTempSync('experiment_options_test_empty');
    // We don't test our functionality at all unless ExperimentStatus has at least
    // one of these.  TODO(jcollins-g): make analyzer+dartdoc connection
    // more amenable to testing.
    defaultOnNotExpired = ExperimentStatus.knownFeatures.values.firstWhere(
        (f) => f.isEnabledByDefault && !f.isExpired,
        orElse: () => null);
    defaultOffNotExpired = ExperimentStatus.knownFeatures.values.firstWhere(
        (f) => !f.isEnabledByDefault && !f.isExpired,
        orElse: () => null);
    assert(defaultOnNotExpired != null || defaultOffNotExpired != null,
        'No experimental options that are not expired found');

    // The "bogus" entries should always exist.
    defaultOnExpired = ExperimentStatus.knownFeatures.values
        .firstWhere((f) => f.isEnabledByDefault && f.isExpired);
    defaultOffExpired = ExperimentStatus.knownFeatures.values
        .firstWhere((f) => !f.isEnabledByDefault && f.isExpired);
  });

  tearDownAll(() {
    emptyTempDir.deleteSync(recursive: true);
  });

  group('Experimental options test', () {
    test('Defaults work for all options', () {
      experimentOptions.parseArguments([]);
      var tester = DartdocOptionContext(experimentOptions, emptyTempDir);
      if (defaultOnNotExpired != null) {
        expect(tester.experimentStatus.isEnabled(defaultOnNotExpired), isTrue);
      }
      if (defaultOffNotExpired != null) {
        expect(
            tester.experimentStatus.isEnabled(defaultOffNotExpired), isFalse);
      }
      expect(tester.experimentStatus.isEnabled(defaultOnExpired), isTrue);
      expect(tester.experimentStatus.isEnabled(defaultOffExpired), isFalse);
    });

    test('Overriding defaults works via args', () {
      // Set all arguments to non-default values.
      experimentOptions.parseArguments([
        '--enable-experiment',
        '${defaultOffNotExpired?.disableString},${defaultOnNotExpired?.disableString},${defaultOnExpired.disableString},${defaultOffExpired.enableString}'
      ]);
      var tester = DartdocOptionContext(experimentOptions, emptyTempDir);
      if (defaultOnNotExpired != null) {
        expect(tester.experimentStatus.isEnabled(defaultOnNotExpired), isFalse);
      }
      if (defaultOffNotExpired != null) {
        expect(
            tester.experimentStatus.isEnabled(defaultOffNotExpired), isFalse);
      }
      expect(tester.experimentStatus.isEnabled(defaultOnExpired), isTrue);
      expect(tester.experimentStatus.isEnabled(defaultOffExpired), isFalse);
    });
  });
}
