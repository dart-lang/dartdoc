// Copyright (c) 2019, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:dartdoc/src/dartdoc_options.dart';
import 'package:dartdoc/src/source_linker.dart';
import 'package:test/test.dart';

void main() {
  group('Source link computations', () {
    test('Basic usage', () {
      String sourceLinkerHref() => SourceLinker(
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
      String sourceLinkerHref() => SourceLinker(
              excludes: [],
              lineNumber: 20,
              root: 'path',
              sourceFileName: 'path/to/file.dart',
              uriTemplate: 'http://github.com/base/%r%/%f%/L%l%')
          .href();
      expect(sourceLinkerHref, throwsA(TypeMatcher<DartdocOptionError>()));
    });

    test('Allow a missing revision as long as it is not in the template', () {
      String sourceLinkerHref() => SourceLinker(
              excludes: [],
              lineNumber: 71,
              root: 'path',
              sourceFileName: 'path/to/file.dart',
              uriTemplate: 'http://github.com/base/main/%f%/L%l%')
          .href();
      expect(sourceLinkerHref(),
          equals('http://github.com/base/main/to/file.dart/L71'));
    });

    test('Throw if only revision specified', () {
      String sourceLinkerHref() => SourceLinker(
            excludes: [],
            lineNumber: 20,
            revision: '12345',
            sourceFileName: 'path/to/file.dart',
          ).href();
      expect(sourceLinkerHref, throwsA(TypeMatcher<DartdocOptionError>()));
    });

    test('Hide a path inside an exclude', () {
      String sourceLinkerHref() => SourceLinker(
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
      String sourceLinkerHref() => SourceLinker(
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

    test('Allow a fragment in the template', () {
      String sourceLinkerHref() => SourceLinker(
              excludes: [],
              lineNumber: 14,
              root: 'path',
              sourceFileName: 'path/to/file.dart',
              uriTemplate: 'https://github.com/base/blob/main/%f%#L%l%')
          .href();
      expect(sourceLinkerHref(),
          equals('https://github.com/base/blob/main/to/file.dart#L14'));
    });

    test('Ignore a template which breaks out of an HTML attribute', () {
      var invalidUrls = <String>[];
      String sourceLinkerHref() => SourceLinker(
              excludes: [],
              lineNumber: 14,
              root: 'path',
              sourceFileName: 'path/to/file.dart',
              uriTemplate: 'x"><img src=x onerror=alert(1)><a x="%f%',
              onInvalidUrl: invalidUrls.add)
          .href();
      expect(sourceLinkerHref(), equals(''));
      expect(invalidUrls,
          equals(['x"><img src=x onerror=alert(1)><a x="to/file.dart']));
    });

    test('Ignore a template with a non-http(s) scheme', () {
      String sourceLinkerHref() => SourceLinker(
              excludes: [],
              lineNumber: 14,
              root: 'path',
              sourceFileName: 'path/to/file.dart',
              uriTemplate: 'javascript:alert(1)//%f%')
          .href();
      expect(sourceLinkerHref(), equals(''));
    });

    test('Ignore a template with a relative URL', () {
      String sourceLinkerHref() => SourceLinker(
              excludes: [],
              lineNumber: 14,
              root: 'path',
              sourceFileName: 'path/to/file.dart',
              uriTemplate: '../src/%f%')
          .href();
      expect(sourceLinkerHref(), equals(''));
    });
  });
}
