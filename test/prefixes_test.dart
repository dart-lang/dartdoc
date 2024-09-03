// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:test/test.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

import 'dartdoc_test_base.dart';
import 'src/utils.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(PrefixesTest);
  });
}

@reflectiveTest
class PrefixesTest extends DartdocTestBase {
  @override
  String get libraryName => 'prefixes';

  @FailingTest(
      reason: 'requires https://github.com/dart-lang/dartdoc/pull/3865')
  void test_referenced() async {
    var library = await bootPackageWithLibrary(
      '''
import 'dart:async' as async;

/// Text [async].
int x = 0;
''',
      additionalArguments: ['--link-to-remote'],
    );
    var x = library.properties.named('x');
    expect(
      x.documentationAsHtml,
      '<p>Text <a href="$dartAsyncUrlPrefix/dart-async-library.html">async</a>.</p>',
    );
  }

  void test_referenced_wildcard() async {
    var library = await bootPackageWithLibrary(
      '''
import 'dart:async' as _;

/// Text [_].
int x = 0;
''',
      additionalArguments: ['--link-to-remote'],
    );
    var x = library.properties.named('x');
    // There is no link, but also no wrong link or crash.
    expect(x.documentationAsHtml, '<p>Text <code>_</code>.</p>');
  }
}
