// Copyright (c) 2019, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library dartdoc.source_linker_test;

import 'package:dartdoc/src/dartdoc_options.dart';
import 'package:dartdoc/src/source_linker.dart';
import 'package:test/test.dart';

void main() {
  group('Source link computations', () {
    test('Basic usage', () {
      var sourceLinkerHref = () => SourceLinker(
              excludes: [],
              lineNumber: 14,
              root: 'path',
              sourceFileName: 'path/to/file.dart',
              revision: '01234abcd',
              uriTemplate: 'http://github.com/base/%r%/%f%/L%l%')
          .href();
      expect(sourceLinkerHref(),
          equals('http://github.com/base/01234abcd/to/file.dart/L14'));
    });

    test('Throw when missing a revision if one is in the template', () {
      var sourceLinkerHref = () => SourceLinker(
              excludes: [],
              lineNumber: 20,
              root: 'path',
              sourceFileName: 'path/to/file.dart',
              uriTemplate: 'http://github.com/base/%r%/%f%/L%l%')
          .href();
      expect(sourceLinkerHref, throwsA(TypeMatcher<DartdocOptionError>()));
    });

    test('Allow a missing revision as long as it is not in the template', () {
      var sourceLinkerHref = () => SourceLinker(
              excludes: [],
              lineNumber: 71,
              root: 'path',
              sourceFileName: 'path/to/file.dart',
              uriTemplate: 'http://github.com/base/master/%f%/L%l%')
          .href();
      expect(sourceLinkerHref(),
          equals('http://github.com/base/master/to/file.dart/L71'));
    });

    test('Throw if only revision specified', () {
      var sourceLinkerHref = () => SourceLinker(
            excludes: [],
            lineNumber: 20,
            revision: '12345',
          ).href();
      expect(sourceLinkerHref, throwsA(TypeMatcher<DartdocOptionError>()));
    });

    test('Hide a path inside an exclude', () {
      var sourceLinkerHref = () => SourceLinker(
              excludes: ['path/under/exclusion'],
              lineNumber: 14,
              root: 'path',
              sourceFileName: 'path/under/exclusion/file.dart',
              revision: '01234abcd',
              uriTemplate: 'http://github.com/base/%r%/%f%/L%l%')
          .href();
      expect(sourceLinkerHref(), equals(''));
    });

    test('Check that paths outside exclusions work', () {
      var sourceLinkerHref = () => SourceLinker(
              excludes: ['path/under/exclusion'],
              lineNumber: 14,
              root: 'path',
              sourceFileName: 'path/not/under/exclusion/file.dart',
              revision: '01234abcd',
              uriTemplate: 'http://github.com/base/%r%/%f%/L%l%')
          .href();
      expect(
          sourceLinkerHref(),
          equals(
              'http://github.com/base/01234abcd/not/under/exclusion/file.dart/L14'));
    });
  });
}
