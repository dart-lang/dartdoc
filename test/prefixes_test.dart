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

  void test_referenced() async {
    var library = await bootPackageWithLibrary(
      '''
import 'dart:async' as async;

/// Text [async].
int x = 0;
''',
      additionalArguments: ['--link-to-remote'],
    );
    var f = library.properties.named('x');
    // There is no link, but also no wrong link or crash.
    expect(f.documentationAsHtml, '<p>Text <code>async</code>.</p>');
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
    var f = library.properties.named('x');
    // There is no link, but also no wrong link or crash.
    expect(f.documentationAsHtml, '<p>Text <code>_</code>.</p>');
  }
}
