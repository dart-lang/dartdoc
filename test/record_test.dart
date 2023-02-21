// Copyright (c) 2022, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:test/test.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

import 'dartdoc_test_base.dart';
import 'src/utils.dart';

void main() {
  defineReflectiveSuite(() {
    if (recordsAllowed) {
      defineReflectiveTests(RecordTest);
    }
  });
}

@reflectiveTest
class RecordTest extends DartdocTestBase {
  @override
  String get libraryName => 'records';

  @override
  String get sdkConstraint => '>=2.19.0-0 <4.0.0';

  @override
  List<String> get experiments => ['records'];

  void test_noFields() async {
    var library = await bootPackageWithLibrary('''
void f(() r) {}
''');
    var fFunction = library.functions.named('f');
    var recordType = fFunction.modelType.parameters.first.modelType;
    expect(recordType.linkedName, equals('()'));
    expect(recordType.nameWithGenerics, equals('Record'));
  }

  void test_onePositionalField() async {
    var library = await bootPackageWithLibrary('''
void f((int) r) {}
''');
    var fFunction = library.functions.named('f');
    var recordType = fFunction.modelType.parameters.first.modelType;
    expect(recordType.linkedName, matchesCompressed(r'''
        \(
          <span class="field">
            <span class="type-annotation">
              <a href=".*/dart-core/int-class.html">int</a>
            </span>
          </span>
        \)
      '''));
    expect(recordType.nameWithGenerics, equals('Record'));
  }

  void test_positionalFields() async {
    var library = await bootPackageWithLibrary('''
void f((int, String) r) {}
''');
    var fFunction = library.functions.named('f');
    var recordType = fFunction.modelType.parameters.first.modelType;
    expect(recordType.linkedName, matchesCompressed(r'''
        \(
          <span class="field">
            <span class="type-annotation">
              <a href=".*/dart-core/int-class.html">int</a>
            </span>,
          </span>
          <span class="field">
            <span class="type-annotation">
              <a href=".*/dart-core/String-class.html">String</a>
            </span>
          </span>
        \)
      '''));
    expect(recordType.nameWithGenerics, equals('Record'));
  }

  void test_namedFields() async {
    var library = await bootPackageWithLibrary('''
void f(({int bbb, String aaa}) record) {}
''');
    var fFunction = library.functions.named('f');
    var recordType = fFunction.modelType.parameters.first.modelType;
    expect(recordType.linkedName, matchesCompressed(r'''
        \(
          <span class="field">
            \{
            <span class="type-annotation">
              <a href=".*/dart-core/String-class.html">String</a>
            </span>
            <span class="field-name">aaa</span>,
          </span>
          <span class="field">
            <span class="type-annotation">
              <a href=".*/dart-core/int-class.html">int</a>
            </span>
            <span class="field-name">bbb</span>
            \}
          </span>
        \)
      '''));
    expect(recordType.nameWithGenerics, equals('Record'));
  }

  void test_positionalAndNamedFields() async {
    var library = await bootPackageWithLibrary('''
void f((int one, String two, {int ccc, String aaa, int bbb}) record) {}
''');
    var fFunction = library.functions.named('f');
    var recordType = fFunction.modelType.parameters.first.modelType;
    expect(recordType.linkedName, matchesCompressed(r'''
        \(
          <span class="field">
            <span class="type-annotation">
              <a href=".*/dart-core/int-class.html">int</a>
            </span>,
          </span>
          <span class="field">
            <span class="type-annotation">
              <a href=".*/dart-core/String-class.html">String</a>
            </span>,
          </span>
          <span class="field">
            \{
            <span class="type-annotation">
              <a href=".*/dart-core/String-class.html">String</a>
            </span>
            <span class="field-name">aaa</span>,
          </span>
          <span class="field">
            <span class="type-annotation">
              <a href=".*/dart-core/int-class.html">int</a>
            </span>
            <span class="field-name">bbb</span>,
          </span>
          <span class="field">
            <span class="type-annotation">
              <a href=".*/dart-core/int-class.html">int</a>
            </span>
            <span class="field-name">ccc</span>
            \}
          </span>
        \)
      '''));
    expect(recordType.nameWithGenerics, equals('Record'));
  }
}
