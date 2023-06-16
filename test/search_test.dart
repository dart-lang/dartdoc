// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:dartdoc/src/model/indexable.dart';
import 'package:dartdoc/src/search.dart';
import 'package:test/test.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(SearchTest);
  });
}

@reflectiveTest
class SearchTest {
  List<Map<String, Object?>> get searchIndex => _toJson([
        {'qualifiedName': 'foo', 'kind': Kind.library.index},
        {'qualifiedName': 'foo.Foo', 'kind': Kind.class_.index},
        {'qualifiedName': 'foo.Bar', 'kind': Kind.class_.index},
        {'qualifiedName': 'foo.Bart', 'kind': Kind.class_.index},
        {'qualifiedName': 'foo.HelloFoo', 'kind': Kind.class_.index},
        {'qualifiedName': 'bar.Bar.foo', 'kind': Kind.method.index},
        {'qualifiedName': 'foo.Foo.method', 'kind': Kind.method.index},
        {
          'qualifiedName': 'foo.Bar.method',
          'kind': Kind.method.index,
          'overriddenDepth': 1,
        },
        {
          'qualifiedName': 'foo.Baz.method',
          'kind': Kind.method.index,
          'overriddenDepth': 2,
        },
        {
          'qualifiedName': 'FOO',
          'kind': Kind.library.index,
          'packageRank': 0,
        },
        {
          'qualifiedName': 'foo.FOO',
          'kind': Kind.class_.index,
          'packageRank': 0,
        },
      ]);

  List<String> matchNames(String query) {
    final indexList = searchIndex.map(IndexItem.fromMap).toList();
    final index = Index(indexList);
    return index.find(query).map((e) => e.qualifiedName).toList();
  }

  void test_doesNotMatchOnlyOneCharacter() {
    expect(
      matchNames('f'),
      isEmpty,
    );
  }

  void test_excludesNotMatches() {
    expect(
      matchNames('bar'),
      allOf(
        isNot(contains(['foo'])),
        isNot(contains(['foo.Foo'])),
      ),
    );
  }

  void test_matchesAgainstLowercaseMatch() {
    expect(
      matchNames('foo.foo'),
      contains('foo.Foo'),
    );
  }

  void test_matchesAgainstLowercaseQuery() {
    expect(
      matchNames('FOO'),
      contains('foo'),
    );
  }

  void test_matchesPrefixBeforeContains() {
    expect(
      matchNames('Fo'),
      containsAllInOrder(['foo.Foo', 'foo.HelloFoo']),
    );
  }

  void test_matchesQualifiedName() {
    expect(
      matchNames('foo.bar'),
      contains('foo.Bar'),
    );
  }

  void test_prefersExactMatch() {
    expect(
      matchNames('Bar'),
      containsAllInOrder(['foo.Bar', 'foo.Bart']),
    );
  }

  void test_prefersHigherPackages() {
    expect(
      matchNames('foo'),
      containsAllInOrder(['foo.FOO', 'FOO', 'foo.Foo', 'foo']),
    );
  }

  void test_prefersNonOverrides() {
    expect(
      matchNames('method'),
      containsAllInOrder(
        ['foo.Foo.method', 'foo.Bar.method', 'foo.Baz.method'],
      ),
    );
  }

  void test_prefersLibraryScoped() {
    expect(
      matchNames('foo'),
      containsAllInOrder(['foo.Foo', 'bar.Bar.foo', 'foo']),
    );
  }

  List<Map<String, Object?>> _toJson(List<Map<String, Object?>> list) {
    for (var item in list) {
      item['name'] ??= (item['qualifiedName']! as String).split('.').last;
      item['href'] ??= 'UNUSED';
      item['packageRank'] ??= 1;
      item['desc'] ??= 'UNUSED.';
      item['overriddenDepth'] ??= 0;
    }
    return list;
  }
}
