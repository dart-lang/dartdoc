// Copyright (c) 2022, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:test/test.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

import '../src/utils.dart';

import 'template_test_base.dart';

void main() async {
  defineReflectiveSuite(() {
    defineReflectiveTests(MethodTest);
  });
}

@reflectiveTest
class MethodTest extends TemplateTestBase {
  @override
  String get packageName => 'method_test';

  @override
  String get libraryName => 'method';

  void test_methodName() async {
    await createPackageWithLibrary('''
class C {
  void m1() {}
}
''');
    var m1Lines = readLines(['lib', 'C', 'm1.html']);
    m1Lines.expectMainContentContainsAllInOrder([
      matches('<h1><span class="kind-method">m1</span> method'),
    ]);
  }

  void test_annotations() async {
    await createPackageWithLibrary('''
class A {
  const A(String m);
}

class C {
  @deprecated
  @A('message')
  void m1() {}
}
''');
    var m1Lines = readLines(['lib', 'C', 'm1.html']);
    m1Lines.expectMainContentContainsAllInOrder(
      [
        matches('<ol class="annotation-list">'),
        matches('<li>@deprecated</li>'),
        matches(
            r'<li>@<a href="../../lib/A-class.html">A</a>\(&#39;message&#39;\)</li>'),
        matches('</ol>'),
      ],
    );
  }

  void test_onClass() async {
    await createPackageWithLibrary('''
class C {
  void m1() {}
}
''');
    var m1Lines = readLines(['lib', 'C', 'm1.html']);
    m1Lines.expectMainContentContainsAllInOrder(
      [
        matches('<h1><span class="kind-method">m1</span> method'),
      ],
    );
  }

  void test_onClass_static() async {
    await createPackageWithLibrary('''
class C {
  static void m1() {}
}
''');
    var m1Lines = readLines(['lib', 'C', 'm1.html']);
    m1Lines.expectMainContentContainsAllInOrder(
      [
        matches('<h1><span class="kind-method">m1</span> static method'),
      ],
    );
  }

  void test_onEnum() async {
    await createPackageWithLibrary('''
enum E {
  one, two;
  void m1() {}
}
''');
    var m1Lines = readLines(['lib', 'E', 'm1.html']);
    m1Lines.expectMainContentContainsAllInOrder(
      [
        matches('<h1><span class="kind-method">m1</span> method'),
      ],
    );
  }

  void test_onEnum_static() async {
    await createPackageWithLibrary('''
enum E {
  one, two;
  static void m1() {}
}
''');
    var m1Lines = readLines(['lib', 'E', 'm1.html']);
    m1Lines.expectMainContentContainsAllInOrder(
      [
        matches('<h1><span class="kind-method">m1</span> static method'),
      ],
    );
  }

  void test_onExtension() async {
    await createPackageWithLibrary('''
extension E on int {
  void m1() {}
}
''');
    var m1Lines = readLines(['lib', 'E', 'm1.html']);
    m1Lines.expectMainContentContainsAllInOrder(
      [
        matches('<h1><span class="kind-method">m1</span> method'),
      ],
    );
  }

  void test_onExtension_static() async {
    await createPackageWithLibrary('''
extension E on int {
  static void m1() {}
}
''');
    var m1Lines = readLines(['lib', 'E', 'm1.html']);
    m1Lines.expectMainContentContainsAllInOrder(
      [
        matches('<h1><span class="kind-method">m1</span> static method'),
      ],
    );
  }

  void test_onMixin() async {
    await createPackageWithLibrary('''
mixin M {
  void m1() {}
}
''');
    var m1Lines = readLines(['lib', 'M', 'm1.html']);
    m1Lines.expectMainContentContainsAllInOrder(
      [
        matches('<h1><span class="kind-method">m1</span> method'),
      ],
    );
  }

  void test_onMixin_static() async {
    await createPackageWithLibrary('''
mixin M {
  static void m1() {}
}
''');
    var m1Lines = readLines(['lib', 'M', 'm1.html']);
    m1Lines.expectMainContentContainsAllInOrder(
      [
        matches('<h1><span class="kind-method">m1</span> static method'),
      ],
    );
  }

  void test_onExtensionType() async {
    await createPackageWithLibrary('''
extension type E(int it) {
  void m1() {}
}
''');
    var m1Lines = readLines(['lib', 'E', 'm1.html']);
    m1Lines.expectMainContentContainsAllInOrder(
      [
        matches('<h1><span class="kind-method">m1</span> method'),
      ],
    );
  }

  void test_onExtensionType_static() async {
    await createPackageWithLibrary('''
extension type E(int it) {
  static void m1() {}
}
''');
    var m1Lines = readLines(['lib', 'E', 'm1.html']);
    m1Lines.expectMainContentContainsAllInOrder(
      [
        matches('<h1><span class="kind-method">m1</span> static method'),
      ],
    );
  }

  // TODO(srawlins): Add rendering tests.
  // * how inherited members look on subclass page ('inherited' feature)
  // * generic methods
  // * linked elements in signature
}
