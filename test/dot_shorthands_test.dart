// Copyright (c) 2025, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.
import 'package:analyzer/dart/ast/ast.dart';
import 'package:test/test.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

import 'dartdoc_test_base.dart';
import 'src/utils.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(DotShorthandsTest);
  });
}

@reflectiveTest
class DotShorthandsTest extends DartdocTestBase {
  @override
  String get libraryName => 'dot_shorthands';

  void test_doc_dot_shorthand_property_access_success() async {
    var library = await bootPackageWithLibrary('''
enum Color {
  red, green
}

class C {
  /// [Color] can be referenced but [.red] cannot.
  void m(Color p) {}

}
''');
    var m = library.classes.named('C').instanceMethods.named('m');

    expect(m.hasDocumentationComment, true);
    expect(
      m.documentationAsHtml,
      '<p><a href="$linkPrefix/Color.html">Color</a> can be referenced but '
      '<code>.red</code> cannot.</p>',
    );
  }

  void test_doc_dot_shorthand_constructor_invocation_success() async {
    var library = await bootPackageWithLibrary('''
class C {
  /// Cannot link [.c()]
  void m(String p) {}

  C.c();
}
''');
    var m = library.classes.named('C').instanceMethods.named('m');

    expect(m.hasDocumentationComment, true);
    expect(
      m.documentationAsHtml,
      '<p>Cannot link <code>.c()</code></p>',
    );
  }

  void test_doc_dot_shorthand_method_invocation_success() async {
    var library = await bootPackageWithLibrary('''
class C {
  /// Cannot link [.f()]
  void m(String p) {}


  static C f() => C();
}
''');
    var m = library.classes.named('C').instanceMethods.named('m');

    expect(m.hasDocumentationComment, true);
    expect(
      m.documentationAsHtml,
      '<p>Cannot link <code>.f()</code></p>',
    );
  }
}
