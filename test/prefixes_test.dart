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
    var x = library.properties.named('x');
    expect(
      x.documentationAsHtml,
      '<p>Text <a href="$dartAsyncUrlPrefix/">async</a>.</p>',
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

  void test_referenced_docImportPrefix() async {
    var library = await bootPackageWithLibrary(
      '''
/// Text [async] and [async.Future].
int x = 0;
''',
      libraryPreamble: '''
/// @docImport 'dart:async' as async;
''',
      additionalArguments: ['--link-to-remote'],
    );
    var x = library.properties.named('x');
    expect(
      x.documentationAsHtml,
      '<p>Text <a href="$dartAsyncUrlPrefix/">async</a> and '
      '<a href="$dartAsyncUrlPrefix/Future-class.html">async.Future</a>.</p>',
    );
  }

  void test_referenced_docImportPrefix_inMember() async {
    var library = await bootPackageWithLibrary(
      '''
class C {
  /// Text [async] and [async.Future].
  void m() {}
}
''',
      libraryPreamble: '''
/// @docImport 'dart:async' as async;
''',
      additionalArguments: ['--link-to-remote'],
    );
    var m = library.classes.named('C').instanceMethods.named('m');
    expect(
      m.documentationAsHtml,
      '<p>Text <a href="$dartAsyncUrlPrefix/">async</a> and '
      '<a href="$dartAsyncUrlPrefix/Future-class.html">async.Future</a>.</p>',
    );
  }

  void test_referenced_docImportPrefix_unresolvedUri() async {
    var library = await bootPackageWithLibrary(
      '''
/// Text [missing].
int x = 0;
''',
      libraryPreamble: '''
/// @docImport 'package:missing/missing.dart' as missing;
''',
    );
    var x = library.properties.named('x');
    // There is no link, but also no crash.
    expect(x.documentationAsHtml, '<p>Text <code>missing</code>.</p>');
  }
}
