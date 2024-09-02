// Copyright (c) 2022, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:test/test.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

import '../src/utils.dart';
import 'template_test_base.dart';

void main() async {
  defineReflectiveSuite(() {
    defineReflectiveTests(FieldTest);
  });
}

@reflectiveTest
class FieldTest extends TemplateTestBase {
  @override
  String get packageName => 'field_test';

  @override
  String get libraryName => 'field';

  void test_class_fieldName() async {
    await createPackageWithLibrary('''
class C {
  int f1 = 1;
}
''');
    var f1Lines = readLines(['lib', 'C', 'f1.html']);
    f1Lines.expectMainContentContainsAllInOrder(
      [
        matches('<h1><span class="kind-property">f1</span> property'),
      ],
    );
  }

  void test_class_annotations() async {
    await createPackageWithLibrary('''
class C {
  @deprecated
  @A('message')
  int f1 = 1;
}

class A {
  const A(String m);
}
''');
    var f1Lines = readLines(['lib', 'C', 'f1.html']);
    f1Lines.expectMainContentContainsAllInOrder(
      [
        matches('<ol class="annotation-list">'),
        matches('<li>@deprecated</li>'),
        matches(
            r'<li>@<a href="../../lib/A-class.html">A</a>\(&#39;message&#39;\)</li>'),
        matches('</ol>'),
      ],
    );
  }

  void test_class_docComment() async {
    await createPackageWithLibrary('''
class C {
  /// Documentation text.
  int f1 = 1;
}
''');
    var f1Lines = readLines(['lib', 'C', 'f1.html']);
    f1Lines.expectMainContentContainsAllInOrder(
      [
        matches('<section class="desc markdown">'),
        matches('<p>Documentation text.</p>'),
      ],
    );
  }

  void test_extensionType_representationField_final() async {
    await createPackageWithLibrary('''
extension type ET(
  /// Documentation text.
  int f1) {}
''');
    var f1Lines = readLines(['lib', 'ET', 'f1.html']);
    f1Lines.expectMainContentContainsAllInOrder(
      [
        matches(
            '<div class="features"><span class="feature">final</span></div>'),
      ],
    );
  }

  void test_getter_signature() async {
    await createPackageWithLibrary('''
class C {
  int get f1 => 1;
}
''');
    var f1Lines = readLines(['lib', 'C', 'f1.html']);
    f1Lines.expectMainContentContainsAllInOrder(
      [
        matches('<h1><span class="kind-property">f1</span> property'),
        matches('<section class="multi-line-signature">'),
        matches('<span class="returntype">int</span>'),
        matches('get'),
        matches('<span class="name ">f1</span>'),
      ],
    );
  }

  void test_getter_overridingProperty_signature() async {
    await createPackageWithLibrary('''
class C {
  int f1 = 0;
}
class D extends C {
  @override
  int get f1 => 1;
}
''');
    var f1Lines = readLines(['lib', 'D', 'f1.html']);
    f1Lines.expectMainContentContainsAllInOrder(
      [
        matches('<h1><span class="kind-property">f1</span> property'),
        matches('<section class="multi-line-signature">'),
        matches('<span class="returntype">int</span>'),
        matches('get'),
        matches('<span class="name ">f1</span>'),
      ],
    );
  }

  void test_setter_signature() async {
    await createPackageWithLibrary('''
class C {
  set f1(int value) {}
}
''');
    var f1Lines = readLines(['lib', 'C', 'f1.html']);
    f1Lines.expectMainContentContainsAllInOrder(
      [
        matches('<section class="multi-line-signature">'),
        matches('set'),
        matches('<span class="name ">f1</span>'),
        matches(r'<span class="signature">\('
            '<wbr><span class="parameter" id="f1=-param-value">'
            '<span class="type-annotation">int</span> '
            '<span class="parameter-name">value</span>'
            r'</span>\)'
            '</span>'),
      ],
    );
  }

  void test_setter_overridingProperty_signature() async {
    await createPackageWithLibrary('''
class C {
  int f1 = 0;
}
class D extends C {
  set f1(int value) {}
}
''');
    var f1Lines = readLines(['lib', 'D', 'f1.html']);
    f1Lines.expectMainContentContainsAllInOrder(
      [
        matches('<section class="multi-line-signature">'),
        matches('set'),
        matches('<span class="name ">f1</span>'),
        matches(r'<span class="signature">\('
            '<wbr><span class="parameter" id="f1=-param-value">'
            '<span class="type-annotation">int</span> '
            '<span class="parameter-name">value</span>'
            r'</span>\)'
            '</span>'),
      ],
    );
  }

  // TODO(srawlins): Add rendering tests:
  // * how inherited fields look on subclass page ('inherited' feature)
  // * static fields
  // * linked elements in signature
}
