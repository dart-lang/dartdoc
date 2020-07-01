// Copyright (c) 2018, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// Unit tests for lib/src/experiment_options.dart.
library dartdoc.experiment_options_test;

import 'dart:cli';
import 'dart:io';

import 'package:analyzer/src/dart/analysis/experiments.dart';
import 'package:analyzer/src/dart/analysis/experiments_impl.dart';
import 'package:dartdoc/src/dartdoc_options.dart';
import 'package:dartdoc/src/experiment_options.dart';
import 'package:test/test.dart';

void main() {
  Directory emptyTempDir;
  ExperimentalFeature defaultOnNotExpired, defaultOffNotExpired;
  ExperimentalFeature defaultOnExpired, defaultOffExpired;

  void withSyntheticExperimentalFeatures(
    void Function() operation,
  ) {
    defaultOnNotExpired = ExperimentalFeature(
      index: 0,
      enableString: 'a',
      isEnabledByDefault: true,
      isExpired: false,
      documentation: 'a',
      firstSupportedVersion: '1.0.0',
    );
    defaultOffNotExpired = ExperimentalFeature(
      index: 1,
      enableString: 'b',
      isEnabledByDefault: false,
      isExpired: false,
      documentation: 'b',
      firstSupportedVersion: null,
    );
    defaultOnExpired = ExperimentalFeature(
      index: 2,
      enableString: 'c',
      isEnabledByDefault: true,
      isExpired: true,
      documentation: 'c',
      firstSupportedVersion: '1.0.0',
    );
    defaultOffExpired = ExperimentalFeature(
      index: 3,
      enableString: 'd',
      isEnabledByDefault: false,
      isExpired: true,
      documentation: 'd',
      firstSupportedVersion: null,
    );

    overrideKnownFeatures(
      {
        'a': defaultOnNotExpired,
        'b': defaultOffNotExpired,
        'c': defaultOnExpired,
        'd': defaultOffExpired,
      },
      () {
        operation();
      },
    );
  }

  setUpAll(() {
    emptyTempDir =
        Directory.systemTemp.createTempSync('experiment_options_test_empty');
  });

  tearDownAll(() {
    emptyTempDir.deleteSync(recursive: true);
  });

  group('Experimental options test', () {
    void withExperimentOptions(
      void Function(DartdocOptionSet) operation,
    ) {
      withSyntheticExperimentalFeatures(() {
        var experimentOptions = waitFor(
          DartdocOptionSet.fromOptionGenerators(
            'dartdoc',
            [createExperimentOptions],
          ),
        );
        operation(experimentOptions);
      });
    }

    test('Defaults work for all options', () {
      withExperimentOptions((experimentOptions) {
        experimentOptions.parseArguments([]);
        var tester = DartdocOptionContext(experimentOptions, emptyTempDir);
        expect(tester.experimentStatus.isEnabled(defaultOnNotExpired), isTrue);
        expect(
            tester.experimentStatus.isEnabled(defaultOffNotExpired), isFalse);
        expect(tester.experimentStatus.isEnabled(defaultOnExpired), isTrue);
        expect(tester.experimentStatus.isEnabled(defaultOffExpired), isFalse);
      });
    });

    test('Overriding defaults works via args', () {
      withExperimentOptions((experimentOptions) {
        // Set all experiments to non-default values.
        experimentOptions.parseArguments([
          '--enable-experiment',
          [
            defaultOnNotExpired.disableString,
            defaultOffNotExpired.enableString,
            defaultOnExpired.disableString,
            defaultOffExpired.enableString,
          ].join(',')
        ]);
        var tester = DartdocOptionContext(experimentOptions, emptyTempDir);
        expect(tester.experimentStatus.isEnabled(defaultOnNotExpired), isFalse);
        expect(tester.experimentStatus.isEnabled(defaultOffNotExpired), isTrue);
        expect(tester.experimentStatus.isEnabled(defaultOnExpired), isTrue);
        expect(tester.experimentStatus.isEnabled(defaultOffExpired), isFalse);
      });
    });
  });
}
