// Copyright (c) 2026, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:test/test.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

import 'dartdoc_test_base.dart';
import 'src/utils.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(ReferenceStyleLinksTest);
  });
}

@reflectiveTest
class ReferenceStyleLinksTest extends DartdocTestBase {
  @override
  String get libraryName => 'reference_style_links';

  void test_referenceStyleLink_withDefinedReference_usesMarkdownLink() async {
    var library = await bootPackageWithLibrary('''
class C {
  /// The [banana][Bananas] is fine.
  ///
  /// [Bananas]: http://example.com/bananas "example of bananas"
  void m() {}
}
''');

    var m = library.classes.named('C').instanceMethods.named('m');

    expect(
      m.documentationAsHtml,
      '<p>The <a href="http://example.com/bananas" '
      'title="example of bananas">banana</a> is fine.</p>',
    );
  }

  void test_referenceStyleLink_withoutDefinition_fallsBackToDocLink() async {
    var library = await bootPackageWithLibrary('''
class Foo {
  static int get bar => 0;
}

class C {
  /// Link [Foo.current.bar][Foo.bar].
  void m() {}
}
''');

    var m = library.classes.named('C').instanceMethods.named('m');

    expect(
      m.documentationAsHtml,
      contains(RegExp('<a href="[^"]+">Foo\\.current\\.bar</a>')),
    );
    expect(m.documentationAsHtml, isNot(contains('>Foo.bar</a>')));
  }

  void test_referenceStyleLink_withoutDefinition_preservesFirstLabel() async {
    var library = await bootPackageWithLibrary('''
class Platform {
  static Platform get current => Platform();
  String get nativePlatform => 'linux';
}

class C {
  /// [Platform.current][Platform.nativePlatform]
  void m() {}
}
''');

    var m = library.classes.named('C').instanceMethods.named('m');

    expect(
      m.documentationAsHtml,
      contains(RegExp('<a href="[^"]+">Platform\\.current</a>')),
    );
    expect(
        m.documentationAsHtml, isNot(contains('>Platform.nativePlatform</a>')));
  }
}
