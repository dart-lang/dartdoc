// Copyright (c) 2022, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:test/test.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

import 'dartdoc_test_base.dart';
import 'src/utils.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(TypeParameterTest);
  });
}

@reflectiveTest
class TypeParameterTest extends DartdocTestBase {
  @override
  String get libraryName => 'type_parameters';

  void test_referenced() async {
    var library = await bootPackageWithLibrary('''
/// Text [T].
void f<T>(int p) {}
typedef T = int;
''');
    var f = library.functions.named('f');
    // There is no link, but also no wrong link or crash.
    expect(f.documentationAsHtml, '<p>Text <code>T</code>.</p>');
  }

  void test_referenced_wildcard() async {
    var library = await bootPackageWithLibrary('''
/// Text [_].
void f<_>() {}
''');
    var f = library.functions.named('f');
    // There is no link, but also no wrong link or crash.
    expect(f.documentationAsHtml, '<p>Text <code>_</code>.</p>');
  }

  void test_referenced_wildcardInParent() async {
    var library = await bootPackageWithLibrary('''
class C<_> {
  /// Text [_].
  void m() {}
}
''');
    var m = library.classes.named('C').instanceMethods.named('m');
    // There is no link, but also no wrong link or crash.
    expect(m.documentationAsHtml, '<p>Text <code>_</code>.</p>');
  }
}
