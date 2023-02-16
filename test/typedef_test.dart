// Copyright (c) 2022, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/dart/element/type.dart';
import 'package:dartdoc/src/element_type.dart';
import 'package:test/test.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

import 'dartdoc_test_base.dart';
import 'src/utils.dart';

void main() {
  defineReflectiveSuite(() {
    if (recordsAllowed) {
      defineReflectiveTests(TypedefTest);
    }
  });
}

@reflectiveTest
class TypedefTest extends DartdocTestBase {
  @override
  String get libraryName => 'typedefs';

  @override
  String get sdkConstraint => '>=2.19.0-0 <3.0.0';

  @override
  List<String> get experiments => ['records'];

  void test_basicFunctionTypedef() async {
    var library = await bootPackageWithLibrary('''
/// Line _one_.
///
/// Line _two_.
typedef Cb1 = void Function();
''');
    final cb1Typedef = library.typedefs.named('Cb1');

    expect(cb1Typedef.nameWithGenerics, 'Cb1');
    expect(cb1Typedef.genericParameters, '');
    expect(cb1Typedef.aliasedType, isA<FunctionType>());
    expect(cb1Typedef.documentationComment, '''
/// Line _one_.
///
/// Line _two_.''');
    expect(cb1Typedef.documentation, '''
Line _one_.

Line _two_.''');
    expect(cb1Typedef.oneLineDoc, 'Line <em>one</em>.');
    expect(cb1Typedef.documentationAsHtml, '''
<p>Line <em>one</em>.</p>
<p>Line <em>two</em>.</p>''');
  }

  void test_genericFunctionTypedef() async {
    var library = await bootPackageWithLibrary('''
typedef Cb2<T> = T Function(T);
''');
    final cb2Typedef = library.typedefs.named('Cb2');

    expect(
      cb2Typedef.nameWithGenerics,
      'Cb2&lt;<wbr><span class="type-parameter">T</span>&gt;',
    );
    expect(
      cb2Typedef.genericParameters,
      '&lt;<wbr><span class="type-parameter">T</span>&gt;',
    );
    expect(cb2Typedef.aliasedType, isA<FunctionType>());
  }

  void test_genericFunctionTypedefReferringToGenericTypedef() async {
    var library = await bootPackageWithLibrary('''
typedef Cb2<T> = T Function(T);

/// Not unlike [Cb2].
typedef Cb3<T> = Cb2<List<T>>;
''');
    final cb3Typedef = library.typedefs.named('Cb3');

    expect(
      cb3Typedef.nameWithGenerics,
      'Cb3&lt;<wbr><span class="type-parameter">T</span>&gt;',
    );
    expect(
      cb3Typedef.genericParameters,
      '&lt;<wbr><span class="type-parameter">T</span>&gt;',
    );
    expect(cb3Typedef.aliasedType, isA<FunctionType>());
    expect(cb3Typedef.parameters, hasLength(1));

    // TODO(srawlins): Dramatically improve typedef testing.
  }

  void test_typedefInDocCommentReference() async {
    var library = await bootPackageWithLibrary('''
typedef Cb2<T> = T Function(T);

/// Not unlike [Cb2].
typedef Cb3<T> = Cb2<List<T>>;
''');
    final cb3Typedef = library.typedefs.named('Cb3');

    expect(cb3Typedef.isDocumented, isTrue);
    expect(cb3Typedef.documentation, 'Not unlike [Cb2].');
    expect(
      cb3Typedef.documentationAsHtml,
      '<p>Not unlike '
      '<a href="%%__HTMLBASE_dartdoc_internal__%%typedefs/Cb2.html">Cb2</a>.'
      '</p>',
    );
  }

  void test_basicRecordTypedef() async {
    var library = await bootPackageWithLibrary('''
/// Line _one_.
///
/// Line _two_.
typedef R1 = (int, String);
''');
    final r1Typedef = library.typedefs.named('R1');

    expect(r1Typedef.nameWithGenerics, 'R1');
    expect(r1Typedef.genericParameters, '');
    expect(r1Typedef.aliasedType, isA<RecordType>());
    expect(r1Typedef.documentationComment, '''
/// Line _one_.
///
/// Line _two_.''');
    expect(r1Typedef.documentation, '''
Line _one_.

Line _two_.''');
    expect(r1Typedef.oneLineDoc, 'Line <em>one</em>.');
    expect(r1Typedef.documentationAsHtml, '''
<p>Line <em>one</em>.</p>
<p>Line <em>two</em>.</p>''');
  }

  void test_genericRecordTypedef() async {
    var library = await bootPackageWithLibrary('''
typedef R2<T> = (T, String);
''');
    final r2Typedef = library.typedefs.named('R2');

    expect(
      r2Typedef.nameWithGenerics,
      'R2&lt;<wbr><span class="type-parameter">T</span>&gt;',
    );
    expect(
      r2Typedef.genericParameters,
      '&lt;<wbr><span class="type-parameter">T</span>&gt;',
    );
    expect(r2Typedef.aliasedType, isA<RecordType>());
  }

  void test_genericRecordTypedefReferringToGenericTypedef() async {
    var library = await bootPackageWithLibrary('''
typedef R2<T> = (T, String);

/// Not unlike [R2].
typedef R3<T> = R2<List<T>>;
''');
    final r3Typedef = library.typedefs.named('R3');

    expect(
      r3Typedef.nameWithGenerics,
      'R3&lt;<wbr><span class="type-parameter">T</span>&gt;',
    );
    expect(
      r3Typedef.genericParameters,
      '&lt;<wbr><span class="type-parameter">T</span>&gt;',
    );
    expect(r3Typedef.aliasedType, isA<RecordType>());
  }

  void test_typedefInDocCommentReference2() async {
    var library = await bootPackageWithLibrary('''
typedef R2<T> = (T, String);

/// Not unlike [R2].
typedef R3<T> = R2<List<T>>;
''');
    final r3Typedef = library.typedefs.named('R3');

    expect(r3Typedef.isDocumented, isTrue);

    expect(r3Typedef.documentation, 'Not unlike [R2].');

    expect(
      r3Typedef.documentationAsHtml,
      '<p>Not unlike '
      '<a href="%%__HTMLBASE_dartdoc_internal__%%typedefs/R2.html">R2</a>.'
      '</p>',
    );
  }

  void test_typedefRetainsAliasWhenUsed() async {
    var library = await bootPackageWithLibrary('''
typedef R<T> = (T, String);

R<int> f(int a, String b) {
  return R<int>(a, b);
}
''');
    final rTypedef = library.typedefs.named('R');
    final fFunc = library.functions.named('f');

    expect(
        fFunc.modelType.returnType,
        isA<AliasedUndefinedElementType>().having((e) => e.typeAliasElement,
            'typeAliasElement', equals(rTypedef.element)));
  }
}
