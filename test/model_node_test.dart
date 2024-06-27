// Copyright (c) 2022, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:dartdoc/src/model/model_node.dart';
import 'package:test/test.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

import 'dartdoc_test_base.dart';
import 'src/utils.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(ModelNodeTest);
  });
}

@reflectiveTest
class ModelNodeTest extends DartdocTestBase {
  @override
  final libraryName = 'model_node';

  void test_onClass_refersToDartCoreImportedElement() async {
    var library = await bootPackageWithLibrary('''
/// Refers to [int].
class C {}
''');
    var c = library.classes.named('C');
    expect(c.name, equals('C'));
    var commentReferenceData = c.modelNode!.commentData!.references;
    expect(
      commentReferenceData['int'],
      isA<CommentReferenceData>()
          .having((e) => e.name, 'name', 'int')
          .having((e) => e.offset, 'offset', realOffsetFor(15))
          .having((e) => e.length, 'length', 3),
    );
  }

  void test_onClass_refersToDocImportedElement() async {
    var library = await bootPackageWithLibrary('''
/// @docImport 'dart:async';
library;

/// Refers to [FutureOr].
class C {}
''');
    var c = library.classes.named('C');
    expect(c.name, equals('C'));
    var commentReferenceData = c.modelNode!.commentData!.references;
    expect(
      commentReferenceData['FutureOr'],
      isA<CommentReferenceData>()
          .having((e) => e.name, 'name', 'FutureOr')
          .having((e) => e.offset, 'offset', realOffsetFor(54))
          .having((e) => e.length, 'length', 8),
    );
  }

  void test_onClass_refersToImportedElement_propertyAccess() async {
    var library = await bootPackageWithLibrary('''
import 'dart:async' as async;
/// Refers to [async.Future.value].
class C {}
''');
    var c = library.classes.named('C');
    expect(c.name, equals('C'));
    var commentReferenceData = c.modelNode!.commentData!.references;
    expect(
      commentReferenceData['async.Future.value'],
      isA<CommentReferenceData>()
          .having((e) => e.name, 'name', 'async.Future.value')
          .having((e) => e.offset, 'offset', realOffsetFor(45))
          .having((e) => e.length, 'length', 18),
    );
  }

  void test_onClass_refersToImportedElement_prefixedIdentifier() async {
    var library = await bootPackageWithLibrary('''
/// Refers to [Future.value].
class C {}
''');
    var c = library.classes.named('C');
    expect(c.name, equals('C'));
    var commentReferenceData = c.modelNode!.commentData!.references;
    expect(
      commentReferenceData['Future.value'],
      isA<CommentReferenceData>()
          .having((e) => e.name, 'name', 'Future.value')
          .having((e) => e.offset, 'offset', realOffsetFor(15))
          .having((e) => e.length, 'length', 12),
    );
  }

  void test_onInstanceGetter_refersToDartCoreImportedElement() async {
    var library = await bootPackageWithLibrary('''
class C {
  /// Refers to [int].
  int get g => 1;
}
''');
    var g = library.classes.named('C').instanceAccessors.named('g');
    expect(g.name, equals('g'));
    var commentReferenceData = g.modelNode!.commentData!.references;
    expect(
      commentReferenceData['int'],
      isA<CommentReferenceData>()
          .having((e) => e.name, 'name', 'int')
          .having((e) => e.offset, 'offset', realOffsetFor(27))
          .having((e) => e.length, 'length', 3),
    );
  }

  void test_onVariableDeclarationList() async {
    var library = await bootPackageWithLibrary('''
/// Refers to [int].
int a = 1, b = 2;
''');
    var a = library.properties.named('a');
    expect(a.name, equals('a'));
    var aData = a.modelNode!.commentData!.references;
    expect(
      aData['int'],
      isA<CommentReferenceData>()
          .having((e) => e.name, 'name', 'int')
          .having((e) => e.offset, 'offset', realOffsetFor(15))
          .having((e) => e.length, 'length', 3),
    );

    var b = library.properties.named('b');
    expect(b.name, equals('b'));
    var bData = b.modelNode!.commentData!.references;
    expect(
      bData['int'],
      isA<CommentReferenceData>()
          .having((e) => e.name, 'name', 'int')
          .having((e) => e.offset, 'offset', realOffsetFor(15))
          .having((e) => e.length, 'length', 3),
    );
  }

  void test_stripIndent_noIndent() {
    expect(
      'void foo() {\n  print(1);\n}\n'.stripIndent,
      'void foo() {\n  print(1);\n}\n',
    );
  }

  void test_stripIndent_sameIndent() {
    expect(
      '  void foo() {\n    print(1);\n  }\n'.stripIndent,
      'void foo() {\n  print(1);\n}\n',
    );
  }

  void test_stripIndent_oddIndent() {
    expect(
      '   void foo() {\n     print(1);\n   }\n'.stripIndent,
      'void foo() {\n  print(1);\n}\n',
    );
  }

  void test_stripDocComments_noComments() {
    expect(
      'void foo() {\n  print(1);\n}\n'.stripDocComments,
      'void foo() {\n  print(1);\n}\n',
    );
  }

  void test_stripDocComments_lineComments() {
    expect(
      '/// foo comment\nvoid foo() {\n  print(1);\n}\n'.stripDocComments,
      'void foo() {\n  print(1);\n}\n',
    );
  }

  void test_stripDocComments_blockComments1() {
    expect(
      '/** foo comment */\nvoid foo() {\n  print(1);\n}\n'.stripDocComments,
      'void foo() {\n  print(1);\n}\n',
    );
  }

  void test_stripDocComments_blockComments2() {
    expect(
      '/**\n * foo comment\n */\nvoid foo() {\n  print(1);\n}\n'
          .stripDocComments,
      'void foo() {\n  print(1);\n}\n',
    );
  }
}
