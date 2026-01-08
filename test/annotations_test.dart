// Copyright (c) 2022, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:dartdoc/src/model/model.dart';
import 'package:test/test.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

import 'dartdoc_test_base.dart';
import 'src/utils.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(AnnotationTest);
  });
}

@reflectiveTest
class AnnotationTest extends DartdocTestBase {
  @override
  final libraryName = 'annotations';

  void test_deprecatedConstant() async {
    var library = await bootPackageWithLibrary('''
@deprecated
int value = 0;
''');
    var valueVariable = library.properties.named('value');
    expect(valueVariable.hasAnnotations, true);
    var annotation = valueVariable.annotations.single;
    expect(
      annotation.linkedName,
      '<a href="$dartCoreUrlPrefix/deprecated-constant.html">deprecated</a>',
    );
    expect(
      annotation.linkedNameWithParameters,
      '@<a href="$dartCoreUrlPrefix/deprecated-constant.html">deprecated</a>',
    );
  }

  void test_DeprecatedConstructorCall() async {
    var library = await bootPackageWithLibrary('''
@Deprecated('text')
int value = 0;
''');
    var valueVariable = library.properties.named('value');
    expect(valueVariable.hasAnnotations, true);
    var annotation = valueVariable.annotations.single;
    expect(
      annotation.linkedName,
      '<a href="$dartCoreUrlPrefix/Deprecated/Deprecated.html">Deprecated</a>',
    );
    expect(
      annotation.linkedNameWithParameters,
      '@<a href="$dartCoreUrlPrefix/Deprecated/Deprecated.html">Deprecated</a>'
      '(&#39;text&#39;)',
    );
  }

  void test_locallyDeclaredConstant() async {
    var library = await bootPackageWithLibrary('''
class MyAnnotation {
  const MyAnnotation();
}

const myAnnotation = MyAnnotation();

@myAnnotation
int value = 0;
''');
    var valueVariable = library.properties.named('value');
    expect(valueVariable.hasAnnotations, true);
    var annotation = valueVariable.annotations.single;
    expect(
      annotation.linkedName,
      '<a href="${htmlBasePlaceholder}annotations/myAnnotation-constant.html">'
      'myAnnotation</a>',
    );
    expect(
      annotation.linkedNameWithParameters,
      '@<a href="${htmlBasePlaceholder}annotations/myAnnotation-constant.html">'
      'myAnnotation</a>',
    );
  }

  void test_locallyDeclaredConstant_private() async {
    var library = await bootPackageWithLibrary('''
class MyAnnotation {
  const MyAnnotation();
}

const _myAnnotation = MyAnnotation();

@_myAnnotation
int value = 0;
''');
    var valueVariable = library.properties.named('value');
    expect(valueVariable.hasAnnotations, false);
  }

  void test_locallyDeclaredConstructorCall() async {
    var library = await bootPackageWithLibrary('''
class MyAnnotation {
  const MyAnnotation(bool b);
}

@MyAnnotation(true)
int value = 0;
''');
    var valueVariable = library.properties.named('value');
    expect(valueVariable.hasAnnotations, true);
    var annotation = valueVariable.annotations.single;
    expect(
      annotation.linkedName,
      '<a href="${htmlBasePlaceholder}annotations/MyAnnotation/MyAnnotation.html">'
      'MyAnnotation</a>',
    );
    expect(
      annotation.linkedNameWithParameters,
      '@<a href="${htmlBasePlaceholder}annotations/MyAnnotation/MyAnnotation.html">'
      'MyAnnotation</a>(true)',
    );
  }

  void test_locallyDeclaredConstructorCall_private() async {
    var library = await bootPackageWithLibrary('''
class _MyAnnotation {
  const _MyAnnotation(bool b);
}

@_MyAnnotation(true)
int value = 0;
''');
    var valueVariable = library.properties.named('value');
    expect(valueVariable.hasAnnotations, false);
  }

  void test_locallyDeclaredConstructorCall_named() async {
    var library = await bootPackageWithLibrary('''
class MyAnnotation {
  const MyAnnotation.named(bool b);
}

@MyAnnotation.named(true)
int value = 0;
''');
    var valueVariable = library.properties.named('value');
    expect(valueVariable.hasAnnotations, true);
    var annotation = valueVariable.annotations.single;
    expect(
      annotation.linkedName,
      '<a href="${htmlBasePlaceholder}annotations/MyAnnotation/MyAnnotation.named.html">'
      'MyAnnotation.named</a>',
    );
    expect(
      annotation.linkedNameWithParameters,
      '@<a href="${htmlBasePlaceholder}annotations/MyAnnotation/MyAnnotation.named.html">'
      'MyAnnotation.named</a>(true)',
    );
  }

  void test_locallyDeclaredConstructorCall_named_private() async {
    var library = await bootPackageWithLibrary('''
class MyAnnotation {
  const MyAnnotation._named(bool b);
}

@MyAnnotation._named(true)
int value = 0;
''');
    var valueVariable = library.properties.named('value');
    expect(valueVariable.hasAnnotations, false);
  }

  void test_genericConstructorCall() async {
    var library = await bootPackageWithLibrary('''
class Ann<T> {
  final T f;
  const Ann(this.f);
}

@Ann(true)
int value = 0;
''');
    var valueVariable = library.properties.named('value');
    expect(valueVariable.hasAnnotations, true);
    var annotation = valueVariable.annotations.single;
    expect(
      annotation.linkedName,
      '<a href="${htmlBasePlaceholder}annotations/Ann/Ann.html">Ann</a>',
    );
    expect(
      annotation.linkedNameWithParameters,
      '@<a href="${htmlBasePlaceholder}annotations/Ann/Ann.html">Ann</a>'
      '&lt;<a href="$dartCoreUrlPrefix/bool-class.html">bool</a>&gt;'
      '(true)',
    );
  }
}
